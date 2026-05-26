import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/review_repository.dart';
import 'shop_reviews_event.dart';
import 'shop_reviews_state.dart';

class ShopReviewsBloc extends Bloc<ShopReviewsEvent, ShopReviewsState> {
  final ReviewRepository reviewRepository;

  ShopReviewsBloc({required this.reviewRepository}) : super(ShopReviewsInitial()) {
    on<ShopReviewsLoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(ShopReviewsLoadRequested event, Emitter<ShopReviewsState> emit) async {
    emit(ShopReviewsLoading());
    final result = await reviewRepository.getShopReviews(event.shopId);
    result.fold(
      (error) => emit(ShopReviewsFailure(error)),
      (reviews) => emit(ShopReviewsLoaded(reviews)),
    );
  }
}
