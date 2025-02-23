import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;

class AppLocalizations {
  final Locale locale;
  Map<String, String>? _localizedStrings;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) 
        ?? AppLocalizations(const Locale('en'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // Supported languages
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('hi'), // Hindi
    Locale('bn'), // Bengali
    Locale('te'), // Telugu
    Locale('mr'), // Marathi
    Locale('ta'), // Tamil
    Locale('gu'), // Gujarati
    Locale('kn'), // Kannada
    Locale('pa'), // Punjabi
    Locale('or'), // Odia
    Locale('ml'), // Malayalam
    Locale('ur'), // Urdu
  ];

  Future<bool> load() async {
    try {
      // Load the language JSON file from the assets
      String jsonString = await rootBundle.loadString(
        'assets/languages/${locale.languageCode}.json',
      );
      
      Map<String, dynamic> jsonMap = json.decode(jsonString);

      _localizedStrings = jsonMap.map((key, value) {
        return MapEntry(key, value.toString());
      });

      return true;
    } catch (e) {
      debugPrint('Error loading language file: $e');
      // Load English as fallback if the requested language file fails to load
      if (locale.languageCode != 'en') {
        try {
          String jsonString = await rootBundle.loadString('assets/languages/en.json');
          Map<String, dynamic> jsonMap = json.decode(jsonString);
          
          _localizedStrings = jsonMap.map((key, value) {
            return MapEntry(key, value.toString());
          });
        } catch (e) {
          debugPrint('Error loading fallback language file: $e');
          _localizedStrings = {};
        }
      } else {
        _localizedStrings = {};
      }
      return false;
    }
  }

  String translate(String key) {
    if (_localizedStrings == null) {
      return key;
    }
    
    final String? value = _localizedStrings![key];
    if (value == null || value.isEmpty) {
      // If translation is missing, try to load it from English
      if (locale.languageCode != 'en') {
        // You might want to implement a mechanism to load the English translation
        // for this specific key as a fallback
        return key;
      }
      return key;
    }
    return value;
  }

  // Helper method to get the display name of the current language
  String get languageName {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'hi':
        return 'हिंदी';
      case 'bn':
        return 'বাংলা';
      case 'te':
        return 'తెలుగు';
      case 'mr':
        return 'मराठी';
      case 'ta':
        return 'தமிழ்';
      case 'gu':
        return 'ગુજરાતી';
      case 'kn':
        return 'ಕನ್ನಡ';
      case 'pa':
        return 'ਪੰਜਾਬੀ';
      case 'or':
        return 'ଓଡ଼ିଆ';
      case 'ml':
        return 'മലയാളം';
      case 'ur':
        return 'اردو';
      default:
        return 'English';
    }
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'hi', 'bn', 'te', 'mr', 'ta', 'gu', 'kn', 'pa', 'or', 'ml', 'ur']
        .contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}