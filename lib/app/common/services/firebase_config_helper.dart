import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseConfigHelper {
  static FirebaseOptions? getFirebaseOptions() {
    if (!kIsWeb) {
      debugPrint('Firebase options only needed for web platform');
      return null;
    }

    try {
      return FirebaseOptions(
        apiKey: dotenv.env['FIREBASE_API_KEY'] ?? '',
        authDomain: dotenv.env['FIREBASE_AUTH_DOMAIN'] ?? '',
        projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? '',
        storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '',
        messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '',
        appId: dotenv.env['FIREBASE_APP_ID'] ?? '',
      );
    } catch (e) {
      debugPrint('Error loading Firebase config from .env: $e');
      return null;
    }
  }

  /// Get Firebase config as JavaScript object string for index.html
  static String getFirebaseConfigForHTML() {
    try {
      return '''
      const firebaseConfig = {
        apiKey: "${dotenv.env['FIREBASE_API_KEY'] ?? ''}",
        authDomain: "${dotenv.env['FIREBASE_AUTH_DOMAIN'] ?? ''}",
        projectId: "${dotenv.env['FIREBASE_PROJECT_ID'] ?? ''}",
        storageBucket: "${dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? ''}",
        messagingSenderId: "${dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? ''}",
        appId: "${dotenv.env['FIREBASE_APP_ID'] ?? ''}"
      };
      ''';
    } catch (e) {
      debugPrint('Error generating Firebase config for HTML: $e');
      return '';
    }
  }
}
