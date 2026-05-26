import 'dart:io';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../data/models/order/print_order_model.dart';
import '../core/colors.dart';
import 'write_review_page.dart';

class OrderSuccessPage extends StatefulWidget {
  final PrintOrderModel order;

  const OrderSuccessPage({super.key, required this.order});

  @override
  State<OrderSuccessPage> createState() => _OrderSuccessPageState();
}

class _OrderSuccessPageState extends State<OrderSuccessPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _hasReviewed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeInOut),
      ),
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
    final imagePath = await File(p.join(directory.path, 'Println_Receipt_${widget.order.id.substring(0, 8)}.png')).create();
    await imagePath.writeAsBytes(image);

    await SharePlus.instance.share(ShareParams(
      files: [XFile(imagePath.path)],
      text: 'Bukti Pemesanan Cetak - Println',
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
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                    child: AnimatedBuilder(
                      animation: _checkAnimation,
                      builder: (context, child) {
                        return Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 50 * _checkAnimation.value,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Pesanan Berhasil!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textHeading,
                  ),
                ),
                const SizedBox(height: 32),
                
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
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Kembali ke Toko'),
                      ),
                    ),
                  ],
                ),
                
                if (widget.order.status == 'completed') ...[
                  const SizedBox(height: 16),
                  if (widget.order.review != null || _hasReviewed)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 32),
                          const SizedBox(height: 8),
                          Text(
                            widget.order.review != null 
                              ? 'Anda memberikan bintang ${widget.order.review!.rating}' 
                              : 'Terima kasih atas ulasan Anda!',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                          if (widget.order.review?.comment != null && widget.order.review!.comment!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                '"${widget.order.review!.comment!}"',
                                style: const TextStyle(fontStyle: FontStyle.italic, color: AppColors.textSubtitle),
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ],
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WriteReviewPage(
                                orderId: widget.order.id,
                                orderType: 'print',
                              ),
                            ),
                          );
                          if (result == true) {
                            setState(() {
                              _hasReviewed = true;
                            });
                          }
                        },
                        icon: const Icon(Icons.star_outline),
                        label: const Text('Beri Ulasan & Nilai'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReceipt({bool isForScreenshot = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isForScreenshot ? null : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Println',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'ID: #${widget.order.id.substring(0, 8).toUpperCase()}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSubtitle, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const Divider(height: 32, thickness: 1, color: AppColors.border),
          _buildInfoRow('Toko', widget.order.shop?.shopName ?? 'Mitra Println'),
          _buildInfoRow(
            'Status',
            _getStatusText(widget.order.status),
            valueColor: _getStatusColor(widget.order.status),
          ),
          _buildInfoRow('Tanggal', widget.order.createdAt.substring(0, 10)),
          const SizedBox(height: 16),
          const Text('RINCIAN CETAK', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSubtitle, letterSpacing: 1)),
          const SizedBox(height: 12),
          _buildDetailItem(Icons.description_outlined, 'File', widget.order.fileUrl.split('/').last.split('?').first),
          _buildDetailItem(Icons.straighten, 'Ukuran', widget.order.paperSize),
          _buildDetailItem(Icons.palette_outlined, 'Warna', widget.order.colorMode == 'full_color' ? 'Berwarna' : 'Hitam Putih'),
          _buildDetailItem(Icons.auto_stories_outlined, 'Sisi', widget.order.sides == 'double' ? 'Bolak Balik' : 'Satu Sisi'),
          _buildDetailItem(Icons.book_outlined, 'Jilid', widget.order.binding == 'none' ? 'Tidak Dijilid' : widget.order.binding.toUpperCase()),
          _buildDetailItem(Icons.copy_outlined, 'Kuantitas', '${widget.order.copies} x ${widget.order.totalPages} Halaman'),
          if (widget.order.notes != null) ...[
            const SizedBox(height: 16),
            const Text('CATATAN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSubtitle, letterSpacing: 1)),
            const SizedBox(height: 4),
            Text(widget.order.notes!, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontStyle: FontStyle.italic)),
          ],
          const Divider(height: 32, thickness: 1, color: AppColors.border),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('TOTAL PEMBAYARAN', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textHeading)),
              Text(
                'Rp ${widget.order.finalPrice}',
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

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Baru (Menunggu)';
      case 'confirmed':
        return 'Diterima';
      case 'processing':
        return 'Diproses';
      case 'ready_for_pickup':
        return 'Siap Diambil';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status.toUpperCase();
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange[800]!;
      case 'confirmed':
        return Colors.purple[800]!;
      case 'processing':
        return Colors.blue[800]!;
      case 'ready_for_pickup':
        return Colors.green[800]!;
      case 'completed':
        return Colors.grey[800]!;
      case 'cancelled':
        return Colors.red[800]!;
      default:
        return AppColors.textHeading;
    }
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 8),
          Text('$label:', style: const TextStyle(fontSize: 13, color: AppColors.textSubtitle)),
          const SizedBox(width: 4),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
