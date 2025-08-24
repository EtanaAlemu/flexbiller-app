# Localization System

This directory contains the localization system for the FlexBiller Flutter app.

## Overview

The localization system is designed to support multiple languages while maintaining a clean, maintainable codebase. Currently, it supports English ('en') with the infrastructure to easily add more languages.

## Files

### `app_localizations.dart`
- Configuration for supported locales
- Localization delegates setup
- Locale resolution logic

### `localization_service.dart`
- Manages current locale state
- Persists language preferences
- Provides utility methods for locale management

### `app_strings.dart`
- Contains all localized strings for English
- Organized by feature/context
- Easy to maintain and extend

### `l10n/app_en.arb`
- ARB format file for English strings
- Ready for integration with Flutter's localization system
- Can be used with `flutter gen-l10n` for code generation

### `language_selector_widget.dart`
- UI components for language selection
- `LanguageSelectorWidget`: Full dropdown with language options
- `SimpleLanguageSelector`: Simple button showing current language

## Usage

### Basic String Access
```dart
import 'package:flexbiller_app/core/localization/app_strings.dart';

Text(AppStrings.welcomeBack)
Text(AppStrings.loginButton)
```

### Dynamic Strings with Parameters
```dart
Text(AppStrings.validationPasswordLength(8))
Text(AppStrings.validationMinLength(6))
```

### Language Management
```dart
import 'package:flexbiller_app/core/localization/localization_service.dart';

// Set language
await LocalizationService.setLanguage('en');

// Get current language info
String currentLang = LocalizationService.getCurrentLanguageName();
```

## Adding New Languages

### 1. Update `app_localizations.dart`
```dart
static const List<Locale> supportedLocales = [
  Locale('en', ''), // English
  Locale('es', ''), // Spanish - NEW
];
```

### 2. Create ARB file
Create `l10n/app_es.arb` with Spanish translations:
```json
{
  "@@locale": "es",
  "appTitle": "FlexBiller",
  "welcomeBack": "Bienvenido de vuelta",
  // ... more translations
}
```

### 3. Update `app_strings.dart`
Add Spanish strings alongside English:
```dart
class AppStrings {
  // English
  static const String welcomeBack = 'Welcome Back';
  
  // Spanish
  static const String welcomeBackEs = 'Bienvenido de vuelta';
  
  // Getter method for current language
  static String get welcomeBackLocalized {
    if (LocalizationService.isEnglish()) {
      return welcomeBack;
    } else {
      return welcomeBackEs;
    }
  }
}
```

### 4. Update language selector
Add Spanish option to `LanguageSelectorWidget`:
```dart
PopupMenuItem<String>(
  value: 'es',
  child: Row(
    children: [
      const Text('🇪🇸'),
      if (showLabel) ...[
        const SizedBox(width: 12),
        Text(LocalizationService.getLanguageName('es')),
      ],
    ],
  ),
),
```

## Best Practices

1. **String Organization**: Group strings by feature or context
2. **Naming Convention**: Use descriptive names that indicate purpose
3. **Parameter Support**: Use methods for strings that need dynamic values
4. **Fallback**: Always provide English as fallback
5. **Testing**: Test with different locales during development

## Future Enhancements

- [ ] Integrate with `flutter gen-l10n` for automatic code generation
- [ ] Add RTL language support (Arabic, Hebrew)
- [ ] Implement pluralization rules
- [ ] Add date/time formatting localization
- [ ] Add number formatting localization
- [ ] Implement locale-specific validation messages

## Dependencies

- `flutter_localizations`: Flutter's built-in localization support
- `intl`: Internationalization and localization support
- `shared_preferences`: For persisting language preferences
