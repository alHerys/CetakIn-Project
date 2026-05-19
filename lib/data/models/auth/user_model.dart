import '../shop/shop_model.dart';

class UserModel {
  final String? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? role;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final ShopModel? shop; // Relasi ke entitas Shop

  UserModel({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.role,
    this.createdAt,
    this.updatedAt,
    this.shop,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      role: json['role'] as String?,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
      shop: json['shop'] != null ? ShopModel.fromJson(json['shop']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'shop': shop?.toJson(),
    };
  }
}
