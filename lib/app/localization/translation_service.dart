import 'dart:ui';
import 'package:get/get.dart';
import 'en_us.dart';
import 'he_li.dart';


class TranslationService extends Translations{

  static Locale? get locale =>Get.locale;

  static const fallbackLocale = Locale('en');

  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': en_US,
    'he_IL': he_IL,
  };
}