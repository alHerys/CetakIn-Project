import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/shop/shop_model.dart';
import 'atk_cart_event.dart';
import 'atk_cart_state.dart';

class AtkCartBloc extends Bloc<AtkCartEvent, AtkCartState> {
  ShopModel? _currentShop;
  final List<CartItem> _items = [];

  AtkCartBloc() : super(AtkCartInitial()) {
    on<AtkCartAddItemRequested>(_onAddItem);
    on<AtkCartUpdateItemQuantityRequested>(_onUpdateQuantity);
    on<AtkCartRemoveItemRequested>(_onRemoveItem);
    on<AtkCartClearRequested>(_onClearCart);
  }

  void _onAddItem(AtkCartAddItemRequested event, Emitter<AtkCartState> emit) {
    if (_currentShop != null && _currentShop!.id != event.shop.id) {
      emit(AtkCartConflict(
        existingShop: _currentShop!,
        newShop: event.shop,
        newProduct: event.product,
        newQuantity: event.quantity,
      ));
      return;
    }

    _currentShop = event.shop;
    
    final existingIndex = _items.indexWhere((item) => item.product.id == event.product.id);
    if (existingIndex >= 0) {
      final existingItem = _items[existingIndex];
      _items[existingIndex] = CartItem(
        product: existingItem.product,
        quantity: existingItem.quantity + event.quantity,
      );
    } else {
      _items.add(CartItem(product: event.product, quantity: event.quantity));
    }

    _emitUpdatedState(emit);
  }

  void _onUpdateQuantity(AtkCartUpdateItemQuantityRequested event, Emitter<AtkCartState> emit) {
    final index = _items.indexWhere((item) => item.product.id == event.productId);
    if (index >= 0) {
      if (event.newQuantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index] = CartItem(product: _items[index].product, quantity: event.newQuantity);
      }
    }
    
    if (_items.isEmpty) {
      _currentShop = null;
    }
    
    _emitUpdatedState(emit);
  }

  void _onRemoveItem(AtkCartRemoveItemRequested event, Emitter<AtkCartState> emit) {
    _items.removeWhere((item) => item.product.id == event.productId);
    if (_items.isEmpty) {
      _currentShop = null;
    }
    _emitUpdatedState(emit);
  }

  void _onClearCart(AtkCartClearRequested event, Emitter<AtkCartState> emit) {
    _items.clear();
    _currentShop = null;
    _emitUpdatedState(emit);
  }

  void _emitUpdatedState(Emitter<AtkCartState> emit) {
    int total = 0;
    for (var item in _items) {
      total += item.subtotal;
    }
    emit(AtkCartUpdated(currentShop: _currentShop, items: List.from(_items), totalAmount: total));
  }
}
