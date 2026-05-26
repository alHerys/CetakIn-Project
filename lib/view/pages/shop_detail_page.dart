import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/discovery/shop_detail_bloc.dart';
import '../../bloc/discovery/shop_detail_event.dart';
import '../../bloc/discovery/shop_detail_state.dart';
import '../../data/models/shop/shop_model.dart';
import '../core/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/services/dio_client.dart';
import '../../data/models/atk/atk_product_model.dart';
import 'atk_shop_catalog_page.dart';
import 'atk_product_detail_page.dart';
import 'print_checkout_page.dart';
import 'package:geolocator/geolocator.dart';

class ShopDetailPage extends StatefulWidget {
  final String shopId;

  const ShopDetailPage({super.key, required this.shopId});

  @override
  State<ShopDetailPage> createState() => _ShopDetailPageState();
}

class _ShopDetailPageState extends State<ShopDetailPage> {
  double? _userLat;
  double? _userLng;

  @override
  void initState() {
    super.initState();
    context.read<ShopDetailBloc>().add(ShopDetailLoadRequested(widget.shopId));
    _loadUserLocation();
  }

  Future<void> _loadUserLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble('user_home_lat');
    final lng = prefs.getDouble('user_home_lng');
    if (lat != null && lng != null) {
      if (mounted) {
        setState(() {
          _userLat = lat;
          _userLng = lng;
        });
      }
    } else {
      try {
        final pos = await Geolocator.getLastKnownPosition();
        if (pos != null && mounted) {
          setState(() {
            _userLat = pos.latitude;
            _userLng = pos.longitude;
          });
        }
      } catch (_) {}
    }
  }

  bool _isShopOpen(ShopModel shop) {
    if (shop.openTime == null || shop.closeTime == null || shop.operatingDays == null) return false;
    
    final now = DateTime.now();
    final List<String> days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    final currentDay = days[now.weekday - 1];
    
    if (!shop.operatingDays!.contains(currentDay)) return false;
    
    try {
      final openParts = shop.openTime!.split(':');
      final closeParts = shop.closeTime!.split(':');
      final openHour = int.parse(openParts[0]);
      final openMin = int.parse(openParts[1]);
      final closeHour = int.parse(closeParts[0]);
      final closeMin = int.parse(closeParts[1]);
      
      final currentMins = now.hour * 60 + now.minute;
      final openMins = openHour * 60 + openMin;
      final closeMins = closeHour * 60 + closeMin;
      
      return currentMins >= openMins && currentMins <= closeMins;
    } catch (e) {
      return false;
    }
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
                    _buildAtkPreview(shop),
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
      centerTitle: false,
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
    final isOpen = _isShopOpen(shop);
    final String statusLine1 = isOpen ? 'Buka' : 'Tutup';
    final String statusLine2 = 'Sekarang';
    final Color statusColor = isOpen ? AppColors.success : Colors.red;

    final String estimasi = '10-15 Menit';

    double distanceKm = shop.distanceKm ?? 0.0;
    if ((distanceKm == 0.0 || shop.distanceKm == null) && _userLat != null && _userLng != null && shop.latitude != null && shop.longitude != null) {
      final distanceMeters = Geolocator.distanceBetween(_userLat!, _userLng!, shop.latitude!, shop.longitude!);
      distanceKm = distanceMeters / 1000;
    }

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.access_time,
            title: 'Waktu Proses',
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
            valueColor: statusColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            icon: Icons.location_on_outlined,
            title: 'Jarak',
            value: '${distanceKm.toStringAsFixed(1)} km',
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

  Widget _buildAtkPreview(ShopModel shop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Alat Tulis (ATK)',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textHeading,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AtkShopCatalogPage(shop: shop)),
                );
              },
              child: const Text(
                'Lihat Semua',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<AtkProductModel>>(
          future: _fetchAtkPreview(shop.id!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Gagal memuat ATK: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('Toko ini belum menjual produk ATK.', style: TextStyle(color: AppColors.textSubtitle));
            }
            
            final products = snapshot.data!;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return _buildAtkCardPreview(product, shop);
              },
            );
          },
        ),
      ],
    );
  }

  Future<List<AtkProductModel>> _fetchAtkPreview(String shopId) async {
    final prefs = await SharedPreferences.getInstance();
    final dioClient = DioClient(prefs);
    final response = await dioClient.dio.get('shops/$shopId/atk');
    final data = response.data['data'] as List;
    final products = data.map((json) => AtkProductModel.fromJson(json)).toList();
    return products.take(2).toList();
  }

  Widget _buildAtkCardPreview(AtkProductModel product, ShopModel shop) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AtkProductDetailPage(product: product, shop: shop)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(color: AppColors.shadow.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: product.photoUrl != null
                    ? Image.network(product.photoUrl!, fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          child: const Icon(Icons.inventory_2, color: AppColors.primary),
                        ))
                    : Container(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        child: const Icon(Icons.inventory_2, color: AppColors.primary),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name ?? 'Tanpa Nama',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textHeading),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp ${product.price ?? 0}',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PrintCheckoutPage(shopId: shop.id!),
                    ),
                  );
                },
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
