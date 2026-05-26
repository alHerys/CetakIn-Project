import '../atk/atk_product_model.dart';

class AtkOrderItemModel {
  final String id;
  final String atkOrderId;
  final String atkProductId;
  final String name;
  final int quantity;
  final int unitPrice;
  final int subtotal;
  final AtkProductModel? product;

  const AtkOrderItemModel({
    required this.id,
    required this.atkOrderId,
    required this.atkProductId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    this.product,
  });

  factory AtkOrderItemModel.fromJson(Map<String, dynamic> json) {
    return AtkOrderItemModel(
      id: json['id'] ?? '',
      atkOrderId: json['atk_order_id'] ?? '',
      atkProductId: json['atk_product_id'] ?? '',
      name: json['name'] ?? '',
      quantity: json['quantity'] != null ? int.parse(json['quantity'].toString()) : 0,
      unitPrice: json['unit_price'] != null ? int.parse(json['unit_price'].toString()) : 0,
      subtotal: json['subtotal'] != null ? int.parse(json['subtotal'].toString()) : 0,
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
      if (product != null) 'product': product!.toJson(),
    };
  }
}
