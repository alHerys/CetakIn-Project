import '../shop/shop_model.dart';
import '../auth/user_model.dart';

class PrintOrderModel {
  final String? id;
  final String? userId;
  final String? shopId;
  final String? fileUrl;
  final String? fileName;
  final int? pages;
  final String? colorMode;
  final String? paperSize;
  final String? side;
  final String? binding;
  final int? copies;
  final String? notes;
  final int? totalPrice;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  final UserModel? user;
  final ShopModel? shop;

  const PrintOrderModel({
    this.id,
    this.userId,
    this.shopId,
    this.fileUrl,
    this.fileName,
    this.pages,
    this.colorMode,
    this.paperSize,
    this.side,
    this.binding,
    this.copies,
    this.notes,
    this.totalPrice,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.shop,
  });

  factory PrintOrderModel.fromJson(Map<String, dynamic> json) {
    return PrintOrderModel(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      shopId: json['shop_id'] as String?,
      fileUrl: json['file_url'] as String?,
      fileName: json['file_name'] as String?,
      pages: json['pages'] as int?,
      colorMode: json['color_mode'] as String?,
      paperSize: json['paper_size'] as String?,
      side: json['side'] as String?,
      binding: json['binding'] as String?,
      copies: json['copies'] as int?,
      notes: json['notes'] as String?,
      totalPrice: json['total_price'] as int?,
      status: json['status'] as String?,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
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
      'file_name': fileName,
      'pages': pages,
      'color_mode': colorMode,
      'paper_size': paperSize,
      'side': side,
      'binding': binding,
      'copies': copies,
      'notes': notes,
      'total_price': totalPrice,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'user': user?.toJson(),
      'shop': shop?.toJson(),
    };
  }
}
