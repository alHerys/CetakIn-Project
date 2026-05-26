import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/order/customer/customer_order_bloc.dart';
import '../../bloc/order/customer/customer_order_event.dart';
import '../../bloc/order/customer/customer_order_state.dart';
import '../../data/models/order/print_order_model.dart';
import '../core/colors.dart';
import 'order_success_page.dart';

class CustomerOrdersPage extends StatefulWidget {
  const CustomerOrdersPage({super.key});

  @override
  State<CustomerOrdersPage> createState() => _CustomerOrdersPageState();
}

class _CustomerOrdersPageState extends State<CustomerOrdersPage> {
  @override
  void initState() {
    super.initState();
    context.read<CustomerOrderBloc>().add(CustomerOrderLoadHistoryRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<CustomerOrderBloc, CustomerOrderState>(
        builder: (context, state) {
          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              _buildSliverAppBar(),
              _buildSliverFilter(state),
              if (state is CustomerOrderLoading)
                const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
              else if (state is CustomerOrderFailure)
                SliverFillRemaining(child: _buildErrorState(state.error))
              else if (state is CustomerOrderLoaded)
                state.orders.isEmpty
                    ? SliverFillRemaining(child: _buildEmptyState(state.filterMode))
                    : SliverPadding(
                        padding: const EdgeInsets.all(20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => _buildOrderCard(state.orders[index]),
                            childCount: state.orders.length,
                          ),
                        ),
                      )
              else
                const SliverToBoxAdapter(child: SizedBox()),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return const SliverAppBar(
      floating: true,
      pinned: true,
      expandedHeight: 120,
      backgroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Pesanan Saya',
          style: TextStyle(color: AppColors.textHeading, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        titlePadding: EdgeInsetsDirectional.only(start: 20, bottom: 16),
      ),
    );
  }

  Widget _buildSliverFilter(CustomerOrderState state) {
    CustomerOrderFilter currentFilter = CustomerOrderFilter.ongoing;
    if (state is CustomerOrderLoaded) {
      currentFilter = state.filterMode;
    }

    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverFilterDelegate(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'Sedang Berjalan',
                  isSelected: currentFilter == CustomerOrderFilter.ongoing,
                  filter: CustomerOrderFilter.ongoing,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Selesai',
                  isSelected: currentFilter == CustomerOrderFilter.finished,
                  filter: CustomerOrderFilter.finished,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip({required String label, required bool isSelected, required CustomerOrderFilter filter}) {
    return GestureDetector(
      onTap: () {
        context.read<CustomerOrderBloc>().add(CustomerOrderFilterChanged(filter));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(PrintOrderModel order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderSuccessPage(order: order),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.storefront, size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            order.shop?.shopName ?? 'Mitra Println',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textHeading),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(order.status),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.picture_as_pdf, color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${order.copies} Salinan • ${order.totalPages} Halaman',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textHeading),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${order.paperSize} • ${order.colorMode == 'full_color' ? 'Warna' : 'B/W'} • ${order.sides == 'double' ? 'Bolak Balik' : '1 Sisi'}',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Pembayaran', style: TextStyle(color: AppColors.textSubtitle, fontSize: 11)),
                      Text(
                        'Rp ${order.finalPrice}',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.primary),
                      ),
                    ],
                  ),
                  if (order.status == 'pending')
                    TextButton(
                      onPressed: () {
                        context.read<CustomerOrderBloc>().add(CustomerOrderCancelRequested(order.id));
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Batalkan', style: TextStyle(fontWeight: FontWeight.bold)),
                    )
                  else
                    const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
                ],
              ),
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
        text = 'Menunggu';
        break;
      case 'confirmed':
        bgColor = Colors.purple.withValues(alpha: 0.1);
        textColor = Colors.purple[800]!;
        text = 'Diterima';
        break;
      case 'processing':
        bgColor = Colors.blue.withValues(alpha: 0.1);
        textColor = Colors.blue[800]!;
        text = 'Diproses';
        break;
      case 'ready_for_pickup':
        bgColor = Colors.green.withValues(alpha: 0.1);
        textColor = Colors.green[800]!;
        text = 'Siap Diambil';
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
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
      child: Text(
        text,
        style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildEmptyState(CustomerOrderFilter filter) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            filter == CustomerOrderFilter.ongoing ? Icons.receipt_long_outlined : Icons.history,
            size: 80,
            color: AppColors.textSubtitle.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            filter == CustomerOrderFilter.ongoing ? 'Tidak ada pesanan aktif' : 'Belum ada riwayat pesanan',
            style: const TextStyle(color: AppColors.textSubtitle, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            filter == CustomerOrderFilter.ongoing ? 'Ayo mulai mencetak dokumenmu sekarang!' : 'Pesanan yang selesai akan tampil di sini',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text('Waduh! Ada masalah: $error', textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.read<CustomerOrderBloc>().add(CustomerOrderLoadHistoryRequested()),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SliverFilterDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SliverFilterDelegate({required this.child});

  @override
  double get minExtent => 70;
  @override
  double get maxExtent => 70;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverFilterDelegate oldDelegate) => true;
}
