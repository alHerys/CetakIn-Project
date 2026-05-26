import '../../../data/models/atk/atk_product_model.dart';

abstract class PartnerAtkState {}

class PartnerAtkInitial extends PartnerAtkState {}

class PartnerAtkLoading extends PartnerAtkState {}

class PartnerAtkLoaded extends PartnerAtkState {
  final List<AtkProductModel> products;
  
  PartnerAtkLoaded(this.products);
}

class PartnerAtkActionLoading extends PartnerAtkState {
  // To keep showing the list while acting
}

class PartnerAtkActionSuccess extends PartnerAtkState {
  final String message;
  
  PartnerAtkActionSuccess(this.message);
}

class PartnerAtkFailure extends PartnerAtkState {
  final String error;

  PartnerAtkFailure(this.error);
}
