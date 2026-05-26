import 'package:dio/dio.dart';
import '../../models/auth/user_model.dart';
import '../dio_client.dart';

class ProfileService {
  final DioClient _dioClient;

  const ProfileService(this._dioClient);

  Future<UserModel> getMe() async {
    try {
      final response = await _dioClient.dio.get('auth/me');
      return UserModel.fromJson(response.data['data']);
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

  Future<UserModel> updateAvatar(dynamic avatar) async {
    try {
      final formData = FormData.fromMap({
        'avatar': avatar,
      });

      final response = await _dioClient.dio.post(
        'auth/me/avatar',
        data: formData,
      );

      return UserModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to update avatar';
    }
  }
}
