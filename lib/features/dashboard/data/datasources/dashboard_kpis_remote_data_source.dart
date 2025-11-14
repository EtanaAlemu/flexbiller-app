import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/dashboard_kpi_model.dart';

abstract class DashboardKPIsRemoteDataSource {
  Future<DashboardKPIModel> getDashboardKPIs();
}

@Injectable(as: DashboardKPIsRemoteDataSource)
class DashboardKPIsRemoteDataSourceImpl implements DashboardKPIsRemoteDataSource {
  final Dio _dio;
  final Logger _logger = Logger();

  DashboardKPIsRemoteDataSourceImpl(this._dio);

  @override
  Future<DashboardKPIModel> getDashboardKPIs() async {
    try {
      _logger.i('🌐 [Dashboard Remote] Fetching dashboard KPIs from API');
      _logger.d(
        '📍 [Dashboard Remote] Endpoint: ${ApiEndpoints.dashboardKPIs}',
      );

      final response = await _dio.get(ApiEndpoints.dashboardKPIs);

      _logger.d('✅ [Dashboard Remote] Response status: ${response.statusCode}');
      _logger.d('📥 [Dashboard Remote] Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;

        // Check if response has the expected structure
        if (data['success'] == true && data['data'] != null) {
          _logger.d('✅ [Dashboard Remote] Response structure valid');
          try {
            final kpiModel = DashboardKPIModel.fromJson(
              data['data'] as Map<String, dynamic>,
            );
            _logger.i(
              '✅ [Dashboard Remote] Successfully parsed dashboard KPIs',
            );
            _logger.d('📊 [Dashboard Remote] KPIs: ${kpiModel.toJson()}');
            return kpiModel;
          } catch (e, stackTrace) {
            _logger.e('❌ [Dashboard Remote] Error parsing KPI model: $e');
            _logger.e('📚 [Dashboard Remote] Stack trace: $stackTrace');
            throw ServerException(
              'Failed to parse dashboard KPIs: $e',
              response.statusCode,
            );
          }
        } else {
          _logger.w('⚠️ [Dashboard Remote] Invalid response structure');
          _logger.w('📥 [Dashboard Remote] Response: $data');
          throw ServerException(
            'Invalid response format from dashboard KPIs API',
            response.statusCode,
          );
        }
      } else {
        _logger.e(
          '❌ [Dashboard Remote] Failed with status: ${response.statusCode}',
        );
        throw ServerException(
          'Failed to fetch dashboard KPIs: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      _logger.e('❌ [Dashboard Remote] DioException: ${e.type}');
      _logger.e('📝 [Dashboard Remote] Message: ${e.message}');
      _logger.e('📊 [Dashboard Remote] Response: ${e.response?.data}');
      _logger.e('🔢 [Dashboard Remote] Status Code: ${e.response?.statusCode}');

      if (e.response?.statusCode == 401) {
        _logger.e('🔒 [Dashboard Remote] Unauthorized access');
        throw AuthException('Unauthorized access to dashboard KPIs');
      } else if (e.response?.statusCode == 403) {
        _logger.e('🚫 [Dashboard Remote] Forbidden access');
        throw AuthException(
          'Forbidden: Insufficient permissions to access dashboard KPIs',
        );
      } else if (e.response?.statusCode == 404) {
        _logger.e('🔍 [Dashboard Remote] Endpoint not found');
        throw ValidationException('Dashboard KPIs endpoint not found');
      } else if (e.response?.statusCode == 500) {
        _logger.e('💥 [Dashboard Remote] Server error');
        throw ServerException('Server error while fetching dashboard KPIs');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        _logger.e('⏱️ [Dashboard Remote] Connection timeout');
        throw NetworkException(
          'Connection timeout while fetching dashboard KPIs',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        _logger.e('📡 [Dashboard Remote] No internet connection');
        throw NetworkException('No internet connection');
      } else {
        _logger.e('🌐 [Dashboard Remote] Network error: ${e.message}');
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e, stackTrace) {
      if (e is ServerException ||
          e is NetworkException ||
          e is AuthException ||
          e is ValidationException) {
        _logger.d('🔄 [Dashboard Remote] Re-throwing known exception: $e');
        rethrow;
      }
      _logger.e('💥 [Dashboard Remote] Unexpected error: $e');
      _logger.e('📚 [Dashboard Remote] Stack trace: $stackTrace');
      throw ServerException('Unexpected error: $e');
    }
  }
}
