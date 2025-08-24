import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService {
  static const String _languageKey = 'language_code';
  static const String _countryKey = 'country_code';

  static const String defaultLanguageCode = 'en';
  static const String defaultCountryCode = '';

  static Locale _currentLocale = const Locale(
    defaultLanguageCode,
    defaultCountryCode,
  );

  static Locale get currentLocale => _currentLocale;

  static Future<void> initialize() async {
    await _loadSavedLocale();
  }

  static Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey) ?? defaultLanguageCode;
      final countryCode = prefs.getString(_countryKey) ?? defaultCountryCode;
      _currentLocale = Locale(languageCode, countryCode);
    } catch (e) {
      _currentLocale = const Locale(defaultLanguageCode, defaultCountryCode);
    }
  }

  static Future<void> setLocale(Locale locale) async {
    if (_currentLocale == locale) return;

    _currentLocale = locale;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, locale.languageCode);
      await prefs.setString(_countryKey, locale.countryCode ?? '');
    } catch (e) {
      // Ignore storage errors
    }
  }

  static Future<void> setLanguage(
    String languageCode, [
    String? countryCode,
  ]) async {
    await setLocale(Locale(languageCode, countryCode));
  }

  static Future<void> resetToDefault() async {
    await setLocale(const Locale(defaultLanguageCode, defaultCountryCode));
  }

  static bool isEnglish() {
    return _currentLocale.languageCode == 'en';
  }

  static String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'fr':
        return 'Français';
      case 'ar':
        return 'العربية';
      case 'zh':
        return '中文';
      default:
        return languageCode.toUpperCase();
    }
  }

  static String getCurrentLanguageName() {
    return getLanguageName(_currentLocale.languageCode);
  }
}
