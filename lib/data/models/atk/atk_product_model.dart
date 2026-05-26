import '../shop/shop_model.dart';

class AtkProductModel {
  final String? id;
  final String? shopId;
  final String? name;
  final String? description;
  final int? price;
  final int? stock;
  final String? photoUrl;
  final bool? isAvailable;
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
    this.isAvailable,
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
      price: json['price'] != null ? int.tryParse(json['price'].toString()) : null,
      stock: json['stock'] != null ? int.tryParse(json['stock'].toString()) : null,
      photoUrl: json['photo_url'] as String?,
      isAvailable: json['is_available'] == 1 || json['is_available'] == true || json['is_available'] == '1',
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
      'is_available': isAvailable,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'shop': shop?.toJson(),
    };
  }
}
