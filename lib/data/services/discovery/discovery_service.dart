import 'package:dio/dio.dart';
import '../../models/shop/shop_model.dart';
import '../dio_client.dart';

class DiscoveryService {
  final DioClient _dioClient;

  DiscoveryService(this._dioClient);
  
  Future<List<ShopModel>> searchShops({
    required double lat,
    required double lng,
    double radius = 10,
    double? minRating,
  }) async {
    try {
      final queryParams = {
        'lat': lat,
        'lng': lng,
        'radius': radius,
      };
      
      if (minRating != null) {
        queryParams['min_rating'] = minRating;
      }

      final response = await _dioClient.dio.get(
        'shops',
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data['data']; // Laravel pagination
      return data.map((json) => ShopModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to search shops';
    }
  }

  Future<ShopModel> getShopDetail(String id) async {
    try {
      final response = await _dioClient.dio.get('shops/$id');
      return ShopModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to get shop details';
    }
  }
}
