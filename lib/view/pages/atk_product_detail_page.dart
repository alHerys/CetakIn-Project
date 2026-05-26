import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/atk/customer/atk_cart_bloc.dart';
import '../../bloc/atk/customer/atk_cart_event.dart';
import '../../bloc/atk/customer/atk_cart_state.dart';
import '../../data/models/atk/atk_product_model.dart';
import '../../data/models/shop/shop_model.dart';
import '../core/colors.dart';
import '../widgets/atk_cart_bottom_sheet.dart';

class AtkProductDetailPage extends StatefulWidget {
  final AtkProductModel product;
  final ShopModel shop;

  const AtkProductDetailPage({super.key, required this.product, required this.shop});

  @override
  State<AtkProductDetailPage> createState() => _AtkProductDetailPageState();
}

class _AtkProductDetailPageState extends State<AtkProductDetailPage> {
  int _quantity = 1;
  final int _maxStock = 99;

  int get _effectiveMax {
    final stock = widget.product.stock ?? _maxStock;
    return stock > 0 ? stock : 1;
  }

  int get _subtotal => (widget.product.price ?? 0) * _quantity;

  void _increment() {
    if (_quantity < _effectiveMax) setState(() => _quantity++);
  }

  void _decrement() {
    if (_quantity > 1) setState(() => _quantity--);
  }

  void _addToCart() {
    context.read<AtkCartBloc>().add(AtkCartAddItemRequested(
      product: widget.product,
      shop: widget.shop,
      quantity: _quantity,
    ));

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
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final shop = widget.shop;
    final isAvailable = product.isAvailable ?? false;
    final stock = product.stock ?? 0;

    return BlocListener<AtkCartBloc, AtkCartState>(
      listener: (context, state) {
        if (state is AtkCartConflict) {
          _showConflictDialog(state);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          slivers: [
            // ─── Hero AppBar ───
            SliverAppBar(
              expandedHeight: 320,
              pinned: true,
              backgroundColor: AppColors.primary,
              elevation: 0,
              leading: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.background, size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Product photo hero
                    product.photoUrl != null
                        ? Image.network(
                            product.photoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              child: const Icon(Icons.inventory_2, color: AppColors.primary, size: 80),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.primary.withValues(alpha: 0.15),
                                  AppColors.primary.withValues(alpha: 0.05),
                                ],
                              ),
                            ),
                            child: const Icon(Icons.inventory_2, color: AppColors.primary, size: 100),
                          ),
                    // Bottom gradient fade
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.5, 1.0],
                          colors: [Colors.transparent, AppColors.background],
                        ),
                      ),
                    ),
                    // Unavailable overlay
                    if (!isAvailable)
                      Container(
                        color: Colors.black.withValues(alpha: 0.45),
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('STOK HABIS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 2)),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // ─── Product Info ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    // Shop badge
                    InkWell(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.storefront_outlined, color: AppColors.primary, size: 14),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            shop.shopName ?? 'Toko Mitra',
                            style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Product name
                    Text(
                      product.name ?? 'Produk ATK',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textHeading, height: 1.2),
                    ),
                    const SizedBox(height: 16),
                    // Price row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Rp ${_formatPrice(product.price ?? 0)}',
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.primary),
                        ),
                        const SizedBox(width: 8),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: Text('/ pcs', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Status & stock row
                    Row(
                      children: [
                        _buildChip(
                          isAvailable ? 'Tersedia' : 'Habis',
                          isAvailable ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        if (stock > 0)
                          _buildChip('Stok: $stock pcs', Colors.orange),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Description card
                    if (product.description != null && product.description!.isNotEmpty) ...[
                      const Text('Deskripsi Produk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textHeading)),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          product.description!,
                          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.7),
                        ),
                      ),
                    ] else ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Text('Tidak ada deskripsi produk.', style: TextStyle(fontSize: 14, color: AppColors.textSubtitle, fontStyle: FontStyle.italic)),
                      ),
                    ],
                    const SizedBox(height: 24),
                    // Info toko mini
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                            backgroundImage: shop.shopPhotoUrl != null ? NetworkImage(shop.shopPhotoUrl!) : null,
                            child: shop.shopPhotoUrl == null ? const Icon(Icons.storefront, color: AppColors.primary) : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(shop.shopName ?? 'Toko Mitra', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textHeading)),
                                if (shop.shopAddress != null)
                                  Text(shop.shopAddress!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          if (shop.averageRating != null)
                            Row(children: [
                              const Icon(Icons.star_rounded, color: AppColors.warning, size: 16),
                              const SizedBox(width: 4),
                              Text(shop.averageRating!.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textHeading)),
                            ]),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // ─── Sticky Bottom Bar ───
        bottomNavigationBar: _buildBottomBar(isAvailable),
      ),
    );
  }

  Widget _buildBottomBar(bool isAvailable) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: AppColors.shadow.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Subtotal row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                Text(
                  'Rp ${_formatPrice(_subtotal)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // Quantity counter
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _counterBtn(Icons.remove, _decrement, _quantity <= 1),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('$_quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textHeading)),
                      ),
                      _counterBtn(Icons.add, _increment, _quantity >= _effectiveMax || !isAvailable),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Add to cart button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isAvailable ? _addToCart : null,
                    icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                    label: const Text('Masukkan Keranjang', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.withValues(alpha: 0.3),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _counterBtn(IconData icon, VoidCallback onTap, bool disabled) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        child: Icon(icon, size: 20, color: disabled ? AppColors.textSecondary.withValues(alpha: 0.4) : AppColors.primary),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
    );
  }

  String _formatPrice(int price) {
    final str = price.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  void _showConflictDialog(AtkCartConflict state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ganti Toko?'),
        content: Text('Keranjang berisi barang dari toko "${state.existingShop.shopName}". Kosongkan keranjang dan beli dari "${state.newShop.shopName}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              context.read<AtkCartBloc>().add(AtkCartClearRequested());
              context.read<AtkCartBloc>().add(AtkCartAddItemRequested(
                product: state.newProduct, shop: state.newShop, quantity: _quantity,
              ));
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
