import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/subscription_trend_model.dart';

abstract class SubscriptionTrendsRemoteDataSource {
  Future<SubscriptionTrendsModel> getSubscriptionTrends(int year);
}

@Injectable(as: SubscriptionTrendsRemoteDataSource)
class SubscriptionTrendsRemoteDataSourceImpl
    implements SubscriptionTrendsRemoteDataSource {
  final Dio _dio;
  final Logger _logger = Logger();

  SubscriptionTrendsRemoteDataSourceImpl(this._dio);

  @override
  Future<SubscriptionTrendsModel> getSubscriptionTrends(int year) async {
    try {
      _logger.i(
        '🌐 [Subscription Trends Remote] Fetching subscription trends from API',
      );
      _logger.d(
        '📍 [Subscription Trends Remote] Endpoint: ${ApiEndpoints.subscriptionTrends(year)}',
      );
      _logger.d('📅 [Subscription Trends Remote] Year: $year');

      final response = await _dio.get(ApiEndpoints.subscriptionTrends(year));

      _logger.d(
        '✅ [Subscription Trends Remote] Response status: ${response.statusCode}',
      );
      _logger.d(
        '📥 [Subscription Trends Remote] Response data: ${response.data}',
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // Check if response has the expected structure
        if (data['success'] == true && data['data'] != null) {
          _logger.d('✅ [Subscription Trends Remote] Response structure valid');
          try {
            final trendsModel = SubscriptionTrendsModel.fromJson(
              data as Map<String, dynamic>,
              year,
            );
            _logger.i(
              '✅ [Subscription Trends Remote] Successfully parsed subscription trends',
            );
            _logger.d(
              '📊 [Subscription Trends Remote] Trends count: ${trendsModel.trends.length}',
            );
            return trendsModel;
          } catch (e, stackTrace) {
            _logger.e(
              '❌ [Subscription Trends Remote] Error parsing trends model: $e',
            );
            _logger.e(
              '📚 [Subscription Trends Remote] Stack trace: $stackTrace',
            );
            throw ServerException(
              'Failed to parse subscription trends: $e',
              response.statusCode,
            );
          }
        } else {
          _logger.w(
            '⚠️ [Subscription Trends Remote] Invalid response structure',
          );
          _logger.w('📥 [Subscription Trends Remote] Response: $data');
          throw ServerException(
            'Invalid response format from subscription trends API',
            response.statusCode,
          );
        }
      } else {
        _logger.e(
          '❌ [Subscription Trends Remote] Failed with status: ${response.statusCode}',
        );
        throw ServerException(
          'Failed to fetch subscription trends: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      _logger.e('❌ [Subscription Trends Remote] DioException: ${e.type}');
      _logger.e('📝 [Subscription Trends Remote] Message: ${e.message}');
      _logger.e(
        '📊 [Subscription Trends Remote] Response: ${e.response?.data}',
      );
      _logger.e(
        '🔢 [Subscription Trends Remote] Status Code: ${e.response?.statusCode}',
      );

      if (e.response?.statusCode == 401) {
        _logger.e('🔒 [Subscription Trends Remote] Unauthorized access');
        throw AuthException('Unauthorized access to subscription trends');
      } else if (e.response?.statusCode == 403) {
        _logger.e('🚫 [Subscription Trends Remote] Forbidden access');
        throw AuthException(
          'Forbidden: Insufficient permissions to access subscription trends',
        );
      } else if (e.response?.statusCode == 404) {
        _logger.e('🔍 [Subscription Trends Remote] Endpoint not found');
        throw ValidationException('Subscription trends endpoint not found');
      } else if (e.response?.statusCode == 500) {
        _logger.e('💥 [Subscription Trends Remote] Server error');
        throw ServerException(
          'Server error while fetching subscription trends',
        );
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        _logger.e('⏱️ [Subscription Trends Remote] Connection timeout');
        throw NetworkException(
          'Connection timeout while fetching subscription trends',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        _logger.e('📡 [Subscription Trends Remote] No internet connection');
        throw NetworkException('No internet connection');
      } else {
        _logger.e(
          '🌐 [Subscription Trends Remote] Network error: ${e.message}',
        );
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e, stackTrace) {
      if (e is ServerException ||
          e is NetworkException ||
          e is AuthException ||
          e is ValidationException) {
        _logger.d(
          '🔄 [Subscription Trends Remote] Re-throwing known exception: $e',
        );
        rethrow;
      }
      _logger.e('💥 [Subscription Trends Remote] Unexpected error: $e');
      _logger.e('📚 [Subscription Trends Remote] Stack trace: $stackTrace');
      throw ServerException('Unexpected error: $e');
    }
  }
}
