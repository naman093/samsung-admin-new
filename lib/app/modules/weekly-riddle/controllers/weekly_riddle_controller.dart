import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:samsung_admin_main_new/app/common/common_dialogs/confirmation_dialog.dart';
import 'package:samsung_admin_main_new/app/common/common_snackbar.dart';
import 'package:samsung_admin_main_new/app/common/core/utils/result.dart';
import 'package:samsung_admin_main_new/app/models/riddle_submission_model.dart';
import 'package:samsung_admin_main_new/app/models/weekly_riddle_model.dart';
import 'package:samsung_admin_main_new/app/repository/weekly_riddle_repo.dart';
import 'package:video_player/video_player.dart';
import '../../../app_theme/app_colors.dart';
import '../local_widget/submission_dialog.dart';
import '../local_widget/view_all_submissions.dart';

class WeeklyRiddleController extends GetxController {
  final Map<String, String> shortByLabelMap = {
    'all': 'All',
    'Text': 'Text',
    'Audio': 'Audio',
    'MCQ': 'MCQ',
  };

  final Map<String, String> taskTypeLabelMap = {
    'Text': 'Text',
    'Audio': 'Audio',
    'MCQ': 'MCQ',
  };

  final shortByList = ['All', 'Text', 'Audio', 'MCQ'];
  final taskTypeList = ['Text', 'Audio', 'MCQ'];
  final selectedShortByValue = 'all'.obs;
  final selectedTaskTypeValue = 'Text'.obs;

  final Map<String, String> sortByLabelMap = {
    'all': 'All',
    'vod': 'VOD',
    'podcast': 'Podcast',
  };

  final sortByList = ['all', 'vod', 'podcast'];
  final selectedSortByValue = 'all'.obs;

  final isEditing = false.obs;
  final editingContentId = ''.obs;

  final startDateController = TextEditingController();
  final endDateController = TextEditingController();
  final missionEndTimeController = TextEditingController();
  final totalPointsController = TextEditingController();
  final missionNameController = TextEditingController();
  final Rx<PlatformFile?> missionImageController = Rx<PlatformFile?>(null);
  final descriptionController = TextEditingController();
  final correctAnswerController = TextEditingController();
  final RxList<TextEditingController> optionControllers =
      <TextEditingController>[].obs;
  final weeklyRiddleList = <WeeklyRiddleModel>[].obs;
  final weeklyRiddleSubmissionList = <RiddleSubmissionModel>[].obs;
  final isLoading = false.obs;
  final isLoadingSubmissions = false.obs;
  final isCreateContentBtnValue = false.obs;
  final shouldOpenFlyout = false.obs;

  final titleError = ''.obs;
  final descriptionError = ''.obs;
  final correctAnswerError = ''.obs;
  final startDateError = ''.obs;
  final endDateError = ''.obs;
  final missionEndTimeError = ''.obs;
  final totalPointsError = ''.obs;
  final missionNameError = ''.obs;
  final isAlreadyAudioSelected = false.obs;

  final weeklyRiddleRepo = Get.find<WeeklyRiddleRepo>();

  final currentPage = 1.obs;
  final perPage = 8.obs;
  final totalPages = 1.obs;
  final totalCount = 0.obs;
  final hasMore = true.obs;
  final isLoadingMore = false.obs;
  late ScrollController scrollController;
  bool _isScrollControllerDisposed = false;

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);
    addOption();
    fetchWeeklyRiddleList();
  }

  @override
  void onReady() {
    super.onReady();
    if (Get.arguments != null &&
        Get.arguments is Map &&
        Get.arguments['openFlyout'] == true) {
      clearAllFields();
      shouldOpenFlyout.value = true;
    }
  }

  @override
  void onClose() {
    if (!_isScrollControllerDisposed) {
      scrollController.removeListener(_onScroll);
      scrollController.dispose();
      _isScrollControllerDisposed = true;
    }
    correctAnswerController.dispose();
    for (var controller in optionControllers) {
      controller.dispose();
    }
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200 &&
        !isLoadingMore.value &&
        !isLoading.value &&
        hasMore.value) {
      loadMore();
    }
  }

  void addOption() {
    optionControllers.add(TextEditingController());
  }

  void removeOption(int index) {
    if (optionControllers.length > 1) {
      optionControllers[index].dispose();
      optionControllers.removeAt(index);
    }
  }

  void setSelectedThumbnailUrlFile(PlatformFile? file) {
    missionImageController.value = file;
    if (file != null) {
      titleError.value = '';
    }
  }

  void prefillFormForEdit(WeeklyRiddleModel weeklyRiddle) {
    isEditing.value = true;
    editingContentId.value = weeklyRiddle.id;
    startDateController.text = DateFormat(
      'dd-MM-yyyy',
    ).format(weeklyRiddle.startDate);
    endDateController.text = DateFormat(
      'dd-MM-yyyy',
    ).format(weeklyRiddle.endDate);
    missionNameController.text = weeklyRiddle.title;
    descriptionController.text = weeklyRiddle.description ?? '';
    totalPointsController.text = weeklyRiddle.pointsToEarn.toString();
    selectedTaskTypeValue.value = weeklyRiddle.solutionType;

    if (weeklyRiddle.endTime != null) {
      missionEndTimeController.text = DateFormat(
        'HH:mm',
      ).format(weeklyRiddle.endTime!);
    }

    // Fill Answer
    if (weeklyRiddle.answer != null && weeklyRiddle.solutionType != 'Audio') {
      correctAnswerController.text = weeklyRiddle.answer!;
    }

    if (weeklyRiddle.answer != null && weeklyRiddle.solutionType == 'Audio') {
      isAlreadyAudioSelected.value = true;
    }

    // Fill Options (Question field for MCQ)
    if (weeklyRiddle.solutionType == 'MCQ') {
      final options = weeklyRiddle.question;
      if (options is List) {
        optionControllers.clear();
        for (var option in options) {
          optionControllers.add(TextEditingController(text: option.toString()));
        }
      }
    }

    // Fallback for legacy data (textSolutions)
    if (correctAnswerController.text.isEmpty &&
        weeklyRiddle.textSolutions != null) {
      correctAnswerController.text =
          weeklyRiddle.textSolutions!['correct_answer'] ?? '';
      final List<dynamic>? options = weeklyRiddle.textSolutions!['options'];
      if (options != null && optionControllers.isEmpty) {
        optionControllers.clear();
        for (var option in options) {
          optionControllers.add(TextEditingController(text: option.toString()));
        }
      }
    }

    missionImageController.value = null;
    titleError.value = '';
  }

  void clearAllFields() {
    isEditing.value = false;
    editingContentId.value = '';
    selectedTaskTypeValue.value = 'Text';
    startDateController.clear();
    endDateController.clear();
    missionEndTimeController.clear();
    totalPointsController.clear();
    missionNameController.clear();
    missionImageController.value = null;
    descriptionController.clear();
    correctAnswerController.clear();
    optionControllers.clear();
    isAlreadyAudioSelected.value = false;
    addOption();
  }

  void clearError() {
    titleError.value = '';
    descriptionError.value = '';
    startDateError.value = '';
    endDateError.value = '';
    missionEndTimeError.value = '';
    totalPointsError.value = '';
    missionNameError.value = '';
    correctAnswerError.value = '';
  }

  bool validateFields() {
    bool hasError = false;
    titleError.value = '';
    descriptionError.value = '';
    startDateError.value = '';
    endDateError.value = '';
    missionEndTimeError.value = '';
    totalPointsError.value = '';
    missionNameError.value = '';
    correctAnswerError.value = '';

    if (missionNameController.text.isEmpty) {
      missionNameError.value = 'missionNameRequired'.tr;
      hasError = true;
    }
    if (totalPointsController.text.isEmpty) {
      totalPointsError.value = 'totalPointsToWinRequired'.tr;
      hasError = true;
    }
    if (descriptionController.text.isEmpty) {
      descriptionError.value = 'descriptionRequired'.tr;
      hasError = true;
    } else {
      final words = descriptionController.text
          .trim()
          .split(RegExp(r'\s+'))
          .length;
      if (words > 1000) {
        descriptionError.value = "Description can't exceed 1000 words";
        hasError = true;
      }
    }
    if (correctAnswerController.text.isEmpty &&
        selectedTaskTypeValue.value != 'Audio') {
      correctAnswerError.value = 'correctAnswerRequired'.tr;
      hasError = true;
    }
    for (var i = 0; i < optionControllers.length; i++) {
      if (optionControllers[i].text.isEmpty &&
          selectedTaskTypeValue.value == 'MCQ') {
        CommonSnackbar.error('${'option'.tr} ${i + 1} ${'isRequired'.tr}');
        hasError = true;
      }
    }
    if (startDateController.text.isEmpty) {
      startDateError.value = 'startDateRequired'.tr;
      hasError = true;
    }
    if (endDateController.text.isEmpty) {
      endDateError.value = 'endDateRequired'.tr;
      hasError = true;
    }
    if (selectedTaskTypeValue.value == 'Audio' &&
        (missionImageController.value == null ||
            missionImageController.value!.name.isEmpty)) {
      titleError.value = 'fileIsRequired'.tr;
      hasError = true;
    }
    if (missionEndTimeController.text.isEmpty) {
      missionEndTimeError.value = 'missionEndTimeRequired'.tr;
      hasError = true;
    }
    return hasError;
  }

  void resetPage() {
    currentPage.value = 1;
    hasMore.value = true;
    weeklyRiddleList.clear();
    if (scrollController.hasClients) {
      scrollController.jumpTo(0);
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value ||
        !hasMore.value ||
        currentPage.value >= totalPages.value) {
      return;
    }
    currentPage.value++;
    await fetchWeeklyRiddleList(append: true);
  }

  Future<void> fetchWeeklyRiddleList({
    String? searchTerm,
    String? shortBy,
    bool append = false,
  }) async {
    if (append) {
      isLoadingMore.value = true;
    } else {
      isLoading.value = true;
      weeklyRiddleList.clear();
      currentPage.value = 1;
      hasMore.value = true;
    }
    try {
      String normalizedShortBy = 'all';
      if (shortBy != null && shortBy.isNotEmpty) {
        final lowerShortBy = shortBy.toLowerCase();
        if (lowerShortBy == 'all') {
          normalizedShortBy = 'all';
        } else {
          normalizedShortBy = shortBy;
        }
      } else {
        normalizedShortBy = selectedShortByValue.value;
      }

      final response = await weeklyRiddleRepo.getWeeklyRiddlesWithPagination(
        pageNumber: currentPage.value,
        perPage: perPage.value,
        searchTerm: searchTerm ?? '',
        shortBy: normalizedShortBy,
      );
      totalCount.value = response.totalCount;
      totalPages.value = response.totalPages;
      if (append) {
        weeklyRiddleList.addAll(response.data);
      } else {
        weeklyRiddleList.value = response.data;
      }
      hasMore.value = currentPage.value < totalPages.value;
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> fetchWeeklyRiddleSubmissions({String riddleId = ''}) async {
    isLoadingSubmissions.value = true;
    try {
      final response = await weeklyRiddleRepo.getRiddleSubmissions(
        riddleId: riddleId,
      );
      weeklyRiddleSubmissionList.value = response.data;
    } catch (e) {
      debugPrint('Error fetching submissions: ${e.toString()}');
    } finally {
      isLoadingSubmissions.value = false;
    }
  }

  Future<void> deleteContent(String riddleId) async {
    try {
      await WeeklyRiddleRepo().deleteRiddle(riddleId);
      fetchWeeklyRiddleList();
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      Get.back();
    }
  }

  Future<void> clickOnDeleteBtn(String riddleId) async {
    CMDialogs.showConfirmationDialog(
      title: 'confirmDeletion'.tr,
      subtitle: 'areYouSureYouWantToDeleteThisRiddle'.tr,
      onPressed: () => deleteContent(riddleId),
    );
  }

  Future<void> createWeeklyRiddle() async {
    final hasValidationError = validateFields();
    if (hasValidationError) return;

    if (selectedTaskTypeValue.value == 'MCQ') {
      final text = correctAnswerController.text;

      final exists = optionControllers.any(
        (controller) => controller.text == text,
      );

      if (!exists) {
        optionControllers.add(TextEditingController(text: text));
      }
    }
    final startText = startDateController.text.trim();
    final endText = endDateController.text.trim();
    if (startText.isEmpty || endText.isEmpty) return;
    DateTime startDateValue;
    DateTime endDateValue;
    try {
      startDateValue = DateFormat('dd-MM-yyyy').parse(startText);
      endDateValue = DateFormat(
        'dd-MM-yyyy',
      ).parse(endText).add(const Duration(hours: 23, minutes: 59, seconds: 59));
    } on FormatException {
      CommonSnackbar.error('invalidDateFormat'.tr);
      return;
    }
    isCreateContentBtnValue.value = true;
    try {
      final response = await WeeklyRiddleRepo.createRiddle(
        solutionType: selectedTaskTypeValue.value,
        startDate: startDateValue.toIso8601String(),
        endDate: endDateValue.toIso8601String(),
        endTime: missionEndTimeController.text,
        missionEndTime: missionEndTimeController.text,
        pointsToEarn:
            int.tryParse(totalPointsController.text)?.toString() ?? "0",
        title: missionNameController.text,
        description: descriptionController.text,
        correctAnswer: correctAnswerController.text,
        options: optionControllers.map((e) => e.text).toList(),
        fileBytes: missionImageController.value?.bytes ?? Uint8List(0),
        fileName: missionImageController.value?.name ?? '',
      );

      Get.back();

      if (response.isSuccess) {
        CommonSnackbar.success('weeklyRiddleCreatedSuccessfully'.tr);
        fetchWeeklyRiddleList();
      } else {
        CommonSnackbar.error('weeklyRiddleCreationFailed'.tr);
      }
    } finally {
      clearAllFields();
      isCreateContentBtnValue.value = false;
    }
  }

  Future<void> updateRiddle() async {
    if (validateFields()) return;
    final startText = startDateController.text.trim();
    final endText = endDateController.text.trim();
    if (startText.isEmpty || endText.isEmpty) return;
    DateTime startDateValue;
    DateTime endDateValue;
    try {
      startDateValue = DateFormat('dd-MM-yyyy').parse(startText);
      endDateValue = DateFormat(
        'dd-MM-yyyy',
      ).parse(endText).add(const Duration(hours: 23, minutes: 59, seconds: 59));
    } on FormatException {
      CommonSnackbar.error('invalidDateFormat'.tr);
      return;
    }
    isCreateContentBtnValue.value = true;
    try {
      final response = await WeeklyRiddleRepo.updateRiddle(
        riddleId: editingContentId.value,
        title: missionNameController.text,
        description: descriptionController.text,
        startDate: startDateValue.toIso8601String(),
        solutionType: selectedTaskTypeValue.value,
        endDate: endDateValue.toIso8601String(),
        endTime: missionEndTimeController.text,
        pointsToEarn:
            int.tryParse(totalPointsController.text)?.toString() ?? "0",
        correctAnswer: correctAnswerController.text,
        options: optionControllers.map((e) => e.text).toList(),
        fileBytes: missionImageController.value?.bytes ?? Uint8List(0),
        fileName: missionImageController.value?.name ?? '',
      );

      Get.back();

      if (response.isSuccess) {
        CommonSnackbar.success('weeklyRiddleUpdatedSuccessfully'.tr);
        fetchWeeklyRiddleList();
      } else {
        CommonSnackbar.error('weeklyRiddleUpdateFailed'.tr);
      }
    } finally {
      clearAllFields();
      isCreateContentBtnValue.value = false;
    }
  }

  Future<void> updateSubmissionStatus({
    required String submissionId,
    required bool isCorrect,
    required String riddleId,
  }) async {
    try {
      final response = await weeklyRiddleRepo.updateSubmissionStatus(
        submissionId: submissionId,
        isCorrect: isCorrect,
      );

      if (response.isSuccess) {
        CommonSnackbar.success('Submission status updated successfully');
        // Refetch submissions
        await fetchWeeklyRiddleSubmissions(riddleId: riddleId);
      } else {
        CommonSnackbar.error('Failed to update submission status');
      }
    } catch (e) {
      debugPrint('Error updating submission status: ${e.toString()}');
      CommonSnackbar.error('Error updating submission status');
    }
  }

  void showImagePreviewDialog(RiddleSubmissionModel submission) {
    final type = detectSolutionType(submission.solution ?? '');

    VideoPlayerController? videoController;
    if (type == SolutionType.video || type == SolutionType.audio) {
      videoController = VideoPlayerController.networkUrl(
        Uri.parse(submission.solution ?? ''),
      );
    }

    showDialog(
      context: Get.context!,
      barrierDismissible: true,
      barrierColor: AppColors.backgroundColor.withValues(alpha: .9),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: SubmissionDialogView(
            type: type,
            submission: submission,
            videoController: videoController,
          ),
        );
      },
    ).then((_) {
      videoController?.dispose();
    });
  }
}
