import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/order/atk_order_model.dart';
import '../../../data/repositories/atk_order_repository.dart';
import 'partner_atk_order_event.dart';
import 'partner_atk_order_state.dart';

class PartnerAtkOrderBloc extends Bloc<PartnerAtkOrderEvent, PartnerAtkOrderState> {
  final AtkOrderRepository _repository;
  
  List<AtkOrderModel> _allOrders = [];
  PartnerAtkOrderFilter _currentFilter = PartnerAtkOrderFilter.active;

  PartnerAtkOrderBloc(this._repository) : super(PartnerAtkOrderInitial()) {
    on<PartnerAtkOrderLoadIncomingRequested>(_onLoadIncomingRequested);
    on<PartnerAtkOrderFilterChanged>(_onFilterChanged);
    on<PartnerAtkOrderUpdateStatusRequested>(_onUpdateStatusRequested);
  }

  Future<void> _onLoadIncomingRequested(
    PartnerAtkOrderLoadIncomingRequested event,
    Emitter<PartnerAtkOrderState> emit,
  ) async {
    emit(PartnerAtkOrderLoading());

    final result = await _repository.getPartnerOrders();

    result.fold(
      (failure) => emit(PartnerAtkOrderFailure(failure)),
      (orders) {
        _allOrders = orders;
        _emitFilteredOrders(emit);
      },
    );
  }

  void _onFilterChanged(
    PartnerAtkOrderFilterChanged event,
    Emitter<PartnerAtkOrderState> emit,
  ) {
    _currentFilter = event.filter;
    if (state is PartnerAtkOrderLoaded || state is PartnerAtkOrderActionSuccess) {
      _emitFilteredOrders(emit);
    }
  }

  Future<void> _onUpdateStatusRequested(
    PartnerAtkOrderUpdateStatusRequested event,
    Emitter<PartnerAtkOrderState> emit,
  ) async {
    emit(PartnerAtkOrderActionLoading(
      orders: _getFilteredOrders(),
      filterMode: _currentFilter,
    ));

    final result = await _repository.updatePartnerOrderStatus(
      event.orderId,
      event.newStatus,
    );

    result.fold(
      (failure) {
        emit(PartnerAtkOrderFailure(failure));
        _emitFilteredOrders(emit); // Re-emit current state
      },
      (updatedOrder) {
        // Update local list
        final index = _allOrders.indexWhere((o) => o.id == updatedOrder.id);
        if (index != -1) {
          _allOrders[index] = updatedOrder;
        }

        emit(PartnerAtkOrderActionSuccess(
          message: 'Status pesanan berhasil diperbarui',
          orders: _getFilteredOrders(),
          filterMode: _currentFilter,
        ));
      },
    );
  }

  List<AtkOrderModel> _getFilteredOrders() {
    return _allOrders.where((order) {
      final isCompleted = order.status == 'completed' || order.status == 'cancelled';
      if (_currentFilter == PartnerAtkOrderFilter.active) {
        return !isCompleted;
      } else {
        return isCompleted;
      }
    }).toList();
  }

  void _emitFilteredOrders(Emitter<PartnerAtkOrderState> emit) {
    emit(PartnerAtkOrderLoaded(
      orders: _getFilteredOrders(),
      filterMode: _currentFilter,
    ));
  }
}
