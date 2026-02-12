import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app_theme/app_colors.dart';

class CustomTimeIntervalPicker {
  const CustomTimeIntervalPicker._();

  static Map<String, int> parseInterval(String value) {
    if (value.isEmpty) return {'days': 0, 'hours': 0, 'minutes': 0};

    final parts = value.split(':');
    if (parts.length != 3) return {'days': 0, 'hours': 0, 'minutes': 0};

    final days = int.tryParse(parts[0]) ?? 0;
    final hours = int.tryParse(parts[1]) ?? 0;
    final minutes = int.tryParse(parts[2]) ?? 0;

    return {'days': days, 'hours': hours, 'minutes': minutes};
  }

  static String formatInterval(int days, int hours, int minutes) {
    return '$days:$hours:$minutes';
  }

  static Future<void> pickInterval({
    required TextEditingController controller,
  }) async {
    final currentInterval = parseInterval(controller.text);
    int days = currentInterval['days'] ?? 0;
    int hours = currentInterval['hours'] ?? 0;
    int minutes = currentInterval['minutes'] ?? 0;

    await showDialog(
      context: Get.context!,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.darkGreyColor,
              title: Text(
                'selectInterval'.tr,
                style: const TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'days'.tr,
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.remove_circle,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    if (days > 0) {
                                      setState(() => days--);
                                    }
                                  },
                                ),
                                SizedBox(
                                  width: 60,
                                  child: Text(
                                    days.toString(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.add_circle,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    setState(() => days++);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'hours'.tr,
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.remove_circle,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    if (hours > 0) {
                                      setState(() => hours--);
                                    }
                                  },
                                ),
                                SizedBox(
                                  width: 60,
                                  child: Text(
                                    hours.toString(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.add_circle,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    if (hours < 23) {
                                      setState(() => hours++);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'minutes'.tr,
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.remove_circle,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    if (minutes > 0) {
                                      setState(() => minutes--);
                                    }
                                  },
                                ),
                                SizedBox(
                                  width: 60,
                                  child: Text(
                                    minutes.toString(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.add_circle,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    if (minutes < 59) {
                                      setState(() => minutes++);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('cancel'.tr),
                ),
                TextButton(
                  onPressed: () {
                    controller.text = formatInterval(days, hours, minutes);
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'save'.tr,
                    style: TextStyle(color: AppColors.primaryColor),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
