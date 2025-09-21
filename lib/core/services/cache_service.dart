import 'dart:io';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'user_persistence_service.dart';
import 'secure_storage_service.dart';

@injectable
class CacheService {
  final UserPersistenceService _userPersistenceService;
  final SecureStorageService _secureStorageService;
  final Logger _logger = Logger();

  CacheService(this._userPersistenceService, this._secureStorageService);

  /// Clear all application cache
  Future<CacheClearResult> clearAllCache() async {
    try {
      _logger.d('Starting comprehensive cache clearing...');

      int totalCleared = 0;
      List<String> clearedItems = [];
      List<String> errors = [];

      // 1. Clear user data from database
      try {
        await _userPersistenceService.clearAllUserData();
        clearedItems.add('User database data');
        totalCleared++;
        _logger.d('✓ User database data cleared');
      } catch (e) {
        errors.add('Failed to clear user database: $e');
        _logger.e('✗ Error clearing user database: $e');
      }

      // 2. Clear secure storage (auth tokens, etc.)
      try {
        await _secureStorageService.clear();
        clearedItems.add('Authentication tokens');
        totalCleared++;
        _logger.d('✓ Secure storage cleared');
      } catch (e) {
        errors.add('Failed to clear secure storage: $e');
        _logger.e('✗ Error clearing secure storage: $e');
      }

      // 3. Clear app cache directory
      try {
        final cacheDir = await getTemporaryDirectory();
        final cleared = await _clearDirectory(cacheDir);
        if (cleared > 0) {
          clearedItems.add('App cache files ($cleared files)');
          totalCleared++;
        }
        _logger.d('✓ App cache directory cleared ($cleared files)');
      } catch (e) {
        errors.add('Failed to clear app cache: $e');
        _logger.e('✗ Error clearing app cache: $e');
      }

      // 5. Clear application documents directory cache
      try {
        final documentsDir = await getApplicationDocumentsDirectory();
        final cleared = await _clearDirectory(
          documentsDir,
          excludeDatabase: true,
        );
        if (cleared > 0) {
          clearedItems.add('Documents cache files ($cleared files)');
          totalCleared++;
        }
        _logger.d('✓ Documents cache cleared ($cleared files)');
      } catch (e) {
        errors.add('Failed to clear documents cache: $e');
        _logger.e('✗ Error clearing documents cache: $e');
      }

      _logger.i('Cache clearing completed. Cleared $totalCleared items');

      return CacheClearResult(
        success: errors.isEmpty,
        totalCleared: totalCleared,
        clearedItems: clearedItems,
        errors: errors,
      );
    } catch (e) {
      _logger.e('Critical error during cache clearing: $e');
      return CacheClearResult(
        success: false,
        totalCleared: 0,
        clearedItems: [],
        errors: ['Critical error: $e'],
      );
    }
  }

  /// Clear only user data (database + secure storage)
  Future<CacheClearResult> clearUserData() async {
    try {
      _logger.d('Starting user data clearing...');

      int totalCleared = 0;
      List<String> clearedItems = [];
      List<String> errors = [];

      // Clear user data from database
      try {
        await _userPersistenceService.clearAllUserData();
        clearedItems.add('User database data');
        totalCleared++;
        _logger.d('✓ User database data cleared');
      } catch (e) {
        errors.add('Failed to clear user database: $e');
        _logger.e('✗ Error clearing user database: $e');
      }

      // Clear secure storage
      try {
        await _secureStorageService.clear();
        clearedItems.add('Authentication tokens');
        totalCleared++;
        _logger.d('✓ Secure storage cleared');
      } catch (e) {
        errors.add('Failed to clear secure storage: $e');
        _logger.e('✗ Error clearing secure storage: $e');
      }

      _logger.i('User data clearing completed. Cleared $totalCleared items');

      return CacheClearResult(
        success: errors.isEmpty,
        totalCleared: totalCleared,
        clearedItems: clearedItems,
        errors: errors,
      );
    } catch (e) {
      _logger.e('Critical error during user data clearing: $e');
      return CacheClearResult(
        success: false,
        totalCleared: 0,
        clearedItems: [],
        errors: ['Critical error: $e'],
      );
    }
  }

  /// Clear only app cache files (not user data)
  Future<CacheClearResult> clearAppCache() async {
    try {
      _logger.d('Starting app cache clearing...');

      int totalCleared = 0;
      List<String> clearedItems = [];
      List<String> errors = [];

      // Clear app cache directory
      try {
        final cacheDir = await getTemporaryDirectory();
        final cleared = await _clearDirectory(cacheDir);
        if (cleared > 0) {
          clearedItems.add('App cache files ($cleared files)');
          totalCleared++;
        }
        _logger.d('✓ App cache directory cleared ($cleared files)');
      } catch (e) {
        errors.add('Failed to clear app cache: $e');
        _logger.e('✗ Error clearing app cache: $e');
      }

      _logger.i('App cache clearing completed. Cleared $totalCleared items');

      return CacheClearResult(
        success: errors.isEmpty,
        totalCleared: totalCleared,
        clearedItems: clearedItems,
        errors: errors,
      );
    } catch (e) {
      _logger.e('Critical error during app cache clearing: $e');
      return CacheClearResult(
        success: false,
        totalCleared: 0,
        clearedItems: [],
        errors: ['Critical error: $e'],
      );
    }
  }

  /// Get cache size information
  Future<CacheSizeInfo> getCacheSize() async {
    try {
      int totalSize = 0;
      int fileCount = 0;
      Map<String, int> directorySizes = {};

      // App cache directory
      try {
        final cacheDir = await getTemporaryDirectory();
        final size = await _getDirectorySize(cacheDir);
        directorySizes['App Cache'] = size;
        totalSize += size;
        fileCount += await _getFileCount(cacheDir);
      } catch (e) {
        _logger.w('Could not get app cache size: $e');
      }

      // Documents directory (excluding database)
      try {
        final documentsDir = await getApplicationDocumentsDirectory();
        final size = await _getDirectorySize(
          documentsDir,
          excludeDatabase: true,
        );
        directorySizes['Documents Cache'] = size;
        totalSize += size;
        fileCount += await _getFileCount(documentsDir, excludeDatabase: true);
      } catch (e) {
        _logger.w('Could not get documents cache size: $e');
      }

      return CacheSizeInfo(
        totalSize: totalSize,
        fileCount: fileCount,
        directorySizes: directorySizes,
      );
    } catch (e) {
      _logger.e('Error getting cache size: $e');
      return CacheSizeInfo(totalSize: 0, fileCount: 0, directorySizes: {});
    }
  }

  /// Helper method to clear directory contents
  Future<int> _clearDirectory(
    Directory dir, {
    bool excludeDatabase = false,
  }) async {
    if (!await dir.exists()) return 0;

    int clearedCount = 0;
    try {
      await for (final entity in dir.list(recursive: true)) {
        if (entity is File) {
          // Skip database files if requested
          if (excludeDatabase && entity.path.endsWith('.db')) {
            continue;
          }

          try {
            await entity.delete();
            clearedCount++;
          } catch (e) {
            _logger.w('Could not delete file ${entity.path}: $e');
          }
        }
      }
    } catch (e) {
      _logger.w('Error clearing directory ${dir.path}: $e');
    }

    return clearedCount;
  }

  /// Helper method to get directory size
  Future<int> _getDirectorySize(
    Directory dir, {
    bool excludeDatabase = false,
  }) async {
    if (!await dir.exists()) return 0;

    int totalSize = 0;
    try {
      await for (final entity in dir.list(recursive: true)) {
        if (entity is File) {
          // Skip database files if requested
          if (excludeDatabase && entity.path.endsWith('.db')) {
            continue;
          }

          try {
            totalSize += await entity.length();
          } catch (e) {
            _logger.w('Could not get size of file ${entity.path}: $e');
          }
        }
      }
    } catch (e) {
      _logger.w('Error getting directory size ${dir.path}: $e');
    }

    return totalSize;
  }

  /// Helper method to get file count
  Future<int> _getFileCount(
    Directory dir, {
    bool excludeDatabase = false,
  }) async {
    if (!await dir.exists()) return 0;

    int fileCount = 0;
    try {
      await for (final entity in dir.list(recursive: true)) {
        if (entity is File) {
          // Skip database files if requested
          if (excludeDatabase && entity.path.endsWith('.db')) {
            continue;
          }
          fileCount++;
        }
      }
    } catch (e) {
      _logger.w('Error counting files in ${dir.path}: $e');
    }

    return fileCount;
  }
}

/// Result of cache clearing operation
class CacheClearResult {
  final bool success;
  final int totalCleared;
  final List<String> clearedItems;
  final List<String> errors;

  CacheClearResult({
    required this.success,
    required this.totalCleared,
    required this.clearedItems,
    required this.errors,
  });

  String get message {
    if (success) {
      if (totalCleared == 0) {
        return 'No cache data found to clear';
      } else {
        return 'Successfully cleared $totalCleared cache items';
      }
    } else {
      return 'Cache clearing completed with errors';
    }
  }
}

/// Cache size information
class CacheSizeInfo {
  final int totalSize;
  final int fileCount;
  final Map<String, int> directorySizes;

  CacheSizeInfo({
    required this.totalSize,
    required this.fileCount,
    required this.directorySizes,
  });

  String get formattedSize {
    if (totalSize < 1024) {
      return '${totalSize}B';
    } else if (totalSize < 1024 * 1024) {
      return '${(totalSize / 1024).toStringAsFixed(1)}KB';
    } else if (totalSize < 1024 * 1024 * 1024) {
      return '${(totalSize / (1024 * 1024)).toStringAsFixed(1)}MB';
    } else {
      return '${(totalSize / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
    }
  }
}
