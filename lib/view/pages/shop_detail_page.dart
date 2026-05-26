import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/discovery/shop_detail_bloc.dart';
import '../../bloc/discovery/shop_detail_event.dart';
import '../../bloc/discovery/shop_detail_state.dart';
import '../../data/models/shop/shop_model.dart';
import '../core/colors.dart';

class ShopDetailPage extends StatefulWidget {
  final String shopId;

  const ShopDetailPage({super.key, required this.shopId});

  @override
  State<ShopDetailPage> createState() => _ShopDetailPageState();
}

class _ShopDetailPageState extends State<ShopDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<ShopDetailBloc>().add(ShopDetailLoadRequested(widget.shopId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: BlocBuilder<ShopDetailBloc, ShopDetailState>(
        builder: (context, state) {
          if (state is ShopDetailLoading || state is ShopDetailInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ShopDetailError) {
            return Center(child: Text(state.message));
          } else if (state is ShopDetailLoaded) {
            return _buildContent(context, state.shop);
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, ShopModel shop) {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            _buildAppBar(shop),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShopInfo(shop),
                    const SizedBox(height: 24),
                    _buildStatsRow(shop),
                    const SizedBox(height: 24),
                    _buildLayananCetak(shop),
                    const SizedBox(height: 24),
                    _buildDaftarHarga(shop),
                    const SizedBox(height: 24),
                    _buildUlasan(shop),
                    const SizedBox(height: 100), // padding for bottom bar
                  ],
                ),
              ),
            ),
          ],
        ),
        _buildBottomBar(shop),
      ],
    );
  }

  Widget _buildAppBar(ShopModel shop) {
    return SliverAppBar(
      expandedHeight: 256.0,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Shop Detail',
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        // TODO: (Share/Favorite) Implement share and favorite actions
        IconButton(
          icon: const Icon(Icons.share_outlined, color: AppColors.primary, size: 20),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.favorite_border_outlined, color: AppColors.primary, size: 20),
          onPressed: () {},
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            shop.shopPhotoUrl != null
                ? Image.network(
                    shop.shopPhotoUrl!,
                    fit: BoxFit.cover,
                  )
                : Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.storefront, size: 64, color: Colors.grey),
                  ),
            Positioned(
              bottom: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, color: AppColors.warning, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${(shop.averageRating ?? 0.0).toStringAsFixed(1)} (${shop.totalReviews ?? 0})',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textHeading,
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

  Widget _buildShopInfo(ShopModel shop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          shop.shopName ?? 'Unknown Shop',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textHeading,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSubtitle),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                shop.shopAddress ?? '',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSubtitle,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          shop.shopDescription ?? 'Tidak ada deskripsi',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSubtitle,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(ShopModel shop) {
    // TODO: (Dynamic Store Hours) Calculate real status (Buka/Tutup) and Estimation based on load
    final String statusLine1 = 'Buka';
    final String statusLine2 = 'Sekarang';
    final String estimasi = '15-30 Menit';

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.access_time,
            title: 'Estimasi',
            value: estimasi,
            valueColor: AppColors.textHeading,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            icon: Icons.store_mall_directory_outlined,
            title: 'Status',
            value: '$statusLine1\n$statusLine2',
            valueColor: AppColors.success,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            icon: Icons.location_on_outlined,
            title: 'Jarak',
            value: '${(shop.distanceKm ?? 0.0).toStringAsFixed(1)} km',
            valueColor: AppColors.textHeading,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.textSubtitle),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSubtitle,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayananCetak(ShopModel shop) {
    final services = shop.shopService;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Layanan Cetak',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textHeading,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildServiceBox(
                'Ukuran Kertas',
                services?.supportedPaperSizes ?? [],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildServiceBox(
                'Mode Warna',
                ['Hitam Putih', if (services?.hasColorPrint == true) 'Warna (CMYK)'],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServiceBox(String title, List<String> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textHeading,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) => _buildChip(item)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE5EEFF),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildDaftarHarga(ShopModel shop) {
    final pricing = shop.shopPricing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Daftar Harga',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textHeading,
              ),
            ),
            Text(
              'Lihat Semua',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildPriceItem(
                'Print HVS A4 (B/W)',
                'Per halaman',
                'Rp ${pricing?.priceBlackWhiteA4 ?? 500}',
                true,
              ),
              _buildPriceItem(
                'Print HVS A4 (Warna)',
                'Tergantung densitas warna',
                'Rp ${pricing?.priceColorA4 ?? 1000}',
                true,
              ),
              _buildPriceItem(
                'Jilid Spiral',
                'Tebal hingga 100 lbr',
                'Rp ${pricing?.priceBinding ?? 12000}',
                false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceItem(String title, String subtitle, String price, bool showBorder) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        border: showBorder
            ? Border(bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.1)))
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textHeading,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSubtitle,
                ),
              ),
            ],
          ),
          Text(
            price,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUlasan(ShopModel shop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Ulasan Pengguna',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textHeading,
              ),
            ),
            Row(
              children: [
                const Icon(Icons.star, color: AppColors.warning, size: 14),
                const SizedBox(width: 4),
                Text(
                  '${(shop.averageRating ?? 0.0).toStringAsFixed(1)}/5',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textHeading,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        // TODO: (Review System) Fetch and map real reviews from backend
        _buildReviewItem('AN', 'Adit Nugroho', '2 hari yang lalu', 'Hasil print sangat jernih dan pengerjaan cepat banget. Rekomen buat yang butuh mendadak!'),
        const SizedBox(height: 8),
        _buildReviewItem('SR', 'Siska Rahma', 'Seminggu yang lalu', 'Langganan di sini karena harganya paling kompetitif di sekitar kampus. Staff ramah.', bgColor: Colors.greenAccent, color: Colors.green),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: () {},
            child: const Text(
              'Tampilkan ulasan lainnya',
              style: TextStyle(fontSize: 16, color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewItem(String initials, String name, String date, String content, {Color bgColor = AppColors.primary, Color color = Colors.white}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: bgColor,
                child: Text(
                  initials,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textHeading),
                    ),
                    Text(
                      date,
                      style: const TextStyle(fontSize: 10, color: AppColors.textSubtitle),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (index) => const Icon(Icons.star, size: 12, color: AppColors.warning)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(fontSize: 14, color: AppColors.textHeading, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(ShopModel shop) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.1))),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Mulai dari', style: TextStyle(fontSize: 13, color: AppColors.textSubtitle)),
                  Text(
                    'Rp ${shop.shopPricing?.priceBlackWhiteA4 ?? 500}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                // TODO: (Order Flow) Navigate to checkout/order page
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                ),
                child: const Text('Pesan Sekarang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
