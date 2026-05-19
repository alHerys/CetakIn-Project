import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bloc/admin/admin_bloc.dart';
import 'bloc/auth/auth_bloc.dart';
import 'data/repositories/admin_repository.dart';
import 'data/repositories/auth_repository.dart';
import 'data/services/admin/admin_service.dart';
import 'data/services/auth/auth_service.dart';
import 'data/services/shop/shop_service.dart';
import 'data/services/core/dio_client.dart';
import 'view/core/colors.dart';
import 'view/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  
  final dioClient = DioClient(prefs);
  final authService = AuthService(dioClient);
  final shopService = ShopService(dioClient);
  final authRepository = AuthRepository(authService, shopService, prefs);
  
  final adminService = AdminService(dioClient);
  final adminRepository = AdminRepository(adminService);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (context) => authRepository,
        ),
        RepositoryProvider<AdminRepository>(
          create: (context) => adminRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(authRepository),
          ),
          BlocProvider<AdminBloc>(
            create: (context) => AdminBloc(adminRepository),
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
        useMaterial3: true,
        textTheme: GoogleFonts.hankenGroteskTextTheme(),
      ),
      home: const LoginPage(),
    );
  }
}
