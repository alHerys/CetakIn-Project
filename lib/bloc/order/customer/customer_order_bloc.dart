import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/order/print_order_model.dart';
import '../../../data/repositories/print_order_repository.dart';
import 'customer_order_event.dart';
import 'customer_order_state.dart';

class CustomerOrderBloc extends Bloc<CustomerOrderEvent, CustomerOrderState> {
  final PrintOrderRepository _repository;

  CustomerOrderBloc(this._repository) : super(CustomerOrderInitial()) {
    on<CustomerOrderLoadHistoryRequested>(_onLoadHistoryRequested);
    on<CustomerOrderFilterChanged>(_onFilterChanged);
    on<CustomerOrderCreateRequested>(_onCreateRequested);
    on<CustomerOrderCancelRequested>(_onCancelRequested);
  }

  Future<void> _onLoadHistoryRequested(
    CustomerOrderLoadHistoryRequested event,
    Emitter<CustomerOrderState> emit,
  ) async {
    emit(CustomerOrderLoading());
    final result = await _repository.getCustomerOrders(status: event.status);
    result.fold(
      (error) => emit(CustomerOrderFailure(error)),
      (orders) {
        final filtered = _filterOrders(orders, CustomerOrderFilter.ongoing);
        emit(CustomerOrderLoaded(
          allOrders: orders,
          orders: filtered,
          filterMode: CustomerOrderFilter.ongoing,
        ));
      },
    );
  }

  void _onFilterChanged(
    CustomerOrderFilterChanged event,
    Emitter<CustomerOrderState> emit,
  ) {
    if (state is CustomerOrderLoaded) {
      final currentState = state as CustomerOrderLoaded;
      final filtered = _filterOrders(currentState.allOrders, event.filterMode);
      emit(CustomerOrderLoaded(
        allOrders: currentState.allOrders,
        orders: filtered,
        filterMode: event.filterMode,
      ));
    }
  }

  List<PrintOrderModel> _filterOrders(
      List<PrintOrderModel> orders, CustomerOrderFilter filterMode) {
    if (filterMode == CustomerOrderFilter.finished) {
      return orders
          .where((o) => o.status == 'completed' || o.status == 'cancelled')
          .toList();
    } else {
      return orders
          .where((o) => o.status != 'completed' && o.status != 'cancelled')
          .toList();
    }
  }

  Future<void> _onCreateRequested(
    CustomerOrderCreateRequested event,
    Emitter<CustomerOrderState> emit,
  ) async {
    emit(CustomerOrderActionLoading());
    try {
      final multipartFile = await MultipartFile.fromFile(event.filePath);
      final formData = FormData.fromMap({
        'shop_id': event.shopId,
        'file': multipartFile,
        'paper_size': event.paperSize,
        'color_mode': event.colorMode,
        'sides': event.sides,
        'binding': event.binding,
        'copies': event.copies,
        'total_pages': event.totalPages,
        if (event.notes != null) 'notes': event.notes,
      });

      final result = await _repository.createOrder(formData);
      result.fold(
        (error) => emit(CustomerOrderFailure(error)),
        (order) => emit(CustomerOrderActionSuccess('Order created successfully', order: order)),
      );
    } catch (e) {
      emit(CustomerOrderFailure(e.toString()));
    }
  }

  Future<void> _onCancelRequested(
    CustomerOrderCancelRequested event,
    Emitter<CustomerOrderState> emit,
  ) async {
    // Keep track of current orders to restore state after success
    List<PrintOrderModel> currentAllOrders = [];
    CustomerOrderFilter currentFilter = CustomerOrderFilter.ongoing;

    if (state is CustomerOrderLoaded) {
      currentAllOrders = (state as CustomerOrderLoaded).allOrders;
      currentFilter = (state as CustomerOrderLoaded).filterMode;
    }

    emit(CustomerOrderActionLoading());
    final result = await _repository.cancelOrder(event.orderId);
    result.fold(
      (error) => emit(CustomerOrderFailure(error)),
      (order) {
        emit(CustomerOrderActionSuccess('Order cancelled successfully', order: order));
        
        // Update the list locally and re-emit Loaded state
        final updatedAllOrders = currentAllOrders.map((o) {
          return o.id == order.id ? order : o;
        }).toList();

        final filtered = _filterOrders(updatedAllOrders, currentFilter);

        emit(CustomerOrderLoaded(
          allOrders: updatedAllOrders,
          orders: filtered,
          filterMode: currentFilter,
        ));
      },
    );
  }
}
