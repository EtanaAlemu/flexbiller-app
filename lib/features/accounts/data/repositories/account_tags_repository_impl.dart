import 'package:injectable/injectable.dart';
import '../../domain/entities/account_tag.dart';
import '../../domain/repositories/account_tags_repository.dart';
import '../datasources/account_tags_remote_data_source.dart';
import '../models/account_tag_model.dart';

@Injectable(as: AccountTagsRepository)
class AccountTagsRepositoryImpl implements AccountTagsRepository {
  final AccountTagsRemoteDataSource _remoteDataSource;

  AccountTagsRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<AccountTagAssignment>> getAccountTags(String accountId) async {
    try {
      final tagsModels = await _remoteDataSource.getAccountTags(accountId);
      return tagsModels.map((tag) => tag.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<AccountTag>> getAllTags() async {
    try {
      final tagsModels = await _remoteDataSource.getAllTags();
      return tagsModels.map((tag) => tag.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<AccountTag>> getAllTagsForAccount(String accountId) async {
    try {
      final tagsModels = await _remoteDataSource.getAllTagsForAccount(accountId);
      return tagsModels.map((tag) => tag.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AccountTag> createTag(AccountTag tag) async {
    try {
      // Convert entity to model for API call
      final tagModel = AccountTagModel.fromEntity(tag);
      final createdTagModel = await _remoteDataSource.createTag(tagModel);
      return createdTagModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AccountTag> updateTag(AccountTag tag) async {
    try {
      // Convert entity to model for API call
      final tagModel = AccountTagModel.fromEntity(tag);
      final updatedTagModel = await _remoteDataSource.updateTag(tagModel);
      return updatedTagModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteTag(String tagId) async {
    try {
      await _remoteDataSource.deleteTag(tagId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AccountTagAssignment> assignTagToAccount(
    String accountId,
    String tagId,
  ) async {
    try {
      final assignmentModel = await _remoteDataSource.assignTagToAccount(
        accountId,
        tagId,
      );
      return assignmentModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<AccountTagAssignment>> assignMultipleTagsToAccount(
    String accountId,
    List<String> tagIds,
  ) async {
    try {
      final assignmentModels = await _remoteDataSource.assignMultipleTagsToAccount(
        accountId,
        tagIds,
      );
      return assignmentModels.map((tag) => tag.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> removeTagFromAccount(String accountId, String tagId) async {
    try {
      await _remoteDataSource.removeTagFromAccount(accountId, tagId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<String>> getAccountsByTag(String tagId) async {
    try {
      // This would require a separate API endpoint
      // For now, return empty list
      // In the future, implement: return await _remoteDataSource.getAccountsByTag(tagId);
      return [];
    } catch (e) {
      rethrow;
    }
  }
}
