import '../../../data/models/order/atk_order_model.dart';
import 'customer_atk_order_event.dart';

abstract class CustomerAtkOrderState {}

class CustomerAtkOrderInitial extends CustomerAtkOrderState {}

class CustomerAtkOrderLoading extends CustomerAtkOrderState {}

class CustomerAtkOrderLoaded extends CustomerAtkOrderState {
  final List<AtkOrderModel> orders;
  final CustomerAtkOrderFilter filterMode;

  CustomerAtkOrderLoaded({
    required this.orders,
    required this.filterMode,
  });
}

class CustomerAtkOrderFailure extends CustomerAtkOrderState {
  final String error;

  CustomerAtkOrderFailure(this.error);
}
