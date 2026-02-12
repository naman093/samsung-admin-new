import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:samsung_admin_main_new/app/common/core/base/base_controller.dart';
import 'package:samsung_admin_main_new/app/common/core/utils/result.dart';
import 'package:samsung_admin_main_new/app/common/services/user_service.dart';
import 'package:samsung_admin_main_new/app/models/dashboard_counts_model.dart';
import 'package:samsung_admin_main_new/app/models/user_model.dart';
import 'package:samsung_admin_main_new/app/repository/dashboard_repo.dart';

import '../../../repository/auth_repo/auth_repo.dart';

class HomeController extends BaseController {
  final UserService _userService;
  final DashBoardRepo _dashBoardRepo;

  final selectedRange = 'weeklyRangeTitle'.obs;
  final chartData = <List<double>>[].obs;

  // Loading state specifically for the dashboard bar chart.
  final RxBool isChartLoading = false.obs;

  final authController = Get.find<AuthRepo>();

  final RxList<UserModel> users = <UserModel>[].obs;

  final RxList<UserModel> filteredUsers = <UserModel>[].obs;

  final RxString searchQuery = ''.obs;

  final RxString statusFilter = 'all'.obs;

  final Rx<UserModel?> selectedUser = Rx<UserModel?>(null);

  final Rx<DashboardCounts?> dashboardCounts = Rx<DashboardCounts?>(null);

  final RxList<String> chartLabels = <String>[].obs;

  HomeController({UserService? userService, DashBoardRepo? dashBoardRepo})
    : _userService = userService ?? UserService(),
      _dashBoardRepo = dashBoardRepo ?? DashBoardRepo();

  @override
  void onInit() {
    super.onInit();
    loadUsers();
    loadDashboardCounts();
    loadChartData();

    ever(searchQuery, (_) => _filterUsers());
    ever(statusFilter, (_) => _filterUsers());
    ever(selectedRange, (_) => loadChartData());
  }

  Future<void> loadDashboardCounts() async {
    final result = await _dashBoardRepo.getCounts();
    if (result.isSuccess) {
      dashboardCounts.value = result.dataOrNull;
      debugPrint(
        '✅ Dashboard counts loaded: ${dashboardCounts.value?.toJson()}',
      );
    } else {
      debugPrint('❌ Error loading dashboard counts: ${result.errorOrNull}');
    }
  }

  Future<void> loadChartData() async {
    isChartLoading.value = true;
    final now = DateTime.now();
    DateTime startDate;
    int bucketCount;
    bool isDaily = false;

    // Map both new (weekly/monthly/yearly) and legacy range keys
    // to concrete date ranges without removing existing behavior.
    if (selectedRange.value == 'yearlyRangeTitle' ||
        selectedRange.value == 'last12MonthsRangeTitle') {
      // Yearly / last 12 months - monthly buckets
      startDate = DateTime(now.year - 1, now.month + 1, 1);
      bucketCount = 12;
    } else if (selectedRange.value == 'monthlyRangeTitle' ||
        selectedRange.value == 'last30DaysRangeTitle') {
      // Monthly view - last 30 days (daily buckets)
      startDate = now.subtract(const Duration(days: 30));
      bucketCount = 30;
      isDaily = true;
    } else if (selectedRange.value == 'weeklyRangeTitle') {
      // Weekly view - last 7 days (daily buckets)
      startDate = now.subtract(const Duration(days: 6));
      bucketCount = 7;
      isDaily = true;
    } else {
      // Default / legacy: last 6 months - monthly buckets
      startDate = DateTime(now.year, now.month - 5, 1);
      bucketCount = 6;
    }

    final result = await _dashBoardRepo.getChartData(
      startDate: startDate,
      endDate: now,
    );

    if (result.isSuccess) {
      final dataMap = result.dataOrNull!;
      final newChartData = <List<double>>[];
      final newLabels = <String>[];

      if (isDaily) {
        for (int i = 0; i < bucketCount; i++) {
          final date = startDate.add(Duration(days: i));
          newLabels.add(DateFormat('dd/MM').format(date));
          newChartData.add(_countForDate(dataMap, date, isMonthly: false));
        }
      } else {
        for (int i = 0; i < bucketCount; i++) {
          final date = DateTime(startDate.year, startDate.month + i, 1);
          newLabels.add(DateFormat('MMM').format(date));
          newChartData.add(_countForDate(dataMap, date, isMonthly: true));
        }
      }

      chartData
        ..clear()
        ..addAll(newChartData);
      chartLabels
        ..clear()
        ..addAll(newLabels);
      debugPrint('✅ Chart data loaded with ${newChartData.length} buckets');
    } else {
      debugPrint('❌ Error loading chart data: ${result.errorOrNull}');
      chartData.clear();
      chartLabels.clear();
    }

    isChartLoading.value = false;
  }

  List<double> _countForDate(
    Map<String, List<DateTime>> dataMap,
    DateTime date, {
    required bool isMonthly,
  }) {
    double posts = 0;
    double lessons = 0;
    double tasks = 0;
    double zoom = 0;

    bool isMatch(DateTime d) {
      if (isMonthly) {
        return d.year == date.year && d.month == date.month;
      } else {
        return d.year == date.year &&
            d.month == date.month &&
            d.day == date.day;
      }
    }

    posts = dataMap['posts']?.where(isMatch).length.toDouble() ?? 0;
    lessons = dataMap['lessons']?.where(isMatch).length.toDouble() ?? 0;
    tasks = dataMap['tasks']?.where(isMatch).length.toDouble() ?? 0;
    zoom = dataMap['zoom']?.where(isMatch).length.toDouble() ?? 0;

    return [posts, lessons, tasks, zoom];
  }

  Future<void> loadUsers() async {
    setLoading(true);
    clearError();

    debugPrint('📋 Loading users...');
    final result = await _userService.getAllUsers();

    setLoading(false);

    if (result.isSuccess) {
      users.value = result.dataOrNull ?? [];

      final adminCount = users.where((u) => u.role == UserRole.admin).length;
      if (adminCount > 0) {
        debugPrint('⚠️  WARNING: $adminCount admin users in users list!');
      }

      _filterUsers();
      debugPrint('✅ Loaded ${users.length} users (before filter)');
      debugPrint('✅ Displaying ${filteredUsers.length} users (after filter)');
    } else {
      final error = result.errorOrNull ?? 'Failed to load users';
      debugPrint('❌ Error loading users: $error');
      handleError(error);
    }
  }

  void _filterUsers() {
    var filtered = users.toList();

    final roleCount = <String, int>{};
    for (var user in filtered) {
      final roleName = user.role.name;
      roleCount[roleName] = (roleCount[roleName] ?? 0) + 1;
    }
    debugPrint('🔍 User roles before filter: $roleCount');

    final beforeCount = filtered.length;
    filtered = filtered.where((user) => user.role != UserRole.admin).toList();
    debugPrint('🔍 Filtered out ${beforeCount - filtered.length} admin users');

    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((user) {
        final name = user.fullName?.toLowerCase() ?? '';
        final phone = user.phoneNumber.toLowerCase();
        final city = user.city?.toLowerCase() ?? '';
        return name.contains(query) ||
            phone.contains(query) ||
            city.contains(query);
      }).toList();
    }

    // Apply status filter
    if (statusFilter.value != 'all') {
      filtered = filtered.where((user) {
        return user.status.name == statusFilter.value;
      }).toList();
    }

    filteredUsers.value = filtered;
    debugPrint(
      '🔍 Filtered to ${filteredUsers.length} users (admins excluded)',
    );
  }

  void searchUsers(String query) {
    searchQuery.value = query;
  }

  void changeStatusFilter(String status) {
    statusFilter.value = status;
  }

  void selectUser(UserModel user) {
    selectedUser.value = user;
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
      final index = users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        users[index] = result.dataOrNull!;
        _filterUsers();
      }
      debugPrint('✅ User confirmed successfully');
    } else {
      final error = result.errorOrNull ?? 'Failed to confirm user';
      handleError(error);
      debugPrint('❌ Error: $error');
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
      final index = users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        users[index] = result.dataOrNull!;
        _filterUsers();
      }
      debugPrint('✅ User rejected successfully');
    } else {
      final error = result.errorOrNull ?? 'Failed to reject user';
      handleError(error);
      debugPrint('❌ Error: $error');
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
      // Update the user in the list
      final index = users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        users[index] = result.dataOrNull!;
        _filterUsers();
      }
      debugPrint('✅ User blocked successfully');
    } else {
      final error = result.errorOrNull ?? 'Failed to block user';
      handleError(error);
      debugPrint('❌ Error: $error');
    }
  }

  Future<void> unblockUser(String userId) async {
    setLoading(true);
    clearError();

    final result = await _userService.unblockUser(userId);

    setLoading(false);

    if (result.isSuccess) {
      // Update the user in the list
      final index = users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        users[index] = result.dataOrNull!;
        _filterUsers();
      }
      debugPrint('✅ User unblocked successfully');
    } else {
      final error = result.errorOrNull ?? 'Failed to unblock user';
      handleError(error);
      debugPrint('❌ Error: $error');
    }
  }

  Future<void> deleteUser(String userId) async {
    setLoading(true);
    clearError();

    final result = await _userService.deleteUser(userId);

    setLoading(false);

    if (result.isSuccess) {
      // Remove the user from the list
      users.removeWhere((u) => u.id == userId);
      _filterUsers();
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
}
