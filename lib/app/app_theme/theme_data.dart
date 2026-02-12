import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData theme = ThemeData(
    fontFamily: 'samsungsharpsans',
    scaffoldBackgroundColor: AppColors.backgroundColor,
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 30,
        fontFamily: 'samsungsharpsans',
        fontWeight: FontWeight.w400,
        color: Colors.white,
      ),
      displayMedium: TextStyle(
        fontSize: 26,
        fontFamily: 'samsungsharpsans',
        fontWeight: FontWeight.w400,
        color: Colors.white,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontFamily: 'samsungsharpsans',
        fontWeight: FontWeight.w400,
        color: Colors.white,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontFamily: 'samsungsharpsans',
        fontWeight: FontWeight.w400,
        color: Colors.white,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontFamily: 'samsungsharpsans',
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontFamily: 'samsungsharpsans',
        fontWeight: FontWeight.w400,
        color: Colors.white,
      ),
      labelMedium: TextStyle(
        fontSize: 14,
        fontFamily: 'samsungsharpsans',
        fontWeight: FontWeight.w400,
        color: Colors.white,
      ),
    ),
  );
}
