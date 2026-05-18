import 'package:flutter/material.dart';
import '../core/colors.dart';
import '../pages/shop_detail_page.dart';

class ShopCard extends StatelessWidget {
  final String title;
  final double distance;
  final String status;
  final String openTime;
  final double rating;
  final String imageUrl;

  const ShopCard({
    super.key,
    required this.title,
    required this.distance,
    required this.status,
    required this.openTime,
    required this.rating,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShopDetailPage(
              title: title,
              distance: distance,
              status: status,
              openTime: openTime,
              rating: rating,
              imageUrl: imageUrl,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
            Stack(
              alignment: .topLeft,
              children: [
                Container(
                  height: 197,
                  width: .infinity,
                  color: AppColors.imagePlaceholder,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    width: .infinity,
                    height: 197,
                  ),
                ),
                Container(
                  margin: const .only(top: 13, left: 16),
                  padding: const .symmetric(horizontal: 8, vertical: 3),
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
                      fontWeight: .w600,
                      color: status == 'BUKA'
                          ? AppColors.statusOpenText
                          : AppColors.statusClosedText,
                    ),
                  ),
                ),
              ],
            ),
      
            Padding(
              padding: const .all(16),
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Row(
                    mainAxisAlignment: .spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: .w600,
                          color: AppColors.textHeading,
                        ),
                      ),
                      Row(
                        spacing: 4,
                        children: [
                          const Icon(
                            Icons.star,
                            color: AppColors.ratingStar,
                            size: 15,
                          ),
                          Text(
                            rating.toString(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: .w600,
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
                        "$distance km",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: .w400,
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
                        'Buka $openTime',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: .w400,
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
