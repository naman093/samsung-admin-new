import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:samsung_admin_main_new/app/common/common_snackbar.dart';
import 'package:samsung_admin_main_new/app/common/constant/types.dart';
import 'package:samsung_admin_main_new/app/common/core/base/base_controller.dart';
import 'package:samsung_admin_main_new/app/common/core/utils/result.dart';
import 'package:samsung_admin_main_new/app/repository/auth_repo/auth_repo.dart';
import 'package:video_player/video_player.dart';

import '../../../app_theme/app_colors.dart';
import '../../../common/services/user_service.dart';
import '../../../models/user_model.dart';
import '../local_widget/user_submission_dialog_view.dart';

class UsersController extends BaseController {
  final UserService _userService;

  final RxList<UserModel> users = <UserModel>[].obs;

  final RxString searchQuery = ''.obs;

  final RxString statusFilter = 'all'.obs;
  final RxString sortBy = 'all'.obs;

  final Rx<UserModel?> selectedUser = Rx<UserModel?>(null);
  final numberOfPoints = TextEditingController();

  final authController = Get.find<AuthRepo>();

  final shortByLabelMap = {
    'all': 'all'.tr,
    'points_balance': 'pointsBalance'.tr,
    'gender': 'gender'.tr,
    'full_name': 'fullName'.tr,
  };

  final shortByList = ['all', 'points_balance', 'gender', 'full_name'];

  final statusLabelMap = {
    'all': 'all'.tr,
    'pending': 'pending'.tr,
    'approved': 'approved'.tr,
    'rejected': 'rejected'.tr,
    'suspended': 'suspended'.tr,
  };

  final statusList = ['all', 'pending', 'approved', 'rejected', 'suspended'];

  final pointError = ''.obs;

  // User Activity Stats
  final zoomParticipations = 0.obs;
  final watchingVideos = 0.obs;
  final academicTasks = 0.obs;
  final isLoadingActivityStats = false.obs;

  // User Task Submissions
  final assignmentSubmissions = <Map<String, dynamic>>[].obs;
  final riddleSubmissions = <Map<String, dynamic>>[].obs;
  final totalSubmissions = 0.obs;
  final isLoadingTaskSubmissions = false.obs;

  // Pagination
  final currentPage = 1.obs;
  final perPage = 10.obs;
  final totalPages = 1.obs;
  final totalCount = 0.obs;
  final hasMore = true.obs;
  final isLoadingMore = false.obs;
  late ScrollController scrollController;
  bool _isScrollControllerDisposed = false;

  UsersController({UserService? userService})
    : _userService = userService ?? UserService();

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);
    fetchUsers();
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

  Future<void> fetchUsers({bool append = false}) async {
    if (append) {
      isLoadingMore.value = true;
    } else {
      setLoading(true);
      clearError();
      users.clear();
      currentPage.value = 1;
      hasMore.value = true;
    }

    debugPrint('📋 Fetching users page ${currentPage.value}...');
    final result = await _userService.fetchUsersWithPagination(
      pageNumber: currentPage.value,
      perPage: perPage.value,
      searchTerm: searchQuery.value,
      statusFilter: statusFilter.value,
      sortBy: sortBy.value,
    );

    setLoading(false);
    isLoadingMore.value = false;

    if (result.isSuccess) {
      final data = result.dataOrNull;
      if (data != null) {
        if (append) {
          users.addAll(data.data);
        } else {
          users.value = data.data;
        }
        totalCount.value = data.totalCount;
        totalPages.value = data.totalPages;
        hasMore.value = currentPage.value < totalPages.value;

        debugPrint(
          '✅ Loaded ${users.length} users (Page ${currentPage.value} of ${totalPages.value})',
        );
      }
    } else {
      final error = result.errorOrNull ?? 'Failed to load users';
      debugPrint('❌ Error loading users: $error');
      handleError(error);
    }
  }

  void resetPage() {
    currentPage.value = 1;
    hasMore.value = true;
    users.clear();
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
    await fetchUsers(append: true);
  }

  Future<void> addPoints(String userId) async {
    if (numberOfPoints.text.isEmpty) {
      pointError.value = 'pointsRequired'.tr;
      return;
    }

    setLoading(true);
    clearError();

    try {
      final result = await _userService.addPoints(
        userId,
        int.parse(numberOfPoints.text),
        TransactionType.earned,
      );

      if (result.isSuccess) {
        // Fetch updated user data
        await _refreshUserData(userId);
        fetchUsers();
        Get.back();
        numberOfPoints.clear();
        pointError.value = '';
        debugPrint('✅ Points added successfully');
      } else {
        final error = result.errorOrNull ?? 'Failed to add points';
        handleError(error);
        debugPrint('❌ Error: $error');
      }
    } finally {
      setLoading(false);
    }
  }

  Future<void> _refreshUserData(String userId) async {
    try {
      final result = await _userService.getUserById(userId);
      if (result.isSuccess && result.dataOrNull != null) {
        final updatedUser = result.dataOrNull!;

        // Update selectedUser if it matches
        if (selectedUser.value?.id == userId) {
          selectedUser.value = updatedUser;
        }

        // Update user in the users list
        final index = users.indexWhere((u) => u.id == userId);
        if (index != -1) {
          users[index] = updatedUser;
        }
      }
    } catch (e) {
      debugPrint('❌ Error refreshing user data: $e');
    }
  }

  void searchUsers(String query) {
    searchQuery.value = query;
    resetPage();
    fetchUsers();
  }

  void changeStatusFilter(String status) {
    statusFilter.value = status;
    resetPage();
    fetchUsers();
  }

  void changeSortBy(String sort) {
    sortBy.value = sort;
    resetPage();
    fetchUsers();
  }

  void selectUser(UserModel user) {
    selectedUser.value = user;
    fetchUserActivityCounts(user.id);
    fetchUserTaskSubmissions(user.id);
  }

  Future<void> fetchUserActivityCounts(String userId) async {
    isLoadingActivityStats.value = true;
    zoomParticipations.value = 0;
    watchingVideos.value = 0;
    academicTasks.value = 0;

    final result = await _userService.getUserActivityCounts(userId);

    isLoadingActivityStats.value = false;

    if (result.isSuccess) {
      final counts = result.dataOrNull;
      if (counts != null) {
        zoomParticipations.value = counts['zoom_participations'] ?? 0;
        watchingVideos.value = counts['watching_videos'] ?? 0;
        academicTasks.value = counts['academic_tasks'] ?? 0;
        debugPrint(
          '✅ Activity counts loaded: Zoom=${zoomParticipations.value}, Videos=${watchingVideos.value}, Tasks=${academicTasks.value}',
        );
      }
    } else {
      final error = result.errorOrNull ?? 'Failed to load activity counts';
      debugPrint('❌ Error loading activity counts: $error');
    }
  }

  Future<void> fetchUserTaskSubmissions(String userId) async {
    isLoadingTaskSubmissions.value = true;
    assignmentSubmissions.clear();
    riddleSubmissions.clear();
    totalSubmissions.value = 0;

    final result = await _userService.getUserTaskSubmissions(userId);

    isLoadingTaskSubmissions.value = false;

    if (result.isSuccess) {
      final submissions = result.dataOrNull;
      if (submissions != null) {
        assignmentSubmissions.value = List<Map<String, dynamic>>.from(
          submissions['assignment_submissions'] ?? [],
        );
        riddleSubmissions.value = List<Map<String, dynamic>>.from(
          submissions['riddle_submissions'] ?? [],
        );
        totalSubmissions.value = submissions['total_count'] ?? 0;
        debugPrint(
          '✅ Task submissions loaded: Assignments=${assignmentSubmissions.length}, Riddles=${riddleSubmissions.length}, Total=${totalSubmissions.value}',
        );
      }
    } else {
      final error = result.errorOrNull ?? 'Failed to load task submissions';
      debugPrint('❌ Error loading task submissions: $error');
    }
  }

  Future<void> confirmUser(String userId, String approvedBy) async {
    setLoading(true);
    clearError();

    final result = await _userService.confirmUser(
      userId: userId,
      approvedBy: approvedBy,
    );

    setLoading(false);

    if (result.isSuccess) {
      fetchUsers();
      CommonSnackbar.success(' User confirmed successfully');
    } else {
      final error = result.errorOrNull ?? 'Failed to confirm user';
      handleError(error);
      CommonSnackbar.error(error);
    }
  }

  Future<void> rejectUser(String userId, String rejectedBy) async {
    setLoading(true);
    clearError();

    final result = await _userService.rejectUser(
      userId: userId,
      rejectedBy: rejectedBy,
    );

    setLoading(false);

    if (result.isSuccess) {
      fetchUsers();
      CommonSnackbar.success(' User rejected successfully');
    } else {
      final error = result.errorOrNull ?? 'Failed to reject user';
      handleError(error);
      CommonSnackbar.error(error);
    }
  }

  Future<void> blockUser(String userId, String blockedBy) async {
    setLoading(true);
    clearError();

    final result = await _userService.blockUser(
      userId: userId,
      blockedBy: blockedBy,
    );

    setLoading(false);

    if (result.isSuccess) {
      fetchUsers();
      CommonSnackbar.success(' User blocked successfully');
    } else {
      final error = result.errorOrNull ?? 'Failed to block user';
      handleError(error);
      CommonSnackbar.error(error);
    }
  }

  Future<void> unblockUser(String userId) async {
    setLoading(true);
    clearError();

    final result = await _userService.unblockUser(userId);

    setLoading(false);

    if (result.isSuccess) {
      fetchUsers();
      CommonSnackbar.success(' User unblocked successfully');
    } else {
      final error = result.errorOrNull ?? 'Failed to unblock user';
      handleError(error);
      CommonSnackbar.error(error);
    }
  }

  Future<void> deleteUser(String userId) async {
    setLoading(true);
    clearError();

    final result = await _userService.deleteUser(userId);

    setLoading(false);

    if (result.isSuccess) {
      fetchUsers();
      debugPrint('✅ User deleted successfully');
    } else {
      final error = result.errorOrNull ?? 'Failed to delete user';
      handleError(error);
      debugPrint('❌ Error: $error');
    }
  }

  String getStatusDisplayText(UserStatus status) {
    switch (status) {
      case UserStatus.pending:
        return 'awaitingApproval'.tr;
      case UserStatus.approved:
        return 'happiness'.tr;
      case UserStatus.rejected:
        return 'rejected'.tr;
      case UserStatus.suspended:
        return 'suspended'.tr;
    }
  }

  String formatDOB(DateTime? dob) {
    if (dob == null) return '-';
    return '${dob.day.toString().padLeft(2, '0')}/${dob.month.toString().padLeft(2, '0')}/${dob.year}';
  }

  String getGenderDisplayText(GenderType? gender) {
    if (gender == null) return '-';
    switch (gender) {
      case GenderType.male:
        return 'Male';
      case GenderType.female:
        return 'Female';
      case GenderType.other:
        return 'Other';
      case GenderType.preferNotToSay:
        return 'Prefer not to say';
    }
  }

  String getSocialMediaLink(Map<String, dynamic> links) {
    if (links.isEmpty) return '-';
    final firstLink = links.values.first;
    if (firstLink is String && firstLink.isNotEmpty) {
      return firstLink;
    }
    return '-';
  }

  SolutionType _detectSolutionType(String solution) {
    bool isValidUrl(String value) {
      final uri = Uri.tryParse(value);
      return uri != null &&
          uri.hasScheme &&
          (uri.scheme == 'http' || uri.scheme == 'https');
    }

    if (!isValidUrl(solution)) {
      return SolutionType.text;
    }

    final lower = solution.toLowerCase();

    // Image
    if (lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.gif')) {
      return SolutionType.image;
    }

    // Video
    if (lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.webm') ||
        lower.endsWith('.mkv')) {
      return SolutionType.video;
    }

    // Audio
    if (lower.endsWith('.mp3') ||
        lower.endsWith('.wav') ||
        lower.endsWith('.aac') ||
        lower.endsWith('.m4a') ||
        lower.endsWith('.ogg')) {
      return SolutionType.audio;
    }

    return SolutionType.unknown;
  }

  void showSubmissionPreviewDialog(
    Map<String, dynamic> submission,
    String type,
  ) {
    final solution = submission['solution'] as String? ?? '';
    final solutionType = _detectSolutionType(solution);

    VideoPlayerController? videoController;
    if (solutionType == SolutionType.video ||
        solutionType == SolutionType.audio) {
      videoController = VideoPlayerController.networkUrl(Uri.parse(solution));
    }

    showDialog(
      context: Get.context!,
      barrierDismissible: true,
      barrierColor: AppColors.backgroundColor.withValues(alpha: .9),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: UserSubmissionDialogView(
            type: type,
            submission: submission,
            solutionType: solutionType,
            videoController: videoController,
          ),
        );
      },
    ).then((_) {
      videoController?.dispose();
    });
  }
}

enum SolutionType { text, image, video, audio, unknown }
