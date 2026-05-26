import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/order/atk_order_model.dart';
import '../../../data/repositories/atk_order_repository.dart';
import 'customer_atk_order_event.dart';
import 'customer_atk_order_state.dart';

class CustomerAtkOrderBloc extends Bloc<CustomerAtkOrderEvent, CustomerAtkOrderState> {
  final AtkOrderRepository _repository;
  
  List<AtkOrderModel> _allOrders = [];
  CustomerAtkOrderFilter _currentFilter = CustomerAtkOrderFilter.ongoing;

  CustomerAtkOrderBloc(this._repository) : super(CustomerAtkOrderInitial()) {
    on<CustomerAtkOrderLoadHistoryRequested>(_onLoadHistoryRequested);
    on<CustomerAtkOrderFilterChanged>(_onFilterChanged);
  }

  Future<void> _onLoadHistoryRequested(
    CustomerAtkOrderLoadHistoryRequested event,
    Emitter<CustomerAtkOrderState> emit,
  ) async {
    emit(CustomerAtkOrderLoading());

    final result = await _repository.getCustomerOrders();

    result.fold(
      (failure) => emit(CustomerAtkOrderFailure(failure)),
      (orders) {
        _allOrders = orders;
        _emitFilteredOrders(emit);
      },
    );
  }

  void _onFilterChanged(
    CustomerAtkOrderFilterChanged event,
    Emitter<CustomerAtkOrderState> emit,
  ) {
    _currentFilter = event.filter;
    if (state is CustomerAtkOrderLoaded) {
      _emitFilteredOrders(emit);
    }
  }

  void _emitFilteredOrders(Emitter<CustomerAtkOrderState> emit) {
    final filteredOrders = _allOrders.where((order) {
      final isFinished = order.status == 'completed' || order.status == 'cancelled';
      if (_currentFilter == CustomerAtkOrderFilter.ongoing) {
        return !isFinished;
      } else {
        return isFinished;
      }
    }).toList();

    emit(CustomerAtkOrderLoaded(
      orders: filteredOrders,
      filterMode: _currentFilter,
    ));
  }
}
