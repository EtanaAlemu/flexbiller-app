import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/constants/api_endpoints.dart';
import '../../../../../core/network/dio_client.dart';
import '../../models/payment_model.dart';

abstract class PaymentsRemoteDataSource {
  Future<List<PaymentModel>> getPayments();
  Future<PaymentModel> getPaymentById(String paymentId);
  Future<List<PaymentModel>> getPaymentsByAccountId(String accountId);
}

@LazySingleton(as: PaymentsRemoteDataSource)
class PaymentsRemoteDataSourceImpl implements PaymentsRemoteDataSource {
  final DioClient _dioClient;

  PaymentsRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<PaymentModel>> getPayments() async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.payments);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> paymentsJson = data['data'];
          return paymentsJson
              .map(
                (json) => PaymentModel.fromJson(json as Map<String, dynamic>),
              )
              .toList();
        } else {
          throw Exception(
            'Failed to fetch payments: ${data['message'] ?? 'Unknown error'}',
          );
        }
      } else {
        throw Exception(
          'Failed to fetch payments: HTTP ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<PaymentModel> getPaymentById(String paymentId) async {
    try {
      final response = await _dioClient.dio.get(
        '${ApiEndpoints.payments}/$paymentId',
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          return PaymentModel.fromJson(data['data'] as Map<String, dynamic>);
        } else {
          throw Exception(
            'Failed to fetch payment: ${data['message'] ?? 'Unknown error'}',
          );
        }
      } else {
        throw Exception('Failed to fetch payment: HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<List<PaymentModel>> getPaymentsByAccountId(String accountId) async {
    try {
      final response = await _dioClient.dio.get(
        '${ApiEndpoints.payments}?accountId=$accountId',
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> paymentsJson = data['data'];
          return paymentsJson
              .map(
                (json) => PaymentModel.fromJson(json as Map<String, dynamic>),
              )
              .toList();
        } else {
          throw Exception(
            'Failed to fetch payments by account: ${data['message'] ?? 'Unknown error'}',
          );
        }
      } else {
        throw Exception(
          'Failed to fetch payments by account: HTTP ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
