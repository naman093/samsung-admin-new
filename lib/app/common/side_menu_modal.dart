import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../app_theme/app_colors.dart';
import 'language_selector.dart';

class SideMenuModal extends StatelessWidget {
  const SideMenuModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const SideMenuModal(),
    );
  }

  void _handleLanguage(BuildContext context) {
    Navigator.of(context).pop();
    LanguageSelector.show(context);
  }

  void _handleSettings(BuildContext context) {
    Navigator.of(context).pop();
    // TODO: Navigate to settings screen
  }

  void _handleProfile(BuildContext context) {
    Navigator.of(context).pop();
    // TODO: Navigate to profile screen
  }

  void _handleLogout(BuildContext context) {
    Navigator.of(context).pop();
    _showLogoutConfirmation(context);
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'logout'.tr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'wantLogout'.tr,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'no'.tr,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _performLogout();
              },
              child: Text(
                'yes'.tr,
                style: const TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout() async {
    try {
      // TODO: Implement actual logout logic
      // final authController = Get.find<AuthController>();
      // await authController.signOut();
      // AppNavigation.pushAndRemoveUntil(AppRoutes.login);
    } catch (e) {
      // Handle logout error silently
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'menu'.tr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _MenuItem(
            icon: Icons.person,
            label: 'profile'.tr,
            onTap: () => _handleProfile(context),
          ),
          const SizedBox(height: 12),
          _MenuItem(
            icon: Icons.language,
            label: 'language'.tr,
            onTap: () => _handleLanguage(context),
          ),
          const SizedBox(height: 12),
          _MenuItem(
            icon: Icons.settings,
            label: 'settings'.tr,
            onTap: () => _handleSettings(context),
          ),
          const SizedBox(height: 12),
          _MenuItem(
            icon: Icons.logout,
            label: 'logout'.tr,
            onTap: () => _handleLogout(context),
            isDestructive: true,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDestructive ? Colors.red.withOpacity(0.3) : Colors.white24,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red : Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isDestructive ? Colors.red : Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
