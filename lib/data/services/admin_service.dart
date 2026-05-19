import 'package:dio/dio.dart';
import '../models/shop/shop_model.dart';
import 'dio_client.dart';

class AdminService {
  final DioClient _dioClient;

  AdminService(this._dioClient);

  Future<List<ShopModel>> getPartners({String? status}) async {
    try {
      final response = await _dioClient.dio.get(
        'admin/partners',
        queryParameters: status != null ? {'status': status} : null,
      );
      
      final List data = response.data['data'];
      return data.map((json) => ShopModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to get partners';
    }
  }

  Future<ShopModel> approvePartner(String id) async {
    try {
      final response = await _dioClient.dio.patch('admin/partners/$id/approve');
      return ShopModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to approve partner';
    }
  }

  Future<ShopModel> rejectPartner(String id, String reason) async {
    try {
      final response = await _dioClient.dio.patch(
        'admin/partners/$id/reject',
        data: {'reason': reason},
      );
      return ShopModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to reject partner';
    }
  }
}
