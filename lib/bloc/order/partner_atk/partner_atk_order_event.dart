abstract class PartnerAtkOrderEvent {}

class PartnerAtkOrderLoadIncomingRequested extends PartnerAtkOrderEvent {}

enum PartnerAtkOrderFilter { active, completed }

class PartnerAtkOrderFilterChanged extends PartnerAtkOrderEvent {
  final PartnerAtkOrderFilter filter;

  PartnerAtkOrderFilterChanged(this.filter);
}

class PartnerAtkOrderUpdateStatusRequested extends PartnerAtkOrderEvent {
  final String orderId;
  final String newStatus;

  PartnerAtkOrderUpdateStatusRequested({
    required this.orderId,
    required this.newStatus,
  });
}
