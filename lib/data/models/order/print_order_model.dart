import '../auth/user_model.dart';
import '../shop/shop_model.dart';

class PrintOrderModel {
  final String id;
  final String userId;
  final String shopId;
  final String fileUrl;
  final String paperSize;
  final String colorMode;
  final String sides;
  final String binding;
  final int copies;
  final int totalPages;
  final int finalPrice;
  final String? notes;
  final String status;
  final String createdAt;
  final UserModel? user;
  final ShopModel? shop;

  PrintOrderModel({
    required this.id,
    required this.userId,
    required this.shopId,
    required this.fileUrl,
    required this.paperSize,
    required this.colorMode,
    required this.sides,
    required this.binding,
    required this.copies,
    required this.totalPages,
    required this.finalPrice,
    this.notes,
    required this.status,
    required this.createdAt,
    this.user,
    this.shop,
  });

  factory PrintOrderModel.fromJson(Map<String, dynamic> json) {
    return PrintOrderModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      shopId: json['shop_id'] as String,
      fileUrl: json['file_url'] as String,
      paperSize: json['paper_size'] as String,
      colorMode: json['color_mode'] as String,
      sides: json['sides'] as String,
      binding: json['binding'] as String,
      copies: json['copies'] is int ? json['copies'] as int : int.parse(json['copies'].toString()),
      totalPages: json['total_pages'] is int ? json['total_pages'] as int : int.parse(json['total_pages'].toString()),
      finalPrice: json['final_price'] is int ? json['final_price'] as int : int.parse(json['final_price'].toString()),
      notes: json['notes'] as String?,
      status: json['status'] as String,
      createdAt: json['created_at'] as String,
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      shop: json['shop'] != null ? ShopModel.fromJson(json['shop']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'shop_id': shopId,
      'file_url': fileUrl,
      'paper_size': paperSize,
      'color_mode': colorMode,
      'sides': sides,
      'binding': binding,
      'copies': copies,
      'total_pages': totalPages,
      'final_price': finalPrice,
      'notes': notes,
      'status': status,
      'created_at': createdAt,
      'user': user?.toJson(),
      'shop': shop?.toJson(),
    };
  }
}
