import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/order/partner/partner_order_bloc.dart';
import '../../bloc/order/partner/partner_order_event.dart';
import '../../bloc/order/partner/partner_order_state.dart';
import '../../data/models/order/print_order_model.dart';
import '../core/colors.dart';
import 'partner_order_detail_page.dart';

class PartnerOrdersPage extends StatefulWidget {
  const PartnerOrdersPage({super.key});

  @override
  State<PartnerOrdersPage> createState() => _PartnerOrdersPageState();
}

class _PartnerOrdersPageState extends State<PartnerOrdersPage> {
  @override
  void initState() {
    super.initState();
    context.read<PartnerOrderBloc>().add(PartnerOrderLoadIncomingRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pesanan', style: TextStyle(color: AppColors.textHeading)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textHeading),
      ),
      body: Column(
        children: [
          _buildFilterRow(),
          Expanded(
            child: BlocBuilder<PartnerOrderBloc, PartnerOrderState>(
              builder: (context, state) {
                if (state is PartnerOrderLoading || state is PartnerOrderActionLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is PartnerOrderFailure) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Gagal memuat pesanan: ${state.error}', textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context.read<PartnerOrderBloc>().add(PartnerOrderLoadIncomingRequested()),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                } else if (state is PartnerOrderLoaded) {
                  if (state.orders.isEmpty) {
                    return Center(
                      child: Text(
                        state.filterMode == OrderFilter.completed
                            ? 'Belum ada riwayat pesanan selesai.'
                            : 'Belum ada pesanan aktif.',
                        style: const TextStyle(color: AppColors.textSubtitle, fontSize: 16),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<PartnerOrderBloc>().add(PartnerOrderLoadIncomingRequested());
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.orders.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final order = state.orders[index];
                        return _buildOrderCard(context, order);
                      },
                    ),
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return BlocBuilder<PartnerOrderBloc, PartnerOrderState>(
      builder: (context, state) {
        OrderFilter currentFilter = OrderFilter.active;
        if (state is PartnerOrderLoaded) {
          currentFilter = state.filterMode;
        }

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          color: Colors.white,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip(
                  context,
                  label: 'Belum Selesai',
                  isSelected: currentFilter == OrderFilter.active,
                  filter: OrderFilter.active,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context,
                  label: 'Selesai',
                  isSelected: currentFilter == OrderFilter.completed,
                  filter: OrderFilter.completed,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required OrderFilter filter,
  }) {
    return GestureDetector(
      onTap: () {
        context.read<PartnerOrderBloc>().add(PartnerOrderFilterChanged(filter));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, PrintOrderModel order) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PartnerOrderDetailPage(order: order)),
        ).then((_) {
          // Refresh list when coming back
          if (context.mounted) {
            context.read<PartnerOrderBloc>().add(PartnerOrderLoadIncomingRequested());
          }
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.user?.name ?? 'Customer',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textHeading),
                ),
                _buildStatusBadge(order.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.picture_as_pdf, size: 28, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${order.copies} Copy • ${order.totalPages} Halaman',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textHeading),
                      ),
                      Text(
                        '${order.paperSize} • ${order.colorMode == 'full_color' ? 'Warna' : 'B/W'} • ${order.sides == 'double' ? 'Bolak Balik' : 'Satu Sisi'}',
                        style: const TextStyle(fontSize: 13, color: AppColors.textSubtitle),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Harga',
                  style: TextStyle(fontSize: 14, color: AppColors.textSubtitle),
                ),
                Text(
                  'Rp ${order.finalPrice}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ],
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
        text = 'Baru';
        break;
      case 'confirmed':
        bgColor = Colors.purple.withValues(alpha: 0.1);
        textColor = Colors.purple[800]!;
        text = 'Diterima';
        break;
      case 'processing':
        bgColor = Colors.blue.withValues(alpha: 0.1);
        textColor = Colors.blue[800]!;
        text = 'Proses';
        break;
      case 'ready_for_pickup':
        bgColor = Colors.green.withValues(alpha: 0.1);
        textColor = Colors.green[800]!;
        text = 'Siap';
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
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
