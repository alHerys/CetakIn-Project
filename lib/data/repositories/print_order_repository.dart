import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import '../models/order/print_order_model.dart';
import '../services/order/print_order_service.dart';

class PrintOrderRepository {
  final PrintOrderService _service;

  PrintOrderRepository(this._service);

  Future<Either<String, PrintOrderModel>> createOrder(FormData data) async {
    try {
      final response = await _service.createOrder(data);
      return Right(PrintOrderModel.fromJson(response.data['data']));
    } on DioException catch (e) {
      return Left(e.response?.data['message'] ?? 'Failed to create order');
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, List<PrintOrderModel>>> getCustomerOrders({String? status}) async {
    try {
      final response = await _service.getCustomerOrders(status: status);
      final List<dynamic> data = response.data['data']; // Fix parsing for paginated response
      final orders = data.map((json) => PrintOrderModel.fromJson(json)).toList();
      return Right(orders);
    } on DioException catch (e) {
      return Left(e.response?.data['message'] ?? 'Failed to get orders');
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, PrintOrderModel>> cancelOrder(String id) async {
    try {
      final response = await _service.cancelOrder(id);
      return Right(PrintOrderModel.fromJson(response.data['data']));
    } on DioException catch (e) {
      return Left(e.response?.data['message'] ?? 'Failed to cancel order');
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, List<PrintOrderModel>>> getPartnerOrders({String? status}) async {
    try {
      final response = await _service.getPartnerOrders(status: status);
      final List<dynamic> data = response.data['data']; // Fix parsing for paginated response
      final orders = data.map((json) => PrintOrderModel.fromJson(json)).toList();
      return Right(orders);
    } on DioException catch (e) {
      return Left(e.response?.data['message'] ?? 'Failed to get partner orders');
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, PrintOrderModel>> updateOrderStatus(String id, String status) async {
    try {
      final response = await _service.updateOrderStatus(id, status);
      return Right(PrintOrderModel.fromJson(response.data['data']));
    } on DioException catch (e) {
      return Left(e.response?.data['message'] ?? 'Failed to update order status');
    } catch (e) {
      return Left(e.toString());
    }
  }
}
