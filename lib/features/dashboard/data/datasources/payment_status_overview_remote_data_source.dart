import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/payment_status_overview_model.dart';

abstract class PaymentStatusOverviewRemoteDataSource {
  Future<PaymentStatusOverviewsModel> getPaymentStatusOverview(int year);
}

@Injectable(as: PaymentStatusOverviewRemoteDataSource)
class PaymentStatusOverviewRemoteDataSourceImpl
    implements PaymentStatusOverviewRemoteDataSource {
  final Dio _dio;
  final Logger _logger = Logger();

  PaymentStatusOverviewRemoteDataSourceImpl(this._dio);

  @override
  Future<PaymentStatusOverviewsModel> getPaymentStatusOverview(int year) async {
    try {
      _logger.i(
        '🌐 [Payment Status Overview Remote] Fetching payment status overview from API',
      );
      _logger.d(
        '📍 [Payment Status Overview Remote] Endpoint: ${ApiEndpoints.paymentStatusOverview(year)}',
      );
      _logger.d('📅 [Payment Status Overview Remote] Year: $year');

      final response = await _dio.get(ApiEndpoints.paymentStatusOverview(year));

      _logger.d(
        '✅ [Payment Status Overview Remote] Response status: ${response.statusCode}',
      );
      _logger.d(
        '📥 [Payment Status Overview Remote] Response data: ${response.data}',
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // Check if response has the expected structure
        if (data['success'] == true && data['data'] != null) {
          _logger.d(
            '✅ [Payment Status Overview Remote] Response structure valid',
          );
          try {
            final overviewModel = PaymentStatusOverviewsModel.fromJson(
              data as Map<String, dynamic>,
              year,
            );
            _logger.i(
              '✅ [Payment Status Overview Remote] Successfully parsed payment status overview',
            );
            _logger.d(
              '📊 [Payment Status Overview Remote] Overview: ${overviewModel.toJson()}',
            );
            return overviewModel;
          } catch (e, stackTrace) {
            _logger.e(
              '❌ [Payment Status Overview Remote] Error parsing overview model: $e',
            );
            _logger.e(
              '📚 [Payment Status Overview Remote] Stack trace: $stackTrace',
            );
            throw ServerException(
              'Failed to parse payment status overview: $e',
              response.statusCode,
            );
          }
        } else {
          _logger.w(
            '⚠️ [Payment Status Overview Remote] Invalid response structure',
          );
          _logger.w('📥 [Payment Status Overview Remote] Response: $data');
          throw ServerException(
            'Invalid response format from payment status overview API',
            response.statusCode,
          );
        }
      } else {
        _logger.e(
          '❌ [Payment Status Overview Remote] Failed with status: ${response.statusCode}',
        );
        throw ServerException(
          'Failed to fetch payment status overview: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      _logger.e('❌ [Payment Status Overview Remote] DioException: ${e.type}');
      _logger.e('📝 [Payment Status Overview Remote] Message: ${e.message}');
      _logger.e(
        '📊 [Payment Status Overview Remote] Response: ${e.response?.data}',
      );
      _logger.e(
        '🔢 [Payment Status Overview Remote] Status Code: ${e.response?.statusCode}',
      );

      if (e.response?.statusCode == 401) {
        _logger.e('🔒 [Payment Status Overview Remote] Unauthorized access');
        throw AuthException('Unauthorized access to payment status overview');
      } else if (e.response?.statusCode == 403) {
        _logger.e('🚫 [Payment Status Overview Remote] Forbidden access');
        throw AuthException(
          'Forbidden: Insufficient permissions to access payment status overview',
        );
      } else if (e.response?.statusCode == 404) {
        _logger.e('🔍 [Payment Status Overview Remote] Endpoint not found');
        throw ValidationException('Payment status overview endpoint not found');
      } else if (e.response?.statusCode == 500) {
        _logger.e('💥 [Payment Status Overview Remote] Server error');
        throw ServerException(
          'Server error while fetching payment status overview',
        );
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        _logger.e('⏱️ [Payment Status Overview Remote] Connection timeout');
        throw NetworkException(
          'Connection timeout while fetching payment status overview',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        _logger.e('📡 [Payment Status Overview Remote] No internet connection');
        throw NetworkException('No internet connection');
      } else {
        _logger.e(
          '🌐 [Payment Status Overview Remote] Network error: ${e.message}',
        );
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e, stackTrace) {
      if (e is ServerException ||
          e is NetworkException ||
          e is AuthException ||
          e is ValidationException) {
        _logger.d(
          '🔄 [Payment Status Overview Remote] Re-throwing known exception: $e',
        );
        rethrow;
      }
      _logger.e('💥 [Payment Status Overview Remote] Unexpected error: $e');
      _logger.e('📚 [Payment Status Overview Remote] Stack trace: $stackTrace');
      throw ServerException('Unexpected error: $e');
    }
  }
}
