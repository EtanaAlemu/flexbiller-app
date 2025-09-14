import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../../core/services/authentication_state_service.dart';
import '../../../../core/services/sync_service.dart';
import '../../../../core/services/database_service.dart';

@injectable
class LogoutUseCase {
  final AuthenticationStateService _authStateService;
  final Logger _logger = Logger();
  final SyncService _syncService;
  final DatabaseService _databaseService;

  LogoutUseCase(
    this._authStateService,
    this._syncService,
    this._databaseService,
  );

  Future<void> call() async {
    try {
      // Stop all background sync operations
      await _syncService.stopAllSyncOperations();
      
      // Clear authentication state
      await _authStateService.clearAuthenticationState();
      
      // Clear all local data
      await _databaseService.clearAllData();
      
      // Clear any cached data in services
      _authStateService.invalidateCache();
    } catch (e) {
      // Log error but don't throw - logout should always succeed
      _logger.e('Error during logout: $e');
    }
  }
}
