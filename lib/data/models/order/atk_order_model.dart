import '../shop/shop_model.dart';
import '../auth/user_model.dart';
import '../atk/atk_product_model.dart';

class AtkOrderItemModel {
  final String? id;
  final String? atkOrderId;
  final String? atkProductId;
  final String name;
  final int unitPrice;
  final int quantity;
  final int subtotal;
  final AtkProductModel? product;

  AtkOrderItemModel({
    this.id,
    this.atkOrderId,
    this.atkProductId,
    required this.name,
    required this.unitPrice,
    required this.quantity,
    required this.subtotal,
    this.product,
  });

  factory AtkOrderItemModel.fromJson(Map<String, dynamic> json) {
    return AtkOrderItemModel(
      id: json['id'] as String?,
      atkOrderId: json['atk_order_id'] as String?,
      atkProductId: json['atk_product_id'] as String?,
      name: json['name']?.toString() ?? '',
      unitPrice: json['unit_price'] != null ? int.tryParse(json['unit_price'].toString()) ?? 0 : 0,
      quantity: json['quantity'] != null ? int.tryParse(json['quantity'].toString()) ?? 1 : 1,
      subtotal: json['subtotal'] != null ? int.tryParse(json['subtotal'].toString()) ?? 0 : 0,
      product: json['product'] != null ? AtkProductModel.fromJson(json['product'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'atk_order_id': atkOrderId,
    'atk_product_id': atkProductId,
    'name': name,
    'unit_price': unitPrice,
    'quantity': quantity,
    'subtotal': subtotal,
    'product': product?.toJson(),
  };
}

class AtkOrderModel {
  final String id;
  final String userId;
  final String shopId;
  final int finalPrice;
  final String? notes;
  final String status;
  final String createdAt;
  final ShopModel? shop;
  final UserModel? user;
  final List<AtkOrderItemModel>? items;

  AtkOrderModel({
    required this.id,
    required this.userId,
    required this.shopId,
    required this.finalPrice,
    this.notes,
    required this.status,
    required this.createdAt,
    this.shop,
    this.user,
    this.items,
  });

  factory AtkOrderModel.fromJson(Map<String, dynamic> json) {
    return AtkOrderModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      shopId: json['shop_id'] as String,
      finalPrice: json['final_price'] != null ? int.tryParse(json['final_price'].toString()) ?? 0 : 0,
      notes: json['notes'] as String?,
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['created_at']?.toString() ?? '',
      shop: json['shop'] != null ? ShopModel.fromJson(json['shop'] as Map<String, dynamic>) : null,
      user: json['user'] != null ? UserModel.fromJson(json['user'] as Map<String, dynamic>) : null,
      items: json['items'] != null
          ? (json['items'] as List).map((e) => AtkOrderItemModel.fromJson(e as Map<String, dynamic>)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'shop_id': shopId,
    'final_price': finalPrice,
    'notes': notes,
    'status': status,
    'created_at': createdAt,
    'shop': shop?.toJson(),
    'user': user?.toJson(),
    'items': items?.map((e) => e.toJson()).toList(),
  };
}
