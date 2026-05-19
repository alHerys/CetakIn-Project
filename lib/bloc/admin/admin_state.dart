import '../../data/models/shop/shop_model.dart';

abstract class AdminState {}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminPartnersLoaded extends AdminState {
  final List<ShopModel> partners;
  AdminPartnersLoaded(this.partners);
}

class AdminActionSuccess extends AdminState {
  final String message;
  AdminActionSuccess(this.message);
}

class AdminFailure extends AdminState {
  final String message;
  AdminFailure(this.message);
}
