import '../../data/models/shop/shop_model.dart';

abstract class ShopDetailState {}

class ShopDetailInitial extends ShopDetailState {}

class ShopDetailLoading extends ShopDetailState {}

class ShopDetailLoaded extends ShopDetailState {
  final ShopModel shop;

  ShopDetailLoaded(this.shop);
}

class ShopDetailError extends ShopDetailState {
  final String message;

  ShopDetailError(this.message);
}
