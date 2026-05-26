import '../../../data/models/order/print_order_model.dart';

enum OrderFilter { active, completed }

abstract class PartnerOrderState {}

class PartnerOrderInitial extends PartnerOrderState {}

class PartnerOrderLoading extends PartnerOrderState {}

class PartnerOrderLoaded extends PartnerOrderState {
  final List<PrintOrderModel> allOrders;
  final List<PrintOrderModel> orders;
  final OrderFilter filterMode;

  PartnerOrderLoaded({
    required this.allOrders,
    required this.orders,
    this.filterMode = OrderFilter.active,
  });
}

class PartnerOrderActionLoading extends PartnerOrderState {}

class PartnerOrderActionSuccess extends PartnerOrderState {
  final String message;
  final PrintOrderModel? order;
  PartnerOrderActionSuccess(this.message, {this.order});
}

class PartnerOrderFailure extends PartnerOrderState {
  final String error;
  PartnerOrderFailure(this.error);
}
