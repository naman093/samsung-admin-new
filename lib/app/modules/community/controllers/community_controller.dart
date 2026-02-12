import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:samsung_admin_main_new/app/common/common_dialogs/confirmation_dialog.dart';
import 'package:samsung_admin_main_new/app/common/common_snackbar.dart';
import 'package:samsung_admin_main_new/app/common/core/utils/result.dart';
import 'package:samsung_admin_main_new/app/repository/community_repo.dart';

import '../../../app_theme/app_colors.dart';
import '../../../common/common_modal.dart';
import '../../../models/comment_model.dart';
import '../../../models/content_full_details_model.dart';
import '../../../repository/auth_repo/auth_repo.dart';
import '../local_widget/community_comments.dart';
import '../local_widget/create_edit_feed.dart';
import '../local_widget/feed_card.dart';

class CommunityController extends GetxController {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final titleError = ''.obs;
  final hasValidated = false.obs;
  final formKey = GlobalKey<FormState>();
  final Rx<PlatformFile?> selectedFile = Rx<PlatformFile?>(null);
  final isCreating = false.obs;
  final currentPage = 1.obs;
  final perPage = 8.obs;
  final totalPages = 1.obs;
  final totalCount = 0.obs;
  final hasMore = true.obs;
  final isLoadingMore = false.obs;
  late ScrollController scrollController;
  bool _isScrollControllerDisposed = false;
  final feeds = <ContentFullDetailsModel>[].obs;
  final isLoading = false.obs;
  final searchController = TextEditingController();
  final isEditing = false.obs;
  final isAlreadyFileUploaded = false.obs;
  final editingContentId = ''.obs;
  final descriptionError = ''.obs;
  final imageError = ''.obs;
  final checkboxValue = true.obs;

  final startDate = ''.obs;
  final endDate = ''.obs;

  final authRepo = Get.find<AuthRepo>();
  final communityRepo = Get.find<CommunityRepo>();

  final Map<String, String> shortByLabelMap = {
    'all': 'All',
    'author_name': 'User Name',
    'title': 'Title',
    'description': 'Description',
  };

  final shortByList = ['all', 'author_name', 'title', 'description'];

  final selectedShortByValue = 'all'.obs;

  final commentControllers = <String, TextEditingController>{}.obs;

  final comments = <ContentCommentViewModel>[].obs;
  final isCommentsLoading = false.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);
    await fetchFeeds();
  }

  @override
  void onReady() {
    super.onReady();
    resetPage();
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

  Future<void> toggleLike(ContentFullDetailsModel model) async {
    final index = feeds.indexWhere(
      (element) => element.contentId == model.contentId,
    );
    if (index == -1) return;

    final isCurrentlyLiked = model.isLikedByMe;
    final currentUser = authRepo.currentUser.value;

    List<LikedByUserInfo> updatedLikedUsers = List.from(
      model.likedByUsers ?? [],
    );

    if (!isCurrentlyLiked) {
      if (currentUser != null) {
        updatedLikedUsers.insert(
          0,
          LikedByUserInfo(
            userId: currentUser.id,
            fullName: currentUser.fullName,
            profilePictureUrl: currentUser.profilePictureUrl,
          ),
        );
      }
    } else {
      updatedLikedUsers.removeWhere((user) => user.userId == currentUser?.id);
    }

    feeds[index] = model.copyWith(
      isLikedByMe: !isCurrentlyLiked,
      likesCount: isCurrentlyLiked
          ? (model.likesCount - 1)
          : (model.likesCount + 1),
      likedByUsers: updatedLikedUsers,
    );
    feeds.refresh();

    final result = await communityRepo.toggleLike(model.contentId);
    if (!result) {
      feeds[index] = model;
      feeds.refresh();
      CommonSnackbar.error('failedToUpdateLike'.tr);
    }
  }

  TextEditingController getCommentController(String contentId) {
    if (!commentControllers.containsKey(contentId)) {
      commentControllers[contentId] = TextEditingController();
    }
    return commentControllers[contentId]!;
  }

  void showCommentsModal(String contentId) {
    fetchComments(contentId);
    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsModal(contentId: contentId),
    );
  }

  final isSubmittingComment = false.obs;

  Future<void> fetchComments(String contentId) async {
    try {
      isCommentsLoading.value = true;
      final result = await communityRepo.getComments(contentId);
      comments.value = result;
    } finally {
      isCommentsLoading.value = false;
    }
  }

  Future<void> submitComment(String contentId, {String? modalText}) async {
    final text = modalText ?? getCommentController(contentId).text.trim();
    if (text.isEmpty) return;

    try {
      isSubmittingComment.value = true;
      final success = await communityRepo.addComment(contentId, text);
      if (success) {
        if (modalText == null) getCommentController(contentId).clear();

        // Refresh comments list
        await fetchComments(contentId);

        // Update local feed count
        final index = feeds.indexWhere((e) => e.contentId == contentId);
        if (index != -1) {
          feeds[index] = feeds[index].copyWith(
            commentsCount: feeds[index].commentsCount + 1,
          );
          feeds.refresh();
        }
        CommonSnackbar.success('commentAdded'.tr);
      }
    } finally {
      isSubmittingComment.value = false;
    }
  }

  String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'titleRequired'.tr;
    }
    if (value.length > 50) {
      return 'titleMaxLengthExceeded'.tr;
    }
    return null;
  }

  String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'descriptionRequired'.tr;
    }
    return null;
  }

  void setSelectedFile(PlatformFile? file) {
    selectedFile.value = file;
    if (file == null) {
      // File was removed - clear the "already uploaded" flag and show validation error
      isAlreadyFileUploaded.value = false;
    } else {
      // New file selected - clear any existing error
      imageError.value = '';
    }
  }

  void clearAllFields() {
    titleController.text = '';
    descriptionController.text = '';
    selectedFile.value = null;
    titleError.value = '';
    descriptionError.value = '';
    imageError.value = '';
    hasValidated.value = false;
    isAlreadyFileUploaded.value = false;
    isEditing.value = false;
    editingContentId.value = '';
    checkboxValue.value = true;
    formKey.currentState?.reset();
  }

  void prefillFormForEdit(ContentFullDetailsModel content) {
    debugPrint('shared: ${content.isSharedToCommunity}');
    isEditing.value = true;
    editingContentId.value = content.contentId;
    titleController.text = content.title ?? '';
    descriptionController.text = content.description ?? '';
    selectedFile.value = null;
    isAlreadyFileUploaded.value =
        content.mediaFileUrl != null && content.mediaFileUrl!.isNotEmpty;
    titleError.value = '';
    imageError.value = '';
    descriptionError.value = '';
    checkboxValue.value = content.isSharedToCommunity;
    hasValidated.value = false;
  }

  final hasError = false.obs;

  Future<void> createFeed() async {
    hasError.value = false;
    titleError.value = '';
    descriptionError.value = '';
    imageError.value = '';
    if (titleController.text.isEmpty) {
      titleError.value = 'titleIsRequired'.tr;
      hasError.value = true;
    }
    if (descriptionController.text.isEmpty) {
      descriptionError.value = 'descriptionIsRequired'.tr;
      hasError.value = true;
    } else {
      final words = descriptionController.text
          .trim()
          .split(RegExp(r'\s+'))
          .length;
      if (words > 1000) {
        descriptionError.value = "Description can't exceed 1000 words";
        hasError.value = true;
      }
    }
    if (selectedFile.value == null ||
        selectedFile.value?.bytes == null ||
        (selectedFile.value?.bytes?.isEmpty ?? true)) {
      imageError.value = 'pleaseSelectAFileToUpload'.tr;
      hasError.value = true;
    }
    if (hasError.value) return;
    if (formKey.currentState?.validate() ?? false) {
      if ((formKey.currentState!.validate())) {
        if (selectedFile.value == null ||
            selectedFile.value?.bytes == null ||
            (selectedFile.value?.bytes?.isEmpty ?? true)) {
          titleError.value = 'pleaseSelectAFileToUpload'.tr;
          return;
        }
        isCreating.value = true;
        try {
          debugPrint('createFeed');
          final result = await CommunityRepo.createFeed(
            titleController.text.trim(),
            descriptionController.text.trim(),
            selectedFile.value!.bytes!,
            selectedFile.value!.name,
            checkboxValue.value,
          );
          if (result.isSuccess) {
            debugPrint('Feed created successfully');
            clearAllFields();
            resetPage();
            fetchFeeds();
            Get.back();
            CommonSnackbar.success('Feed created successfully');
          } else {
            debugPrint('Failed to create feed');
            CommonSnackbar.error(result.errorOrNull ?? 'Failed to create feed');
          }
        } finally {
          isCreating.value = false;
        }
      }
    }
  }

  Future<void> updateFeed() async {
    hasError.value = false;
    titleError.value = '';
    descriptionError.value = '';
    imageError.value = '';
    if (formKey.currentState?.validate() ?? false) {
      if ((formKey.currentState!.validate())) {
        if (titleController.text.isEmpty) {
          titleError.value = 'titleIsRequired'.tr;
          hasError.value = true;
        }
        if (descriptionController.text.isEmpty) {
          descriptionError.value = 'descriptionIsRequired'.tr;
          hasError.value = true;
        } else {
          final words = descriptionController.text
              .trim()
              .split(RegExp(r'\s+'))
              .length;
          if (words > 1000) {
            descriptionError.value = "Description can't exceed 1000 words";
            hasError.value = true;
          }
        }
        if (hasError.value) return;
        isCreating.value = true;
        try {
          debugPrint('updateFeed');
          final result = await communityRepo.updateFeed(
            editingContentId.value,
            titleController.text.trim(),
            descriptionController.text.trim(),
            selectedFile.value?.bytes,
            selectedFile.value?.name,
            checkboxValue.value,
          );
          if (result.isSuccess) {
            debugPrint('Feed updated successfully');
            clearAllFields();
            resetPage();
            fetchFeeds();
            Get.back();
            CommonSnackbar.success('Feed updated successfully');
          } else {
            debugPrint('Failed to update feed');
            CommonSnackbar.error(result.errorOrNull ?? 'Failed to update feed');
          }
        } finally {
          isCreating.value = false;
        }
      }
    }
  }

  void resetPage() {
    currentPage.value = 1;
    hasMore.value = true;
    feeds.clear();
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
    await fetchFeeds(append: true);
  }

  void clickOnDeleteBtn(String contentId) {
    CMDialogs.showConfirmationDialog(
      title: 'confirmDeletion'.tr,
      subtitle: 'areYouSureYouWantToDeleteThisPost'.tr,
      onPressed: isLoading.value ? null : () => deleteContent(contentId),
    );
  }

  Future<void> deleteContent(String contentId) async {
    debugPrint('called: $contentId');
    try {
      isLoading.value = true;
      final success = await communityRepo.deleteContent(contentId);
      Get.back();
      if (success) {
        await fetchFeeds();
        CommonSnackbar.success('contentDeletedSuccessfully'.tr);
      } else {
        CommonSnackbar.error('failedToDeleteContent'.tr);
      }
    } finally {
      isLoading.value = false;
    }
  }

  void clickOnDeleteComment(String contentId, String commentId) {
    CMDialogs.showConfirmationDialog(
      title: 'confirmDeletion'.tr,
      subtitle: 'areYouSureYouWantToDeleteThisComment'.tr,
      onPressed: isCommentsLoading.value
          ? null
          : () {
              Get.back(); // close dialog
              deleteComment(contentId, commentId);
            },
    );
  }

  Future<void> deleteComment(String contentId, String commentId) async {
    try {
      final success = await communityRepo.deleteComment(commentId);
      if (success) {
        await fetchComments(contentId);
        // Update local feed count
        final index = feeds.indexWhere((e) => e.contentId == contentId);
        if (index != -1) {
          feeds[index] = feeds[index].copyWith(
            commentsCount: feeds[index].commentsCount > 0
                ? feeds[index].commentsCount - 1
                : 0,
          );
          feeds.refresh();
        }
        CommonSnackbar.success('commentDeletedSuccessfully'.tr);
      } else {
        CommonSnackbar.error('failedToDeleteComment'.tr);
      }
    } catch (e) {
      debugPrint('🔥 Error in deleteComment: $e');
      CommonSnackbar.error('failedToDeleteComment'.tr);
    }
  }

  Future<void> fetchFeeds({
    String? searchTerm,
    String? orderBy,
    String? startDate,
    String? endDate,
    bool append = false,
  }) async {
    try {
      if (append) {
        isLoadingMore.value = true;
      } else {
        isLoading.value = true;
        feeds.clear();
        currentPage.value = 1;
        hasMore.value = true;
      }
      CommunityListResponse response = await communityRepo
          .getFeedsWithPagination(
            page: currentPage.value,
            perPage: perPage.value,
            searchTerm: searchTerm ?? searchController.text,
            shortBy: orderBy ?? selectedShortByValue.value,
            startDate: startDate,
            endDate: endDate,
          );
      totalCount.value = response.totalCount;
      totalPages.value = response.totalPages;
      if (append) {
        feeds.addAll(response.data);
      } else {
        feeds.value = response.data;
      }
      hasMore.value = currentPage.value < totalPages.value;
    } catch (e) {
      debugPrint('🔥 Exception occurred in fetchFeeds');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  void clickReadMoreBtn(ContentFullDetailsModel model) {
    final contentId = model.contentId;
    showDialog(
      context: Get.context!,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Obx(() {
        final updatedModel = feeds.firstWhere(
          (element) => element.contentId == contentId,
          orElse: () => model,
        );

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: GestureDetector(
            onTap: () => Get.back(),
            behavior: HitTestBehavior.opaque,
            child: Center(
              child: GestureDetector(
                onTap: () {}, // Prevent tap from closing when clicking on card
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.backgroundColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: FeedCard(
                        contentModel: updatedModel,
                        itemWidth: Get.width * 0.4,
                        showFullContent: true,
                        onDelete: () {
                          Get.back();
                          clickOnDeleteBtn(updatedModel.contentId);
                        },
                        onEdit: () {
                          Get.back();
                          prefillFormForEdit(updatedModel);
                          showCommonModal(
                            Get.context!,
                            width: 678,
                            title: 'editPost'.tr,
                            description: 'communityDescription'.tr,
                            child: CreateEditFeed(controller: this),
                            canDismiss: () => !isCreating.value,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
