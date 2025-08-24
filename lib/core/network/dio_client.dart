import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import '../constants/app_constants.dart';

@injectable
class DioClient {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;
  
  DioClient(this._secureStorage)
      : _dio = Dio(BaseOptions(
          baseUrl: AppConstants.baseUrl,
          connectTimeout: Duration(milliseconds: AppConstants.connectionTimeout),
          receiveTimeout: Duration(milliseconds: AppConstants.receiveTimeout),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        )) {
    _setupInterceptors();
  }
  
  Dio get dio => _dio;
  
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token if available
          final token = await _secureStorage.read(key: AppConstants.authTokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            // Token expired, try to refresh
            final refreshToken = await _secureStorage.read(key: AppConstants.refreshTokenKey);
            if (refreshToken != null) {
              try {
                final response = await _dio.post(
                  '/auth/refresh',
                  data: {'refresh_token': refreshToken},
                );
                
                if (response.statusCode == 200) {
                  final newToken = response.data['access_token'];
                  await _secureStorage.write(key: AppConstants.authTokenKey, value: newToken);
                  
                  // Retry original request with new token
                  error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
                  final retryResponse = await _dio.fetch(error.requestOptions);
                  return handler.resolve(retryResponse);
                }
              } catch (refreshError) {
                // Refresh failed, clear tokens and redirect to login
                await _secureStorage.delete(key: AppConstants.authTokenKey);
                await _secureStorage.delete(key: AppConstants.refreshTokenKey);
                return handler.reject(
                  DioException(
                    requestOptions: error.requestOptions,
                    error: 'Authentication failed. Please login again.',
                  ),
                );
              }
            }
          }
          
          return handler.next(error);
        },
      ),
    );
  }
}
