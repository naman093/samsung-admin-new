import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../../app_theme/app_colors.dart';
import '../../../app_theme/textstyles.dart';
import '../../../common/common_flyout.dart';
import '../../../common/constant/app_assets.dart';
import '../../../common/widgets/asset_image_widget.dart';
import '../../../common/widgets/common_widget.dart';
import '../../../repository/academy_repo.dart';
import '../../../repository/weekly_riddle_repo.dart';
import '../controllers/users_controller.dart';

class UserSubmissionDialogView extends StatelessWidget {
  final Map<String, dynamic> submission;
  final String type; // 'Assignment' or 'Riddle'
  final SolutionType solutionType;
  final VideoPlayerController? videoController;

  const UserSubmissionDialogView({
    super.key,
    required this.submission,
    required this.type,
    required this.solutionType,
    this.videoController,
  });

  @override
  Widget build(BuildContext context) {
    final solution = submission['solution'] as String? ?? '';
    final isAlreadyAnswerChecked = submission['is_correct'] != null;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FlyoutCloseButton(onTap: () => Get.back()),
                FlyoutCloseButton(
                  radius: 10,
                  onTap: () => Get.back(),
                  icon: Icon(Icons.download, color: Colors.white, size: 24),
                ),
              ],
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: Get.height * 0.5,
                        ),
                        child: _buildSolutionPreview(
                          solutionType,
                          solution,
                          videoController,
                        ),
                      ),
                    ),
                    if ((type == 'Assignment' || type == 'Riddle') &&
                        !isAlreadyAnswerChecked) ...[
                      SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _actionButton(
                            icon: AppAssets.clearIc,
                            onTap: () async {
                              try {
                                final controller = Get.find<UsersController>();
                                final submissionId =
                                    submission['id'] as String?;

                                if (submissionId == null) {
                                  Get.back();
                                  return;
                                }

                                bool success = false;
                                if (type == 'Assignment') {
                                  final academyRepo = AcademyRepo();
                                  success = await academyRepo.verifySubmission(
                                    submissionId: submissionId,
                                    status: false,
                                  );
                                } else if (type == 'Riddle') {
                                  final weeklyRiddleRepo = WeeklyRiddleRepo();
                                  success = await weeklyRiddleRepo
                                      .verifySubmission(
                                        submissionId: submissionId,
                                        status: false,
                                      );
                                }

                                if (success &&
                                    controller.selectedUser.value != null) {
                                  await controller.fetchUserTaskSubmissions(
                                    controller.selectedUser.value!.id,
                                  );
                                }

                                Get.back();
                              } catch (e) {
                                debugPrint('❌ Error rejecting submission: $e');
                                Get.back();
                              }
                            },
                          ),
                          SizedBox(width: 40),
                          _actionButton(
                            icon: AppAssets.checkIc,
                            onTap: () async {
                              try {
                                final controller = Get.find<UsersController>();
                                final submissionId =
                                    submission['id'] as String?;

                                if (submissionId == null) {
                                  Get.back();
                                  return;
                                }

                                bool success = false;
                                if (type == 'Assignment') {
                                  final academyRepo = AcademyRepo();
                                  success = await academyRepo.verifySubmission(
                                    submissionId: submissionId,
                                    status: true,
                                  );
                                } else if (type == 'Riddle') {
                                  final weeklyRiddleRepo = WeeklyRiddleRepo();
                                  success = await weeklyRiddleRepo
                                      .verifySubmission(
                                        submissionId: submissionId,
                                        status: true,
                                      );
                                }

                                if (success &&
                                    controller.selectedUser.value != null) {
                                  await controller.fetchUserTaskSubmissions(
                                    controller.selectedUser.value!.id,
                                  );
                                }

                                Get.back();
                              } catch (e) {
                                debugPrint('❌ Error approving submission: $e');
                                Get.back();
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSolutionPreview(
    SolutionType type,
    String source,
    VideoPlayerController? controller,
  ) {
    switch (type) {
      case SolutionType.image:
        return CommonWidget.commonNetworkImageView(
          imageUrl: source,
          fit: BoxFit.contain,
          width: double.infinity,
          height: Get.height * .45,
        );

      case SolutionType.video:
      case SolutionType.audio:
        if (controller == null) return Text("Error loading media");
        return FutureBuilder(
          future: controller.initialize(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return _audioView(controller);
            }
            return CommonWidget.isLoadingAndEmptyWidget();
          },
        );

      case SolutionType.text:
      default:
        return Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            source,
            style: AppTextStyles.rubik14w400().copyWith(color: Colors.white),
          ),
        );
    }
  }

  Widget _audioView(VideoPlayerController videoController) {
    return StatefulBuilder(
      builder: (context, setState) {
        return SizedBox(
          width: Get.width * .6,
          height: Get.width * .35,
          child: Stack(
            children: [
              Center(
                child: AspectRatio(
                  aspectRatio: videoController.value.aspectRatio,
                  child: VideoPlayer(videoController),
                ),
              ),
              Center(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      videoController.value.isPlaying
                          ? videoController.pause()
                          : videoController.play();
                    });
                  },
                  child: Icon(
                    videoController.value.isPlaying
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
                  valueListenable: videoController,
                  builder: (context, value, child) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(value.position),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              _formatDuration(value.duration),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        VideoProgressIndicator(
                          videoController,
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
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Widget _actionButton({required String icon, required VoidCallback onTap}) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: AssetImageWidget(imagePath: icon, height: 50, width: 50),
      ),
    );
  }
}
