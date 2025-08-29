import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:logger/logger.dart';
import '../constants/app_constants.dart';
import '../constants/api_endpoints.dart';
import '../errors/exceptions.dart';
import '../config/build_config.dart';

@injectable
class DioClient {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;
  final Logger _logger = Logger();

  DioClient(this._dio, this._secureStorage) {
    // Debug: Log the base URL being used
    if (BuildConfig.enableLogging) {
      _logger.i(
        '🌐 Dio Client initialized with base URL: ${_dio.options.baseUrl}',
      );
      _logger.i('⏱️ Connection timeout: ${_dio.options.connectTimeout}');
      _logger.i('⏱️ Receive timeout: ${_dio.options.receiveTimeout}');
    }
    _setupInterceptors();
  }

  Dio get dio => _dio;

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Debug logging for development
          if (BuildConfig.enableLogging) {
            _logger.i('🌐 Dio Request: ${options.method} ${options.uri}');
            _logger.i('📤 Headers: ${options.headers}');
            if (options.data != null) {
              _logger.i('📦 Data: ${options.data}');
            }
          }

          // Add auth token if available
          final token = await _secureStorage.read(
            key: AppConstants.authTokenKey,
          );
          _logger.d(
            '🔑 Dio Interceptor - Token retrieved: ${token != null ? 'YES (${token.length} chars)' : 'NO'}',
          );
          _logger.d(
            '🔑 Dio Interceptor - Looking for key: ${AppConstants.authTokenKey}',
          );

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            _logger.d(
              '🔑 Dio Interceptor - Authorization header added: Bearer ${token.substring(0, 10)}...',
            );

            // Add API key and secret from JWT metadata if available
            try {
              final decodedToken = JwtDecoder.decode(token);
              final userMetadata = decodedToken['user_metadata'];
              if (userMetadata != null) {
                final apiKey = userMetadata['api_key'];
                final apiSecret = userMetadata['api_secret'];

                if (apiKey != null && apiKey.isNotEmpty) {
                  options.headers['api_key'] = apiKey;
                }
                if (apiSecret != null && apiSecret.isNotEmpty) {
                  options.headers['api_secret'] = apiSecret;
                }
              }
            } catch (e) {
              // JWT decode failed, continue without API headers
            }
          } else {
            _logger.w(
              '⚠️ Dio Interceptor - No token found, request will proceed without authorization',
            );
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Debug logging for development
          if (BuildConfig.enableLogging) {
            _logger.i(
              '✅ Dio Response: ${response.statusCode} ${response.requestOptions.uri}',
            );
            _logger.i('📥 Data: ${response.data}');
          }
          return handler.next(response);
        },
        onError: (error, handler) async {
          // Debug logging for development
          if (BuildConfig.enableLogging) {
            _logger.e('❌ Dio Error: ${error.type} - ${error.message}');
            _logger.e('🔗 URL: ${error.requestOptions.uri}');
            _logger.e('📊 Status: ${error.response?.statusCode}');
            _logger.e('📥 Response Data: ${error.response?.data}');
          }

          if (error.response?.statusCode == 401) {
            // Token expired, try to refresh
            final refreshToken = await _secureStorage.read(
              key: AppConstants.refreshTokenKey,
            );
            if (refreshToken != null) {
              try {
                final response = await _dio.post(
                  ApiEndpoints.refreshToken,
                  data: {'refreshToken': refreshToken},
                );

                if (response.statusCode == 200) {
                  final responseData = response.data;
                  if (responseData['success'] == true &&
                      responseData['data'] != null) {
                    final newToken = responseData['data']['access_token'];
                    final newRefreshToken =
                        responseData['data']['refresh_token'];

                    // Store new tokens
                    await _secureStorage.write(
                      key: AppConstants.authTokenKey,
                      value: newToken,
                    );
                    await _secureStorage.write(
                      key: AppConstants.refreshTokenKey,
                      value: newRefreshToken,
                    );

                    // Retry original request with new token
                    error.requestOptions.headers['Authorization'] =
                        'Bearer $newToken';

                    // Add API key and secret from new token
                    try {
                      final decodedToken = JwtDecoder.decode(newToken);
                      final userMetadata = decodedToken['user_metadata'];
                      if (userMetadata != null) {
                        final apiKey = userMetadata['api_key'];
                        final apiSecret = userMetadata['api_secret'];

                        if (apiKey != null && apiKey.isNotEmpty) {
                          error.requestOptions.headers['api_key'] = apiKey;
                        }
                        if (apiSecret != null && apiSecret.isNotEmpty) {
                          error.requestOptions.headers['api_secret'] =
                              apiSecret;
                        }
                      }
                    } catch (e) {
                      // JWT decode failed, continue without API headers
                    }

                    final retryResponse = await _dio.fetch(
                      error.requestOptions,
                    );
                    return handler.resolve(retryResponse);
                  }
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
