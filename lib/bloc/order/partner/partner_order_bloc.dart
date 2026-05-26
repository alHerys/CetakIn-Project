import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/order/print_order_model.dart';
import '../../../data/repositories/print_order_repository.dart';
import 'partner_order_event.dart';
import 'partner_order_state.dart';

class PartnerOrderBloc extends Bloc<PartnerOrderEvent, PartnerOrderState> {
  final PrintOrderRepository _repository;

  PartnerOrderBloc(this._repository) : super(PartnerOrderInitial()) {
    on<PartnerOrderLoadIncomingRequested>(_onLoadIncomingRequested);
    on<PartnerOrderFilterChanged>(_onFilterChanged);
    on<PartnerOrderUpdateStatusRequested>(_onUpdateStatusRequested);
  }

  Future<void> _onLoadIncomingRequested(
    PartnerOrderLoadIncomingRequested event,
    Emitter<PartnerOrderState> emit,
  ) async {
    emit(PartnerOrderLoading());
    final result = await _repository.getPartnerOrders(status: event.status);
    result.fold(
      (error) => emit(PartnerOrderFailure(error)),
      (orders) {
        final filtered = _filterOrders(orders, OrderFilter.active);
        emit(PartnerOrderLoaded(
          allOrders: orders,
          orders: filtered,
          filterMode: OrderFilter.active,
        ));
      },
    );
  }

  void _onFilterChanged(
    PartnerOrderFilterChanged event,
    Emitter<PartnerOrderState> emit,
  ) {
    if (state is PartnerOrderLoaded) {
      final currentState = state as PartnerOrderLoaded;
      final filtered = _filterOrders(currentState.allOrders, event.filterMode);
      emit(PartnerOrderLoaded(
        allOrders: currentState.allOrders,
        orders: filtered,
        filterMode: event.filterMode,
      ));
    }
  }

  List<PrintOrderModel> _filterOrders(
      List<PrintOrderModel> orders, OrderFilter filterMode) {
    if (filterMode == OrderFilter.completed) {
      return orders
          .where((o) => o.status == 'completed' || o.status == 'cancelled')
          .toList();
    } else {
      return orders
          .where((o) => o.status != 'completed' && o.status != 'cancelled')
          .toList();
    }
  }

  Future<void> _onUpdateStatusRequested(
    PartnerOrderUpdateStatusRequested event,
    Emitter<PartnerOrderState> emit,
  ) async {
    // Keep track of current orders to restore state after success
    List<PrintOrderModel> currentAllOrders = [];
    OrderFilter currentFilter = OrderFilter.active;

    if (state is PartnerOrderLoaded) {
      currentAllOrders = (state as PartnerOrderLoaded).allOrders;
      currentFilter = (state as PartnerOrderLoaded).filterMode;
    }

    emit(PartnerOrderActionLoading());
    final result =
        await _repository.updateOrderStatus(event.orderId, event.status);
    
    result.fold(
      (error) => emit(PartnerOrderFailure(error)),
      (order) {
        // Emit success message
        emit(PartnerOrderActionSuccess('Status updated successfully', order: order));
        
        // Update the list locally and re-emit Loaded state
        final updatedAllOrders = currentAllOrders.map((o) {
          return o.id == order.id ? order : o;
        }).toList();
        
        final filtered = _filterOrders(updatedAllOrders, currentFilter);
        
        emit(PartnerOrderLoaded(
          allOrders: updatedAllOrders,
          orders: filtered,
          filterMode: currentFilter,
        ));
      },
    );
  }
}
