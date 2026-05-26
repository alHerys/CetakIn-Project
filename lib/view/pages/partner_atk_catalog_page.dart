import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/atk/partner/partner_atk_bloc.dart';
import '../../../bloc/atk/partner/partner_atk_event.dart';
import '../../../bloc/atk/partner/partner_atk_state.dart';
import '../../../data/models/atk/atk_product_model.dart';
import '../core/colors.dart';
import 'partner_atk_form_page.dart';

class PartnerAtkCatalogPage extends StatefulWidget {
  const PartnerAtkCatalogPage({super.key});

  @override
  State<PartnerAtkCatalogPage> createState() => _PartnerAtkCatalogPageState();
}

class _PartnerAtkCatalogPageState extends State<PartnerAtkCatalogPage> {
  @override
  void initState() {
    super.initState();
    context.read<PartnerAtkBloc>().add(PartnerAtkLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Katalog ATK', style: TextStyle(color: AppColors.textHeading)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textHeading),
      ),
      body: BlocConsumer<PartnerAtkBloc, PartnerAtkState>(
        listener: (context, state) {
          if (state is PartnerAtkActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is PartnerAtkFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        builder: (context, state) {
          if (state is PartnerAtkLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PartnerAtkFailure && state is! PartnerAtkActionSuccess && state is! PartnerAtkActionLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Gagal memuat katalog: ${state.error}', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<PartnerAtkBloc>().add(PartnerAtkLoadRequested()),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          } else if (state is PartnerAtkLoaded) {
            if (state.products.isEmpty) {
              return const Center(
                child: Text(
                  'Belum ada produk ATK.\nTekan + untuk menambahkan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSubtitle, fontSize: 16),
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<PartnerAtkBloc>().add(PartnerAtkLoadRequested());
              },
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: state.products.length,
                itemBuilder: (context, index) {
                  return _buildProductCard(context, state.products[index]);
                },
              ),
            );
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PartnerAtkFormPage()),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, AtkProductModel product) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PartnerAtkFormPage(product: product),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: product.photoUrl != null
                    ? Image.network(
                        product.photoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.image_not_supported, color: AppColors.textSecondary, size: 40),
                      )
                    : Container(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        child: const Icon(Icons.inventory, color: AppColors.primary, size: 40),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name ?? 'Tanpa Nama',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textHeading),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp ${product.price ?? 0}',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.primary),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Stok: ${product.stock ?? 0}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: (product.isAvailable ?? false) ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          (product.isAvailable ?? false) ? 'Tersedia' : 'Habis',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: (product.isAvailable ?? false) ? Colors.green[800] : Colors.red[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
