import 'package:flutter/material.dart';
import '../../data/models/shop/shop_model.dart';
import '../core/colors.dart';
import '../pages/shop_detail_page.dart';

class ShopCard extends StatelessWidget {
  final ShopModel shop;

  const ShopCard({
    super.key,
    required this.shop,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: (Dynamic Store Hours) Calculate real status (BUKA/TUTUP) based on openTime/closeTime and current time
    final status = 'BUKA'; 

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShopDetailPage(shopId: shop.id!),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Stack(
              alignment: Alignment.topLeft,
              children: [
                Container(
                  height: 197,
                  width: double.infinity,
                  color: AppColors.imagePlaceholder,
                  child: shop.shopPhotoUrl != null
                      ? Image.network(
                          shop.shopPhotoUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 197,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.storefront, size: 48, color: Colors.grey),
                        )
                      : const Icon(Icons.storefront, size: 48, color: Colors.grey),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 13, left: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: status == 'BUKA'
                        ? AppColors.statusOpenBg
                        : AppColors.statusClosedBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: status == 'BUKA'
                          ? AppColors.statusOpenText
                          : AppColors.statusClosedText,
                    ),
                  ),
                ),
              ],
            ),
      
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          shop.shopName ?? 'Unknown Shop',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textHeading,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: AppColors.ratingStar,
                            size: 15,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            (shop.averageRating ?? 0.0).toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ratingStar,
                              letterSpacing: 0.14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
      
                  const SizedBox(height: 8),
      
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: AppColors.textSubtitle,
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${(shop.distanceKm ?? 0.0).toStringAsFixed(1)} km",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSubtitle,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.access_time_outlined,
                        color: AppColors.textSubtitle,
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Buka ${shop.openTime?.substring(0, 5) ?? '08:00'}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSubtitle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
