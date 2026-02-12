import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:samsung_admin_main_new/app/app_theme/app_colors.dart';
import 'package:samsung_admin_main_new/app/common/constant/app_assets.dart';

class ProfilePictureWidget extends StatelessWidget {
  final File? imageFile;
  final Uint8List? imageBytes;
  final String? imageUrl;
  final bool isLoading;
  final VoidCallback? onTap;
  final bool showAddText;
  final bool showAddIcon;

  const ProfilePictureWidget({
    super.key,
    this.imageFile,
    this.imageBytes,
    this.imageUrl,
    this.isLoading = false,
    this.onTap,
    this.showAddText = true,
    this.showAddIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 157,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                width: 105,
                height: 105,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: const Alignment(-0.5, -0.8),
                    end: const Alignment(0.5, 0.8),
                    colors: [Colors.white, Colors.white.withOpacity(0)],
                    stops: const [0.0094, 0.8153],
                  ),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, 19),
                      blurRadius: 23,
                      spreadRadius: 0,
                      color: AppColors.cardShadowFeed,
                    ),
                  ],
                ),
                padding: EdgeInsets.all(2),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.profileImgBgColor,
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: imageBytes != null
                            ? Image.memory(imageBytes!, fit: BoxFit.cover)
                            : imageFile != null && !kIsWeb
                            ? Image.file(imageFile!, fit: BoxFit.cover)
                            : imageUrl != null && imageUrl!.isNotEmpty
                            ? Image.network(
                                imageUrl!,
                                key: ValueKey(imageUrl),
                                fit: BoxFit.cover,
                                cacheWidth: null,
                                cacheHeight: null,
                                headers: const {
                                  'Cache-Control':
                                      'no-cache, no-store, must-revalidate',
                                  'Pragma': 'no-cache',
                                  'Expires': '0',
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(color: AppColors.white);
                                },
                              )
                            : null,
                      ),
                    ),
                    if (isLoading)
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    if (!isLoading &&
                        showAddIcon &&
                        imageFile == null &&
                        imageBytes == null &&
                        (imageUrl == null || imageUrl!.isEmpty))
                      Center(
                        child: GestureDetector(
                          onTap: onTap,
                          child: Image.asset(
                            AppAssets.profileImgUpload,
                            width: 43,
                            height: 57,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (showAddText) ...[
            SizedBox(height: 14),
            SizedBox(
              height: 14,
              child: Center(
                child: Text(
                  'addProfilePicture'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    letterSpacing: 0,
                    color: AppColors.lightBlueColor,
                    height: 1,
                  ),
                  textScaler: const TextScaler.linear(1.0),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
