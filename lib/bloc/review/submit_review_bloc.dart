import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/review_repository.dart';
import 'submit_review_event.dart';
import 'submit_review_state.dart';

class SubmitReviewBloc extends Bloc<SubmitReviewEvent, SubmitReviewState> {
  final ReviewRepository reviewRepository;

  SubmitReviewBloc({required this.reviewRepository}) : super(SubmitReviewInitial()) {
    on<SubmitReviewRequested>(_onSubmitReviewRequested);
  }

  Future<void> _onSubmitReviewRequested(SubmitReviewRequested event, Emitter<SubmitReviewState> emit) async {
    emit(SubmitReviewLoading());
    
    final result = event.orderType == 'atk' 
      ? await reviewRepository.submitAtkReview(orderId: event.orderId, rating: event.rating, comment: event.comment)
      : await reviewRepository.submitPrintReview(orderId: event.orderId, rating: event.rating, comment: event.comment);
      
    result.fold(
      (error) => emit(SubmitReviewFailure(error)),
      (review) => emit(SubmitReviewSuccess(review)),
    );
  }
}
