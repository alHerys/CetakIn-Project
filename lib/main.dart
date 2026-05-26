import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bloc/admin/admin_bloc.dart';
import 'bloc/auth/auth_bloc.dart';
import 'bloc/profile/profile_bloc.dart';
import 'bloc/discovery/discovery_bloc.dart';
import 'bloc/discovery/shop_detail_bloc.dart';
import 'data/repositories/admin_repository.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/profile_repository.dart';
import 'data/repositories/discovery_repository.dart';
import 'data/services/admin/admin_service.dart';
import 'data/services/auth/auth_service.dart';
import 'data/services/dio_client.dart';
import 'data/services/profile/profile_service.dart';
import 'data/services/shop/shop_service.dart';
import 'data/services/discovery/discovery_service.dart';
import 'view/core/colors.dart';
import 'view/pages/login_page.dart';

import 'data/services/order/print_order_service.dart';
import 'data/repositories/print_order_repository.dart';
import 'bloc/order/customer/customer_order_bloc.dart';
import 'bloc/order/partner/partner_order_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  
  final dioClient = DioClient(prefs);
  final authService = AuthService(dioClient);
  final profileService = ProfileService(dioClient);
  final shopService = ShopService(dioClient);
  final discoveryService = DiscoveryService(dioClient);
  final printOrderService = PrintOrderService(dioClient);
  
  final authRepository = AuthRepository(authService, prefs);
  final profileRepository = ProfileRepository(profileService, shopService);
  final discoveryRepository = DiscoveryRepository(discoveryService);
  final printOrderRepository = PrintOrderRepository(printOrderService);
  
  final adminService = AdminService(dioClient);
  final adminRepository = AdminRepository(adminService);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (context) => authRepository,
        ),
        RepositoryProvider<ProfileRepository>(
          create: (context) => profileRepository,
        ),
        RepositoryProvider<AdminRepository>(
          create: (context) => adminRepository,
        ),
        RepositoryProvider<DiscoveryRepository>(
          create: (context) => discoveryRepository,
        ),
        RepositoryProvider<PrintOrderRepository>(
          create: (context) => printOrderRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(authRepository, profileRepository),
          ),
          BlocProvider<ProfileBloc>(
            create: (context) => ProfileBloc(profileRepository),
          ),
          BlocProvider<AdminBloc>(
            create: (context) => AdminBloc(adminRepository),
          ),
          BlocProvider<DiscoveryBloc>(
            create: (context) => DiscoveryBloc(discoveryRepository),
          ),
          BlocProvider<ShopDetailBloc>(
            create: (context) => ShopDetailBloc(discoveryRepository),
          ),
          BlocProvider<CustomerOrderBloc>(
            create: (context) => CustomerOrderBloc(printOrderRepository),
          ),
          BlocProvider<PartnerOrderBloc>(
            create: (context) => PartnerOrderBloc(printOrderRepository),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CetakIn',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
        useMaterial3: true,
        textTheme: GoogleFonts.hankenGroteskTextTheme(),
      ),
      home: const LoginPage(),
    );
  }
}
