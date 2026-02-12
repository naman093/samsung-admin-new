import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LanguageController extends GetxController {
  static const String _localeKey = 'current_locale';
  final _storage = GetStorage();

  String _currentLocale = 'en_US';

  String get currentLocale => _currentLocale;

  @override
  void onInit() {
    super.onInit();
    // Load saved locale from storage
    if (_storage.hasData(_localeKey)) {
      _currentLocale = _storage.read(_localeKey) ?? 'en_US';
      // Update GetX locale
      Get.updateLocale(
        Locale(_currentLocale.split('_')[0], _currentLocale.split('_')[1]),
      );
    }
  }

  /// Change language and persist it
  void changeLanguage(String languageCode) {
    _currentLocale = languageCode;
    // Save to persistent storage
    _storage.write(_localeKey, _currentLocale);
    // Update GetX locale (this will update the UI automatically)
    final parts = languageCode.split('_');
    Get.updateLocale(Locale(parts[0], parts.length > 1 ? parts[1] : ''));
    update(); // Notify listeners
  }

  /// Get available languages
  static List<LanguageOption> get languages => [
    LanguageOption(
      id: 'en_US',
      name: 'English', // Will be translated via 'english' key
      locale: 'en_US',
      boxText: 'EN',
      translationKey: 'english',
    ),
    LanguageOption(
      id: 'he_IL',
      name: 'Hebrew', // Will be translated via 'hebrew' key
      locale: 'he_IL',
      boxText: 'HE',
      translationKey: 'hebrew',
    ),
  ];
}

class LanguageOption {
  final String id;
  final String name;
  final String locale;
  final String boxText;
  final String translationKey;

  LanguageOption({
    required this.id,
    required this.name,
    required this.locale,
    required this.boxText,
    required this.translationKey,
  });
}
