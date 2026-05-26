import '../../../data/models/atk/atk_product_model.dart';
import '../../../data/models/shop/shop_model.dart';

class CartItem {
  final AtkProductModel product;
  final int quantity;

  CartItem({required this.product, required this.quantity});
  
  int get subtotal => (product.price ?? 0) * quantity;
}

abstract class AtkCartState {}

class AtkCartInitial extends AtkCartState {}

class AtkCartUpdated extends AtkCartState {
  final ShopModel? currentShop;
  final List<CartItem> items;
  final int totalAmount;

  AtkCartUpdated({
    required this.currentShop,
    required this.items,
    required this.totalAmount,
  });
}

class AtkCartConflict extends AtkCartState {
  final ShopModel existingShop;
  final ShopModel newShop;
  final AtkProductModel newProduct;
  final int newQuantity;

  AtkCartConflict({
    required this.existingShop,
    required this.newShop,
    required this.newProduct,
    required this.newQuantity,
  });
}
