abstract class AdminEvent {}

class AdminGetPartnersRequested extends AdminEvent {
  final String? status;
  AdminGetPartnersRequested({this.status});
}

class AdminApprovePartnerRequested extends AdminEvent {
  final String id;
  AdminApprovePartnerRequested(this.id);
}

class AdminRejectPartnerRequested extends AdminEvent {
  final String id;
  final String reason;
  AdminRejectPartnerRequested({required this.id, required this.reason});
}
