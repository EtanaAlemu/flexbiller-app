import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../models/account_tag_model.dart';

abstract class AccountTagsRemoteDataSource {
  Future<List<AccountTagAssignmentModel>> getAccountTags(String accountId);
  Future<List<AccountTagModel>> getAllTags();
  Future<List<AccountTagModel>> getAllTagsForAccount(String accountId);
  Future<AccountTagModel> createTag(AccountTagModel tag);
  Future<AccountTagModel> updateTag(AccountTagModel tag);
  Future<void> deleteTag(String tagId);
  Future<AccountTagAssignmentModel> assignTagToAccount(
    String accountId,
    String tagId,
  );
  Future<List<AccountTagAssignmentModel>> assignMultipleTagsToAccount(
    String accountId,
    List<String> tagIds,
  );
  Future<void> removeTagFromAccount(String accountId, String tagId);
  Future<void> removeMultipleTagsFromAccount(
    String accountId,
    List<String> tagIds,
  );
}

@Injectable(as: AccountTagsRemoteDataSource)
class AccountTagsRemoteDataSourceImpl implements AccountTagsRemoteDataSource {
  final Dio _dio;

  AccountTagsRemoteDataSourceImpl(this._dio);

  @override
  Future<List<AccountTagAssignmentModel>> getAccountTags(
    String accountId,
  ) async {
    try {
      final response = await _dio.get('/accounts/$accountId/tags');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> tagsData = responseData['data'] as List<dynamic>;
          return tagsData
              .map(
                (tag) => AccountTagAssignmentModel.fromJson(
                  tag as Map<String, dynamic>,
                ),
              )
              .toList();
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to fetch account tags',
          );
        }
      } else {
        throw ServerException(
          'Failed to fetch account tags: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized access to account tags');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to access account tags',
        );
      } else if (e.response?.statusCode == 404) {
        throw ValidationException('Account tags not found');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout while fetching tags');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to fetch account tags: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<List<AccountTagModel>> getAllTags() async {
    try {
      final response = await _dio.get('/tags');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> tagsData = responseData['data'] as List<dynamic>;
          return tagsData
              .map(
                (tag) => AccountTagModel.fromJson(tag as Map<String, dynamic>),
              )
              .toList();
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to fetch tags',
          );
        }
      } else {
        throw ServerException('Failed to fetch tags: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized access to tags');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to access tags',
        );
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout while fetching tags');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to fetch tags: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<List<AccountTagModel>> getAllTagsForAccount(String accountId) async {
    try {
      final response = await _dio.get('/accounts/$accountId/allTags');

      if (response.statusCode == 200) {
        final responseData = response.data;

        // The allTags endpoint returns a different structure than other endpoints
        if (responseData['tags'] != null) {
          final List<dynamic> tagsData = responseData['tags'] as List<dynamic>;
          return tagsData
              .map(
                (tag) => AccountTagModel.fromJson(tag as Map<String, dynamic>),
              )
              .toList();
        } else if (responseData['success'] == true && responseData['data'] != null) {
          // Fallback to standard response structure
          final List<dynamic> tagsData = responseData['data'] as List<dynamic>;
          return tagsData
              .map(
                (tag) => AccountTagModel.fromJson(tag as Map<String, dynamic>),
              )
              .toList();
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to fetch account tags',
          );
        }
      } else {
        throw ServerException(
          'Failed to fetch account tags: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized access to account tags');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to access account tags',
        );
      } else if (e.response?.statusCode == 404) {
        throw ValidationException('Account not found');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException(
          'Connection timeout while fetching account tags',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to fetch account tags: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<AccountTagModel> createTag(AccountTagModel tag) async {
    try {
      final response = await _dio.post('/tags', data: tag.toJson());

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          return AccountTagModel.fromJson(
            responseData['data'] as Map<String, dynamic>,
          );
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to create tag',
          );
        }
      } else {
        throw ServerException('Failed to create tag: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to create tag');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to create tag',
        );
      } else if (e.response?.statusCode == 400) {
        throw ValidationException('Invalid tag data');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout while creating tag');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to create tag: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<AccountTagModel> updateTag(AccountTagModel tag) async {
    try {
      final response = await _dio.put('/tags/${tag.id}', data: tag.toJson());

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          return AccountTagModel.fromJson(
            responseData['data'] as Map<String, dynamic>,
          );
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to update tag',
          );
        }
      } else {
        throw ServerException('Failed to update tag: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to update tag');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to update tag',
        );
      } else if (e.response?.statusCode == 404) {
        throw ValidationException('Tag not found');
      } else if (e.response?.statusCode == 400) {
        throw ValidationException('Invalid tag data');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout while updating tag');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to update tag: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteTag(String tagId) async {
    try {
      final response = await _dio.delete('/tags/$tagId');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException('Failed to delete tag: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to delete tag');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to delete tag',
        );
      } else if (e.response?.statusCode == 404) {
        throw ValidationException('Tag not found');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout while deleting tag');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to delete tag: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<AccountTagAssignmentModel> assignTagToAccount(
    String accountId,
    String tagId,
  ) async {
    try {
      final response = await _dio.post(
        '/accounts/$accountId/tags',
        data: {
          'tagDefIds': [tagId],
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          return AccountTagAssignmentModel.fromJson(
            responseData['data'] as Map<String, dynamic>,
          );
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to assign tag to account',
          );
        }
      } else {
        throw ServerException(
          'Failed to assign tag to account: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to assign tag');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to assign tag',
        );
      } else if (e.response?.statusCode == 404) {
        throw ValidationException('Account or tag not found');
      } else if (e.response?.statusCode == 400) {
        throw ValidationException('Invalid tag assignment data');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout while assigning tag');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to assign tag: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<List<AccountTagAssignmentModel>> assignMultipleTagsToAccount(
    String accountId,
    List<String> tagIds,
  ) async {
    try {
      final response = await _dio.post(
        '/accounts/$accountId/tags',
        data: {'tagDefIds': tagIds},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          // The API returns a confirmation response, not the actual tag objects
          final assignmentResponse = AccountTagAssignmentResponseModel.fromJson(
            responseData['data'] as Map<String, dynamic>,
          );
          
          // Convert to AccountTagAssignmentModel for backward compatibility
          return assignmentResponse.toAccountTagAssignmentModels();
        } else {
          throw ServerException(
            responseData['message'] ??
                'Failed to assign multiple tags to account',
          );
        }
      } else {
        throw ServerException(
          'Failed to assign multiple tags to account: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to assign multiple tags');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to assign multiple tags',
        );
      } else if (e.response?.statusCode == 404) {
        throw ValidationException('Account not found');
      } else if (e.response?.statusCode == 400) {
        throw ValidationException('Invalid tag assignment data');
      } else if (e.response?.statusCode == 500) {
        // Handle 500 error which might indicate tag definition issues
        final responseData = e.response?.data;
        if (responseData != null && responseData['error'] == 'CONNECTION_ERROR') {
          final details = responseData['details'];
          if (details != null && details['originalError'] != null) {
            final originalError = details['originalError'] as String;
            if (originalError.contains("does not exist")) {
              throw ValidationException('One or more tag definitions do not exist');
            }
          }
        }
        throw ServerException('Server error while assigning tags to account');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException(
          'Connection timeout while assigning multiple tags',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to assign multiple tags: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<void> removeTagFromAccount(String accountId, String tagId) async {
    try {
      final response = await _dio.delete(
        '/accounts/$accountId/tags',
        data: {
          'tagDefIds': [tagId],
        },
      );

      if (response.statusCode == 200) {
        // The API returns a success response with data about removed tags
        final responseData = response.data;
        if (responseData['success'] == true) {
          // Successfully removed tags
          return;
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to remove tag from account',
          );
        }
      } else if (response.statusCode != 204) {
        throw ServerException(
          'Failed to remove tag from account: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to remove tag');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to remove tag',
        );
      } else if (e.response?.statusCode == 404) {
        throw ValidationException('Account or tag assignment not found');
      } else if (e.response?.statusCode == 400) {
        throw ValidationException('Invalid tag removal data');
      } else if (e.response?.statusCode == 500) {
        // Handle 500 error which might indicate tag definition issues
        final responseData = e.response?.data;
        if (responseData != null && responseData['message'] != null) {
          final message = responseData['message'] as String;
          if (message.contains("does not exist")) {
            throw ValidationException('One or more tag definitions do not exist');
          }
        }
        throw ServerException('Server error while removing tags from account');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout while removing tag');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to remove tag: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<void> removeMultipleTagsFromAccount(
    String accountId,
    List<String> tagIds,
  ) async {
    try {
      final response = await _dio.delete(
        '/accounts/$accountId/tags',
        data: {'tagDefIds': tagIds},
      );

      if (response.statusCode == 200) {
        // The API returns a success response with data about removed tags
        final responseData = response.data;
        if (responseData['success'] == true) {
          // Successfully removed tags
          return;
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to remove multiple tags from account',
          );
        }
      } else if (response.statusCode != 204) {
        throw ServerException(
          'Failed to remove multiple tags from account: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to remove multiple tags');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to remove multiple tags',
        );
      } else if (e.response?.statusCode == 404) {
        throw ValidationException('Account not found');
      } else if (e.response?.statusCode == 400) {
        throw ValidationException('Invalid tag removal data');
      } else if (e.response?.statusCode == 500) {
        // Handle 500 error which might indicate tag definition issues
        final responseData = e.response?.data;
        if (responseData != null && responseData['message'] != null) {
          final message = responseData['message'] as String;
          if (message.contains("does not exist")) {
            throw ValidationException('One or more tag definitions do not exist');
          }
        }
        throw ServerException('Server error while removing tags from account');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException(
          'Connection timeout while removing multiple tags',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to remove multiple tags: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }
}
