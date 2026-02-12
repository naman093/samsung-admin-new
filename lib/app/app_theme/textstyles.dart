import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Centralized text styles for the app.
///
/// These helpers **optionally** take a [BuildContext]. If not provided, they
/// fall back to `Get.context`. This keeps the API simple at call‑sites while
/// still allowing local theming when needed.
class AppTextStyles {
  AppTextStyles._();

  /// Safely get a text style from the current theme.
  /// Prefer passing an explicit [context]; otherwise falls back to [Get.context].
  static TextStyle? _fromTheme(
    TextStyle? Function(TextTheme theme) selector, {
    BuildContext? context,
    required TextStyle fallback,
  }) {
    final BuildContext? ctx = context ?? Get.context;
    if (ctx == null) return fallback;

    final textTheme = Theme.of(ctx).textTheme;
    return selector(textTheme) ?? fallback;
  }

  static TextStyle rubik30w400({BuildContext? context}) => _fromTheme(
    (theme) => theme.displayLarge,
    context: context,
    fallback: const TextStyle(
      fontFamily: 'samsungsharpsans',
      fontSize: 30,
      fontWeight: FontWeight.w400,
    ),
  )!;

  static TextStyle rubik26w400({BuildContext? context}) => _fromTheme(
    (theme) => theme.displayMedium,
    context: context,
    fallback: const TextStyle(
      fontFamily: 'samsungsharpsans',
      fontSize: 26,
      fontWeight: FontWeight.w400,
    ),
  )!;

  static TextStyle rubik24w400({BuildContext? context}) => _fromTheme(
    (theme) => theme.displaySmall,
    context: context,
    fallback: const TextStyle(
      fontFamily: 'samsungsharpsans',
      fontSize: 24,
      fontWeight: FontWeight.w400,
    ),
  )!;

  static TextStyle rubik16w400({BuildContext? context}) => _fromTheme(
    (theme) => theme.bodyLarge,
    context: context,
    fallback: const TextStyle(
      fontFamily: 'samsungsharpsans',
      fontSize: 16,
      fontWeight: FontWeight.w400,
    ),
  )!;

  static TextStyle rubik14w500({BuildContext? context}) => _fromTheme(
    (theme) => theme.bodyMedium,
    context: context,
    fallback: const TextStyle(
      fontFamily: 'samsungsharpsans',
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
  )!;

  static TextStyle rubik14w400({BuildContext? context}) => _fromTheme(
    (theme) => theme.labelMedium,
    context: context,
    fallback: const TextStyle(
      fontFamily: 'samsungsharpsans',
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
  )!;

  static TextStyle rubik12w400({BuildContext? context}) => _fromTheme(
    (theme) => theme.bodySmall,
    context: context,
    fallback: const TextStyle(
      fontFamily: 'samsungsharpsans',
      fontSize: 12,
      fontWeight: FontWeight.w400,
    ),
  )!;
}
