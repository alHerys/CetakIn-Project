import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth/auth_response.dart';
import '../models/auth/user_model.dart';
import '../models/shop/shop_model.dart';
import '../services/auth/auth_service.dart';
import '../services/shop/shop_service.dart';

class AuthRepository {
  final AuthService _authService;
  final ShopService _shopService;
  final SharedPreferences _prefs;

  AuthRepository(this._authService, this._shopService, this._prefs);

  Future<Either<String, AuthResponse>> login(String email, String password) async {
    try {
      final response = await _authService.login(email, password);
      await _saveToken(response.token);
      return Right(response);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, AuthResponse>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String phone,
  }) async {
    try {
      final response = await _authService.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        phone: phone,
      );
      await _saveToken(response.token);
      return Right(response);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, AuthResponse>> registerPartner({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String phone,
    required String shopName,
    required String shopAddress,
    required String shopPhone,
    required String openTime,
    required String closeTime,
    required List<String> operatingDays,
    dynamic shopPhoto,
  }) async {
    try {
      final response = await _authService.registerPartner(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        phone: phone,
        shopName: shopName,
        shopAddress: shopAddress,
        shopPhone: shopPhone,
        openTime: openTime,
        closeTime: closeTime,
        operatingDays: operatingDays,
        shopPhoto: shopPhoto,
      );
      await _saveToken(response.token);
      return Right(response);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, void>> logout() async {
    try {
      await _authService.logout();
      await _clearToken();
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, UserModel>> getMe() async {
    try {
      final response = await _authService.getMe();
      var user = response.user;
      
      if (user.role == 'partner') {
        final shop = await _shopService.getMyShop();
        user = user.copyWith(shop: shop);
      }
      
      return Right(user);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, UserModel>> updateProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    try {
      final user = await _authService.updateProfile(name: name, email: email, phone: phone);
      return Right(user);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, ShopModel>> updateShop({
    String? shopName,
    String? shopAddress,
    String? shopPhone,
    String? shopDescription,
  }) async {
    try {
      final shop = await _shopService.updateShop(
        shopName: shopName,
        shopAddress: shopAddress,
        shopPhone: shopPhone,
        shopDescription: shopDescription,
      );
      return Right(shop);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<void> _saveToken(String token) async {
    await _prefs.setString('auth_token', token);
  }

  Future<void> _clearToken() async {
    await _prefs.remove('auth_token');
  }

  Future<String?> getToken() async {
    return _prefs.getString('auth_token');
  }
}
