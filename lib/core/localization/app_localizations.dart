import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocalizations {
  static const List<Locale> supportedLocales = [
    Locale('en', ''), // English
    // Add more locales here when needed:
    // Locale('es', ''), // Spanish
    // Locale('fr', ''), // French
    // Locale('ar', ''), // Arabic
    // Locale('zh', ''), // Chinese
  ];

  static const String defaultLanguageCode = 'en';
  static const String defaultCountryCode = '';

  static const Locale defaultLocale = Locale(defaultLanguageCode, defaultCountryCode);

  static List<LocalizationsDelegate<dynamic>> get localizationsDelegates => [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    // Add custom delegates here when needed
  ];

  static List<Locale> get supportedLocalesList => supportedLocales;

  static bool isSupported(Locale locale) {
    return supportedLocales.any((supported) =>
        supported.languageCode == locale.languageCode &&
        (supported.countryCode?.isEmpty == true ||
            supported.countryCode == locale.countryCode));
  }

  static Locale getFallbackLocale() {
    return defaultLocale;
  }

  static Locale? getSupportedLocale(Locale? locale) {
    if (locale == null) return defaultLocale;
    
    // Check if the locale is supported
    if (isSupported(locale)) {
      return locale;
    }
    
    // Try to find a supported locale with the same language code
    final supportedLocale = supportedLocales.firstWhere(
      (supported) => supported.languageCode == locale.languageCode,
      orElse: () => defaultLocale,
    );
    
    return supportedLocale;
  }
}
