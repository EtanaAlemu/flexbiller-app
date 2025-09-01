import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../models/account_timeline_model.dart';

abstract class AccountTimelineRemoteDataSource {
  Future<AccountTimelineModel> getAccountTimeline(String accountId);
  Future<AccountTimelineModel> getAccountTimelinePaginated(
    String accountId, {
    int offset = 0,
    int limit = 50,
  });
}

@Injectable(as: AccountTimelineRemoteDataSource)
class AccountTimelineRemoteDataSourceImpl implements AccountTimelineRemoteDataSource {
  final Dio _dio;

  AccountTimelineRemoteDataSourceImpl(this._dio);

  @override
  Future<AccountTimelineModel> getAccountTimeline(String accountId) async {
    try {
      final response = await _dio.get('/accounts/$accountId/timeline');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          return AccountTimelineModel.fromJson(
            responseData['data'] as Map<String, dynamic>,
          );
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to fetch account timeline',
          );
        }
      } else {
        throw ServerException(
          'Failed to fetch account timeline: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized access to account timeline');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to access account timeline',
        );
      } else if (e.response?.statusCode == 404) {
        throw ValidationException('Account timeline not found');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout while fetching timeline');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to fetch account timeline: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<AccountTimelineModel> getAccountTimelinePaginated(
    String accountId, {
    int offset = 0,
    int limit = 50,
  }) async {
    try {
      final response = await _dio.get(
        '/accounts/$accountId/timeline',
        queryParameters: {
          'offset': offset,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          return AccountTimelineModel.fromJson(
            responseData['data'] as Map<String, dynamic>,
          );
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to fetch account timeline',
          );
        }
      } else {
        throw ServerException(
          'Failed to fetch account timeline: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized access to account timeline');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to access account timeline',
        );
      } else if (e.response?.statusCode == 404) {
        throw ValidationException('Account timeline not found');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout while fetching timeline');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to fetch account timeline: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }
}
