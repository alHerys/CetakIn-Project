import '../shop/shop_model.dart';
import '../auth/user_model.dart';
import 'atk_order_item_model.dart';

class AtkOrderModel {
  final String? id;
  final String? userId;
  final String? shopId;
  final int? finalPrice;
  final String? notes;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  final UserModel? user;
  final ShopModel? shop;
  final List<AtkOrderItemModel>? items;

  AtkOrderModel({
    this.id,
    this.userId,
    this.shopId,
    this.finalPrice,
    this.notes,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.shop,
    this.items,
  });

  factory AtkOrderModel.fromJson(Map<String, dynamic> json) {
    return AtkOrderModel(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      shopId: json['shop_id'] as String?,
      finalPrice: json['final_price'] as int?,
      notes: json['notes'] as String?,
      status: json['status'] as String?,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      shop: json['shop'] != null ? ShopModel.fromJson(json['shop']) : null,
      items: json['items'] != null 
          ? (json['items'] as List).map((i) => AtkOrderItemModel.fromJson(i)).toList() 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'shop_id': shopId,
      'final_price': finalPrice,
      'notes': notes,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'user': user?.toJson(),
      'shop': shop?.toJson(),
      'items': items?.map((i) => i.toJson()).toList(),
    };
  }
}
