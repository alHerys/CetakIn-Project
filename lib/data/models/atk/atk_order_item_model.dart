import 'atk_product_model.dart';

class AtkOrderItemModel {
  final String? id;
  final String? atkOrderId;
  final String? atkProductId;
  final String? name;
  final int? quantity;
  final int? unitPrice;
  final int? subtotal;
  
  final AtkProductModel? product;

  AtkOrderItemModel({
    this.id,
    this.atkOrderId,
    this.atkProductId,
    this.name,
    this.quantity,
    this.unitPrice,
    this.subtotal,
    this.product,
  });

  factory AtkOrderItemModel.fromJson(Map<String, dynamic> json) {
    return AtkOrderItemModel(
      id: json['id'] as String?,
      atkOrderId: json['atk_order_id'] as String?,
      atkProductId: json['atk_product_id'] as String?,
      name: json['name'] as String?,
      quantity: json['quantity'] as int?,
      unitPrice: json['unit_price'] as int?,
      subtotal: json['subtotal'] as int?,
      product: json['product'] != null ? AtkProductModel.fromJson(json['product']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'atk_order_id': atkOrderId,
      'atk_product_id': atkProductId,
      'name': name,
      'quantity': quantity,
      'unit_price': unitPrice,
      'subtotal': subtotal,
      'product': product?.toJson(),
    };
  }
}
