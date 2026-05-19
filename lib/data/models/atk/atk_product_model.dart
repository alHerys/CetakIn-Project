import '../shop/shop_model.dart';

class AtkProductModel {
  final String? id;
  final String? shopId;
  final String? name;
  final String? description;
  final int? price;
  final int? stock;
  final String? photoUrl;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  final ShopModel? shop;

  AtkProductModel({
    this.id,
    this.shopId,
    this.name,
    this.description,
    this.price,
    this.stock,
    this.photoUrl,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.shop,
  });

  factory AtkProductModel.fromJson(Map<String, dynamic> json) {
    return AtkProductModel(
      id: json['id'] as String?,
      shopId: json['shop_id'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      price: json['price'] as int?,
      stock: json['stock'] as int?,
      photoUrl: json['photo_url'] as String?,
      isActive: json['is_active'] == 1 || json['is_active'] == true, // Handle tinyint boolean
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
      shop: json['shop'] != null ? ShopModel.fromJson(json['shop']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop_id': shopId,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'photo_url': photoUrl,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'shop': shop?.toJson(),
    };
  }
}
