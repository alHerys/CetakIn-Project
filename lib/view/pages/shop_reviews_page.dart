import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/review/shop_reviews_bloc.dart';
import '../../bloc/review/shop_reviews_event.dart';
import '../../bloc/review/shop_reviews_state.dart';
import '../../data/models/shop/shop_model.dart';
import '../core/colors.dart';

class ShopReviewsPage extends StatefulWidget {
  final ShopModel shop;

  const ShopReviewsPage({super.key, required this.shop});

  @override
  State<ShopReviewsPage> createState() => _ShopReviewsPageState();
}

class _ShopReviewsPageState extends State<ShopReviewsPage> {
  @override
  void initState() {
    super.initState();
    // Refresh reviews when opening this page
    context.read<ShopReviewsBloc>().add(ShopReviewsLoadRequested(widget.shop.id!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ulasan Pelanggan',
              style: TextStyle(
                color: AppColors.textHeading,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.shop.shopName ?? '',
              style: const TextStyle(
                color: AppColors.textSubtitle,
                fontSize: 12,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: AppColors.textHeading),
      ),
      body: BlocBuilder<ShopReviewsBloc, ShopReviewsState>(
        builder: (context, state) {
          if (state is ShopReviewsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ShopReviewsFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.error, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ShopReviewsBloc>().add(ShopReviewsLoadRequested(widget.shop.id!));
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          } else if (state is ShopReviewsLoaded) {
            final reviews = state.reviews;
            if (reviews.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    const Text(
                      'Belum Ada Ulasan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textHeading,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Toko ini belum memiliki ulasan dari pelanggan.',
                      style: TextStyle(color: AppColors.textSubtitle),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ShopReviewsBloc>().add(ShopReviewsLoadRequested(widget.shop.id!));
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: reviews.length + 1, // +1 for the header summary
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildSummaryHeader(widget.shop);
                  }

                  final review = reviews[index - 1];
                  String initials = 'NN';
                  if (review.user != null && review.user!.name != null && review.user!.name!.length >= 2) {
                    initials = review.user!.name!.substring(0, 2).toUpperCase();
                  } else if (review.user != null && review.user!.name != null && review.user!.name!.isNotEmpty) {
                    initials = review.user!.name!.substring(0, 1).toUpperCase();
                  }

                  return _buildReviewCard(
                    initials,
                    review.user?.name ?? 'Anonim',
                    review.createdAt.substring(0, 10),
                    review.comment ?? 'Tidak ada komentar',
                    review.rating,
                    review.orderType == 'atk' ? 'Pesanan ATK' : 'Pesanan Cetak',
                  );
                },
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildSummaryHeader(ShopModel shop) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                (shop.averageRating ?? 0.0).toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textHeading,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: List.generate(5, (index) => Icon(
                  index < (shop.averageRating ?? 0).round() ? Icons.star : Icons.star_border, 
                  size: 16, 
                  color: AppColors.warning
                )),
              ),
              const SizedBox(height: 8),
              Text(
                '${shop.totalReviews ?? 0} ulasan',
                style: const TextStyle(color: AppColors.textSubtitle, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Peringkat rata-rata', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                const Text(
                  'Berdasarkan ulasan dari pelanggan yang telah menyelesaikan transaksi.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(String initials, String name, String date, String content, int rating, String type) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  initials,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textHeading),
                    ),
                    Row(
                      children: [
                        Text(
                          date,
                          style: const TextStyle(fontSize: 11, color: AppColors.textSubtitle),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          type,
                          style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      rating.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.amber),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: const TextStyle(fontSize: 14, color: AppColors.textHeading, height: 1.5),
          ),
        ],
      ),
    );
  }
}
