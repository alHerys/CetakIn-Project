import 'package:dartz/dartz.dart';
import '../models/shop/shop_model.dart';
import '../services/discovery/discovery_service.dart';

class DiscoveryRepository {
  final DiscoveryService _discoveryService;

  DiscoveryRepository(this._discoveryService);

  Future<Either<String, List<ShopModel>>> searchShops({
    required double lat,
    required double lng,
    double radius = 10,
    double? minRating,
  }) async {
    try {
      final shops = await _discoveryService.searchShops(
        lat: lat,
        lng: lng,
        radius: radius,
        minRating: minRating,
      );
      return Right(shops);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, ShopModel>> getShopDetail(String id) async {
    try {
      final shop = await _discoveryService.getShopDetail(id);
      return Right(shop);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
