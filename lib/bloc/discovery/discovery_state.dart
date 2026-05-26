import '../../data/models/shop/shop_model.dart';

abstract class DiscoveryState {}

class DiscoveryInitial extends DiscoveryState {}

class DiscoveryLoading extends DiscoveryState {}

class DiscoveryLoaded extends DiscoveryState {
  final List<ShopModel> shops;

  DiscoveryLoaded(this.shops);
}

class DiscoveryError extends DiscoveryState {
  final String message;

  DiscoveryError(this.message);
}
