import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:samsung_admin_main_new/app/app_theme/app_colors.dart';
import 'package:samsung_admin_main_new/app/common/common_snackbar.dart';
import 'package:samsung_admin_main_new/app/common/constant/types.dart';
import 'package:samsung_admin_main_new/app/common/core/utils/result.dart';
import 'package:samsung_admin_main_new/app/repository/vod_podcast_repo.dart';
import 'package:samsung_admin_main_new/app/models/content_model.dart';
import 'package:video_player/video_player.dart';

import '../../../common/common_dialogs/confirmation_dialog.dart';
import '../local_widget/vod_podcast_video.dart';

class VodPodcastsController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final backgroundImageController = TextEditingController();
  final selectedContentType = ContentType.vod.obs;
  final isEditing = false.obs;
  final editingContentId = ''.obs;
  final searchController = TextEditingController();
  final Rx<ContentType?> selectedFilterContentType = Rx<ContentType?>(null);

  final Map<String, String> sortByLabelMap = {
    'all': 'all'.tr,
    'vod': 'vod'.tr,
    'podcast': 'podcast'.tr,
  };

  final sortByList = ['all', 'vod', 'podcast'];
  final selectedSortByValue = 'all'.obs;

  final isAlreadyFileUploaded = false.obs;
  final isAlreadyThumbnailUrlUploaded = false.obs;

  final titleError = ''.obs;
  final hasValidated = false.obs;
  final files = <ContentModel>[].obs;
  final Rx<PlatformFile?> selectedFile = Rx<PlatformFile?>(null);
  final Rx<PlatformFile?> selectedThumbnailUrlFile = Rx<PlatformFile?>(null);
  final descriptionErrorValue = ''.obs;

  final startDate = ''.obs;
  final endDate = ''.obs;

  final Map<String, String> shortByLabelMap = {
    'all': 'all'.tr,
    'title': 'title'.tr,
    'description': 'description'.tr,
    'content_type': 'contentType'.tr,
  };

  final shortByList = ['all', 'title', 'description', 'content_type'];

  final selectedShortByValue = 'all'.obs;

  final vodPodcastRepo = Get.find<VodPodcastRepo>();

  final isCreateContentBtnValue = false.obs;
  final isLoading = true.obs;
  late VideoPlayerController videoController;

  final videoFileError = ''.obs;
  final thumbnailUrlFileError = ''.obs;

  final currentPage = 1.obs;
  final perPage = 8.obs;
  final totalPages = 1.obs;
  final totalCount = 0.obs;
  final hasMore = true.obs;
  final isLoadingMore = false.obs;
  late ScrollController scrollController;
  bool _isScrollControllerDisposed = false;

  @override
  Future<void> onInit() async {
    super.onInit();
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);
    await fetchFiles();
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

  @override
  void onReady() {
    super.onReady();
  }

  int _getWordCount(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 0;
    return trimmed.split(RegExp(r'\s+')).length;
  }

  void setSelectedFile(PlatformFile? file) {
    debugPrint('called::123');
    selectedFile.value = file;
    if (file != null) {
      videoFileError.value = '';
      isAlreadyFileUploaded.value = false;
    } else {
      isAlreadyFileUploaded.value = false;
    }
  }

  void setSelectedThumbnailUrlFile(PlatformFile? file) {
    selectedThumbnailUrlFile.value = file;
    if (file == null) {
      isAlreadyThumbnailUrlUploaded.value = false;
    } else {
      isAlreadyThumbnailUrlUploaded.value = false;
    }
  }

  String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'titleIsRequired'.tr;
    }
    if (value.trim().length > 50) {
      return 'Title cannot exceed 50 characters';
    }
    return null;
  }

  void clearAllFields() {
    titleController.text = '';
    descriptionController.text = '';
    selectedFile.value = null;
    selectedThumbnailUrlFile.value = null;
    titleError.value = '';
    descriptionErrorValue.value = '';
    videoFileError.value = '';
    thumbnailUrlFileError.value = '';
    hasValidated.value = false;
    isAlreadyFileUploaded.value = false;
    isAlreadyThumbnailUrlUploaded.value = false;
    editingContentId.value = '';
    selectedContentType.value = ContentType.vod;
    formKey.currentState?.reset();
  }

  Future<void> updateFile() async {
    hasError = false;
    if (formKey.currentState?.validate() ?? false) {
      if ((formKey.currentState!.validate())) {
        if (titleController.text.isEmpty) {
          titleError.value = 'titleIsRequired'.tr;
          hasError = true;
        } else if (titleController.text.trim().length > 50) {
          titleError.value = 'Title cannot exceed 50 characters';
          hasError = true;
        }
        if (descriptionController.text.isEmpty) {
          descriptionErrorValue.value = 'descriptionIsRequired'.tr;
          hasError = true;
        } else if (_getWordCount(descriptionController.text) > 1000) {
          descriptionErrorValue.value =
              "Description can't exceed 1000 words";
          hasError = true;
        }
        if (selectedFile.value == null && !isAlreadyFileUploaded.value) {
          videoFileError.value = 'fileIsRequired'.tr;
          hasError = true;
        }
        if (selectedContentType.value == ContentType.podcast &&
            selectedThumbnailUrlFile.value == null &&
            !isAlreadyThumbnailUrlUploaded.value) {
          thumbnailUrlFileError.value = 'thumbnailIsRequired'.tr;
          hasError = true;
        }
        if (hasError) return;
        isEditing.value = true;
        isCreateContentBtnValue.value = true;
        try {
          debugPrint('updateFile');
          final result = await VodPodcastRepo.updateFile(
            editingContentId.value,
            titleController.text.trim(),
            descriptionController.text.trim(),
            selectedFile.value?.bytes,
            selectedFile.value?.name,
            selectedThumbnailUrlFile.value?.bytes,
            selectedThumbnailUrlFile.value?.name,
          );
          if (result.isSuccess) {
            debugPrint('File updated successfully');
            await fetchFiles();
            Get.back();
            CommonSnackbar.success('File updated successfully');
          } else {
            debugPrint('Failed to update file');
            CommonSnackbar.error(result.errorOrNull ?? 'Failed to update file');
          }
        } catch (e) {
          debugPrint('❌ Failed to update file');
          titleError.value = 'genericErrorTryAgain'.tr;
          CommonSnackbar.error(titleError.value);
        } finally {
          clearAllFields();
          isCreateContentBtnValue.value = false;
          isCreateContentBtnValue.value = false;
        }
      }
    }
  }

  bool hasError = false;

  Future<void> createFile() async {
    titleError.value = '';
    isEditing.value = false;
    descriptionErrorValue.value = '';
    hasError = false;
    if (titleController.text.isEmpty) {
      titleError.value = 'titleIsRequired'.tr;
      hasError = true;
    } else if (titleController.text.trim().length > 50) {
      titleError.value = 'Title cannot exceed 50 characters';
      hasError = true;
    }
    if (descriptionController.text.isEmpty) {
      descriptionErrorValue.value = 'descriptionIsRequired'.tr;
      hasError = true;
    } else if (_getWordCount(descriptionController.text) > 1000) {
      descriptionErrorValue.value = "Description can't exceed 1000 words";
      hasError = true;
    }
    if (selectedFile.value == null) {
      videoFileError.value = 'fileIsRequired'.tr;
      hasError = true;
    }
    if (selectedThumbnailUrlFile.value == null &&
        selectedContentType.value == ContentType.podcast) {
      thumbnailUrlFileError.value = 'thumbnailIsRequired'.tr;
      hasError = true;
    }
    if (hasError) return;
    if ((formKey.currentState!.validate())) {
      isCreateContentBtnValue.value = true;
      hasValidated.value = true;
      titleError.value = '';

      final file = selectedFile.value;
      final title = titleController.text.trim();
      try {
        final result = await VodPodcastRepo.createFile(
          title,
          descriptionController.text.trim(),
          selectedContentType.value,
          file?.bytes ?? Uint8List(0),
          file?.name ?? '',
          selectedThumbnailUrlFile.value?.bytes,
          selectedThumbnailUrlFile.value?.name,
        );
        if (result.isSuccess) {
          debugPrint('✅ File created successfully');
          clearAllFields();
          await fetchFiles();
          Get.back();
          CommonSnackbar.success('fileCreatedSuccessfully'.tr);
        } else {
          debugPrint('❌ Failed to create file');
          debugPrint('result.errorOrNull::  ${result}');
          CommonSnackbar.error(result.errorOrNull ?? 'Failed to create file');
        }
      } catch (e) {
        titleError.value = 'genericErrorTryAgain'.tr;
        CommonSnackbar.error(titleError.value);
      } finally {
        hasValidated.value = false;
        isCreateContentBtnValue.value = false;
      }

      debugPrint('🔴 createFile() completed');
    }
  }

  void resetPage() {
    currentPage.value = 1;
    hasMore.value = true;
    files.clear();
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
    await fetchFiles(append: true);
  }

  void changeFilterType(ContentType? type) {
    selectedFilterContentType.value = type;
    resetPage();
    fetchFiles(searchTerm: searchController.text);
  }

  void prefillFormForEdit(ContentModel content) {
    print('content.contentType::  ${content.contentType}');
    isEditing.value = true;
    editingContentId.value = content.id;
    titleController.text = content.title ?? '';
    descriptionController.text = content.description ?? '';
    isAlreadyFileUploaded.value =
        content.mediaFileUrl != null && content.mediaFileUrl!.isNotEmpty;
    isAlreadyThumbnailUrlUploaded.value =
        content.thumbnailUrl != null && content.thumbnailUrl!.isNotEmpty;
    selectedFile.value = null;
    hasValidated.value = false;
    selectedContentType.value = content.contentType;
  }

  clearAllErrors() {
    titleError.value = '';
    descriptionErrorValue.value = '';
    videoFileError.value = '';
    thumbnailUrlFileError.value = '';
  }

  Future<void> fetchFiles({
    String? searchTerm,
    String? shortBy,
    String? contentType,
    String? sortBy,
    String? startDate,
    String? endDate,
    bool append = false,
  }) async {
    try {
      if (append) {
        isLoadingMore.value = true;
      } else {
        isLoading.value = true;
        files.clear();
        currentPage.value = 1;
        hasMore.value = true;
      }
      VODPodcastListResponse response = await vodPodcastRepo
          .fetchContentListWithPagination(
            pageNumber: currentPage.value,
            searchTerm: searchTerm ?? searchController.text,
            perPage: perPage.value,
            shortBy: shortBy ?? selectedShortByValue.value,
            startDate: startDate,
            endDate: endDate,
            contentType: selectedSortByValue.value == 'all'
                ? null
                : selectedSortByValue.value,
          );
      totalCount.value = response.totalCount;
      totalPages.value = response.totalPages;
      if (append) {
        files.addAll(response.data);
      } else {
        files.value = response.data;
      }
      hasMore.value = currentPage.value < totalPages.value;
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  void clickOnDeleteBtn(String contentId) {
    CMDialogs.showConfirmationDialog(
      title: 'confirmDeletion'.tr,
      subtitle: 'areYouSureYouWantToDeleteThisPost'.tr,
      onPressed: isLoading.value ? null : () => deleteContent(contentId),
    );
  }

  Future<void> deleteContent(String contentId) async {
    try {
      isLoading.value = true;
      final success = await vodPodcastRepo.deleteContentById(contentId);
      searchController.clear();
      Get.back();
      if (success) {
        await fetchFiles();
        CommonSnackbar.success('contentDeletedSuccessfully'.tr);
      } else {
        CommonSnackbar.error('failedToDeleteContent'.tr);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> playVideo(ContentModel contentModel) async {
    try {
      if (contentModel.mediaFileUrl != null &&
          contentModel.mediaFileUrl!.isNotEmpty) {
        videoController = VideoPlayerController.networkUrl(
          Uri.parse(contentModel.mediaFileUrl ?? ''),
        );
        await videoController.initialize();
        videoController.play();
        showDialog(
          context: Get.context!,
          barrierDismissible: false,
          builder: (context) => Dialog(
            backgroundColor: AppColors.backgroundColor,
            child: FullScreenVideoDialog(controller: videoController),
          ),
        );
      }
    } finally {}
  }
}
