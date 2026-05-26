import '../../../data/models/atk/atk_product_model.dart';
import '../../../data/models/shop/shop_model.dart';

abstract class AtkCartEvent {}

class AtkCartAddItemRequested extends AtkCartEvent {
  final AtkProductModel product;
  final ShopModel shop;
  final int quantity;

  AtkCartAddItemRequested({
    required this.product,
    required this.shop,
    this.quantity = 1,
  });
}

class AtkCartUpdateItemQuantityRequested extends AtkCartEvent {
  final String productId;
  final int newQuantity;

  AtkCartUpdateItemQuantityRequested(this.productId, this.newQuantity);
}

class AtkCartRemoveItemRequested extends AtkCartEvent {
  final String productId;

  AtkCartRemoveItemRequested(this.productId);
}

class AtkCartClearRequested extends AtkCartEvent {}
