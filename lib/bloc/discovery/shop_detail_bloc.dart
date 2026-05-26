import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/discovery_repository.dart';
import 'shop_detail_event.dart';
import 'shop_detail_state.dart';

class ShopDetailBloc extends Bloc<ShopDetailEvent, ShopDetailState> {
  final DiscoveryRepository _discoveryRepository;

  ShopDetailBloc(this._discoveryRepository) : super(ShopDetailInitial()) {
    on<ShopDetailLoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(
    ShopDetailLoadRequested event,
    Emitter<ShopDetailState> emit,
  ) async {
    emit(ShopDetailLoading());
    final result = await _discoveryRepository.getShopDetail(event.shopId);

    result.fold(
      (failure) => emit(ShopDetailError(failure)),
      (shop) => emit(ShopDetailLoaded(shop)),
    );
  }
}
