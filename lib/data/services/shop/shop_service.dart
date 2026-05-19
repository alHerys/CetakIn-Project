import 'package:dio/dio.dart';
import '../../models/shop/shop_model.dart';
import '../dio_client.dart';

class ShopService {
  final DioClient _dioClient;

  ShopService(this._dioClient);

  Future<ShopModel> getMyShop() async {
    try {
      final response = await _dioClient.dio.get('shops/me');
      return ShopModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to get shop info';
    }
  }

  Future<ShopModel> updateShop({
    String? shopName,
    String? shopAddress,
    String? shopPhone,
    String? shopDescription,
  }) async {
    try {
      final response = await _dioClient.dio.put(
        'shops/me',
        data: {
          'shop_name': shopName,
          'shop_address': shopAddress,
          'shop_phone': shopPhone,
          'shop_description': shopDescription,
        },
      );
      return ShopModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to update shop info';
    }
  }
}
