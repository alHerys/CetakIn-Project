import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../bloc/order/partner/partner_order_bloc.dart';
import '../../bloc/order/partner/partner_order_event.dart';
import '../../bloc/order/partner/partner_order_state.dart';
import '../../data/models/order/print_order_model.dart';
import '../core/colors.dart';

class PartnerOrderDetailPage extends StatefulWidget {
  final PrintOrderModel order;

  const PartnerOrderDetailPage({super.key, required this.order});

  @override
  State<PartnerOrderDetailPage> createState() => _PartnerOrderDetailPageState();
}

class _PartnerOrderDetailPageState extends State<PartnerOrderDetailPage> {
  late String _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.order.status;
  }

  Future<void> _downloadFile() async {
    final url = Uri.parse(widget.order.fileUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka file dokumen')),
        );
      }
    }
  }

  void _updateStatus(String newStatus) {
    context.read<PartnerOrderBloc>().add(
      PartnerOrderUpdateStatusRequested(
        orderId: widget.order.id,
        status: newStatus,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detail Pesanan', style: TextStyle(color: AppColors.textHeading)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textHeading),
      ),
      body: BlocConsumer<PartnerOrderBloc, PartnerOrderState>(
        listener: (context, state) {
          if (state is PartnerOrderActionSuccess) {
            setState(() {
              _currentStatus = state.order?.status ?? _currentStatus;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is PartnerOrderFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is PartnerOrderActionLoading;

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildCustomerInfo(),
                    const SizedBox(height: 24),
                    _buildOrderDetails(),
                    const SizedBox(height: 24),
                    _buildDocumentInfo(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
              if (_currentStatus != 'completed' && _currentStatus != 'cancelled')
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: _buildActionButtons(isLoading),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Pelanggan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textHeading),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.order.user?.name ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    Text(
                      widget.order.user?.phone ?? 'Tidak ada nomor HP',
                      style: const TextStyle(color: AppColors.textSubtitle),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detail Cetak',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textHeading),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Ukuran Kertas', widget.order.paperSize),
          const Divider(),
          _buildDetailRow('Mode Warna', widget.order.colorMode == 'full_color' ? 'Berwarna' : 'Hitam Putih'),
          const Divider(),
          _buildDetailRow('Sisi Cetak', widget.order.sides == 'double' ? 'Bolak Balik' : 'Satu Sisi'),
          const Divider(),
          _buildDetailRow('Penjilidan', widget.order.binding),
          const Divider(),
          _buildDetailRow('Kuantitas', '${widget.order.copies} Copy'),
          if (widget.order.notes != null && widget.order.notes!.isNotEmpty) ...[
            const Divider(),
            _buildDetailRow('Catatan', widget.order.notes!),
          ],
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Pembayaran',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textHeading),
                ),
                Text(
                  'Rp ${widget.order.finalPrice}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSubtitle),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, color: AppColors.textHeading),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dokumen',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textHeading),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.picture_as_pdf, size: 40, color: Colors.red),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('File Dokumen (PDF)', style: TextStyle(fontWeight: FontWeight.w500)),
                    Text('${widget.order.totalPages} Halaman', style: const TextStyle(color: AppColors.textSubtitle, fontSize: 13)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.download, color: AppColors.primary),
                onPressed: _downloadFile,
                tooltip: 'Unduh Dokumen',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isLoading) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_currentStatus == 'pending') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _updateStatus('confirmed'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: AppColors.primary,
          ),
          child: const Text('Terima Pesanan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      );
    } else if (_currentStatus == 'confirmed') {
      return ElevatedButton(
        onPressed: () => _updateStatus('processing'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.orange,
        ),
        child: const Text('Mulai Proses Cetak', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      );
    } else if (_currentStatus == 'processing') {
      return ElevatedButton(
        onPressed: () => _updateStatus('ready_for_pickup'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.blue,
        ),
        child: const Text('Selesai Dicetak (Siap Diambil)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      );
    } else if (_currentStatus == 'ready_for_pickup') {
      return ElevatedButton(
        onPressed: () => _updateStatus('completed'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.green,
        ),
        child: const Text('Pesanan Selesai / Diserahkan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      );
    }

    return const SizedBox();
  }
}
