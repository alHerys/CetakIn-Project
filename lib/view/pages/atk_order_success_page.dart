import 'dart:io';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../data/models/order/atk_order_model.dart';
import '../core/colors.dart';

class AtkOrderSuccessPage extends StatefulWidget {
  final AtkOrderModel order;

  const AtkOrderSuccessPage({super.key, required this.order});

  @override
  State<AtkOrderSuccessPage> createState() => _AtkOrderSuccessPageState();
}

class _AtkOrderSuccessPageState extends State<AtkOrderSuccessPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.elasticOut)),
    );
    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.6, 1.0, curve: Curves.easeInOut)),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _shareReceipt() async {
    final image = await _screenshotController.captureFromWidget(
      _buildReceipt(isForScreenshot: true),
      delay: const Duration(milliseconds: 10),
    );
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = await File(p.join(directory.path, 'Println_ATK_${widget.order.id.substring(0, 8)}.png')).create();
    await imagePath.writeAsBytes(image);
    await SharePlus.instance.share(ShareParams(
      files: [XFile(imagePath.path)],
      text: 'Bukti Pemesanan ATK - Println',
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              children: [
                // Animated check circle
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                    child: AnimatedBuilder(
                      animation: _checkAnimation,
                      builder: (context, child) => Icon(Icons.check, color: Colors.white, size: 50 * _checkAnimation.value),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Pesanan Berhasil!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textHeading)),
                const SizedBox(height: 6),
                const Text('Pesanan ATK Anda telah diteruskan ke mitra toko.', style: TextStyle(fontSize: 14, color: AppColors.textSecondary), textAlign: TextAlign.center),
                const SizedBox(height: 32),

                // Receipt
                Screenshot(
                  controller: _screenshotController,
                  child: _buildReceipt(),
                ),

                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _shareReceipt,
                        icon: const Icon(Icons.share, size: 20),
                        label: const Text('Simpan & Bagikan'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Kembali ke Beranda'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReceipt({bool isForScreenshot = false}) {
    final order = widget.order;
    final items = order.items ?? [];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isForScreenshot ? null : [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Println', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primary, letterSpacing: -0.5)),
              Text(
                'ID: #${order.id.substring(0, 8).toUpperCase()}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSubtitle, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          // Type badge
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF4FF),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text('PESANAN ATK', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 1)),
          ),
          const Divider(height: 32, thickness: 1, color: AppColors.border),

          // Order info
          _buildInfoRow('Toko', order.shop?.shopName ?? 'Mitra Println'),
          _buildInfoRow('Status', _getStatusText(order.status), valueColor: _getStatusColor(order.status)),
          _buildInfoRow('Tanggal', order.createdAt.isNotEmpty ? order.createdAt.substring(0, 10) : '-'),

          const SizedBox(height: 16),
          const Text('RINCIAN PESANAN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSubtitle, letterSpacing: 1)),
          const SizedBox(height: 12),

          // Items list
          if (items.isEmpty)
            const Text('(Detail item tidak tersedia)', style: TextStyle(color: AppColors.textSecondary, fontSize: 13))
          else
            ...items.map((item) => _buildItemRow(item)),

          if (order.notes != null && order.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('CATATAN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSubtitle, letterSpacing: 1)),
            const SizedBox(height: 4),
            Text(order.notes!, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontStyle: FontStyle.italic)),
          ],

          const Divider(height: 32, thickness: 1, color: AppColors.border),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('TOTAL PEMBAYARAN', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textHeading)),
              Text(
                'Rp ${_formatPrice(order.finalPrice)}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              'Terima kasih telah menggunakan Println!',
              style: TextStyle(fontSize: 12, color: AppColors.textSubtitle, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSubtitle, fontSize: 14)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: valueColor ?? AppColors.textHeading, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildItemRow(AtkOrderItemModel item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textHeading)),
                Text('Rp ${_formatPrice(item.unitPrice)} × ${item.quantity}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text('Rp ${_formatPrice(item.subtotal)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textHeading)),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending': return 'Menunggu Konfirmasi';
      case 'confirmed': return 'Diterima';
      case 'processing': return 'Diproses';
      case 'ready_for_pickup': return 'Siap Diambil';
      case 'completed': return 'Selesai';
      case 'cancelled': return 'Dibatalkan';
      default: return status.toUpperCase();
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange[800]!;
      case 'confirmed': return Colors.purple[800]!;
      case 'processing': return Colors.blue[800]!;
      case 'ready_for_pickup': return Colors.green[800]!;
      case 'completed': return Colors.grey[800]!;
      case 'cancelled': return Colors.red[800]!;
      default: return AppColors.textHeading;
    }
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
