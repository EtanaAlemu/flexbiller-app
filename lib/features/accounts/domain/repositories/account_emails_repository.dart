import '../entities/account_email.dart';

abstract class AccountEmailsRepository {
  /// Get all emails for a specific account
  Future<List<AccountEmail>> getAccountEmails(String accountId);

  /// Get a specific email by ID
  Future<AccountEmail> getAccountEmail(String accountId, String emailId);

  /// Create a new email for an account
  Future<AccountEmail> createAccountEmail(String accountId, String email);

  /// Update an existing email
  Future<AccountEmail> updateAccountEmail(String accountId, String emailId, String email);

  /// Delete an email from an account
  Future<void> deleteAccountEmail(String accountId, String emailId);

  /// Search emails by email address
  Future<List<AccountEmail>> searchEmailsByAddress(String emailAddress);

  /// Get emails by domain
  Future<List<AccountEmail>> getEmailsByDomain(String domain);
}
