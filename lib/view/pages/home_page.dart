import 'package:flutter/material.dart';
import '../core/colors.dart';
import '../widgets/shop_card_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedCategory = 0;
  int _selectedNavIndex = 0;
  final SearchController _searchController = SearchController();

  final List<String> _categories = [
    'Semua',
    'Digital Printing',
    'Fotocopy',
    'Stationery',
  ];

  final location = 'Jakarta Selatan, ID';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.appBarBackground,
        elevation: 0,
        titleSpacing: 20,
        centerTitle: false,
        title: Text(
          'CetakIn',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            letterSpacing: -0.55,
          ),
        ),
        actions: [
          Padding(
            padding: const .only(right: 20),
            child: Icon(
              Icons.notifications_none_outlined,
              color: AppColors.primary,
              size: 24,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const .symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: .start,
            children: [
              const SizedBox(height: 24),

              Text(
                'Halo, mau cetak apa hari ini?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),

              SearchAnchor(
                searchController: _searchController,
                builder: (BuildContext context, SearchController controller) {
                  return SearchBar(
                    controller: controller,
                    hintText: 'Cari percetakan terdekat...',
                    onTap: () => controller.openView(),
                    onChanged: (_) => controller.openView(),
                    leading: const Icon(
                      Icons.search,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                    hintStyle: WidgetStatePropertyAll(
                      TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    textStyle: WidgetStatePropertyAll(
                      TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    backgroundColor: const WidgetStatePropertyAll(Colors.white),
                    elevation: const WidgetStatePropertyAll(0),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppColors.border),
                      ),
                    ),
                    padding: const WidgetStatePropertyAll(
                      .symmetric(horizontal: 16, vertical: 0),
                    ),
                    constraints: const BoxConstraints(
                      minHeight: 48,
                      maxHeight: 48,
                    ),
                  );
                },
                suggestionsBuilder:
                    (BuildContext context, SearchController controller) {
                      return [];
                    },
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: AppColors.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    location,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      letterSpacing: 0.14,
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
              ),

              const SizedBox(height: 8),

              SingleChildScrollView(
                scrollDirection: .horizontal,
                child: Row(
                  children: List.generate(_categories.length, (index) {
                    final bool isSelected = _selectedCategory == index;
                    return Padding(
                      padding: .only(
                        right: index < _categories.length - 1 ? 8 : 0,
                      ),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedCategory = index),
                        child: Container(
                          padding: const .symmetric(
                            horizontal: 16,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.white,
                            borderRadius: BorderRadius.circular(9999),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                          ),
                          child: Text(
                            _categories[index],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                              letterSpacing: 0.14,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  Text(
                    'Dekat Kamu',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textHeading,
                    ),
                  ),
                  Text(
                    'Lihat Semua',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      letterSpacing: 0.14,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              const ShopCard(
                title: 'Cetak Kilat Tebet',
                distance: 1.2,
                status: 'BUKA',
                openTime: '08:00',
                rating: 4.9,
                imageUrl: 'https://picsum.photos/800/400?random=1',
              ),

              const SizedBox(height: 24),

              const ShopCard(
                title: 'Kencana Print',
                distance: 1.5,
                status: 'TUTUP',
                openTime: '08:00',
                rating: 4.7,
                imageUrl: 'https://picsum.photos/800/400?random=2',
              ),

              const SizedBox(height: 24),

              const ShopCard(
                title: 'Warung Print',
                distance: 2.1,
                status: 'BUKA',
                openTime: '07:00',
                rating: 4.9,
                imageUrl: 'https://picsum.photos/800/400?random=3',
              ),

              const SizedBox(height: 96),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const .symmetric(horizontal: 41, vertical: 12),
            child: Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => setState(() => _selectedNavIndex = 0),
                  child: Column(
                    mainAxisSize: .min,
                    children: [
                      Icon(
                        Icons.home_outlined,
                        color: _selectedNavIndex == 0
                            ? AppColors.primary
                            : AppColors.textPrimary,
                        size: 22,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Home',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: .w600,
                          color: _selectedNavIndex == 0
                              ? AppColors.primary
                              : AppColors.textPrimary,
                          letterSpacing: 0.14,
                        ),
                      ),
                    ],
                  ),
                ),

                GestureDetector(
                  onTap: () => setState(() => _selectedNavIndex = 1),
                  child: Column(
                    mainAxisSize: .min,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        color: _selectedNavIndex == 1
                            ? AppColors.primary
                            : AppColors.textPrimary,
                        size: 22,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Orders',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: .w600,
                          color: _selectedNavIndex == 1
                              ? AppColors.primary
                              : AppColors.textPrimary,
                          letterSpacing: 0.14,
                        ),
                      ),
                    ],
                  ),
                ),

                GestureDetector(
                  onTap: () => setState(() => _selectedNavIndex = 2),
                  child: Column(
                    mainAxisSize: .min,
                    children: [
                      Icon(
                        Icons.storefront_outlined,
                        color: _selectedNavIndex == 2
                            ? AppColors.primary
                            : AppColors.textPrimary,
                        size: 22,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Shop',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: .w600,
                          color: _selectedNavIndex == 2
                              ? AppColors.primary
                              : AppColors.textPrimary,
                          letterSpacing: 0.14,
                        ),
                      ),
                    ],
                  ),
                ),

                GestureDetector(
                  onTap: () => setState(() => _selectedNavIndex = 3),
                  child: Column(
                    mainAxisSize: .min,
                    children: [
                      Icon(
                        Icons.person_outline,
                        color: _selectedNavIndex == 3
                            ? AppColors.primary
                            : AppColors.textPrimary,
                        size: 22,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Profile',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: .w600,
                          color: _selectedNavIndex == 3
                              ? AppColors.primary
                              : AppColors.textPrimary,
                          letterSpacing: 0.14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
