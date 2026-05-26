import '../../../data/models/order/atk_order_model.dart';
import 'partner_atk_order_event.dart';

abstract class PartnerAtkOrderState {}

class PartnerAtkOrderInitial extends PartnerAtkOrderState {}

class PartnerAtkOrderLoading extends PartnerAtkOrderState {}

class PartnerAtkOrderLoaded extends PartnerAtkOrderState {
  final List<AtkOrderModel> orders;
  final PartnerAtkOrderFilter filterMode;

  PartnerAtkOrderLoaded({
    required this.orders,
    required this.filterMode,
  });
}

class PartnerAtkOrderFailure extends PartnerAtkOrderState {
  final String error;

  PartnerAtkOrderFailure(this.error);
}

class PartnerAtkOrderActionLoading extends PartnerAtkOrderState {
  final List<AtkOrderModel> orders;
  final PartnerAtkOrderFilter filterMode;

  PartnerAtkOrderActionLoading({
    required this.orders,
    required this.filterMode,
  });
}

class PartnerAtkOrderActionSuccess extends PartnerAtkOrderState {
  final String message;
  final List<AtkOrderModel> orders;
  final PartnerAtkOrderFilter filterMode;

  PartnerAtkOrderActionSuccess({
    required this.message,
    required this.orders,
    required this.filterMode,
  });
}
