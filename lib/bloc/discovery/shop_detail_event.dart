abstract class ShopDetailEvent {}

class ShopDetailLoadRequested extends ShopDetailEvent {
  final String shopId;

  ShopDetailLoadRequested(this.shopId);
}
