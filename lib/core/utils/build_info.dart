import 'package:package_info_plus/package_info_plus.dart';

/// Utility class to access build information including version details
class BuildInfo {
  static String? _version;
  static String? _buildNumber;
  static String? _gitCommitHash;
  static String? _buildTime;
  static int? _versionCode;

  /// Initialize build information
  static Future<void> init() async {
    final packageInfo = await PackageInfo.fromPlatform();
    _version = packageInfo.version;
    _buildNumber = packageInfo.buildNumber;
    _versionCode = int.tryParse(_buildNumber ?? '0') ?? 0;

    // Git information is embedded in the version name as: 1.0.0-debug.abc123
    // We can extract the commit hash from the version name
    _gitCommitHash = _extractGitCommitFromVersion(_version ?? '');

    // Build time would need to be passed via platform channels
    // For now, we'll use a placeholder
    _buildTime = "Build time not available";
  }

  /// Extract git commit hash from version name (format: 1.0.0-debug.abc123 or 1.0.0)
  static String _extractGitCommitFromVersion(String version) {
    // Check for debug format: 1.0.0-debug.abc123
    if (version.contains('-debug.')) {
      final parts = version.split('-debug.');
      return parts.length > 1 ? parts[1] : 'unknown';
    }
    // Check for release format with commit: 1.0.0+abc123
    if (version.contains('+')) {
      final parts = version.split('+');
      return parts.length > 1 ? parts[1] : 'unknown';
    }
    return 'unknown';
  }

  /// Get the app version (e.g., "1.0.0" or "1.0.0-debug.abc123")
  static String get version => _version ?? 'Unknown';

  /// Get the build number (version code)
  static String get buildNumber => _buildNumber ?? 'Unknown';

  /// Get the version code as integer
  static int get versionCode => _versionCode ?? 0;

  /// Get the git commit hash
  static String get gitCommit => _gitCommitHash ?? 'unknown';

  /// Get the build time
  static String get buildTime => _buildTime ?? 'unknown';

  /// Get a formatted version string for display
  static String get displayVersion => 'v$version (Build $buildNumber)';

  /// Get a detailed version string with git info
  static String get detailedVersion =>
      'v$version\nCommit: $gitCommit\nBuild: $buildNumber';

  /// Check if this is a debug build
  static bool get isDebugBuild => version.contains('-debug');

  /// Check if this is a release build
  static bool get isReleaseBuild => !isDebugBuild;

  /// Get semantic version components
  static Map<String, int> get semanticVersion {
    final parts = version
        .split('-')[0]
        .split('.'); // Remove debug suffix and split
    return {
      'major': int.tryParse(parts.length > 0 ? parts[0] : '0') ?? 0,
      'minor': int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
      'patch': int.tryParse(parts.length > 2 ? parts[2] : '0') ?? 0,
    };
  }

  /// Get major version number
  static int get majorVersion => semanticVersion['major'] ?? 0;

  /// Get minor version number
  static int get minorVersion => semanticVersion['minor'] ?? 0;

  /// Get patch version number
  static int get patchVersion => semanticVersion['patch'] ?? 0;
}

/// Extension to add build info to any widget
extension BuildInfoExtension on Object {
  /// Get build info for debugging
  String get buildInfo => BuildInfo.detailedVersion;
}
