import 'shop_model.dart';
import '../auth/user_model.dart';

class ReviewModel {
  final String? id;
  final String? userId;
  final String? shopId;
  final String? orderType;
  final String? printOrderId;
  final String? atkOrderId;
  final int? rating;
  final String? review;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final UserModel? user;
  final ShopModel? shop;

  ReviewModel({
    this.id,
    this.userId,
    this.shopId,
    this.orderType,
    this.printOrderId,
    this.atkOrderId,
    this.rating,
    this.review,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.shop,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      shopId: json['shop_id'] as String?,
      orderType: json['order_type'] as String?,
      printOrderId: json['print_order_id'] as String?,
      atkOrderId: json['atk_order_id'] as String?,
      rating: json['rating'] as int?,
      review: json['review'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      shop: json['shop'] != null ? ShopModel.fromJson(json['shop']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'shop_id': shopId,
      'order_type': orderType,
      'print_order_id': printOrderId,
      'atk_order_id': atkOrderId,
      'rating': rating,
      'review': review,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'user': user?.toJson(),
      'shop': shop?.toJson(),
    };
  }
}
