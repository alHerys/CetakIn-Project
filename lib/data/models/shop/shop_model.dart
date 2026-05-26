import 'shop_pricing_model.dart';
import 'shop_service_model.dart';
import '../auth/user_model.dart';

class ShopModel {
  final String? id;
  final String? userId;
  final String? shopName;
  final String? shopAddress;
  final String? shopPhone;
  final String? shopDescription;
  final String? shopPhotoUrl;
  final String? openTime;
  final String? closeTime;
  final List<String>? operatingDays;
  final String? status;
  final String? rejectionReason;
  final double? averageRating;
  final int? totalReviews;
  final double? latitude;
  final double? longitude;
  final double? distanceKm;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Relasi opsional
  final ShopServiceModel? shopService;
  final ShopPricingModel? shopPricing;
  final UserModel? user;

  const ShopModel({
    this.id,
    this.userId,
    this.shopName,
    this.shopAddress,
    this.shopPhone,
    this.shopDescription,
    this.shopPhotoUrl,
    this.openTime,
    this.closeTime,
    this.operatingDays,
    this.status,
    this.rejectionReason,
    this.averageRating,
    this.totalReviews,
    this.latitude,
    this.longitude,
    this.distanceKm,
    this.createdAt,
    this.updatedAt,
    this.shopService,
    this.shopPricing,
    this.user,
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      shopName: json['shop_name'] as String?,
      shopAddress: json['shop_address'] as String?,
      shopPhone: json['shop_phone'] as String?,
      shopDescription: json['shop_description'] as String?,
      shopPhotoUrl: json['shop_photo_url'] as String?,
      openTime: json['open_time'] as String?,
      closeTime: json['close_time'] as String?,
      operatingDays: (json['operating_days'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      status: json['status'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      averageRating: json['average_rating'] != null
          ? double.tryParse(json['average_rating'].toString())
          : null,
      totalReviews: json['total_reviews'] as int?,
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      distanceKm: json['distance_km'] != null
          ? double.tryParse(json['distance_km'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      shopService: json['shop_service'] != null
          ? ShopServiceModel.fromJson(json['shop_service'])
          : null,
      shopPricing: json['shop_pricing'] != null
          ? ShopPricingModel.fromJson(json['shop_pricing'])
          : null,
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'shop_name': shopName,
      'shop_address': shopAddress,
      'shop_phone': shopPhone,
      'shop_description': shopDescription,
      'shop_photo_url': shopPhotoUrl,
      'open_time': openTime,
      'close_time': closeTime,
      'operating_days': operatingDays,
      'status': status,
      'rejection_reason': rejectionReason,
      'average_rating': averageRating,
      'total_reviews': totalReviews,
      'latitude': latitude,
      'longitude': longitude,
      'distance_km': distanceKm,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'shop_service': shopService?.toJson(),
      'shop_pricing': shopPricing?.toJson(),
      'user': user?.toJson(),
    };
  }
}
