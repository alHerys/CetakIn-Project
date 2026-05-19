class AtkOrderStatusHistoryModel {
  final String? id;
  final String? orderId;
  final String? status;
  final DateTime? createdAt;

  AtkOrderStatusHistoryModel({
    this.id,
    this.orderId,
    this.status,
    this.createdAt,
  });

  factory AtkOrderStatusHistoryModel.fromJson(Map<String, dynamic> json) {
    return AtkOrderStatusHistoryModel(
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
