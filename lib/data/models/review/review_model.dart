import '../auth/user_model.dart';

class ReviewModel {
  final String id;
  final String userId;
  final String shopId;
  final String orderType;
  final String? printOrderId;
  final String? atkOrderId;
  final int rating;
  final String? comment;
  final String createdAt;
  final UserModel? user;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.shopId,
    required this.orderType,
    this.printOrderId,
    this.atkOrderId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.user,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      shopId: json['shop_id'] as String,
      orderType: json['order_type'] as String,
      printOrderId: json['print_order_id'] as String?,
      atkOrderId: json['atk_order_id'] as String?,
      rating: json['rating'] is int ? json['rating'] as int : int.parse(json['rating'].toString()),
      comment: json['comment'] as String?,
      createdAt: json['created_at'] != null ? json['created_at'] as String : DateTime.now().toIso8601String(),
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'shop_id': shopId,
      'order_type': orderType,
      'print_order_id': printOrderId,
      'atk_order_id': atkOrderId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt,
      'user': user?.toJson(),
    };
  }
}
