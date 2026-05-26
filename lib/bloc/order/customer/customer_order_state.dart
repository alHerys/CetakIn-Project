import '../../../data/models/order/print_order_model.dart';

enum CustomerOrderFilter { ongoing, finished }

abstract class CustomerOrderState {}

class CustomerOrderInitial extends CustomerOrderState {}

class CustomerOrderLoading extends CustomerOrderState {}

class CustomerOrderLoaded extends CustomerOrderState {
  final List<PrintOrderModel> allOrders;
  final List<PrintOrderModel> orders;
  final CustomerOrderFilter filterMode;

  CustomerOrderLoaded({
    required this.allOrders,
    required this.orders,
    this.filterMode = CustomerOrderFilter.ongoing,
  });
}

class CustomerOrderActionLoading extends CustomerOrderState {}

class CustomerOrderActionSuccess extends CustomerOrderState {
  final String message;
  final PrintOrderModel? order;
  CustomerOrderActionSuccess(this.message, {this.order});
}

class CustomerOrderFailure extends CustomerOrderState {
  final String error;
  CustomerOrderFailure(this.error);
}
