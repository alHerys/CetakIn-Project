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
import 'location_picker_page.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  String _locationName = 'Mencari lokasi...';
  double? _currentLat;
  double? _currentLng;
  bool _isGpsValid = false;
  String _gpsError = '';
  bool _isEnforcing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileState = context.read<ProfileBloc>().state;
      if (profileState is ProfileLoaded && profileState.user.role == 'user') {
        _enforceGps();
      }
    });
  }

  Future<void> _enforceGps() async {
    if (_isEnforcing) return;

    final prefs = await SharedPreferences.getInstance();
    final savedAddress = prefs.getString('user_home_address');
    final savedLat = prefs.getDouble('user_home_lat');
    final savedLng = prefs.getDouble('user_home_lng');

    if (savedAddress != null && savedLat != null && savedLng != null) {
      setState(() {
        _locationName = savedAddress;
        _currentLat = savedLat;
        _currentLng = savedLng;
        _isGpsValid = true;
      });
      if (mounted) {
        context.read<DiscoveryBloc>().add(DiscoverySearchRequested(
          lat: _currentLat!,
          lng: _currentLng!,
        ));
      }
      return;
    }

    setState(() {
      _isEnforcing = true;
      _gpsError = 'Mengecek GPS...';
    });

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _isEnforcing = false;
        _isGpsValid = false;
        _gpsError = 'GPS tidak aktif. Mohon nyalakan GPS Anda.';
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _isEnforcing = false;
          _isGpsValid = false;
          _gpsError = 'Izin lokasi ditolak. Aplikasi butuh lokasi Anda.';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _isEnforcing = false;
        _isGpsValid = false;
        _gpsError = 'Izin lokasi ditolak permanen. Buka pengaturan aplikasi untuk mengizinkan.';
      });
      return;
    }

    setState(() {
      _gpsError = 'Mendapatkan lokasi...';
    });

    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      _currentLat = position.latitude;
      _currentLng = position.longitude;

      await _updateLocationName(_currentLat!, _currentLng!);

      setState(() {
        _isGpsValid = true;
        _isEnforcing = false;
      });

      if (mounted) {
        context.read<DiscoveryBloc>().add(DiscoverySearchRequested(
          lat: _currentLat!,
          lng: _currentLng!,
        ));
      }
    } catch (e) {
      setState(() {
        _isEnforcing = false;
        _isGpsValid = false;
        _gpsError = 'Gagal mendapat lokasi: $e';
      });
    }
  }

  Future<void> _updateLocationName(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final name = place.thoroughfare?.isNotEmpty == true ? place.thoroughfare : place.subLocality;
        final city = place.locality?.isNotEmpty == true ? place.locality : place.subAdministrativeArea;
        _locationName = '${name ?? ''}, ${city ?? ''}'.trim().replaceAll(RegExp(r'^,\s*'), '');
        if (_locationName.isEmpty) _locationName = 'Lokasi ditemukan';
      }
    } catch (e) {
      _locationName = 'Detail alamat tidak ditemukan';
    }
  }

  PageRouteBuilder _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.ease;
        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
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
      onTap: () {
        setState(() => _selectedNavIndex = index);
        if (index == 0) {
          _enforceGps();
        }
      },
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

  Widget _buildGpsBlockingUI() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_off, size: 80, color: AppColors.primary),
              const SizedBox(height: 24),
              const Text(
                'Akses Lokasi Diperlukan',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textHeading,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                _gpsError,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _enforceGps,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Coba Lagi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeBody(BuildContext context) {
    if (!_isGpsValid) {
      return _buildGpsBlockingUI();
    }

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
              const SizedBox(height: 16),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      _createRoute(
                        LocationPickerPage(
                          initialLat: _currentLat,
                          initialLng: _currentLng,
                        ),
                      ),
                    );
                    if (result != null && result is Map<String, dynamic>) {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('user_home_address', result['address']);
                      await prefs.setDouble('user_home_lat', result['lat']);
                      await prefs.setDouble('user_home_lng', result['lng']);

                      if (!context.mounted) return;

                      setState(() {
                        _currentLat = result['lat'];
                        _currentLng = result['lng'];
                        _locationName = result['address'];
                      });
                      context.read<DiscoveryBloc>().add(DiscoverySearchRequested(
                        lat: _currentLat!,
                        lng: _currentLng!,
                      ));
                    }
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: _isEnforcing
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                )
                              : Text(
                                  _locationName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                        ),
                        if (!_isEnforcing) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.keyboard_arrow_down, color: AppColors.primary, size: 20),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
