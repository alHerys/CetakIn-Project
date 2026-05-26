import 'package:dio/dio.dart';
import '../../models/shop/shop_model.dart';
import '../../models/shop/shop_pricing_model.dart';
import '../../models/shop/shop_service_model.dart';
import '../dio_client.dart';

class ShopService {
  final DioClient _dioClient;

  ShopService(this._dioClient);

  Future<ShopModel> getMyShop() async {
    try {
      final response = await _dioClient.dio.get('shops/me');
      final responseData = response.data['data'] as Map<String, dynamic>;
      
      if (responseData['service'] != null) {
        responseData['shop_service'] = responseData['service'];
      }
      if (responseData['pricing'] != null) {
        responseData['shop_pricing'] = responseData['pricing'];
      }
      
      return ShopModel.fromJson(responseData);
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to get shop info';
    }
  }

  Future<ShopModel> updateShop({
    String? shopName,
    String? shopAddress,
    String? shopPhone,
    String? shopDescription,
    double? latitude,
    double? longitude,
    String? openTime,
    String? closeTime,
    List<String>? operatingDays,
    MultipartFile? shopPhoto,
  }) async {
    try {
      Response response;

      if (shopPhoto != null) {
        // Use POST with _method=PUT for multipart/form-data in Laravel
        final Map<String, dynamic> mapData = {
          '_method': 'PUT',
          'shop_photo': shopPhoto,
        };
        if (shopName != null) mapData['shop_name'] = shopName;
        if (shopAddress != null) mapData['shop_address'] = shopAddress;
        if (shopPhone != null) mapData['shop_phone'] = shopPhone;
        if (shopDescription != null) mapData['shop_description'] = shopDescription;
        if (latitude != null) mapData['latitude'] = latitude;
        if (longitude != null) mapData['longitude'] = longitude;
        if (openTime != null) mapData['open_time'] = openTime;
        if (closeTime != null) mapData['close_time'] = closeTime;
        if (operatingDays != null) mapData['operating_days'] = operatingDays;

        final formData = FormData.fromMap(mapData, ListFormat.multiCompatible);

        response = await _dioClient.dio.post(
          'shops/me',
          data: formData,
        );
      } else {
        // Use regular PUT with JSON for updates without files
        final data = <String, dynamic>{};
        if (shopName != null) data['shop_name'] = shopName;
        if (shopAddress != null) data['shop_address'] = shopAddress;
        if (shopPhone != null) data['shop_phone'] = shopPhone;
        if (shopDescription != null) data['shop_description'] = shopDescription;
        if (latitude != null) data['latitude'] = latitude;
        if (longitude != null) data['longitude'] = longitude;
        if (openTime != null) data['open_time'] = openTime;
        if (closeTime != null) data['close_time'] = closeTime;
        if (operatingDays != null) data['operating_days'] = operatingDays;
        
        response = await _dioClient.dio.put(
          'shops/me',
          data: data,
        );
      }

      final responseData = response.data['data'] as Map<String, dynamic>;
      
      // Map relations so ShopModel can parse them
      if (responseData['service'] != null) {
        responseData['shop_service'] = responseData['service'];
      }
      if (responseData['pricing'] != null) {
        responseData['shop_pricing'] = responseData['pricing'];
      }
      
      return ShopModel.fromJson(responseData);
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to update shop info';
    }
  }
  Future<ShopServiceModel> updateShopServices({
    required List<String> paperSizes,
    required List<String> colorModes,
    required List<String> sides,
    required List<String> bindings,
  }) async {
    try {
      final response = await _dioClient.dio.put(
        'shops/me/services',
        data: {
          'paper_sizes': paperSizes,
          'color_modes': colorModes,
          'sides': sides,
          'bindings': bindings,
        },
      );
      return ShopServiceModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to update shop services';
    }
  }

  Future<ShopPricingModel> updateShopPricing({
    required int blackAndWhitePerPage,
    required int fullColorPerPage,
    required int doubleSideSurcharge,
    required Map<String, int> bindingPrices,
  }) async {
    try {
      final response = await _dioClient.dio.put(
        'shops/me/pricing',
        data: {
          'black_and_white_per_page': blackAndWhitePerPage,
          'full_color_per_page': fullColorPerPage,
          'double_side_surcharge': doubleSideSurcharge,
          'binding_prices': bindingPrices,
        },
      );
      return ShopPricingModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to update shop pricing';
    }
  }
}
