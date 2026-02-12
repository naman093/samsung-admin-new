import 'package:flutter/material.dart';
import 'package:samsung_admin_main_new/app/app_theme/app_colors.dart';
import 'package:video_player/video_player.dart';
import 'package:get/get.dart';

import '../../../common/header.dart';

class FullScreenVideoDialog extends StatelessWidget {
  final VideoPlayerController controller;

  const FullScreenVideoDialog({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (context, setState) {
      return SafeArea(
        child: SizedBox(
          width: Get.width*.6,
          height: Get.width*.35,
          child: Stack(
            children: [
              Center(
                child: AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: VideoPlayer(controller),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: GlassCircle(
                  icon: Icons.close,
                  onTap: () {
                    controller.pause();
                    Get.back();
                  },
                ),
              ),
              Center(
                child: GestureDetector(
                  onTap: () {
                    setState((){
                      controller.value.isPlaying
                          ? controller.pause()
                          : controller.play();
                    });
                  },
                  child: Icon(
                    controller.value.isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_fill,
                    size: 72,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 12,
                child: ValueListenableBuilder<VideoPlayerValue>(
                  valueListenable: controller,
                  builder: (context, value, child) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(value.position),
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                            Text(
                              _formatDuration(value.duration),
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        VideoProgressIndicator(
                          controller,
                          allowScrubbing: false,
                          colors: VideoProgressColors(
                            playedColor: AppColors.primaryColor,
                            bufferedColor: Colors.white54,
                            backgroundColor: Colors.white24,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },);
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

}
