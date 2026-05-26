import '../../data/models/review/review_model.dart';

abstract class ShopReviewsState {}

class ShopReviewsInitial extends ShopReviewsState {}

class ShopReviewsLoading extends ShopReviewsState {}

class ShopReviewsLoaded extends ShopReviewsState {
  final List<ReviewModel> reviews;
  ShopReviewsLoaded(this.reviews);
}

class ShopReviewsFailure extends ShopReviewsState {
  final String error;
  ShopReviewsFailure(this.error);
}
