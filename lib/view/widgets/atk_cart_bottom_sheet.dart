import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/atk/customer/atk_cart_bloc.dart';
import '../../bloc/atk/customer/atk_cart_event.dart';
import '../../bloc/atk/customer/atk_cart_state.dart';
import '../core/colors.dart';
import '../pages/atk_checkout_page.dart';

class AtkCartBottomSheet extends StatelessWidget {
  const AtkCartBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AtkCartBloc, AtkCartState>(
      builder: (context, state) {
        if (state is! AtkCartUpdated || state.items.isEmpty) {
          // If cart becomes empty, pop the bottom sheet automatically
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          });
          return const SizedBox.shrink();
        }

        final totalItems = state.items.fold(0, (sum, item) => sum + item.quantity);

        return Container(
          padding: const EdgeInsets.only(top: 12),
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Keranjang Belanja',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textHeading),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<AtkCartBloc>().add(AtkCartClearRequested());
                      },
                      child: const Text('Kosongkan', style: TextStyle(color: AppColors.error)),
                    ),
                  ],
                ),
              ),
              
              // Items List
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: state.items.length,
                  itemBuilder: (context, index) {
                    final item = state.items[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        children: [
                          // Item Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: item.product.photoUrl != null
                                ? Image.network(item.product.photoUrl!, width: 50, height: 50, fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => _placeholderImage())
                                : _placeholderImage(),
                          ),
                          const SizedBox(width: 12),
                          // Item Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product.name ?? 'Tanpa Nama',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textHeading),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Rp ${_formatPrice(item.product.price ?? 0)}',
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.primary),
                                ),
                              ],
                            ),
                          ),
                          // Quantity Controls
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => context.read<AtkCartBloc>().add(AtkCartUpdateItemQuantityRequested(item.product.id!, item.quantity - 1)),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(Icons.remove, size: 16, color: AppColors.primary),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              ),
                              GestureDetector(
                                onTap: () {
                                  // Don't add more than stock
                                  if (item.product.stock != null && item.quantity >= item.product.stock!) return;
                                  context.read<AtkCartBloc>().add(AtkCartUpdateItemQuantityRequested(item.product.id!, item.quantity + 1));
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(Icons.add, size: 16, color: AppColors.primary),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom Section (Total & Checkout)
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24), // Extra bottom padding for safe area
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: AppColors.shadow.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4))],
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total ($totalItems barang)', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            Text('Rp ${_formatPrice(state.totalAmount)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textHeading)),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Close bottom sheet
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const AtkCheckoutPage()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Checkout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _placeholderImage() {
    return Container(
      width: 50,
      height: 50,
      color: AppColors.primary.withValues(alpha: 0.1),
      child: const Icon(Icons.inventory_2, color: AppColors.primary, size: 24),
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
}
