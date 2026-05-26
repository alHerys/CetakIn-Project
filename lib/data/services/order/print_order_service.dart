import 'package:dio/dio.dart';
import '../dio_client.dart';

class PrintOrderService {
  final DioClient _dioClient;

  PrintOrderService(this._dioClient);
  
  // Customer: Create a print order
  Future<Response> createOrder(FormData data) async {
    return await _dioClient.dio.post('/orders/print', data: data);
  }

  // Customer: Get order history
  Future<Response> getCustomerOrders({String? status}) async {
    final queryParams = status != null ? {'status': status} : null;
    return await _dioClient.dio.get('/orders/print', queryParameters: queryParams);
  }

  // Customer: Cancel an order
  Future<Response> cancelOrder(String id) async {
    return await _dioClient.dio.post('/orders/print/$id/cancel');
  }

  // Partner: Get incoming orders
  Future<Response> getPartnerOrders({String? status}) async {
    final queryParams = status != null ? {'status': status} : null;
    return await _dioClient.dio.get('/partner/orders/print', queryParameters: queryParams);
  }

  // Partner: Update order status
  Future<Response> updateOrderStatus(String id, String status) async {
    return await _dioClient.dio.patch('/partner/orders/print/$id/status', data: {
      'status': status,
    });
  }
}
