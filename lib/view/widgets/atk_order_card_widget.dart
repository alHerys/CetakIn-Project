import 'package:flutter/material.dart';
import '../../data/models/order/atk_order_model.dart';
import '../core/colors.dart';

class AtkOrderCardWidget extends StatelessWidget {
  final AtkOrderModel order;
  final bool isPartner;
  final VoidCallback? onTap;
  final Widget? trailingAction;

  const AtkOrderCardWidget({
    super.key,
    required this.order,
    this.isPartner = false,
    this.onTap,
    this.trailingAction,
  });

  @override
  Widget build(BuildContext context) {
    // Ambil item pertama sebagai perwakilan
    final firstItem = order.items != null && order.items!.isNotEmpty ? order.items!.first : null;
    final otherItemsCount = (order.items?.length ?? 1) - 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          isPartner ? Icons.person : Icons.storefront,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isPartner
                                ? (order.user?.name ?? 'Pelanggan')
                                : (order.shop?.shopName ?? 'Toko Mitra'),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: AppColors.textHeading),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(order.status),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: firstItem?.product?.photoUrl != null
                        ? Image.network(
                            firstItem!.product!.photoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.category,
                              color: AppColors.primary,
                              size: 28,
                            ),
                          )
                        : const Icon(
                            Icons.category,
                            color: AppColors.primary,
                            size: 28,
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          firstItem?.name ?? 'Produk ATK',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.textHeading,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${firstItem?.quantity ?? 0} x Rp ${firstItem?.unitPrice ?? 0}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        if (otherItemsCount > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '+$otherItemsCount produk lainnya',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Pesanan',
                          style: TextStyle(color: AppColors.textSubtitle, fontSize: 11)),
                      Text(
                        'Rp ${order.finalPrice}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: AppColors.primary),
                      ),
                    ],
                  ),
                  trailingAction ??
                      const Icon(Icons.arrow_forward_ios,
                          size: 14, color: AppColors.textSecondary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String text;

    switch (status) {
      case 'pending':
        bgColor = Colors.orange.withValues(alpha: 0.1);
        textColor = Colors.orange[800]!;
        text = 'Menunggu';
        break;
      case 'confirmed':
        bgColor = Colors.purple.withValues(alpha: 0.1);
        textColor = Colors.purple[800]!;
        text = 'Diterima';
        break;
      case 'processing':
        bgColor = Colors.blue.withValues(alpha: 0.1);
        textColor = Colors.blue[800]!;
        text = 'Diproses';
        break;
      case 'ready_for_pickup':
        bgColor = Colors.green.withValues(alpha: 0.1);
        textColor = Colors.green[800]!;
        text = 'Siap Diambil';
        break;
      case 'completed':
        bgColor = Colors.grey.withValues(alpha: 0.1);
        textColor = Colors.grey[800]!;
        text = 'Selesai';
        break;
      case 'cancelled':
      default:
        bgColor = Colors.red.withValues(alpha: 0.1);
        textColor = Colors.red[800]!;
        text = 'Dibatalkan';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
      child: Text(
        text,
        style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
