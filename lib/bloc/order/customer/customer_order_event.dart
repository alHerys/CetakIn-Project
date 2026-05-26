import 'customer_order_state.dart';

abstract class CustomerOrderEvent {}

class CustomerOrderLoadHistoryRequested extends CustomerOrderEvent {
  final String? status;
  CustomerOrderLoadHistoryRequested({this.status});
}

class CustomerOrderFilterChanged extends CustomerOrderEvent {
  final CustomerOrderFilter filterMode;
  CustomerOrderFilterChanged(this.filterMode);
}

class CustomerOrderCreateRequested extends CustomerOrderEvent {
  final String shopId;
  final String filePath;
  final String paperSize;
  final String colorMode;
  final String sides;
  final String binding;
  final int copies;
  final int totalPages;
  final String? notes;

  CustomerOrderCreateRequested({
    required this.shopId,
    required this.filePath,
    required this.paperSize,
    required this.colorMode,
    required this.sides,
    required this.binding,
    required this.copies,
    required this.totalPages,
    this.notes,
  });
}

class CustomerOrderCancelRequested extends CustomerOrderEvent {
  final String orderId;
  CustomerOrderCancelRequested(this.orderId);
}
