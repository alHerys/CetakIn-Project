import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/discovery_repository.dart';
import 'discovery_event.dart';
import 'discovery_state.dart';

class DiscoveryBloc extends Bloc<DiscoveryEvent, DiscoveryState> {
  final DiscoveryRepository _discoveryRepository;

  DiscoveryBloc(this._discoveryRepository) : super(DiscoveryInitial()) {
    on<DiscoverySearchRequested>(_onSearchRequested);
    on<DiscoveryRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onSearchRequested(
    DiscoverySearchRequested event,
    Emitter<DiscoveryState> emit,
  ) async {
    emit(DiscoveryLoading());
    final result = await _discoveryRepository.searchShops(
      lat: event.lat,
      lng: event.lng,
      radius: event.radius,
      minRating: event.minRating,
    );

    result.fold(
      (failure) => emit(DiscoveryError(failure)),
      (shops) => emit(DiscoveryLoaded(shops)),
    );
  }

  Future<void> _onRefreshRequested(
    DiscoveryRefreshRequested event,
    Emitter<DiscoveryState> emit,
  ) async {
    // Keep current loaded state while refreshing if possible, but for simplicity let's just show loading
    final result = await _discoveryRepository.searchShops(
      lat: event.lat,
      lng: event.lng,
      radius: event.radius,
      minRating: event.minRating,
    );

    result.fold(
      (failure) => emit(DiscoveryError(failure)),
      (shops) => emit(DiscoveryLoaded(shops)),
    );
  }
}
