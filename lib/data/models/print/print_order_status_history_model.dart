class PrintOrderStatusHistoryModel {
  final String? id;
  final String? orderId;
  final String? status;
  final DateTime? createdAt;

  const PrintOrderStatusHistoryModel({
    this.id,
    this.orderId,
    this.status,
    this.createdAt,
  });

  factory PrintOrderStatusHistoryModel.fromJson(Map<String, dynamic> json) {
    return PrintOrderStatusHistoryModel(
      id: json['id'] as String?,
      orderId: json['order_id'] as String?,
      status: json['status'] as String?,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
