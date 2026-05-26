import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';

import '../models/review/review_model.dart';
import 'auth_repository.dart';

class ReviewRepository {
  final Dio dio;
  final AuthRepository authRepository;

  ReviewRepository({required this.dio, required this.authRepository});

  Future<Map<String, String>> _getHeaders() async {
    final token = await authRepository.getToken();
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
  }

  Future<Either<String, List<ReviewModel>>> getShopReviews(String shopId) async {
    try {
      final headers = await _getHeaders();
      final response = await dio.get(
        'shops/$shopId/reviews',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        final reviews = data.map((e) => ReviewModel.fromJson(e)).toList();
        return Right(reviews);
      } else {
        return Left(response.data['message'] ?? 'Gagal mengambil daftar ulasan');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(e.response?.data['message'] ?? 'Terjadi kesalahan pada server');
      }
      return Left('Tidak dapat terhubung ke server');
    } catch (e) {
      return Left('Terjadi kesalahan yang tidak diketahui');
    }
  }

  Future<Either<String, ReviewModel>> submitPrintReview({
    required String orderId,
    required int rating,
    String? comment,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await dio.post(
        'orders/print/$orderId/review',
        data: {
          'rating': rating,
          if (comment != null && comment.isNotEmpty) 'comment': comment,
        },
        options: Options(headers: headers),
      );

      if (response.statusCode == 201) {
        return Right(ReviewModel.fromJson(response.data['data']));
      } else {
        return Left(response.data['message'] ?? 'Gagal mengirim ulasan');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(e.response?.data['message'] ?? 'Terjadi kesalahan pada server');
      }
      return Left('Tidak dapat terhubung ke server');
    } catch (e) {
      return Left('Terjadi kesalahan yang tidak diketahui');
    }
  }

  Future<Either<String, ReviewModel>> submitAtkReview({
    required String orderId,
    required int rating,
    String? comment,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await dio.post(
        'orders/atk/$orderId/review',
        data: {
          'rating': rating,
          if (comment != null && comment.isNotEmpty) 'comment': comment,
        },
        options: Options(headers: headers),
      );

      if (response.statusCode == 201) {
        return Right(ReviewModel.fromJson(response.data['data']));
      } else {
        return Left(response.data['message'] ?? 'Gagal mengirim ulasan');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(e.response?.data['message'] ?? 'Terjadi kesalahan pada server');
      }
      return Left('Tidak dapat terhubung ke server');
    } catch (e) {
      return Left('Terjadi kesalahan yang tidak diketahui');
    }
  }
}
