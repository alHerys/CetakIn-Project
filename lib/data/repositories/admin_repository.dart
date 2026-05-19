import 'package:dartz/dartz.dart';
import '../models/shop/shop_model.dart';
import '../services/admin_service.dart';

class AdminRepository {
  final AdminService _adminService;

  AdminRepository(this._adminService);

  Future<Either<String, List<ShopModel>>> getPartners({String? status}) async {
    try {
      final partners = await _adminService.getPartners(status: status);
      return Right(partners);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, ShopModel>> approvePartner(String id) async {
    try {
      final shop = await _adminService.approvePartner(id);
      return Right(shop);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, ShopModel>> rejectPartner(String id, String reason) async {
    try {
      final shop = await _adminService.rejectPartner(id, reason);
      return Right(shop);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
