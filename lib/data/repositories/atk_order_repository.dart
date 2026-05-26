import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../models/order/atk_order_model.dart';
import '../services/dio_client.dart';

class AtkOrderRepository {
  final DioClient _dioClient;

  AtkOrderRepository(this._dioClient);

  Future<Either<String, List<AtkOrderModel>>> getCustomerOrders({String? status}) async {
    try {
      final response = await _dioClient.dio.get(
        'orders/atk',
        queryParameters: status != null ? {'status': status} : null,
      );

      final List<dynamic> data = response.data['data'];
      final orders = data.map((json) => AtkOrderModel.fromJson(json)).toList();
      return Right(orders);
    } on DioException catch (e) {
      return Left(e.response?.data['message'] ?? 'Failed to get ATK orders');
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, AtkOrderModel>> getCustomerOrderDetail(String id) async {
    try {
      final response = await _dioClient.dio.get('orders/atk/$id');
      return Right(AtkOrderModel.fromJson(response.data['data']));
    } on DioException catch (e) {
      return Left(e.response?.data['message'] ?? 'Failed to get ATK order detail');
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, List<AtkOrderModel>>> getPartnerOrders({String? status}) async {
    try {
      final response = await _dioClient.dio.get(
        'partner/orders/atk',
        queryParameters: status != null ? {'status': status} : null,
      );

      final List<dynamic> data = response.data['data'];
      final orders = data.map((json) => AtkOrderModel.fromJson(json)).toList();
      return Right(orders);
    } on DioException catch (e) {
      return Left(e.response?.data['message'] ?? 'Failed to get partner ATK orders');
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, AtkOrderModel>> updatePartnerOrderStatus(String id, String status) async {
    try {
      final response = await _dioClient.dio.patch(
        'partner/orders/atk/$id/status',
        data: {'status': status},
      );
      return Right(AtkOrderModel.fromJson(response.data['data']));
    } on DioException catch (e) {
      return Left(e.response?.data['message'] ?? 'Failed to update ATK order status');
    } catch (e) {
      return Left(e.toString());
    }
  }
}
