import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/profile/profile_bloc.dart';
import '../../bloc/profile/profile_state.dart';
import '../../bloc/discovery/discovery_bloc.dart';
import '../../bloc/discovery/discovery_event.dart';
import '../../bloc/discovery/discovery_state.dart';
import '../core/colors.dart';
import '../widgets/admin_home_body.dart';
import '../widgets/shop_card_widget.dart';
import 'profile_page.dart';

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
  void initState() {
    super.initState();
    // Iteration 2 will handle Location and Discovery
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoaded) {
          final user = state.user;
          final isAdmin = user.role == 'admin';

          return Scaffold(
            backgroundColor: AppColors.background,
            body: IndexedStack(
              index: _selectedNavIndex,
              children: isAdmin
                  ? [
                      const AdminHomeBody(),
                      const ProfilePage(),
                    ]
                  : user.role == 'partner'
                      ? [
                          _buildPartnerHomeBody(),
                          const Center(child: Text('Partner Orders (Coming Soon)')),
                          const ProfilePage(),
                        ]
                      : [
                          _buildHomeBody(context),
                          const Center(child: Text('Orders Page (Coming Soon)')),
                          const Center(child: Text('Shop Page (Coming Soon)')),
                          const ProfilePage(),
                        ],
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 41, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: isAdmin
                        ? [
                            _buildNavItem(0, Icons.home_outlined, 'Home'),
                            _buildNavItem(1, Icons.person_outline, 'Profile'),
                          ]
                        : user.role == 'partner'
                            ? [
                                _buildNavItem(0, Icons.storefront_outlined, 'Dashboard'),
                                _buildNavItem(1, Icons.receipt_long_outlined, 'Orders'),
                                _buildNavItem(2, Icons.person_outline, 'Profile'),
                              ]
                            : [
                                _buildNavItem(0, Icons.home_outlined, 'Home'),
                                _buildNavItem(1, Icons.receipt_long_outlined, 'Orders'),
                                _buildNavItem(2, Icons.storefront_outlined, 'Shop'),
                                _buildNavItem(3, Icons.person_outline, 'Profile'),
                              ],
                  ),
                ),
              ),
            ),
          );
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedNavIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedNavIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
            size: 22,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.primary : AppColors.textPrimary,
              letterSpacing: 0.14,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildPartnerHomeBody() {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Text(
          'Partner Dashboard (Coming Soon)',
          style: TextStyle(fontSize: 18, color: AppColors.textHeading),
        ),
      ),
    );
  }

  Widget _buildHomeBody(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.appBarBackground,
        elevation: 0,
        titleSpacing: 20,
        centerTitle: false,
        title: const Text(
          'CetakIn',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            letterSpacing: -0.55,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20),
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
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      letterSpacing: 0.14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_categories.length, (index) {
                    final bool isSelected = _selectedCategory == index;
                    return Padding(
                      padding: EdgeInsets.only(
                        right: index < _categories.length - 1 ? 8 : 0,
                      ),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedCategory = index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.circular(9999),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.border,
                            ),
                          ),
                          child: Text(
                            _categories[index],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : AppColors.textPrimary,
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
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
              BlocBuilder<DiscoveryBloc, DiscoveryState>(
                builder: (context, state) {
                  if (state is DiscoveryLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is DiscoveryError) {
                    return Center(child: Text(state.message));
                  } else if (state is DiscoveryLoaded) {
                    if (state.shops.isEmpty) {
                      return const Center(child: Text('Tidak ada toko terdekat'));
                    }
                    return Column(
                      children: state.shops.map((shop) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: ShopCard(
                            shop: shop,
                          ),
                        );
                      }).toList(),
                    );
                  }
                  return const SizedBox();
                },
              ),
              const SizedBox(height: 96),
            ],
          ),
        ),
      ),
    );
  }
}
