import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConsts {
  static const String appName = 'Samsung Community Admin';
  static const String currentLocale = "currentLocale";
  
  // Supabase configuration from .env file
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  
  // Add other configuration constants here as needed
}

