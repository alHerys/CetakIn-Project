import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../bloc/atk/customer/atk_cart_bloc.dart';
import '../../bloc/atk/customer/atk_cart_event.dart';
import '../../bloc/atk/customer/atk_cart_state.dart';
import '../../bloc/discovery/discovery_bloc.dart';
import '../../bloc/discovery/discovery_state.dart';
import '../../data/models/atk/atk_product_model.dart';
import '../../data/models/shop/shop_model.dart';
import '../../data/services/dio_client.dart';
import '../core/colors.dart';
import 'atk_product_detail_page.dart';
import 'atk_shop_catalog_page.dart';
import '../widgets/atk_cart_bottom_sheet.dart';

// Pairs a product with its owning shop for display in the marketplace
class _AtkProductEntry {
  final AtkProductModel product;
  final ShopModel shop;

  _AtkProductEntry({required this.product, required this.shop});
}

class AtkMarketplacePage extends StatefulWidget {
  const AtkMarketplacePage({super.key});

  @override
  State<AtkMarketplacePage> createState() => _AtkMarketplacePageState();
}

class _AtkMarketplacePageState extends State<AtkMarketplacePage> {
  List<_AtkProductEntry> _allProducts = [];
  List<_AtkProductEntry> _filteredProducts = [];
  bool _isLoading = false;
  String? _error;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final discoveryState = context.read<DiscoveryBloc>().state;
      if (discoveryState is DiscoveryLoaded) {
        _loadAllProducts();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = query.isEmpty
          ? List.from(_allProducts)
          : _allProducts.where((e) =>
              (e.product.name ?? '').toLowerCase().contains(query) ||
              (e.shop.shopName ?? '').toLowerCase().contains(query)).toList();
    });
  }

  Future<void> _loadAllProducts() async {
    // Get shops from DiscoveryBloc — only fetch if shops are loaded
    final discoveryState = context.read<DiscoveryBloc>().state;
    if (discoveryState is! DiscoveryLoaded || discoveryState.shops.isEmpty) {
      setState(() {
        _error = 'Belum ada toko di sekitar Anda. Silakan buka tab Beranda terlebih dahulu.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final shops = discoveryState.shops;
    final prefs = await SharedPreferences.getInstance();
    final dioClient = DioClient(prefs);

    final List<_AtkProductEntry> collected = [];

    // Fetch catalogs in parallel
    final futures = shops.map((shop) async {
      if (shop.id == null) return;
      try {
        final response = await dioClient.dio.get('shops/${shop.id}/atk');
        final data = response.data['data'] as List;
        final products = data.map((json) => AtkProductModel.fromJson(json)).toList();
        for (final p in products) {
          collected.add(_AtkProductEntry(product: p, shop: shop));
        }
      } catch (_) {
        // Silently skip shops with failed ATK fetch
      }
    });

    await Future.wait(futures);

    if (mounted) {
      setState(() {
        _allProducts = collected;
        _filteredProducts = List.from(collected);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AtkCartBloc, AtkCartState>(
          listener: (context, state) {
            if (state is AtkCartConflict) _showConflictDialog(state);
          },
        ),
        BlocListener<DiscoveryBloc, DiscoveryState>(
          listener: (context, state) {
            if (state is DiscoveryLoaded) {
              _loadAllProducts();
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: RefreshIndicator(
          onRefresh: _loadAllProducts,
          child: CustomScrollView(
            slivers: [
              // ─── Vibrant SliverAppBar ───
              SliverAppBar(
                expandedHeight: 150,
                pinned: true,
                backgroundColor: AppColors.primary,
                // title: const Text('Toko ATK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                flexibleSpace: LayoutBuilder(
                  builder: (context, constraints) {
                    final top = constraints.biggest.height;
                    final collapsedHeight = MediaQuery.of(context).padding.top + kToolbarHeight + 56;
                    
                    // expandRatio is 1.0 when expanded, 0.0 when collapsed.
                    // Fading happens in the last 30 pixels of scrolling.
                    double expandRatio = (top - collapsedHeight) / 30.0;
                    expandRatio = expandRatio.clamp(0.0, 1.0);

                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        FlexibleSpaceBar(
                          background: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF004AC6), Color(0xFF0070F3)],
                              ),
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  right: -20,
                                  top: -20,
                                  child: Container(
                                    width: 150,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.06),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 40,
                                  bottom: -30,
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.04),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 75,
                                  left: 20,
                                  child: Opacity(
                                    opacity: expandRatio,
                                    child: const Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Alat Tulis Kantor', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                                        SizedBox(height: 2),
                                        Text('Dari berbagai toko mitra terdekat', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // Collapsed Title
                        Positioned(
                          top: MediaQuery.of(context).padding.top + 16,
                          left: 0,
                          right: 0,
                          child: Opacity(
                            opacity: 1.0 - expandRatio,
                            child: const Center(
                              child: Text(
                                'Katalog ATK',
                                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(56),
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Cari produk atau nama toko...',
                        hintStyle: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                        prefixIcon: Icon(Icons.search, color: AppColors.textSecondary, size: 20),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
              ),

              // ─── Content ───
              if (_isLoading)
                const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
              else if (_error != null)
                SliverFillRemaining(
                  child: _buildEmptyState(
                    icon: Icons.location_off_outlined,
                    title: 'Produk ATK Belum Tersedia',
                    message: _error!,
                    showRetry: false,
                  ),
                )
              else if (_filteredProducts.isEmpty)
                SliverFillRemaining(
                  child: _buildEmptyState(
                    icon: Icons.search_off,
                    title: _searchController.text.isEmpty ? 'Belum Ada Produk' : 'Tidak Ditemukan',
                    message: _searchController.text.isEmpty
                        ? 'Toko mitra di sekitar Anda belum memiliki produk ATK.'
                        : 'Tidak ada produk yang cocok dengan pencarian "${_searchController.text}".',
                    showRetry: _searchController.text.isEmpty,
                  ),
                )
              else ...[
                // Section header
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_filteredProducts.length} Produk Tersedia',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
                // Product Grid
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.6,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildProductCard(_filteredProducts[index]),
                      childCount: _filteredProducts.length,
                    ),
                  ),
                ),
                // Bottom spacer for floating cart
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ],
            ],
          ),
        ),
        bottomNavigationBar: _buildFloatingCart(),
      ),
    );
  }

  Widget _buildProductCard(_AtkProductEntry entry) {
    final product = entry.product;
    final shop = entry.shop;
    final isAvailable = product.isAvailable ?? false;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => AtkProductDetailPage(product: product, shop: shop),
      )),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: AppColors.shadow.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image section
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: product.photoUrl != null
                        ? Image.network(product.photoUrl!, fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => _placeholderImage())
                        : _placeholderImage(),
                  ),
                  // Store badge on top-left
                  Positioned(
                    top: 8, left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.storefront_outlined, color: Colors.white, size: 10),
                          const SizedBox(width: 4),
                          Text(
                            shop.shopName ?? 'Toko',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!isAvailable)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      alignment: Alignment.center,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(6)),
                        child: const Text('Habis', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                    ),
                ],
              ),
            ),
            // Info section
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textHeading),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                    const Spacer(),
                    Text('Rp ${product.price ?? 0}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.primary)),
                    const SizedBox(height: 6),
                    // Tapping icon to view all shop products
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => AtkShopCatalogPage(shop: shop),
                      )),
                      child: Row(
                        children: [
                          Text(shop.shopName ?? '', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(width: 2),
                          const Icon(Icons.arrow_forward_ios, size: 9, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: double.infinity,
                      height: 30,
                      child: ElevatedButton(
                        onPressed: isAvailable ? () {
                          context.read<AtkCartBloc>().add(AtkCartAddItemRequested(product: product, shop: shop));
                        } : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text('+ Keranjang', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.07),
      child: const Icon(Icons.inventory_2, color: AppColors.primary, size: 40),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String title, required String message, bool showRetry = true}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 72, color: AppColors.primary.withValues(alpha: 0.3)),
            const SizedBox(height: 20),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textHeading), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(message, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary), textAlign: TextAlign.center),
            if (showRetry) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadAllProducts,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                child: const Text('Muat Ulang', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingCart() {
    return BlocBuilder<AtkCartBloc, AtkCartState>(
      builder: (context, state) {
        if (state is AtkCartUpdated && state.items.isNotEmpty) {
          final totalItems = state.items.fold(0, (sum, item) => sum + item.quantity);
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: AppColors.shadow.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, -4))],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Badge(
                    label: Text('$totalItems', style: const TextStyle(fontSize: 10)),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.shopping_cart_outlined, color: AppColors.primary, size: 22),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        Text('Rp ${state.totalAmount}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textHeading)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => DraggableScrollableSheet(
                          initialChildSize: 0.6,
                          minChildSize: 0.4,
                          maxChildSize: 0.9,
                          builder: (_, controller) => const AtkCartBottomSheet(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Lihat Keranjang', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _showConflictDialog(AtkCartConflict state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ganti Toko?'),
        content: Text('Keranjang berisi barang dari toko "${state.existingShop.shopName}". Kosongkan dan beli dari "${state.newShop.shopName}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              context.read<AtkCartBloc>().add(AtkCartClearRequested());
              context.read<AtkCartBloc>().add(AtkCartAddItemRequested(product: state.newProduct, shop: state.newShop));
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Ya, Ganti', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
