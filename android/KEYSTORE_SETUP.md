# FlexBiller Keystore Setup

This document explains the keystore configuration for FlexBiller app builds.

## Keystore Files

### Development Keystore (Debug)
- **File**: `android/keystores/flexbiller-debug.keystore`
- **Alias**: `flexbiller-debug`
- **Password**: `flexbiller123`
- **Purpose**: Used for debug builds during development
- **Validity**: 10,000 days

### Production Keystore (Release)
- **File**: `android/keystores/flexbiller-release.keystore`
- **Alias**: `flexbiller-release`
- **Password**: `FlexBiller2025!`
- **Purpose**: Used for release builds and app store distribution
- **Validity**: 10,000 days

## Build Configuration

The keystores are configured directly in `android/app/build.gradle.kts` using a simplified approach:

```kotlin
import java.io.FileInputStream
import java.util.*

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

// Load keystore properties directly
val keystorePropertiesFile = rootProject.file("keystore.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
    println("✓ Loaded keystore properties from: ${keystorePropertiesFile.absolutePath}")
} else {
    println("✗ Warning: keystore.properties not found at: ${keystorePropertiesFile.absolutePath}")
}

android {
    // ... other configuration ...
    
    signingConfigs {
        getByName("debug") {
            keyAlias = keystoreProperties.getProperty("debugKeyAlias", "flexbiller-debug")
            keyPassword = keystoreProperties.getProperty("debugKeyPassword", "flexbiller123")
            storeFile = file(keystoreProperties.getProperty("debugStoreFile", "../keystores/flexbiller-debug.keystore"))
            storePassword = keystoreProperties.getProperty("debugStorePassword", "flexbiller123")
        }
        create("release") {
            keyAlias = keystoreProperties.getProperty("releaseKeyAlias") 
                ?: throw GradleException("releaseKeyAlias not found in keystore.properties")
            keyPassword = keystoreProperties.getProperty("releaseKeyPassword") 
                ?: throw GradleException("releaseKeyPassword not found in keystore.properties")
            storeFile = file(keystoreProperties.getProperty("releaseStoreFile") 
                ?: throw GradleException("releaseStoreFile not found in keystore.properties"))
            storePassword = keystoreProperties.getProperty("releaseStorePassword") 
                ?: throw GradleException("releaseStorePassword not found in keystore.properties")
        }
    }
    
    // ... rest of configuration ...
}
```

### Using keystore.properties File

The keystore configuration is stored in `android/keystore.properties`:

```properties
# FlexBiller Keystore Configuration
# This file contains sensitive information and should be kept secure
# DO NOT commit this file to version control

# Debug Keystore (Development)
debugStoreFile=../keystores/flexbiller-debug.keystore
debugStorePassword=flexbiller123
debugKeyAlias=flexbiller-debug
debugKeyPassword=flexbiller123

# Release Keystore (Production)
releaseStoreFile=../keystores/flexbiller-release.keystore
releaseStorePassword=FlexBiller2025!
releaseKeyAlias=flexbiller-release
releaseKeyPassword=FlexBiller2025!
```

### Gradle Properties Configuration

Additional Gradle configuration is stored in `android/gradle.properties`:

```properties
# AndroidX Configuration
android.useAndroidX=true
android.enableJetifier=true

# Gradle JVM Configuration
org.gradle.jvmargs=-Xmx4096m -XX:MaxMetaspaceSize=1024m -XX:+HeapDumpOnOutOfMemoryError
org.gradle.parallel=true
org.gradle.caching=true
org.gradle.daemon=true
```

## Benefits of This Simplified Approach

✅ **All-in-One Configuration**: Everything is in `build.gradle.kts` - no external scripts needed
✅ **No Hardcoded Passwords**: Passwords are loaded from `keystore.properties`
✅ **Fallback Values**: Default values are provided for debug builds if properties file is missing
✅ **Strict Release Validation**: Release builds fail if keystore properties are missing
✅ **Clean Architecture**: Keystore properties separate from general Gradle configuration
✅ **Java 17 Compatible**: Updated for modern Java versions with proper memory allocation
✅ **Team Friendly**: Each developer can have their own keystore.properties
✅ **CI/CD Ready**: Can be configured via environment variables

## Security Notes

⚠️ **IMPORTANT SECURITY CONSIDERATIONS:**

1. **Never commit keystore files to version control**
2. **Keep keystore passwords secure and private**
3. **Backup production keystore safely** - losing it means you can't update your app
4. **Use different passwords for different environments**
5. **Consider using environment variables for production passwords**

## Building the App

### Debug Build
```bash
flutter build apk --debug
```
- Uses `flexbiller-debug.keystore`
- For development and testing
- Has fallback values if `keystore.properties` is missing

### Release Build
```bash
flutter build apk --release
```
- Uses `flexbiller-release.keystore`
- For production and app store distribution
- **Fails if keystore properties are missing** (security feature)

## File Structure

```
android/
├── app/
│   ├── build.gradle.kts              # Main build configuration with keystore setup
│   └── proguard-rules.pro            # R8/ProGuard rules for code optimization
├── keystores/
│   ├── flexbiller-debug.keystore     # Debug keystore
│   └── flexbiller-release.keystore   # Production keystore
├── keystore.properties               # Keystore configuration (gitignored)
├── keystore.properties.template      # Template for other developers
├── gradle.properties                 # General Gradle configuration
└── KEYSTORE_SETUP.md                 # This documentation
```

## For New Developers

1. Copy `keystore.properties.template` to `keystore.properties`
2. Update the passwords in `keystore.properties` with your own values
3. Generate your own keystores using the keytool command
4. Never commit the actual keystore files or `keystore.properties` to version control

## Keystore Generation Commands

### Debug Keystore
```bash
keytool -genkey -v -keystore android/keystores/flexbiller-debug.keystore \
  -alias flexbiller-debug -keyalg RSA -keysize 2048 -validity 10000 \
  -storepass flexbiller123 -keypass flexbiller123 \
  -dname "CN=FlexBiller Debug, OU=Development, O=AumTech, L=City, S=State, C=US"
```

### Release Keystore
```bash
keytool -genkey -v -keystore android/keystores/flexbiller-release.keystore \
  -alias flexbiller-release -keyalg RSA -keysize 2048 -validity 10000 \
  -storepass FlexBiller2025! -keypass FlexBiller2025! \
  -dname "CN=FlexBiller Production, OU=Production, O=AumTech, L=City, S=State, C=US"
```

## Build Optimization Features

### R8 Code Shrinking
- **Enabled**: Code shrinking, obfuscation, and optimization
- **ProGuard Rules**: Comprehensive rules in `proguard-rules.pro`
- **APK Size**: Significantly reduced from original size

### ABI Splits
- **Architectures**: `arm64-v8a`, `armeabi-v7a`
- **Benefits**: Smaller APK files for specific device architectures
- **Universal APK**: Disabled to force architecture-specific builds

### Memory Configuration
- **Heap Size**: 4GB maximum
- **Metaspace**: 1GB maximum
- **Parallel Builds**: Enabled for faster compilation

## Troubleshooting

### Keystore Not Found Error
- Ensure keystore files exist in `android/keystores/`
- Check file paths in `keystore.properties`
- Verify keystore file permissions

### Wrong Password Error
- Verify passwords in `keystore.properties` match keystore passwords
- Check for typos in alias names

### Build Fails
- Ensure all keystore files are present
- Check that `keystore.properties` exists and has correct values
- Verify keystore file paths are correct

### Java Version Issues
- Ensure Java 17 is installed and configured
- Check `flutter doctor -v` for Java configuration
- Update `gradle.properties` if memory issues occur

### Memory Issues (Metaspace)
- Increase `XX:MaxMetaspaceSize` in `gradle.properties`
- Increase `Xmx` value for larger heap size
- Enable parallel builds and caching

## Migration from Old Setup

If migrating from the old external script approach:

1. **Remove old files**:
   - `android/load_keystore_properties.gradle`
   - `android/load_props.gradle`

2. **Update build.gradle.kts**:
   - Add imports: `import java.io.FileInputStream` and `import java.util.*`
   - Replace external script with direct property loading
   - Update signing configurations to use `keystoreProperties`

3. **Verify configuration**:
   - Run `flutter clean`
   - Run `flutter build apk --release`
   - Check that keystore properties are loaded correctly