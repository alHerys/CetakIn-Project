import '../../data/models/review/review_model.dart';

abstract class SubmitReviewState {}

class SubmitReviewInitial extends SubmitReviewState {}

class SubmitReviewLoading extends SubmitReviewState {}

class SubmitReviewSuccess extends SubmitReviewState {
  final ReviewModel review;
  SubmitReviewSuccess(this.review);
}

class SubmitReviewFailure extends SubmitReviewState {
  final String error;
  SubmitReviewFailure(this.error);
}
