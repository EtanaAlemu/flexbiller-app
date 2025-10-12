# FlexBiller Versioning Guide

This document explains the industry-standard Semantic Versioning (SemVer) system implemented for FlexBiller app.

## 🏆 Versioning Strategy

### **Semantic Versioning (SemVer) Format**
```
MAJOR.MINOR.PATCH[-PRERELEASE][+BUILD_METADATA]
```

**Examples:**
- `1.0.0` - First stable release
- `1.2.3` - Major 1, Minor 2, Patch 3
- `1.0.0-debug.abc123` - Debug build with git commit
- `2.1.0-beta.1` - Beta release

## 📱 Current Version Configuration

### **Version Properties File**
Located at: `android/version.properties`

```properties
# FlexBiller Version Configuration
# Update these values for each release following Semantic Versioning (SemVer)
# Format: MAJOR.MINOR.PATCH

# Manual version (update for each release)
major=1
minor=0
patch=0

# Build metadata (auto-generated from git)
# These are automatically calculated during build
# versionCode=auto
# gitCommit=auto
# buildTime=auto
```

### **Current Build Information**
- **Version Name**: `1.0.0` (SemVer)
- **Version Code**: `201` (Git commit count)
- **Git Commit**: `78dad69`
- **Debug Version**: `1.0.0-debug.78dad69`

## 🔧 How It Works

### **1. Manual Version Control**
- **Major, Minor, Patch** versions are manually controlled in `version.properties`
- Updated by developers for each release
- Follows SemVer principles

### **2. Automatic Build Numbers**
- **Version Code** is automatically generated from git commit count
- **Git Commit Hash** is automatically extracted from git
- **Build Time** is automatically generated during build

### **3. Build Types**
- **Debug**: `1.0.0-debug.78dad69` (includes git commit for identification)
- **Release**: `1.0.0` (clean SemVer format)

## 📋 Version Management Workflow

### **When to Update Versions**

| Change Type | Version Update | Example | Description |
|-------------|----------------|---------|-------------|
| **Breaking changes** | `MAJOR++` | `1.2.3` → `2.0.0` | API changes, major UI redesign |
| **New features** | `MINOR++` | `1.2.3` → `1.3.0` | New functionality, minor UI changes |
| **Bug fixes** | `PATCH++` | `1.2.3` → `1.2.4` | Bug fixes, small improvements |

### **Release Workflow**

1. **Development**: `1.0.0-dev` (feature branches)
2. **Testing**: `1.0.0-beta.1` (test builds)
3. **Production**: `1.0.0` (app store release)
4. **Hotfix**: `1.0.1` (urgent bug fixes)

## 🛠️ How to Update Versions

### **Step 1: Update Version Properties**
Edit `android/version.properties`:
```properties
# For a new feature release
major=1
minor=1
patch=0

# For a bug fix release
major=1
minor=0
patch=1

# For a breaking change release
major=2
minor=0
patch=0
```

### **Step 2: Build the App**
```bash
# Debug build
flutter build apk --debug
# Result: 1.1.0-debug.abc123

# Release build
flutter build apk --release
# Result: 1.1.0
```

### **Step 3: Verify Version**
Check the build output:
```
=== Build Info ===
Version: 1.1.0
Version Code: 205
Git Commit: abc123
==================
```

## 📱 Accessing Version Info in Flutter

### **BuildInfo Utility**
```dart
import 'package:flexbiller_app/utils/build_info.dart';

// Initialize (done automatically in main.dart)
await BuildInfo.init();

// Access version information
String version = BuildInfo.version;           // "1.0.0" or "1.0.0-debug.abc123"
String buildNumber = BuildInfo.buildNumber;   // "201"
int versionCode = BuildInfo.versionCode;      // 201
String gitCommit = BuildInfo.gitCommit;       // "78dad69"
String buildTime = BuildInfo.buildTime;       // "1703123456789"

// Semantic version components
int major = BuildInfo.majorVersion;           // 1
int minor = BuildInfo.minorVersion;           // 0
int patch = BuildInfo.patchVersion;           // 0

// Build type detection
bool isDebug = BuildInfo.isDebugBuild;        // true for debug builds
bool isRelease = BuildInfo.isReleaseBuild;    // true for release builds

// Display strings
String display = BuildInfo.displayVersion;    // "v1.0.0 (Build 201)"
String detailed = BuildInfo.detailedVersion;  // "v1.0.0\nCommit: 78dad69\nBuild: 201"
```

### **Example Usage in UI**
```dart
// Show version in settings
Text('App Version: ${BuildInfo.displayVersion}')

// Show debug info (debug builds only)
if (BuildInfo.isDebugBuild)
  Text('Debug Info: ${BuildInfo.detailedVersion}')

// Check for specific version
if (BuildInfo.majorVersion >= 2) {
  // Show new features for v2.0.0+
}
```

## 🔍 Build Configuration Details

### **Gradle Configuration**
The versioning is configured in `android/app/build.gradle.kts`:

```kotlin
// Load version properties
val versionProps = Properties()
versionProps.load(FileInputStream(rootProject.file("version.properties")))

// Manual version control
val majorVersion = versionProps.getProperty("major", "1").toInt()
val minorVersion = versionProps.getProperty("minor", "0").toInt()
val patchVersion = versionProps.getProperty("patch", "0").toInt()

// Automatic git-based build numbers
val versionCodeGit = getGitCommitCount()  // From git
val gitCommitHash = getGitCommitHash()    // From git

// Final configuration
versionCode = versionCodeGit
versionName = "$majorVersion.$minorVersion.$patchVersion"
```

### **Build Types**
```kotlin
buildTypes {
    debug {
        versionNameSuffix = "-debug.$gitCommitHash"  // 1.0.0-debug.abc123
    }
    release {
        // Clean version name: 1.0.0
    }
}
```

## ✅ Benefits of This System

1. **Industry Standard**: Follows SemVer conventions used by major projects
2. **Clear Communication**: Users understand version significance
3. **App Store Compliance**: Proper integer version codes for updates
4. **Traceability**: Git commits linked to builds
5. **Team Coordination**: Standardized across industry
6. **Update Management**: Clear breaking vs non-breaking changes
7. **Debug Friendly**: Easy identification of build sources

## 🚨 Important Notes

### **Version Code Rules**
- **Must be an integer** that increases with each release
- **Never decrease** this number
- Used by app stores for update detection
- Currently auto-generated from git commit count

### **Version Name Rules**
- **Must be human-readable**
- **Follows SemVer pattern**
- **Used for display to users**
- **Manual control for meaningful releases**

### **Git Integration**
- **Version Code**: Automatically generated from git commit count
- **Git Commit**: Automatically extracted for traceability
- **Build Time**: Automatically generated during build
- **Debug Suffix**: Automatically added for debug builds

## 🔄 Migration from Old System

If migrating from the old git-only versioning:

1. **Backup**: Save current `build.gradle.kts`
2. **Update**: Replace with new SemVer configuration
3. **Configure**: Set initial version in `version.properties`
4. **Test**: Build and verify version output
5. **Deploy**: Use new versioning for future releases

## 📚 References

- [Semantic Versioning Specification](https://semver.org/)
- [Android Versioning Guide](https://developer.android.com/studio/publish/versioning)
- [Flutter Versioning Best Practices](https://docs.flutter.dev/deployment/versioning)

---

**Last Updated**: January 2025  
**Current Version**: 1.0.0 (Build 201)  
**Git Commit**: 78dad69
