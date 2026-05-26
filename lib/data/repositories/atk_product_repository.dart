import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../models/atk/atk_product_model.dart';
import '../services/shop/atk_product_service.dart';

class AtkProductRepository {
  final AtkProductService _service;

  AtkProductRepository(this._service);

  Future<Either<String, List<AtkProductModel>>> getProducts() async {
    try {
      final products = await _service.getProducts();
      return Right(products);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, AtkProductModel>> getProduct(String id) async {
    try {
      final product = await _service.getProduct(id);
      return Right(product);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, AtkProductModel>> createProduct({
    required String name,
    required int price,
    required int stock,
    String? description,
    bool? isAvailable,
    MultipartFile? photo,
  }) async {
    try {
      final product = await _service.createProduct(
        name: name,
        price: price,
        stock: stock,
        description: description,
        isAvailable: isAvailable,
        photo: photo,
      );
      return Right(product);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, AtkProductModel>> updateProduct(
    String id, {
    String? name,
    int? price,
    int? stock,
    String? description,
    bool? isAvailable,
    MultipartFile? photo,
  }) async {
    try {
      final product = await _service.updateProduct(
        id,
        name: name,
        price: price,
        stock: stock,
        description: description,
        isAvailable: isAvailable,
        photo: photo,
      );
      return Right(product);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, void>> deleteProduct(String id) async {
    try {
      await _service.deleteProduct(id);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
