import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:samsung_admin_main_new/app/repository/auth_repo/auth_repo.dart';
import 'package:toastification/toastification.dart';
import 'app/localization/language_controller.dart';
import 'app/app_theme/theme_data.dart';
import 'app/common/constant/app_consts.dart';
import 'app/common/constant/app_strings.dart';
// import 'app/common/base_layout.dart';
import 'app/common/services/get_prefs.dart';
import 'app/common/services/supabase_service.dart';
import 'app/common/services/firebase_notification_service.dart';
import 'app/common/services/firebase_config_helper.dart';
import 'app/localization/translation_service.dart';
import 'app/routes/app_pages.dart';

Locale _getLocaleFromString(String localeString) {
  final parts = localeString.split('_');
  return Locale(parts[0], parts.length > 1 ? parts[1] : '');
}

/// Read saved locale from storage, or fall back to English.
Locale _getSavedOrDefaultLocale() {
  final box = GetStorage();
  final saved = box.read('current_locale') as String?;
  if (saved != null && saved.isNotEmpty) {
    return _getLocaleFromString(saved);
  }
  return _getLocaleFromString('en_US');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await GetPrefs.init();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Warning: .env file not found, using default values: $e');
  }

  // Initialize Firebase for web platform
  if (kIsWeb) {
    try {
      // Get Firebase options from environment variables
      final firebaseOptions = FirebaseConfigHelper.getFirebaseOptions();
      
      if (firebaseOptions != null) {
        // Firebase is also initialized via JavaScript in index.html
        // Here we initialize it in Dart for Flutter to use
        await Firebase.initializeApp(options: firebaseOptions);
        debugPrint('Firebase initialized successfully for web');
      } else {
        debugPrint('Warning: Firebase config not found in .env file');
        debugPrint('Note: Add Firebase config to .env file or update index.html manually');
      }
    } catch (e) {
      debugPrint('Error initializing Firebase: $e');
      debugPrint('Note: Make sure Firebase config is set in .env file and index.html');
    }
  }

  await SupabaseService.initialize(
    supabaseUrl: AppConsts.supabaseUrl,
    supabaseAnonKey: AppConsts.supabaseAnonKey,
  );

  // Register global controllers
  Get.put(LanguageController(), permanent: true);
  Get.put(AuthRepo(), permanent: true);
  
  // Initialize Firebase Notification Service (web only)
  if (kIsWeb) {
    Get.put(FirebaseNotificationService(), permanent: true);
  }

  runApp(
    ToastificationWrapper(
      child: GetMaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        enableLog: true,
        translations: TranslationService(),
        fallbackLocale: TranslationService.fallbackLocale,
        theme: AppTheme.theme,
        locale: _getSavedOrDefaultLocale(),
        defaultTransition: Transition.fade,
        transitionDuration: const Duration(milliseconds: 0),
        initialRoute: AppPages.INITIAL,
        getPages: AppPages.routes,
      ),
    ),
  );
}
