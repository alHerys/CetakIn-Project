import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../bloc/profile/profile_bloc.dart';
import '../../bloc/profile/profile_event.dart';
import '../../bloc/profile/profile_state.dart';
import '../core/colors.dart';
import '../pages/edit_shop_setup_page.dart';
import '../pages/edit_shop_hours_page.dart';
import '../pages/edit_address_page.dart';
import '../pages/edit_shop_info_page.dart';
import '../pages/partner_orders_page.dart';
import '../pages/partner_atk_catalog_page.dart';

class PartnerHomeBody extends StatefulWidget {
  const PartnerHomeBody({super.key});

  @override
  State<PartnerHomeBody> createState() => _PartnerHomeBodyState();
}

class _PartnerHomeBodyState extends State<PartnerHomeBody> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickShopPhoto() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1200,
      maxHeight: 800,
    );

    if (image != null && mounted) {
      context.read<ProfileBloc>().add(
        ProfileUpdateShopPhotoRequested(shopPhoto: image.path),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdateSuccess && state.message.contains('photo')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is ProfileUpdateFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error)),
          );
        }
      },
      builder: (context, state) {
        if (state is! ProfileLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final shop = state.user.shop;
        final status = shop?.status ?? 'N/A';
        final isLoading = state is ProfileUpdateLoading;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: AppColors.primary,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    'Dashboard Mitra',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (shop?.shopPhotoUrl != null)
                        Image.network(
                          shop!.shopPhotoUrl!,
                          fit: BoxFit.cover,
                        )
                      else
                        Container(
                          color: AppColors.primary.withValues(alpha: 0.8),
                          child: const Icon(Icons.storefront, size: 80, color: Colors.white54),
                        ),
                      // Gradient overlay
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),
                      // Edit photo button
                      Positioned(
                        right: 16,
                        bottom: 16,
                        child: isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Material(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: const CircleBorder(),
                                child: IconButton(
                                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                                  onPressed: _pickShopPhoto,
                                  tooltip: 'Ubah Foto Toko',
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildStatusBanner(status, shop?.rejectionReason),
                      const SizedBox(height: 16),
                      _buildShopInfoCard(shop),
                      const SizedBox(height: 24),
                      _buildProfileChecklist(shop),
                      const SizedBox(height: 24),
                      const Text(
                        'Pengaturan Toko',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textHeading,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildActionCard(
                        context,
                        icon: Icons.storefront,
                        title: 'Informasi Dasar',
                        subtitle: 'Ubah nama, telepon, dan deskripsi toko',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const EditShopInfoPage()),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildActionCard(
                        context,
                        icon: Icons.access_time_filled,
                        title: 'Jam Operasional',
                        subtitle: 'Atur waktu buka dan tutup',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const EditShopHoursPage()),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildActionCard(
                        context,
                        icon: Icons.inventory_2_outlined,
                        title: 'Katalog ATK',
                        subtitle: 'Kelola produk alat tulis yang dijual',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PartnerAtkCatalogPage()),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildActionCard(
                        context,
                        icon: Icons.print,
                        title: 'Layanan & Harga',
                        subtitle: 'Atur layanan cetak dan harga per halaman',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const EditShopSetupPage()),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildActionCard(
                        context,
                        icon: Icons.location_on,
                        title: 'Lokasi & Peta',
                        subtitle: 'Sesuaikan alamat dan pin poin lokasi peta',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const EditAddressPage()),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildActionCard(
                        context,
                        icon: Icons.receipt_long,
                        title: 'Pesanan Masuk',
                        subtitle: 'Kelola pesanan print dari pelanggan',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PartnerOrdersPage()),
                          );
                        },
                      ),
                      const SizedBox(height: 40),
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

  Widget _buildStatusBanner(String status, String? reason) {
    Color bgColor;
    Color textColor;
    String text;
    IconData icon;

    switch (status) {
      case 'approved':
        bgColor = Colors.green.withValues(alpha: 0.1);
        textColor = Colors.green[800]!;
        text = 'Toko Anda telah disetujui dan aktif!';
        icon = Icons.check_circle;
        break;
      case 'rejected':
        bgColor = Colors.red.withValues(alpha: 0.1);
        textColor = Colors.red[800]!;
        text = 'Toko ditolak: ${reason ?? "Hubungi admin"}';
        icon = Icons.error;
        break;
      default:
        bgColor = Colors.orange.withValues(alpha: 0.1);
        textColor = Colors.orange[800]!;
        text = 'Toko Anda sedang dalam peninjauan admin.';
        icon = Icons.pending;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopInfoCard(dynamic shop) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.storefront, color: AppColors.primary, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shop?.shopName ?? 'Nama Toko Belum Diatur',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textHeading,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      shop?.shopAddress ?? 'Alamat belum diatur',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(Icons.star, '${shop?.averageRating ?? "0.0"}', 'Rating'),
              _buildStatItem(Icons.access_time, shop?.openTime != null ? '${shop!.openTime!.substring(0, 5)} - ${shop!.closeTime!.substring(0, 5)}' : '--:--', 'Jam Buka'),
              _buildStatItem(Icons.calendar_today, '${shop?.operatingDays?.length ?? 0} Hari', 'Beroperasi'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textHeading),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textHeading),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
  Widget _buildProfileChecklist(dynamic shop) {
    final bool hasLocation = shop?.latitude != null && shop?.longitude != null;
    final bool hasBasicInfo = shop?.shopName != null && shop?.shopName!.isNotEmpty == true && shop?.shopPhone != null && shop?.shopPhone!.isNotEmpty == true;
    final bool hasHours = shop?.openTime != null && shop?.closeTime != null && shop?.operatingDays != null && shop!.operatingDays!.isNotEmpty;

    final bool isAllComplete = hasLocation && hasBasicInfo && hasHours;

    if (isAllComplete) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Data profil toko sudah lengkap.',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Lengkapi Data Toko Anda',
                  style: TextStyle(color: Colors.red[800], fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildChecklistItem('Informasi Dasar (Nama, No HP)', hasBasicInfo),
          const SizedBox(height: 8),
          _buildChecklistItem('Jam & Hari Operasional', hasHours),
          const SizedBox(height: 8),
          _buildChecklistItem('Koordinat Peta Lokasi (Wajib)', hasLocation),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(String label, bool isComplete) {
    return Row(
      children: [
        Icon(
          isComplete ? Icons.check_circle : Icons.cancel,
          color: isComplete ? Colors.green : Colors.red,
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: isComplete ? AppColors.textPrimary : Colors.red[800],
            fontSize: 13,
            fontWeight: isComplete ? FontWeight.normal : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
