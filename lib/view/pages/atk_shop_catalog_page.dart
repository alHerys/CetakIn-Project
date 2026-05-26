import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../bloc/atk/customer/atk_cart_bloc.dart';
import '../../bloc/atk/customer/atk_cart_event.dart';
import '../../bloc/atk/customer/atk_cart_state.dart';
import '../../data/models/atk/atk_product_model.dart';
import '../../data/models/shop/shop_model.dart';
import '../../data/services/dio_client.dart';
import '../core/colors.dart';
import 'atk_product_detail_page.dart';
import '../widgets/atk_cart_bottom_sheet.dart';

class AtkShopCatalogPage extends StatefulWidget {
  final ShopModel shop;

  const AtkShopCatalogPage({super.key, required this.shop});

  @override
  State<AtkShopCatalogPage> createState() => _AtkShopCatalogPageState();
}

class _AtkShopCatalogPageState extends State<AtkShopCatalogPage> {
  List<AtkProductModel> _products = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final dioClient = DioClient(prefs);
      final response = await dioClient.dio.get('shops/${widget.shop.id}/atk');
      final data = response.data['data'] as List;
      if (mounted) {
        setState(() {
          _products = data.map((json) => AtkProductModel.fromJson(json)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AtkCartBloc, AtkCartState>(
      listener: (context, state) {
        if (state is AtkCartConflict) {
          _showConflictDialog(context, state);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 180,
              pinned: true,
              backgroundColor: AppColors.primary,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  widget.shop.shopName ?? 'Katalog ATK',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (widget.shop.shopPhotoUrl != null)
                      Image.network(widget.shop.shopPhotoUrl!, fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(color: AppColors.primary))
                    else
                      Container(color: AppColors.primary),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_isLoading)
              const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
            else if (_error != null)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                      const SizedBox(height: 16),
                      Text('Gagal memuat katalog', style: const TextStyle(fontSize: 16, color: AppColors.textHeading)),
                      const SizedBox(height: 8),
                      ElevatedButton(onPressed: _loadProducts, child: const Text('Coba Lagi')),
                    ],
                  ),
                ),
              )
            else if (_products.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.textSecondary),
                      SizedBox(height: 16),
                      Text('Belum ada produk ATK di toko ini.', style: TextStyle(fontSize: 16, color: AppColors.textSubtitle)),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.62,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildProductCard(_products[index]),
                    childCount: _products.length,
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: _buildFloatingCart(),
      ),
    );
  }

  Widget _buildProductCard(AtkProductModel product) {
    final isAvailable = product.isAvailable ?? false;
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => AtkProductDetailPage(product: product, shop: widget.shop),
        ));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: AppColors.shadow.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: product.photoUrl != null
                        ? Image.network(product.photoUrl!, fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              child: const Icon(Icons.inventory_2, color: AppColors.primary, size: 36),
                            ))
                        : Container(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            child: const Icon(Icons.inventory_2, color: AppColors.primary, size: 36),
                          ),
                  ),
                  if (!isAvailable)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      alignment: Alignment.center,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(6)),
                        child: const Text('Habis', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ),
                ],
              ),
            ),
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
                    Text('Rp ${product.price ?? 0}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.primary)),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: double.infinity,
                      height: 32,
                      child: ElevatedButton(
                        onPressed: isAvailable ? () {
                          context.read<AtkCartBloc>().add(AtkCartAddItemRequested(product: product, shop: widget.shop));
                        } : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text('+ Keranjang', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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

  void _showConflictDialog(BuildContext context, AtkCartConflict state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ganti Toko?'),
        content: Text('Keranjang berisi barang dari ${state.existingShop.shopName}. Kosongkan dan pindah ke ${state.newShop.shopName}?'),
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
