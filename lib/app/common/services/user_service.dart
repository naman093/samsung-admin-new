import 'package:flutter/material.dart';
import 'package:samsung_admin_main_new/app/common/constant/types.dart';
import 'package:samsung_admin_main_new/app/common/core/exceptions/app_exception.dart';
import 'package:samsung_admin_main_new/app/common/core/utils/result.dart';
import 'package:samsung_admin_main_new/app/common/services/supabase_service.dart';
import 'package:samsung_admin_main_new/app/models/user_model.dart';

/// Service for user management operations
class UserService {
  /// Get all users from the database
  /// Returns a list of all users with their details
  Future<Result<List<UserModel>>> getAllUsers({
    String? statusFilter,
    String? roleFilter,
    int? limit,
    int? offset,
  }) async {
    try {
      print('📋 Fetching all users...');

      // Build query dynamically
      dynamic query = SupabaseService.client
          .from('users')
          .select()
          .or('deleted_at.is.null');

      // Exclude admin users from the list
      query = query.neq('role', 'admin');

      // Apply filters if provided
      if (statusFilter != null && statusFilter.isNotEmpty) {
        query = query.eq('status', statusFilter);
      }

      if (roleFilter != null && roleFilter.isNotEmpty) {
        query = query.eq('role', roleFilter);
      }

      // Apply ordering
      query = query.order('created_at', ascending: false);

      // Apply pagination if provided
      if (limit != null) {
        query = query.limit(limit);
      }

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 10) - 1);
      }

      final response = await query;

      if (response == null || response.isEmpty) {
        print('  ℹ️ No users found');
        return const Success([]);
      }

      final users = (response as List)
          .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
          .toList();

      print('  ✅ Fetched ${users.length} users');
      if (users.isNotEmpty) {
        print(
          '  📊 Sample user: ${users.first.fullName ?? users.first.phoneNumber}',
        );
      }

      // Debug: Check if any admin users slipped through
      final adminUsers = users.where((u) => u.role == UserRole.admin).toList();
      if (adminUsers.isNotEmpty) {
        print(
          '  ⚠️  WARNING: ${adminUsers.length} admin users found in results!',
        );
        print(
          '  Admin users: ${adminUsers.map((u) => u.phoneNumber).join(", ")}',
        );
      }

      // Filter out admin users as a safety measure
      final filteredUsers = users
          .where((u) => u.role != UserRole.admin)
          .toList();
      print('  🔒 After admin filter: ${filteredUsers.length} users');

      return Success(filteredUsers);
    } catch (e) {
      print('  ❌ Error fetching users: $e');
      print('  Stack trace: ${StackTrace.current}');
      // Check if it's a permission error
      if (e.toString().contains('permission')) {
        print('  ⚠️  Database permission issue detected!');
        print('  💡 Check your Supabase RLS policies for the users table');
      }
      return Failure(AppException.fromError(e).message);
    }
  }

  /// Add points to a user
  Future<Result<UserModel>> addPoints(
    String userId,
    int points,
    TransactionType transactionType, {
    String? description,
  }) async {
    try {
      final user = await SupabaseService.client
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      int currentPoints = user?['points_balance'] ?? 0;
      int newBalance = transactionType == TransactionType.spent
          ? currentPoints - points
          : currentPoints + points;

      await SupabaseService.client.from('points_transactions').insert({
        'user_id': userId,
        'amount': transactionType == TransactionType.spent ? -points : points,
        'transaction_type': transactionType.name,
        'description': description ?? 'Point added by admin',
        'balance_after': newBalance,
      });

      final response = await SupabaseService.client
          .from('users')
          .update({
            'points_balance': newBalance,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId)
          .select()
          .single();

      final updatedUser = UserModel.fromJson(response);
      print('  ✅ Points updated successfully. New balance: $newBalance');
      return Success(updatedUser);
    } catch (e) {
      print('  ❌ Error adding points: $e');
      return Failure(AppException.fromError(e).message);
    }
  }

  /// Get pending users (awaiting approval)
  Future<Result<List<UserModel>>> getPendingUsers() async {
    return getAllUsers(statusFilter: 'pending');
  }

  /// Get user by ID
  Future<Result<UserModel?>> getUserById(String userId) async {
    try {
      print('👤 Fetching user by ID: $userId');

      final response = await SupabaseService.client
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        print('  ⚠️ User not found');
        return const Success(null);
      }

      final user = UserModel.fromJson(response);
      print('  ✅ User found: ${user.fullName ?? user.phoneNumber}');
      return Success(user);
    } catch (e) {
      print('  ❌ Error fetching user: $e');
      return Failure(AppException.fromError(e).message);
    }
  }

  /// Confirm/Approve a user
  /// Changes status from 'pending' to 'approved'
  Future<Result<UserModel>> confirmUser({
    required String userId,
    required String approvedBy,
  }) async {
    try {
      print('✅ Confirming user: $userId');

      final response = await SupabaseService.client
          .from('users')
          .update({
            'status': 'approved',
            'approved_at': DateTime.now().toIso8601String(),
            'approved_by': approvedBy,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId)
          .select()
          .single();

      final updatedUser = UserModel.fromJson(response);
      print('  ✅ User confirmed successfully');
      return Success(updatedUser);
    } catch (e) {
      print('  ❌ Error confirming user: $e');
      return Failure(AppException.fromError(e).message);
    }
  }

  /// Reject a user
  /// Changes status from 'pending' to 'rejected'
  Future<Result<UserModel>> rejectUser({
    required String userId,
    required String rejectedBy,
  }) async {
    try {
      print('❌ Rejecting user: $userId');

      final response = await SupabaseService.client
          .from('users')
          .update({
            'status': 'rejected',
            'approved_by': rejectedBy, // Store who rejected
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId)
          .select()
          .single();

      final updatedUser = UserModel.fromJson(response);
      print('  ✅ User rejected successfully');
      return Success(updatedUser);
    } catch (e) {
      print('  ❌ Error rejecting user: $e');
      return Failure(AppException.fromError(e).message);
    }
  }

  /// Block/Suspend a user
  /// Changes status to 'suspended'
  Future<Result<UserModel>> blockUser({
    required String userId,
    required String blockedBy,
  }) async {
    try {
      print('🚫 Blocking user: $userId');

      final response = await SupabaseService.client
          .from('users')
          .update({
            'status': 'suspended',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId)
          .select()
          .single();

      final updatedUser = UserModel.fromJson(response);
      print('  ✅ User blocked successfully');
      return Success(updatedUser);
    } catch (e) {
      print('  ❌ Error blocking user: $e');
      return Failure(AppException.fromError(e).message);
    }
  }

  /// Unblock a user
  /// Changes status from 'suspended' back to 'approved'
  Future<Result<UserModel>> unblockUser(String userId) async {
    try {
      print('🔓 Unblocking user: $userId');

      final response = await SupabaseService.client
          .from('users')
          .update({
            'status': 'approved',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId)
          .select()
          .single();

      final updatedUser = UserModel.fromJson(response);
      print('  ✅ User unblocked successfully');
      return Success(updatedUser);
    } catch (e) {
      print('  ❌ Error unblocking user: $e');
      return Failure(AppException.fromError(e).message);
    }
  }

  /// Delete a user (soft delete or hard delete)
  Future<Result<void>> deleteUser(String userId) async {
    try {
      print('🗑️ Deleting user: $userId');

      await SupabaseService.client
          .from('users')
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', userId)
          .select()
          .single();

      print('  ✅ User deleted successfully');
      return const Success(null);
    } catch (e) {
      print('  ❌ Error deleting user: $e');
      return Failure(AppException.fromError(e).message);
    }
  }

  /// Update user details
  Future<Result<UserModel>> updateUser({
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      print('📝 Updating user: $userId');

      // Always update the updated_at timestamp
      updates['updated_at'] = DateTime.now().toIso8601String();

      final response = await SupabaseService.client
          .from('users')
          .update(updates)
          .eq('id', userId)
          .select()
          .single();

      final updatedUser = UserModel.fromJson(response);
      print('  ✅ User updated successfully');
      return Success(updatedUser);
    } catch (e) {
      print('  ❌ Error updating user: $e');
      return Failure(AppException.fromError(e).message);
    }
  }

  /// Search users by name, phone, or email
  Future<Result<List<UserModel>>> searchUsers(String query) async {
    try {
      print('🔍 Searching users with query: $query');

      final response = await SupabaseService.client
          .from('users')
          .select()
          .neq('role', 'admin') // Exclude admin users
          .or('full_name.ilike.%$query%,phone_number.ilike.%$query%')
          .order('created_at', ascending: false);

      if (response.isEmpty) {
        print('  ℹ️ No users found matching query');
        return const Success([]);
      }

      final users = (response as List)
          .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
          .toList();

      // Filter out admin users as a safety measure
      final filteredUsers = users
          .where((u) => u.role != UserRole.admin)
          .toList();
      print('  ✅ Found ${filteredUsers.length} users (admins excluded)');
      return Success(filteredUsers);
    } catch (e) {
      print('  ❌ Error searching users: $e');
      return Failure(AppException.fromError(e).message);
    }
  }

  Future<Result<Map<String, int>>> getUserStats() async {
    try {
      final allUsers = await SupabaseService.client
          .from('users')
          .select('status, role')
          .neq('role', 'admin');

      if (allUsers.isEmpty) {
        return const Success({
          'total': 0,
          'pending': 0,
          'approved': 0,
          'rejected': 0,
          'suspended': 0,
        });
      }

      final usersList = allUsers as List;
      final stats = {
        'total': usersList.length,
        'pending': usersList.where((u) => u['status'] == 'pending').length,
        'approved': usersList.where((u) => u['status'] == 'approved').length,
        'rejected': usersList.where((u) => u['status'] == 'rejected').length,
        'suspended': usersList.where((u) => u['status'] == 'suspended').length,
      };

      return Success(stats);
    } catch (e) {
      return Failure(AppException.fromError(e).message);
    }
  }

  Future<List<UserModel>> fetchUserBlockList() async {
    try {
      // ---------- DATA QUERY ----------
      dynamic dataQuery = SupabaseService.client
          .from('users')
          .select('*')
          .eq('status', 'suspended');

      final response = await dataQuery.order('updated_at', ascending: false);

      final data = (response as List)
          .map((e) => UserModel.fromJson(e))
          .toList();

      return data;
    } catch (e) {
      debugPrint('❌ fetchUserBlockListWithPagination Error: $e');
      return [];
    }
  }

  Future<Result<Map<String, int>>> getUserActivityCounts(String userId) async {
    try {
      final zoomResponse = await SupabaseService.client
          .from('event_registrations')
          .select('id')
          .eq('user_id', userId);

      final zoomCount = (zoomResponse as List).length;
      final academicResponse = await SupabaseService.client
          .from('assignment_submissions')
          .select('id')
          .eq('user_id', userId);

      final academicCount = (academicResponse as List).length;

      final counts = {
        'zoom_participations': zoomCount,
        'watching_videos': 0,
        'academic_tasks': academicCount,
      };

      return Success(counts);
    } catch (e) {
      return Failure(AppException.fromError(e).message);
    }
  }

  Future<Result<Map<String, dynamic>>> getUserTaskSubmissions(
    String userId,
  ) async {
    try {
      final assignmentResponse = await SupabaseService.client
          .from('assignment_submissions')
          .select('*, assignments(total_points_to_win)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final assignmentSubmissions = assignmentResponse as List;

      final riddleResponse = await SupabaseService.client
          .from('riddle_submissions')
          .select('*, weekly_riddles(points_to_earn)')
          .eq('user_id', userId);

      final riddleSubmissions = riddleResponse as List;

      final submissions = {
        'assignment_submissions': assignmentSubmissions,
        'riddle_submissions': riddleSubmissions,
        'total_count': assignmentSubmissions.length + riddleSubmissions.length,
      };

      return Success(submissions);
    } catch (e) {
      return Failure(AppException.fromError(e).message);
    }
  }

  /// Fetch users with pagination, search, sorting, and filtering
  Future<Result<UserListResponse>> fetchUsersWithPagination({
    required int pageNumber,
    required int perPage,
    String? searchTerm,
    String? statusFilter,
    String? sortBy,
  }) async {
    try {
      print('📋 Fetching users page $pageNumber...');

      final from = (pageNumber - 1) * perPage;
      final to = from + perPage - 1;

      // Base function to apply filters
      dynamic applyFilters(dynamic base) {
        // Filter for users with role='user' and deleted_at is null
        var query = base.eq('role', 'user').or('deleted_at.is.null');

        if (statusFilter != null && statusFilter != 'all') {
          query = query.eq('status', statusFilter);
        }

        if (searchTerm != null && searchTerm.isNotEmpty) {
          query = query.or(
            'full_name.ilike.%$searchTerm%,phone_number.ilike.%$searchTerm%,city.ilike.%$searchTerm%',
          );
        }
        return query;
      }

      // 1. Get Count
      // Use dynamic for the query chain to avoid strict typing issues with supabase_flutter
      final countQuery = applyFilters(
        SupabaseService.client.from('users').select('id'),
      );
      final countResponse = await countQuery;
      final totalCount = (countResponse as List).length;

      // 2. Get Data
      var dataQuery = applyFilters(
        SupabaseService.client.from('users').select(),
      );

      // Sorting
      if (sortBy != null && sortBy != 'all') {
        String column = 'created_at';
        bool ascending = false;

        switch (sortBy) {
          case 'points_balance':
            column = 'points_balance';
            ascending = false;
            break;
          case 'full_name':
            column = 'full_name';
            ascending = true;
            break;
          case 'gender':
            column = 'gender';
            ascending = true;
            break;
          default:
            column = 'created_at';
            ascending = false;
        }
        dataQuery = dataQuery.order(column, ascending: ascending);
      } else {
        // Default sort
        dataQuery = dataQuery.order('created_at', ascending: false);
      }

      // Pagination
      final response = await dataQuery.range(from, to);

      final data = (response as List)
          .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
          .toList();

      final totalPages = (totalCount / perPage).ceil();

      print('  ✅ Fetched ${data.length} users (Total: $totalCount)');

      return Success(
        UserListResponse(
          totalCount: totalCount,
          totalPages: totalPages < 1 ? 1 : totalPages,
          pageNumber: pageNumber,
          data: data,
        ),
      );
    } catch (e) {
      print('  ❌ Error fetching users with pagination: $e');
      return Failure(AppException.fromError(e).message);
    }
  }
}

class UserListResponse {
  final int totalCount;
  final int totalPages;
  final int pageNumber;
  final List<UserModel> data;

  UserListResponse({
    required this.totalCount,
    required this.totalPages,
    required this.pageNumber,
    required this.data,
  });
}
