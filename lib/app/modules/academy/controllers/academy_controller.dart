import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'package:universal_html/html.dart' as html;

import '../../../app_theme/app_colors.dart';
import 'package:samsung_admin_main_new/app/common/services/storage_service.dart';
import '../../../common/common_dialogs/confirmation_dialog.dart';
import '../../../common/common_snackbar.dart';
import '../../../models/academy_content_model.dart';
import '../../../models/academy_content_view_model.dart';
import '../../../models/assignment_submission_model.dart';
import '../../../repository/academy_repo.dart';
import '../../weekly-riddle/local_widget/view_all_submissions.dart';
import '../local_widget/assigment_submission_dialog.dart';
import '../local_widget/forms/academy_mission_challenge_form.dart';
import '../local_widget/upload_post_flyout.dart';

class AcademyController extends GetxController {
  final selectedType = AcademyPostType.vod.obs;
  final selectedMissionTaskType = MissionTaskType.mcq.obs;
  final missionTaskTypes = MissionTaskType.values;

  final videoNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final totalPointController = TextEditingController();

  final workshopDateController = TextEditingController();
  final startTimeController = TextEditingController();
  final endTimeController = TextEditingController();
  final nameOfWorkshopController = TextEditingController();
  final zoomLinkController = TextEditingController();

  final costOfParticipationInPointsController = TextEditingController();
  final costOfParticipationInCreditController = TextEditingController();

  final taskStartDateController = TextEditingController();
  final taskCompletionDateController = TextEditingController();
  final missionEndTimeController = TextEditingController();
  final missionNameController = TextEditingController();
  final correctAnswerController = TextEditingController();

  final listMissionChallengeAnotherField =
      <AcademyMissionChallengeAnotherFieldModel>[].obs;

  final Rx<PlatformFile?> selectedAudioFile = Rx<PlatformFile?>(null);
  final Rx<PlatformFile?> selectedVODFile = Rx<PlatformFile?>(null);
  final Rx<PlatformFile?> selectedZoomFile = Rx<PlatformFile?>(null);

  final selectedVodUrl = ''.obs;

  final searchController = TextEditingController();
  final academyList = <AcademyContentViewModel>[].obs;

  RxString startDate = ''.obs;
  RxString endDate = ''.obs;

  final shortByLabelMap = {
    'all': 'all'.tr,
    'title': 'title'.tr,
    'description': 'description'.tr,
    'file_type': 'fileType'.tr,
  };

  final shortByList = ['all', 'title', 'description', 'file_type'];
  final selectedShortByValue = 'all'.obs;

  final currentPage = 1.obs;
  final perPage = 8.obs;
  final totalPages = 1.obs;
  final totalCount = 0.obs;
  final hasMore = true.obs;
  final isLoadingMore = false.obs;
  late ScrollController scrollController;
  bool _isScrollControllerDisposed = false;

  final isCreateContentBtnValue = false.obs;
  final isLoading = true.obs;

  final academyRepo = Get.find<AcademyRepo>();

  final isEditMode = false.obs;
  final editingAcademyId = ''.obs;
  final zoomLinkError = ''.obs;

  // VOD Form Errors
  final videoNameError = ''.obs;
  final vodFileError = ''.obs;
  final totalPointError = ''.obs;

  // Mission Challenge Form Errors
  final taskStartDateError = ''.obs;
  final taskCompletionDateError = ''.obs;
  final missionNameError = ''.obs;
  final missionEndTimeError = ''.obs;
  final correctAnswerError = ''.obs;
  final missionOptionErrors = <int, String>{}.obs;
  final audioFileError = ''.obs;

  // Zoom Workshop Form Errors
  final workshopDateError = ''.obs;
  final startTimeError = ''.obs;
  final endTimeError = ''.obs;
  final nameOfWorkshopError = ''.obs;
  final zoomFileError = ''.obs;
  final descriptionError = ''.obs;

  final isLoadingSubmissions = false.obs;
  final assignmentSubmissionList = <AssignmentSubmissionModel>[].obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);

    selectedMissionTaskType.listen((taskType) {
      if (taskType != MissionTaskType.mcq) {
        listMissionChallengeAnotherField.clear();
      } else {
        if (listMissionChallengeAnotherField.isEmpty) {
          listMissionChallengeAnotherField.add(
            AcademyMissionChallengeAnotherFieldModel(
              title: 'option'.tr,
              textEditingController: TextEditingController(),
            ),
          );
        }
      }
    });

    if (selectedMissionTaskType.value == MissionTaskType.mcq &&
        listMissionChallengeAnotherField.isEmpty) {
      listMissionChallengeAnotherField.add(
        AcademyMissionChallengeAnotherFieldModel(
          title: 'option'.tr,
          textEditingController: TextEditingController(),
        ),
      );
    }

    await fetchAcademyList();
  }

  @override
  void onClose() {
    if (!_isScrollControllerDisposed) {
      scrollController.removeListener(_onScroll);
      scrollController.dispose();
      _isScrollControllerDisposed = true;
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

  /// ---------------------------
  /// Fetch Academy List
  /// ---------------------------
  void resetPage() {
    currentPage.value = 1;
    hasMore.value = true;
    academyList.clear();
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
    await fetchAcademyList(append: true);
  }

  Future<void> fetchAcademyList({
    String? startDate,
    String? endDate,
    String? searchTerm,
    String? shortBy,
    bool append = false,
  }) async {
    try {
      if (append) {
        isLoadingMore.value = true;
      } else {
        isLoading.value = true;
        academyList.clear();
        currentPage.value = 1;
        hasMore.value = true;
      }

      final response = await academyRepo.fetchAcademyViewListWithPagination(
        pageNumber: currentPage.value,
        searchTerm: searchTerm ?? searchController.text,
        perPage: perPage.value,
        shortBy: shortBy ?? selectedShortByValue.value,
        startDate: startDate,
        endDate: endDate,
      );

      totalCount.value = response.totalCount;
      totalPages.value = response.totalPages;
      if (append) {
        academyList.addAll(response.data);
      } else {
        academyList.value = response.data;
      }
      hasMore.value = currentPage.value < totalPages.value;
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  /// ---------------------------
  /// Delete Content
  /// ---------------------------
  void clickOnDeleteBtn(String id) {
    CMDialogs.showConfirmationDialog(
      title: 'confirmDeletion'.tr,
      subtitle: 'areYouSureYouWantToDeleteThisPost'.tr,
      onPressed: isLoading.value ? null : () => deleteContent(id),
    );
  }

  Future<void> deleteContent(String id) async {
    try {
      isLoading.value = true;
      final success = await academyRepo.deleteAcademyContent(id);
      Get.back();

      if (success) {
        await fetchAcademyList();
        CommonSnackbar.success('contentDeletedSuccessfully'.tr);
      } else {
        CommonSnackbar.error('failedToDeleteContent'.tr);
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// ---------------------------
  /// Reset and validation Form
  /// ---------------------------
  void resetAllFormControllers() {
    selectedVODFile.value = null;
    selectedVodUrl.value = '';
    videoNameController.clear();
    descriptionController.clear();
    totalPointController.clear();
    workshopDateController.clear();
    startTimeController.clear();
    endTimeController.clear();
    nameOfWorkshopController.clear();
    selectedAudioFile.value = null;
    zoomLinkController.clear();
    zoomLinkError.value = '';
    selectedZoomFile.value = null;
    costOfParticipationInPointsController.clear();
    costOfParticipationInCreditController.clear();
    taskStartDateController.clear();
    taskCompletionDateController.clear();
    missionEndTimeController.clear();
    missionNameController.clear();
    correctAnswerController.clear();

    // Clear all errors
    videoNameError.value = '';
    vodFileError.value = '';
    totalPointError.value = '';
    taskStartDateError.value = '';
    taskCompletionDateError.value = '';
    missionNameError.value = '';
    missionEndTimeError.value = '';
    correctAnswerError.value = '';
    missionOptionErrors.clear();
    workshopDateError.value = '';
    startTimeError.value = '';
    endTimeError.value = '';
    nameOfWorkshopError.value = '';
    zoomFileError.value = '';
    audioFileError.value = '';
    descriptionError.value = '';

    for (var field in listMissionChallengeAnotherField) {
      field.textEditingController?.dispose();
    }
    listMissionChallengeAnotherField.clear();

    selectedMissionTaskType.value = MissionTaskType.mcq;
    listMissionChallengeAnotherField.add(
      AcademyMissionChallengeAnotherFieldModel(
        title: 'option'.tr,
        textEditingController: TextEditingController(),
      ),
    );
    isEditMode.value = false;
    editingAcademyId.value = '';
  }

  /// ---------------------------
  /// Helpers
  /// ---------------------------
  int _parsePoints(TextEditingController controller) {
    return controller.text.isEmpty ? 0 : int.parse(controller.text);
  }

  bool validateVODForm() {
    videoNameError.value = '';
    vodFileError.value = '';
    totalPointError.value = '';
    descriptionError.value = '';
    bool hasError = false;

    if (videoNameController.text.trim().isEmpty) {
      videoNameError.value = 'vodNameIsRequired'.tr;
      hasError = true;
    }

    if (selectedVodUrl.value.trim().isEmpty) {
      vodFileError.value = 'videoFileIsRequired'.tr;
      hasError = true;
    }

    if (descriptionController.text.trim().isNotEmpty) {
      final words = descriptionController.text
          .trim()
          .split(RegExp(r'\s+'))
          .length;
      if (words > 1000) {
        descriptionError.value = "Description can't exceed 1000 words";
        hasError = true;
      }
    }

    if (totalPointController.text.isNotEmpty &&
        int.tryParse(totalPointController.text) == null) {
      totalPointError.value = 'invalidPoints'.tr;
      hasError = true;
    }

    return !hasError;
  }

  bool validateMissionChallengeForm() {
    taskStartDateError.value = '';
    taskCompletionDateError.value = '';
    missionNameError.value = '';
    missionEndTimeError.value = '';
    correctAnswerError.value = '';
    missionOptionErrors.clear();
    descriptionError.value = '';
    audioFileError.value = '';
    bool hasError = false;

    if (taskStartDateController.text.isEmpty) {
      taskStartDateError.value = 'taskStartDateIsRequired'.tr;
      hasError = true;
    }

    if (taskCompletionDateController.text.isEmpty) {
      taskCompletionDateError.value = 'taskCompletionDateIsRequired'.tr;
      hasError = true;
    }

    if (missionNameController.text.isEmpty) {
      missionNameError.value = 'missionNameIsRequired'.tr;
      hasError = true;
    }

    if (descriptionController.text.trim().isNotEmpty) {
      final words = descriptionController.text
          .trim()
          .split(RegExp(r'\s+'))
          .length;
      if (words > 1000) {
        descriptionError.value = "Description can't exceed 1000 words";
        hasError = true;
      }
    }

    if (missionEndTimeController.text.isEmpty) {
      missionEndTimeError.value = 'missionEndTimeIsRequired'.tr;
      hasError = true;
    }

    if (selectedMissionTaskType.value == MissionTaskType.audio) {
      final hasNewFile = selectedAudioFile.value != null;
      final hasExistingFile = selectedVodUrl.value.trim().isNotEmpty;
      if (!hasNewFile && !hasExistingFile) {
        audioFileError.value = 'audioFileIsRequired'.tr;
        hasError = true;
      }
    }

    if (selectedMissionTaskType.value == MissionTaskType.mcq) {
      for (int i = 0; i < listMissionChallengeAnotherField.length; i++) {
        if (listMissionChallengeAnotherField[i].textEditingController?.text
                .trim()
                .isEmpty ??
            true) {
          missionOptionErrors[i] = 'option${i + 1}CannotBeEmpty'.tr;
          hasError = true;
        }
      }
    }

    // if (correctAnswerController.text.trim().isEmpty) {
    //   correctAnswerError.value = 'correctAnswerIsRequired'.tr;
    //   hasError = true;
    // }

    return !hasError;
  }

  bool validateZoomWorkshopForm() {
    zoomLinkError.value = '';
    workshopDateError.value = '';
    startTimeError.value = '';
    endTimeError.value = '';
    nameOfWorkshopError.value = '';
    zoomFileError.value = '';
    descriptionError.value = '';
    bool hasError = false;

    if (workshopDateController.text.isEmpty) {
      workshopDateError.value = 'workshopDateIsRequired'.tr.isEmpty
          ? 'Workshop date is required'
          : 'workshopDateIsRequired'.tr;
      hasError = true;
    }

    if (startTimeController.text.isEmpty) {
      startTimeError.value = 'startTimeIsRequired'.tr.isEmpty
          ? 'Start time is required'
          : 'startTimeIsRequired'.tr;
      hasError = true;
    }

    if (endTimeController.text.isEmpty) {
      endTimeError.value = 'endTimeIsRequired'.tr.isEmpty
          ? 'End time is required'
          : 'endTimeIsRequired'.tr;
      hasError = true;
    }

    if (nameOfWorkshopController.text.isEmpty) {
      nameOfWorkshopError.value = 'nameOfWorkshopIsRequired'.tr.isEmpty
          ? 'Name of workshop is required'
          : 'nameOfWorkshopIsRequired'.tr;
      hasError = true;
    }

    final hasNewImage = selectedZoomFile.value != null;
    final hasExistingImage = selectedVodUrl.value.trim().isNotEmpty;
    if (!hasNewImage && !hasExistingImage) {
      zoomFileError.value = 'backgroundImageIsRequired'.tr.isEmpty
          ? 'Background image is required'
          : 'backgroundImageIsRequired'.tr;
      hasError = true;
    }

    if (descriptionController.text.trim().isNotEmpty) {
      final words = descriptionController.text
          .trim()
          .split(RegExp(r'\s+'))
          .length;
      if (words > 1000) {
        descriptionError.value = "Description can't exceed 1000 words";
        hasError = true;
      }
    }

    if (zoomLinkController.text.trim().isEmpty) {
      final errorMsg = 'zoomLinkIsRequired'.tr.isEmpty
          ? 'Zoom link is required'
          : 'zoomLinkIsRequired'.tr;
      zoomLinkError.value = errorMsg;
      hasError = true;
    }

    final uri = Uri.tryParse(zoomLinkController.text.trim());
    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'http' && uri.scheme != 'https')) {
      final errorMsg = 'invalidUrl'.tr.isEmpty
          ? 'Please enter a valid URL'
          : 'invalidUrl'.tr;
      zoomLinkError.value = errorMsg;
      hasError = true;
    }

    return !hasError;
  }

  /// ---------------------------
  /// Create
  /// ---------------------------
  Future<void> createAcademyContentVOD() async {
    try {
      isCreateContentBtnValue.value = true;

      selectedVodUrl.value =
          await academyRepo.uploadFile(
            selectedVODFile.value?.bytes ?? Uint8List(0),
            MediaType.video,
          ) ??
          '';

      if (!validateVODForm()) return;

      final success = await academyRepo.createAcademyContent(
        academyFileType: 'video',
        title: videoNameController.text.trim(),
        description: descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
        mediaFileUrl: selectedVodUrl.value,
        pointsToEarn: _parsePoints(totalPointController),
      );

      if (success) {
        resetAllFormControllers();
        selectedType.value = AcademyPostType.vod;
        resetPage();
        Get.back();
        CommonSnackbar.success('academyVODCreatedSuccessfully'.tr);
        await fetchAcademyList();
      }
    } catch (_) {
      CommonSnackbar.error('failedToCreateVOD'.tr);
    } finally {
      isCreateContentBtnValue.value = false;
    }
  }

  List<Map<String, dynamic>> buildMissionAnswersPayload() {
    final correctAnswer = correctAnswerController.text.trim();
    final List<Map<String, dynamic>> answers = [];

    if (selectedMissionTaskType.value == MissionTaskType.mcq) {
      for (var field in listMissionChallengeAnotherField) {
        final option = field.textEditingController?.text.trim() ?? '';
        if (option.isNotEmpty) {
          answers.add({'option': option});
        }
      }

      final correctAnswerInOptions = listMissionChallengeAnotherField.any(
        (field) =>
            field.textEditingController?.text.trim().toLowerCase() ==
            correctAnswer.toLowerCase(),
      );

      if (!correctAnswerInOptions && correctAnswer.isNotEmpty) {
        answers.add({'option': correctAnswer});
      }
    } else {
      if (correctAnswer.isNotEmpty) {
        answers.add({'option': ''});
      }
    }
    if (correctAnswer.isNotEmpty) {
      answers.add({'correct_answer': correctAnswer});
    }

    return answers;
  }

  Future<void> createAcademyContentMissionChallenge() async {
    try {
      isCreateContentBtnValue.value = true;

      if (!validateMissionChallengeForm()) return;

      if (selectedMissionTaskType.value == MissionTaskType.audio &&
          selectedAudioFile.value != null) {
        selectedVodUrl.value =
            await academyRepo.uploadFile(
              selectedAudioFile.value!.bytes ?? Uint8List(0),
              MediaType.audio,
            ) ??
            '';
      }

      final success = await academyRepo.createAcademyContent(
        academyFileType: 'assignment',
        title: missionNameController.text.trim(),
        mediaFileUrl: selectedVodUrl.value,
        description: descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
        pointsToEarn: _parsePoints(totalPointController),
        assignment: {
          'task_name': missionNameController.text.trim(),
          'task_type': selectedMissionTaskType.value.apiValue,
          'task_start_date': taskStartDateController.text.trim(),
          'task_end_date': taskCompletionDateController.text.trim().isEmpty
              ? null
              : taskCompletionDateController.text.trim(),
          'task_end_time': missionEndTimeController.text.trim(),
          'total_points_to_win': _parsePoints(totalPointController),
          'answers': buildMissionAnswersPayload(),
        },
      );

      if (success) {
        resetAllFormControllers();
        selectedType.value = AcademyPostType.vod;
        resetPage();
        Get.back();
        CommonSnackbar.success('missionChallengeCreatedSuccessfully'.tr);
        await fetchAcademyList();
      }
    } catch (e) {
      CommonSnackbar.error('$e');
    } finally {
      isCreateContentBtnValue.value = false;
    }
  }

  Future<void> createAcademyContentZoomWorkshop() async {
    try {
      isCreateContentBtnValue.value = true;

      selectedVodUrl.value =
          await academyRepo.uploadFile(
            selectedZoomFile.value?.bytes ?? Uint8List(0),
            MediaType.image,
          ) ??
          '';

      if (!validateZoomWorkshopForm()) return;

      final success = await academyRepo.createAcademyContent(
        academyFileType: 'zoom_workshop',
        title: nameOfWorkshopController.text.trim(),
        mediaFileUrl: selectedVodUrl.value,
        description: descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
        event: {
          'event_date': workshopDateController.text.trim(),
          'start_time': startTimeController.text.trim(),
          'end_time': endTimeController.text.trim(),
          'zoom_link': zoomLinkController.text.trim(),
          'cost_points': _parsePoints(costOfParticipationInPointsController),
          'cost_credits': _parsePoints(costOfParticipationInCreditController),
          'image_url': selectedVodUrl.value,
        },
      );

      if (success) {
        resetAllFormControllers();
        selectedType.value = AcademyPostType.vod;
        resetPage();
        Get.back();
        CommonSnackbar.success('zoomWorkshopCreatedSuccessfully'.tr);
        await fetchAcademyList();
      }
    } catch (e) {
      CommonSnackbar.error('failedToCreateZoomWorkshop'.tr);
    } finally {
      isCreateContentBtnValue.value = false;
    }
  }

  /// ---------------------------
  /// Edit Academy Flow
  /// ---------------------------
  void clickOnEditAcademyBtn(AcademyContentViewModel academy) {
    populateFormForEdit(academy);

    showGeneralDialog(
      context: Get.context!,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) {
        return Obx(
          () => PopScope(
            canPop: !isCreateContentBtnValue.value,
            child: Align(
              alignment: Alignment.centerRight,
              child: Material(
                color: Colors.transparent,
                child: UploadPostFlyout(),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, animation, __, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    );
  }

  String formatDateDDMMYYYY(DateTime? date) {
    if (date == null) return '';

    return "${date.day.toString().padLeft(2, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.year}";
  }

  String formatTime12Hour(DateTime? dateTime) {
    if (dateTime == null) return '';

    final timeOfDay = TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
    return timeOfDay.format(Get.context!);
  }

  /// Converts time string from Supabase format (e.g., '15:42:00+00' or '15:42:00') to 12-hour format (e.g., '3:42 pm')
  String convertTimeStringTo12Hour(String? timeString) {
    if (timeString == null || timeString.isEmpty) return '';

    try {
      // Remove timezone suffix if present (e.g., '+00', '-05:00', '+00:00')
      // Find the first occurrence of '+' or '-' that's not at the start
      String cleanTime = timeString.trim();

      // Check for timezone indicators (after the time part, typically after seconds)
      final plusIndex = cleanTime.indexOf(
        '+',
        1,
      ); // Start from index 1 to avoid edge cases
      final minusIndex = cleanTime.indexOf(
        '-',
        1,
      ); // Start from index 1 to avoid matching negative hours

      if (plusIndex > 0) {
        cleanTime = cleanTime.substring(0, plusIndex);
      } else if (minusIndex > 0) {
        // Only split on '-' if it's not at the start (which would be a negative hour, unlikely)
        cleanTime = cleanTime.substring(0, minusIndex);
      }

      cleanTime = cleanTime.trim();

      // Split by colon to get hours and minutes
      final parts = cleanTime.split(':');
      if (parts.length < 2)
        return timeString; // Return original if format is unexpected

      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);

      if (hour == null || minute == null)
        return timeString; // Return original if parsing fails

      // Validate hour and minute ranges
      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
        return timeString; // Return original if values are invalid
      }

      // Create TimeOfDay and format to 12-hour format
      final timeOfDay = TimeOfDay(hour: hour, minute: minute);
      return timeOfDay.format(Get.context!);
    } catch (e) {
      // If any error occurs, return original string
      return timeString;
    }
  }

  void populateMissionAnswers(List<dynamic>? answers) {
    listMissionChallengeAnotherField.clear();
    correctAnswerController.clear();

    if (answers == null || answers.isEmpty) {
      if (selectedMissionTaskType.value == MissionTaskType.mcq) {
        listMissionChallengeAnotherField.add(
          AcademyMissionChallengeAnotherFieldModel(
            title: 'option'.tr,
            textEditingController: TextEditingController(),
          ),
        );
      }
      return;
    }

    String? extractedCorrectAnswer;

    for (int i = 0; i < answers.length; i++) {
      final Map<String, dynamic> item = Map<String, dynamic>.from(answers[i]);
      if (item.containsKey('correct_answer') && item['option'] == null) {
        extractedCorrectAnswer = item['correct_answer']?.toString();
        if (extractedCorrectAnswer != null &&
            extractedCorrectAnswer.isNotEmpty) {
          correctAnswerController.text = extractedCorrectAnswer;
        }
        break;
      }
    }

    if (selectedMissionTaskType.value == MissionTaskType.mcq) {
      for (int i = 0; i < answers.length; i++) {
        final Map<String, dynamic> item = Map<String, dynamic>.from(answers[i]);
        if (item.containsKey('option')) {
          final String optionValue = item['option']?.toString() ?? '';

          if (optionValue.isNotEmpty) {
            listMissionChallengeAnotherField.add(
              AcademyMissionChallengeAnotherFieldModel(
                title: 'option'.tr,
                textEditingController: TextEditingController(text: optionValue),
              ),
            );
          }
        }
      }

      if (listMissionChallengeAnotherField.isEmpty) {
        listMissionChallengeAnotherField.add(
          AcademyMissionChallengeAnotherFieldModel(
            title: 'option'.tr,
            textEditingController: TextEditingController(),
          ),
        );
      }
    }
  }

  void populateFormForEdit(AcademyContentViewModel academy) {
    resetAllFormControllers();

    isEditMode.value = true;
    editingAcademyId.value = academy.academyContentId;

    /// Common fields
    descriptionController.text = academy.description ?? '';
    totalPointController.text = academy.pointsToEarn.toString();

    selectedVodUrl.value = academy.mediaFileUrl ?? '';

    /// File Type (VOD)
    if (academy.isVideo) {
      selectedType.value = AcademyPostType.vod;
      videoNameController.text = academy.title;
    }

    /// Zoom Workshop
    if (academy.isZoomWorkshop) {
      selectedType.value = AcademyPostType.zoomWorkshop;
      nameOfWorkshopController.text = academy.title;
      zoomLinkController.text = academy.zoomLink ?? '';
      workshopDateController.text = formatDateDDMMYYYY(academy.eventDate);
      startTimeController.text = convertTimeStringTo12Hour(
        academy.zoomStartTime,
      );
      endTimeController.text = convertTimeStringTo12Hour(academy.zoomEndTime);
      costOfParticipationInPointsController.text = academy.eventCostPoints
          .toString();
      costOfParticipationInCreditController.text = academy.eventCostCreditCents
          .toString();
    }

    /// Mission Challenge
    if (academy.isAssignment) {
      selectedType.value = AcademyPostType.assignment;

      missionNameController.text = academy.title;

      taskStartDateController.text = formatDateDDMMYYYY(academy.taskStartDate);

      taskCompletionDateController.text = formatDateDDMMYYYY(
        academy.taskEndDate,
      );

      missionEndTimeController.text = academy.taskEndTime ?? '';

      selectedMissionTaskType.value = MissionTaskTypeX.fromApiValue(
        academy.taskType,
      );

      if (academy.totalPointsToWin != null) {
        totalPointController.text = academy.totalPointsToWin.toString();
      }

      populateMissionAnswers(academy.answers);
    }
  }

  Future<void> updateAcademyContentVOD() async {
    if (editingAcademyId.value.isEmpty) return;
    try {
      isCreateContentBtnValue.value = true;
      if (selectedVODFile.value != null) {
        selectedVodUrl.value =
            await academyRepo.uploadFile(
              selectedVODFile.value!.bytes ?? Uint8List(0),
              MediaType.video,
            ) ??
            selectedVodUrl.value;
      }

      if (!validateVODForm()) return;

      final success = await academyRepo.updateAcademyContent(
        academyContentId: editingAcademyId.value,
        title: videoNameController.text.trim(),
        description: descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
        mediaFileUrl: selectedVodUrl.value,
        pointsToEarn: _parsePoints(totalPointController),
      );

      if (success) {
        resetAllFormControllers();
        selectedType.value = AcademyPostType.vod;
        resetPage();
        Get.back();
        CommonSnackbar.success('VOD updated successfully');
        await fetchAcademyList();
      }
    } catch (e) {
      CommonSnackbar.error('Failed to update VOD: $e');
    } finally {
      isCreateContentBtnValue.value = false;
    }
  }

  Future<void> updateAcademyContentMissionChallenge() async {
    if (editingAcademyId.value.isEmpty) return;

    try {
      isCreateContentBtnValue.value = true;

      if (!validateMissionChallengeForm()) return;

      if (selectedMissionTaskType.value == MissionTaskType.audio &&
          selectedAudioFile.value != null) {
        selectedVodUrl.value =
            await academyRepo.uploadFile(
              selectedAudioFile.value!.bytes ?? Uint8List(0),
              MediaType.audio,
            ) ??
            selectedVodUrl.value;
      }

      final success = await academyRepo.updateAcademyContent(
        academyContentId: editingAcademyId.value,
        title: missionNameController.text.trim(),
        description: descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
        mediaFileUrl: selectedVodUrl.value,
        pointsToEarn: _parsePoints(totalPointController),
        assignment: {
          'task_name': missionNameController.text.trim(),
          'task_start_date': taskStartDateController.text.trim(),
          'task_end_date': taskCompletionDateController.text.trim().isEmpty
              ? null
              : taskCompletionDateController.text.trim(),
          'task_end_time': missionEndTimeController.text.trim(),
          'total_points_to_win': _parsePoints(totalPointController),
          'answers': buildMissionAnswersPayload(),
        },
      );

      if (success) {
        resetAllFormControllers();
        selectedType.value = AcademyPostType.vod;
        resetPage();
        Get.back();
        CommonSnackbar.success('Mission Challenge updated successfully');
        await fetchAcademyList();
      }
    } catch (e) {
      CommonSnackbar.error('Failed to update Mission Challenge: $e');
    } finally {
      isCreateContentBtnValue.value = false;
    }
  }

  Future<void> updateAcademyContentZoomWorkshop() async {
    if (editingAcademyId.value.isEmpty) return;

    try {
      isCreateContentBtnValue.value = true;

      if (selectedZoomFile.value != null) {
        selectedVodUrl.value =
            await academyRepo.uploadFile(
              selectedZoomFile.value!.bytes ?? Uint8List(0),
              MediaType.image,
            ) ??
            selectedVodUrl.value;
      }

      if (!validateZoomWorkshopForm()) return;

      final success = await academyRepo.updateAcademyContent(
        academyContentId: editingAcademyId.value,
        title: nameOfWorkshopController.text.trim(),
        description: descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
        mediaFileUrl: selectedVodUrl.value,
        pointsToEarn: _parsePoints(totalPointController),
        event: {
          'event_date': workshopDateController.text.trim(),
          'start_time': startTimeController.text.trim(),
          'end_time': endTimeController.text.trim(),
          'zoom_link': zoomLinkController.text.trim(),
          'cost_points': _parsePoints(costOfParticipationInPointsController),
          'cost_credits': _parsePoints(costOfParticipationInCreditController),
          'image_url': selectedVodUrl.value,
        },
      );

      if (success) {
        resetAllFormControllers();
        selectedType.value = AcademyPostType.vod;
        resetPage();
        Get.back();
        CommonSnackbar.success('Zoom Workshop updated successfully');
        await fetchAcademyList();
      }
    } catch (e) {
      CommonSnackbar.error('Failed to update Zoom Workshop: $e');
    } finally {
      isCreateContentBtnValue.value = false;
    }
  }

  Future<void> fetchAssignmentSubmissions({
    required String assignmentId,
  }) async {
    isLoadingSubmissions.value = true;
    assignmentSubmissionList.clear();
    try {
      final response = await academyRepo.getAssignmentSubmissions(
        assignmentId: assignmentId,
      );
      assignmentSubmissionList.value = response.data;
    } catch (e) {
      debugPrint('Error fetching submissions: ${e.toString()}');
    } finally {
      isLoadingSubmissions.value = false;
    }
  }

  void downloadAssignmentSubmissionsCsv() {
    final submissions = assignmentSubmissionList;

    if (submissions.isEmpty) {
      CommonSnackbar.notification(message: 'noData'.tr);
      return;
    }

    final List<List<dynamic>> rows = [];

    rows.add(['User Name', 'Submission Date', 'Answer Status']);

    for (final submission in submissions) {
      final username =
          submission.submittedByName ?? submission.submittedByPhone ?? '-';

      final submissionDate = DateFormat(
        'dd/MM/yyyy',
      ).format(submission.submissionCreatedAt);

      String answerStatus;
      if (submission.isCorrect == null) {
        answerStatus = 'answerStatusPending'.tr;
      } else if (submission.isCorrect == true) {
        answerStatus = 'answerStatusCorrect'.tr;
      } else {
        answerStatus = 'answerStatusWrong'.tr;
      }

      rows.add([username, submissionDate, answerStatus]);
    }

    final csvString = const ListToCsvConverter().convert(rows);

    if (kIsWeb) {
      final bytes = utf8.encode(csvString);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute('download', 'assignment_submissions.csv')
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      debugPrint('CSV Export (Assignment Submissions):\n$csvString');
      Get.snackbar(
        'Info',
        'CSV export is only supported on Web currently. Data printed to console.',
      );
    }
  }

  void showImagePreviewDialog(AssignmentSubmissionModel submission) {
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
          child: AssignmentSubmissionDialogView(
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

class AcademyMissionChallengeAnotherFieldModel {
  final String? title;
  final TextEditingController? textEditingController;

  AcademyMissionChallengeAnotherFieldModel({
    this.title,
    this.textEditingController,
  });
}
