import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:samsung_admin_main_new/app/common/constant/app_assets.dart';

/// A reusable glassmorphism-style modal that you can use anywhere.
///
/// Usage:
/// ```dart
/// showCommonModal(
///   context,
///   child: YourContentWidget(),
/// );
/// ```

class CommonModal extends StatelessWidget {
  final String title;
  final String description;
  final Widget? child;
  final double? width;
  final double? height;
  final bool Function()? canDismiss;

  const CommonModal({
    super.key,
    String? title,
    String? description,
    this.child,
    this.width,
    this.height,
    this.canDismiss,
  })  : title = title ?? '',
        description = description ?? '';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            width: width ?? 520,
            height: height, // Respects explicit height if provided
            constraints: const BoxConstraints(maxWidth: 720),
            decoration: BoxDecoration(
              // Using a fallback color if image fails or is missing
              color: Colors.white.withOpacity(0.05),
              image: const DecorationImage(
                image: AssetImage(AppAssets.modalBg),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Shrinks to content
                children: [
                  SizedBox(height: 30),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontFamily: 'samsungsharpsans',
                                fontWeight: FontWeight.w500,
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              description,
                              style: TextStyle(
                                fontFamily: 'samsungsharpsans',
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: Color(0xFFBDBDBD),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16),
                      _buildCloseButton(context),
                    ],
                  ),
                  if (child != null) ...[
                    SizedBox(height: 10),
                    Flexible(
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: child!.paddingOnly(bottom: 30,top: 14),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    if (canDismiss != null) {
      return Obx(() {
        final canDismissValue = canDismiss!();
        return _CloseIconButton(
          onTap: canDismissValue ? () => Navigator.of(context).pop() : null,
          enabled: canDismissValue,
        );
      });
    }
    return _CloseIconButton(onTap: () => Navigator.of(context).pop());
  }
}

/// Internal helper for the stylized close button
class _CloseIconButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool enabled;

  const _CloseIconButton({this.onTap, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: onTap,
        child: Opacity(
          opacity: enabled ? 1.0 : 0.5,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(110),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8.63, sigmaY: 8.63),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(110),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromRGBO(214, 214, 214, 0.2),
                      Color.fromRGBO(112, 112, 112, 0.2),
                    ],
                  ),
                  border: Border.all(
                    width: 1.1,
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 18),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Helper to show [CommonModal] using Flutter's [showDialog].
Future<T?> showCommonModal<T>(
    BuildContext context, {
      required String title,
      required String description,
      Widget? child,
      double? width,
      double? height,
      bool barrierDismissible = true,
      bool Function()? canDismiss,
    }) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (dialogContext) {
      Widget modal = CommonModal(
        title: title,
        description: description,
        width: width,
        height: height,
        canDismiss: canDismiss,
        child: child,
      );

      if (canDismiss != null) {
        return Obx(() {
          final canDismissValue = canDismiss();
          return PopScope(
            canPop: canDismissValue,
            child: _DialogWrapper(
              barrierDismissible: barrierDismissible && canDismissValue,
              child: modal,
            ),
          );
        });
      }

      return _DialogWrapper(
        barrierDismissible: barrierDismissible,
        child: modal,
      );
    },
  );
}

/// Private wrapper to handle dialog styling and barrier logic
class _DialogWrapper extends StatelessWidget {
  final Widget child;
  final bool barrierDismissible;

  const _DialogWrapper({required this.child, required this.barrierDismissible});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (barrierDismissible) Get.back();
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        child: GestureDetector(
          onTap: () {}, // Prevents clicks on modal from closing it
          child: child,
        ),
      ),
    );
  }
}