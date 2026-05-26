abstract class ShopReviewsEvent {}

class ShopReviewsLoadRequested extends ShopReviewsEvent {
  final String shopId;
  ShopReviewsLoadRequested(this.shopId);
}
