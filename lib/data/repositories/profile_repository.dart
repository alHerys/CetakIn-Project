import 'package:dartz/dartz.dart';
import '../models/auth/user_model.dart';
import '../models/shop/shop_model.dart';
import '../models/shop/shop_pricing_model.dart';
import '../models/shop/shop_service_model.dart';
import '../services/profile/profile_service.dart';
import '../services/shop/shop_service.dart';
import 'package:dio/dio.dart';

class ProfileRepository {
  final ProfileService _profileService;
  final ShopService _shopService;

  ProfileRepository(this._profileService, this._shopService);

  Future<Either<String, UserModel>> getMe() async {
    try {
      final user = await _profileService.getMe();
      return Right(user);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, ShopModel>> getMyShop() async {
    try {
      final shop = await _shopService.getMyShop();
      return Right(shop);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, UserModel>> updateProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    try {
      final user = await _profileService.updateProfile(name: name, email: email, phone: phone);
      return Right(user);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, UserModel>> updateAvatar(dynamic avatar) async {
    try {
      final user = await _profileService.updateAvatar(avatar);
      return Right(user);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, ShopModel>> updateShop({
    String? shopName,
    String? shopAddress,
    String? shopPhone,
    String? shopDescription,
    double? latitude,
    double? longitude,
    String? openTime,
    String? closeTime,
    List<String>? operatingDays,
    dynamic shopPhoto,
  }) async {
    try {
      MultipartFile? file;
      if (shopPhoto is String) {
        file = await MultipartFile.fromFile(shopPhoto);
      } else if (shopPhoto is MultipartFile) {
        file = shopPhoto;
      }

      final shop = await _shopService.updateShop(
        shopName: shopName,
        shopAddress: shopAddress,
        shopPhone: shopPhone,
        shopDescription: shopDescription,
        latitude: latitude,
        longitude: longitude,
        openTime: openTime,
        closeTime: closeTime,
        operatingDays: operatingDays,
        shopPhoto: file,
      );
      return Right(shop);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, ShopServiceModel>> updateShopServices({
    required List<String> paperSizes,
    required List<String> colorModes,
    required List<String> sides,
    required List<String> bindings,
  }) async {
    try {
      final services = await _shopService.updateShopServices(
        paperSizes: paperSizes,
        colorModes: colorModes,
        sides: sides,
        bindings: bindings,
      );
      return Right(services);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, ShopPricingModel>> updateShopPricing({
    required int blackAndWhitePerPage,
    required int fullColorPerPage,
    required int doubleSideSurcharge,
    required Map<String, int> bindingPrices,
  }) async {
    try {
      final pricing = await _shopService.updateShopPricing(
        blackAndWhitePerPage: blackAndWhitePerPage,
        fullColorPerPage: fullColorPerPage,
        doubleSideSurcharge: doubleSideSurcharge,
        bindingPrices: bindingPrices,
      );
      return Right(pricing);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
