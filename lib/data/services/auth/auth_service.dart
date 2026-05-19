import 'package:dio/dio.dart';
import '../../models/auth/auth_response.dart';
import '../../models/auth/user_model.dart';
import '../core/dio_client.dart';

class AuthService {
  final DioClient _dioClient;

  AuthService(this._dioClient);

  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _dioClient.dio.post(
        'auth/login',
        data: {'email': email, 'password': password},
      );

      return AuthResponse.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Login failed';
    }
  }

  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String phone,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        'auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'phone': phone,
        },
      );

      return AuthResponse.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Registration failed';
    }
  }

  Future<AuthResponse> registerPartner({
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
      final Map<String, dynamic> formDataMap = {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'phone': phone,
        'shop_name': shopName,
        'shop_address': shopAddress,
        'shop_phone': shopPhone,
        'open_time': openTime,
        'close_time': closeTime,
      };

      if (shopPhoto != null) {
        formDataMap['shop_photo'] = shopPhoto;
      }

      final formData = FormData.fromMap(formDataMap);
      for (var day in operatingDays) {
        formData.fields.add(MapEntry('operating_days[]', day));
      }

      final response = await _dioClient.dio.post(
        'auth/register/partner',
        data: formData,
      );

      return AuthResponse.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Partner registration failed';
    }
  }

  Future<void> logout() async {
    try {
      await _dioClient.dio.post('auth/logout');
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Logout failed';
    }
  }

  Future<AuthResponse> getMe() async {
    try {
      final response = await _dioClient.dio.get('auth/me');
      return AuthResponse(
        user: UserModel.fromJson(response.data['data']),
        token: '', 
      );
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to get user data';
    }
  }

  Future<UserModel> updateProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    try {
      final response = await _dioClient.dio.put(
        'auth/me',
        data: {
          'name': name,
          'email': email,
          'phone': phone,
        },
      );
      return UserModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to update profile';
    }
  }
}
