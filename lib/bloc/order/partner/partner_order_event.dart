import 'partner_order_state.dart';

abstract class PartnerOrderEvent {}

class PartnerOrderLoadIncomingRequested extends PartnerOrderEvent {
  final String? status;
  PartnerOrderLoadIncomingRequested({this.status});
}

class PartnerOrderFilterChanged extends PartnerOrderEvent {
  final OrderFilter filterMode;
  PartnerOrderFilterChanged(this.filterMode);
}

class PartnerOrderUpdateStatusRequested extends PartnerOrderEvent {
  final String orderId;
  final String status;
  PartnerOrderUpdateStatusRequested({required this.orderId, required this.status});
}
