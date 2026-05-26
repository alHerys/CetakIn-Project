abstract class SubmitReviewEvent {}

class SubmitReviewRequested extends SubmitReviewEvent {
  final String orderId;
  final String orderType; // 'print' or 'atk'
  final int rating;
  final String? comment;

  SubmitReviewRequested({
    required this.orderId,
    required this.orderType,
    required this.rating,
    this.comment,
  });
}
