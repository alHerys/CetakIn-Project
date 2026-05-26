import 'package:dio/dio.dart';
import '../../models/atk/atk_product_model.dart';
import '../dio_client.dart';

class AtkProductService {
  final DioClient _dioClient;

  AtkProductService(this._dioClient);

  Future<List<AtkProductModel>> getProducts() async {
    try {
      final response = await _dioClient.dio.get('shops/me/atk');
      final data = response.data['data'] as List;
      return data.map((json) => AtkProductModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Gagal mengambil data produk ATK';
    }
  }

  Future<AtkProductModel> getProduct(String id) async {
    try {
      final response = await _dioClient.dio.get('shops/me/atk/$id');
      final data = response.data['data'] as Map<String, dynamic>;
      return AtkProductModel.fromJson(data);
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Gagal mengambil detail produk ATK';
    }
  }

  Future<AtkProductModel> createProduct({
    required String name,
    required int price,
    required int stock,
    String? description,
    bool? isAvailable,
    MultipartFile? photo,
  }) async {
    try {
      final Map<String, dynamic> mapData = {
        'name': name,
        'price': price,
        'stock': stock,
      };
      
      if (description != null) mapData['description'] = description;
      if (isAvailable != null) mapData['is_available'] = isAvailable ? 1 : 0;
      if (photo != null) mapData['photo'] = photo;

      final formData = FormData.fromMap(mapData, ListFormat.multiCompatible);

      final response = await _dioClient.dio.post(
        'shops/me/atk',
        data: formData,
      );

      final data = response.data['data'] as Map<String, dynamic>;
      return AtkProductModel.fromJson(data);
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Gagal menambahkan produk ATK';
    }
  }

  Future<AtkProductModel> updateProduct(
    String id, {
    String? name,
    int? price,
    int? stock,
    String? description,
    bool? isAvailable,
    MultipartFile? photo,
  }) async {
    try {
      Response response;
      if (photo != null) {
        // Use POST with _method=PUT for multipart/form-data
        final Map<String, dynamic> mapData = {
          '_method': 'PUT',
        };
        if (name != null) mapData['name'] = name;
        if (price != null) mapData['price'] = price;
        if (stock != null) mapData['stock'] = stock;
        if (description != null) mapData['description'] = description;
        if (isAvailable != null) mapData['is_available'] = isAvailable ? 1 : 0;
        mapData['photo'] = photo;

        final formData = FormData.fromMap(mapData, ListFormat.multiCompatible);

        response = await _dioClient.dio.post(
          'shops/me/atk/$id',
          data: formData,
        );
      } else {
        // Use regular PUT with JSON
        final Map<String, dynamic> data = {};
        if (name != null) data['name'] = name;
        if (price != null) data['price'] = price;
        if (stock != null) data['stock'] = stock;
        if (description != null) data['description'] = description;
        if (isAvailable != null) data['is_available'] = isAvailable ? 1 : 0;

        response = await _dioClient.dio.put(
          'shops/me/atk/$id',
          data: data,
        );
      }

      final responseData = response.data['data'] as Map<String, dynamic>;
      return AtkProductModel.fromJson(responseData);
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Gagal memperbarui produk ATK';
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _dioClient.dio.delete('shops/me/atk/$id');
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Gagal menghapus produk ATK';
    }
  }
}
