import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/order/partner/partner_order_bloc.dart';
import '../../bloc/order/partner/partner_order_event.dart';
import '../../bloc/order/partner/partner_order_state.dart' as print_state;
import '../../bloc/order/partner_atk/partner_atk_order_bloc.dart';
import '../../bloc/order/partner_atk/partner_atk_order_event.dart' as atk_event;
import '../../bloc/order/partner_atk/partner_atk_order_state.dart' as atk_state;

import '../../data/models/order/print_order_model.dart';
import '../core/colors.dart';
import 'partner_order_detail_page.dart';
import '../widgets/atk_order_card_widget.dart';

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
    context.read<PartnerAtkOrderBloc>().add(atk_event.PartnerAtkOrderLoadIncomingRequested());
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Pesanan Masuk', style: TextStyle(color: AppColors.textHeading)),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.textHeading),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'Cetak Dokumen'),
              Tab(text: 'Alat Tulis Kantor'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _PrintOrdersTab(),
            _AtkOrdersTab(),
          ],
        ),
      ),
    );
  }
}

class _PrintOrdersTab extends StatelessWidget {
  const _PrintOrdersTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFilterRow(context),
        Expanded(
          child: BlocBuilder<PartnerOrderBloc, print_state.PartnerOrderState>(
            builder: (context, state) {
              if (state is print_state.PartnerOrderLoading || state is print_state.PartnerOrderActionLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is print_state.PartnerOrderFailure) {
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
              } else if (state is print_state.PartnerOrderLoaded) {
                if (state.orders.isEmpty) {
                  return Center(
                    child: Text(
                      state.filterMode == print_state.OrderFilter.completed
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
    );
  }

  Widget _buildFilterRow(BuildContext context) {
    return BlocBuilder<PartnerOrderBloc, print_state.PartnerOrderState>(
      builder: (context, state) {
        print_state.OrderFilter currentFilter = print_state.OrderFilter.active;
        if (state is print_state.PartnerOrderLoaded) {
          currentFilter = state.filterMode;
        }

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          width: double.infinity,
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFilterChip(
                context,
                label: 'Belum Selesai',
                isSelected: currentFilter == print_state.OrderFilter.active,
                onTap: () => context.read<PartnerOrderBloc>().add(PartnerOrderFilterChanged(print_state.OrderFilter.active)),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                context,
                label: 'Selesai',
                isSelected: currentFilter == print_state.OrderFilter.completed,
                onTap: () => context.read<PartnerOrderBloc>().add(PartnerOrderFilterChanged(print_state.OrderFilter.completed)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(BuildContext context, {required String label, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
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
                const Text('Total Harga', style: TextStyle(fontSize: 14, color: AppColors.textSubtitle)),
                Text('Rp ${order.finalPrice}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
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
      case 'pending': bgColor = Colors.orange.withValues(alpha: 0.1); textColor = Colors.orange[800]!; text = 'Baru'; break;
      case 'confirmed': bgColor = Colors.purple.withValues(alpha: 0.1); textColor = Colors.purple[800]!; text = 'Diterima'; break;
      case 'processing': bgColor = Colors.blue.withValues(alpha: 0.1); textColor = Colors.blue[800]!; text = 'Diproses'; break;
      case 'ready_for_pickup': bgColor = Colors.green.withValues(alpha: 0.1); textColor = Colors.green[800]!; text = 'Siap Diambil'; break;
      case 'completed': bgColor = Colors.grey.withValues(alpha: 0.1); textColor = Colors.grey[800]!; text = 'Selesai'; break;
      case 'cancelled': default: bgColor = Colors.red.withValues(alpha: 0.1); textColor = Colors.red[800]!; text = 'Dibatalkan'; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class _AtkOrdersTab extends StatelessWidget {
  const _AtkOrdersTab();

  Widget? _buildNextStatusButton(BuildContext context, String orderId, String currentStatus) {
    String nextStatus;
    String label;
    Color color;

    switch (currentStatus) {
      case 'pending':
        nextStatus = 'confirmed';
        label = 'Terima Pesanan';
        color = Colors.orange; // Kuning/Oranye
        break;
      case 'confirmed':
        nextStatus = 'processing';
        label = 'Proses Kemas';
        color = Colors.lightBlue; // Biru Muda
        break;
      case 'processing':
        nextStatus = 'ready_for_pickup';
        label = 'Siap Diambil';
        color = Colors.purple; // Ungu
        break;
      case 'ready_for_pickup':
        nextStatus = 'completed';
        label = 'Selesai';
        color = Colors.green; // Hijau
        break;
      default:
        return null;
    }

    return ElevatedButton(
      onPressed: () {
        context.read<PartnerAtkOrderBloc>().add(
          atk_event.PartnerAtkOrderUpdateStatusRequested(orderId: orderId, newStatus: nextStatus)
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFilterRow(context),
        Expanded(
          child: BlocConsumer<PartnerAtkOrderBloc, atk_state.PartnerAtkOrderState>(
            listener: (context, state) {
              if (state is atk_state.PartnerAtkOrderActionSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Status diubah'), 
                    backgroundColor: Colors.green,
                    duration: Duration(milliseconds: 500),
                  ),
                );
              } else if (state is atk_state.PartnerAtkOrderFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error), 
                    backgroundColor: Colors.red,
                    duration: const Duration(milliseconds: 500),
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is atk_state.PartnerAtkOrderLoading || state is atk_state.PartnerAtkOrderActionLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is atk_state.PartnerAtkOrderFailure) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Gagal memuat pesanan ATK: ${state.error}', textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.read<PartnerAtkOrderBloc>().add(atk_event.PartnerAtkOrderLoadIncomingRequested()),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                );
              } else if (state is atk_state.PartnerAtkOrderLoaded || state is atk_state.PartnerAtkOrderActionSuccess) {
                final orders = state is atk_state.PartnerAtkOrderLoaded ? state.orders : (state as atk_state.PartnerAtkOrderActionSuccess).orders;
                final filterMode = state is atk_state.PartnerAtkOrderLoaded ? state.filterMode : (state as atk_state.PartnerAtkOrderActionSuccess).filterMode;

                if (orders.isEmpty) {
                  return Center(
                    child: Text(
                      filterMode == atk_event.PartnerAtkOrderFilter.completed
                          ? 'Belum ada riwayat pesanan selesai.'
                          : 'Belum ada pesanan aktif.',
                      style: const TextStyle(color: AppColors.textSubtitle, fontSize: 16),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<PartnerAtkOrderBloc>().add(atk_event.PartnerAtkOrderLoadIncomingRequested());
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return AtkOrderCardWidget(
                        order: order,
                        isPartner: true,
                        onTap: () {
                          // View details if needed
                        },
                        trailingAction: filterMode == atk_event.PartnerAtkOrderFilter.active
                          ? _buildNextStatusButton(context, order.id, order.status)
                          : null,
                      );
                    },
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterRow(BuildContext context) {
    return BlocBuilder<PartnerAtkOrderBloc, atk_state.PartnerAtkOrderState>(
      builder: (context, state) {
        atk_event.PartnerAtkOrderFilter currentFilter = atk_event.PartnerAtkOrderFilter.active;
        if (state is atk_state.PartnerAtkOrderLoaded) {
          currentFilter = state.filterMode;
        } else if (state is atk_state.PartnerAtkOrderActionSuccess) {
          currentFilter = state.filterMode;
        }

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          width: double.infinity,
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFilterChip(
                context,
                label: 'Belum Selesai',
                isSelected: currentFilter == atk_event.PartnerAtkOrderFilter.active,
                onTap: () => context.read<PartnerAtkOrderBloc>().add(atk_event.PartnerAtkOrderFilterChanged(atk_event.PartnerAtkOrderFilter.active)),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                context,
                label: 'Selesai',
                isSelected: currentFilter == atk_event.PartnerAtkOrderFilter.completed,
                onTap: () => context.read<PartnerAtkOrderBloc>().add(atk_event.PartnerAtkOrderFilterChanged(atk_event.PartnerAtkOrderFilter.completed)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(BuildContext context, {required String label, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
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
}
