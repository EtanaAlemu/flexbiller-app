# Build Configuration System

This directory contains environment-specific configuration files for the FlexBiller app.

## Files

- `build_config.dart` - Main build configuration with environment detection
- `env_config.dart` - Simple environment configuration (legacy)

## Usage

### Basic Usage

```dart
import 'package:flexbiller_app/core/config/build_config.dart';

// Check environment
if (BuildConfig.isDevelopment) {
  // Development-specific code
}

// Get environment-specific values
String apiUrl = BuildConfig.baseUrl;
String email = BuildConfig.email;
String password = BuildConfig.password;
```

### Environment Detection

The system automatically detects the environment:

- **Development**: When running in debug mode (`flutter run`)
- **Staging**: When `ENVIRONMENT=staging` is set
- **Production**: When running in release mode (`flutter build`)

### Build Commands

#### Development

```bash
flutter run
# Automatically uses development configuration
```

#### Staging

```bash
flutter run --dart-define=ENVIRONMENT=staging
# Uses staging configuration
```

#### Production

```bash
flutter build apk --release
# Automatically uses production configuration
```

### Configuration Values

| Environment | Email               | Password | API URL                    | App Name           |
| ----------- | ------------------- | -------- | -------------------------- | ------------------ |
| Development | mbahar651@gmail.com | Bhr@1234 | dev-api.flexbiller.com     | FlexBiller Dev     |
| Staging     | (empty)             | (empty)  | staging-api.flexbiller.com | FlexBiller Staging |
| Production  | (empty)             | (empty)  | api.flexbiller.com         | FlexBiller         |

### Adding New Configuration

To add new environment-specific values:

1. Add private constants in `BuildConfig`:

```dart
static const String _devFeatureFlag = 'enabled';
static const String _prodFeatureFlag = 'disabled';
```

2. Add public getter:

```dart
static String get featureFlag {
  switch (environment) {
    case BuildEnvironment.development:
      return _devFeatureFlag;
    case BuildEnvironment.staging:
      return _stagingFeatureFlag;
    case BuildEnvironment.production:
      return _prodFeatureFlag;
  }
}
```

### Security Notes

- **Never commit real credentials** to version control
- **Production credentials** are always empty strings
- **Development credentials** are only loaded in debug mode
- Use environment variables or secure storage for sensitive production data

### Custom Build Flavors

For more advanced build configurations, you can:

1. Create custom build flavors in `android/app/build.gradle`
2. Use `--flavor` parameter with `flutter run` and `flutter build`
3. Extend `BuildConfig` to detect custom flavors

Example:

```bash
flutter run --flavor development
flutter run --flavor staging
flutter run --flavor production
```

