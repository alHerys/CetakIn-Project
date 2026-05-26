import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/atk/customer/atk_cart_bloc.dart';
import '../../../bloc/atk/customer/atk_cart_event.dart';
import '../../../bloc/atk/customer/atk_cart_state.dart';
import '../../../data/services/dio_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../core/colors.dart';
import '../../../data/models/shop/shop_model.dart';
import '../../../data/models/order/atk_order_model.dart';
import 'atk_order_success_page.dart';

class AtkCheckoutPage extends StatefulWidget {
  const AtkCheckoutPage({super.key});

  @override
  State<AtkCheckoutPage> createState() => _AtkCheckoutPageState();
}

class _AtkCheckoutPageState extends State<AtkCheckoutPage> {
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitOrder(AtkCartUpdated cartState) async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final dioClient = DioClient(prefs);
      
      final items = cartState.items.map((item) => {
        'atk_id': item.product.id,
        'quantity': item.quantity,
      }).toList();

      final response = await dioClient.dio.post('orders/atk', data: {
        'shop_id': cartState.currentShop!.id,
        'items': items,
        'notes': _notesController.text.trim(),
      });

      final order = AtkOrderModel.fromJson(response.data['data'] as Map<String, dynamic>);
      
      if (!mounted) return;
      
      // Clear cart
      context.read<AtkCartBloc>().add(AtkCartClearRequested());
      
      // Navigate to AtkOrderSuccessPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AtkOrderSuccessPage(order: order),
        ),
      );

    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.response?.data['message'] ?? 'Gagal membuat pesanan ATK')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AtkCartBloc, AtkCartState>(
      builder: (context, state) {
        if (state is! AtkCartUpdated || state.items.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Checkout', style: TextStyle(color: AppColors.textHeading))),
            body: const Center(child: Text('Keranjang Kosong')),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Checkout ATK', style: TextStyle(color: AppColors.textHeading)),
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: AppColors.textHeading),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildShopHeader(state.currentShop!),
                const SizedBox(height: 24),
                const Text('Rincian Belanja', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textHeading)),
                const SizedBox(height: 12),
                ...state.items.map((item) => _buildCartItem(item)),
                const SizedBox(height: 24),
                const Text('Catatan Tambahan (Opsional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textHeading)),
                const SizedBox(height: 12),
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Cth: Tolong dibungkus rapi...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomBar(state),
        );
      },
    );
  }

  Widget _buildShopHeader(ShopModel shop) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.storefront, color: AppColors.primary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Membeli dari:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                Text(shop.shopName ?? 'Toko', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textHeading)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item.product.photoUrl != null
                ? Image.network(item.product.photoUrl!, width: 60, height: 60, fit: BoxFit.cover)
                : Container(width: 60, height: 60, color: AppColors.primary.withValues(alpha: 0.1), child: const Icon(Icons.inventory, color: AppColors.primary)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name ?? 'ATK', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textHeading)),
                Text('Rp ${item.product.price}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary),
                onPressed: () {
                  context.read<AtkCartBloc>().add(AtkCartUpdateItemQuantityRequested(item.product.id!, item.quantity - 1));
                },
              ),
              Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                onPressed: () {
                  context.read<AtkCartBloc>().add(AtkCartUpdateItemQuantityRequested(item.product.id!, item.quantity + 1));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(AtkCartUpdated state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: AppColors.shadow.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Pembayaran', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  Text('Rp ${state.totalAmount}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.textHeading)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: _isSubmitting ? null : () => _submitOrder(state),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSubmitting
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Pesan Sekarang', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
