import '../entities/account_tag.dart';

abstract class AccountTagsRepository {
  /// Stream of account tags for reactive UI updates
  Stream<List<AccountTagAssignment>> get accountTagsStream;

  /// Get all tags for a specific account
  Future<List<AccountTagAssignment>> getAccountTags(String accountId);
  
  /// Get all available tags in the system
  Future<List<AccountTag>> getAllTags();
  
  /// Get all available tags for a specific account (including unassigned ones)
  Future<List<AccountTag>> getAllTagsForAccount(String accountId);
  
  /// Create a new tag
  Future<AccountTag> createTag(AccountTag tag);
  
  /// Update an existing tag
  Future<AccountTag> updateTag(AccountTag tag);
  
  /// Delete a tag
  Future<void> deleteTag(String tagId);
  
  /// Assign a tag to an account
  Future<AccountTagAssignment> assignTagToAccount(
    String accountId,
    String tagId,
  );
  
  /// Assign multiple tags to an account
  Future<List<AccountTagAssignment>> assignMultipleTagsToAccount(
    String accountId,
    List<String> tagIds,
  );
  
  /// Remove a tag from an account
  Future<void> removeTagFromAccount(String accountId, String tagId);
  
  /// Remove multiple tags from an account
  Future<void> removeMultipleTagsFromAccount(String accountId, List<String> tagIds);
  
  /// Get accounts by tag
  Future<List<String>> getAccountsByTag(String tagId);
}
