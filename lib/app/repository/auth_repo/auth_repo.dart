import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:samsung_admin_main_new/app/common/common_snackbar.dart';
import 'package:samsung_admin_main_new/app/common/core/base/base_controller.dart';
import 'package:samsung_admin_main_new/app/common/core/utils/result.dart';
import 'package:samsung_admin_main_new/app/routes/app_pages.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../common/services/auth_service.dart';
import '../../common/services/get_prefs.dart';
import '../../common/services/storage_service.dart';
import '../../common/services/supabase_service.dart';
import '../../models/user_model.dart';

/// Controller for authentication state management
class AuthRepo extends BaseController {
  final SupabaseClient supabase = Supabase.instance.client;
  final AuthService _authService;

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isAuthenticated = false.obs;

  AuthRepo({AuthService? authService})
    : _authService = authService ?? AuthService();

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  /// Check authentication status
  /// Called on app startup to determine initial route
  Future<void> checkAuthStatus() async {
    print('🔐 Checking authentication status...');

    // First check if we have a stored session
    final hasStoredSession = await checkSessionStatus();
    if (hasStoredSession) {
      print('✅ Valid session found, user is authenticated');
      // If we have a session but no profile, fetch it
      if (currentUser.value == null) {
        print('📝 Loading user profile...');
        await loadCurrentUser();
      } else {
        print(
          '👤 User profile already loaded: ${currentUser.value?.phoneNumber}',
        );
      }
      return;
    }

    // Fallback to Supabase auth check
    isAuthenticated.value = _authService.isAuthenticated;
    if (isAuthenticated.value) {
      print('✅ Supabase session found, loading user...');
      await loadCurrentUser();
    } else {
      print('❌ No valid session found, user needs to log in');
    }
  }

  /// Load current user data from database
  Future<void> loadCurrentUser() async {
    setLoading(true);

    // First try to get user from stored profile
    final storedProfile = GetPrefs.getMap(GetPrefs.userProfile);
    if (storedProfile.isNotEmpty) {
      try {
        currentUser.value = UserModel.fromJson(storedProfile);
        setLoading(false);
        // Still fetch from server to ensure it's up to date
        _fetchAndUpdateUserProfile();
        return;
      } catch (e) {
        print('Error parsing stored profile: $e');
      }
    }

    // If no stored profile, fetch from database
    final result = await _authService.getCurrentUser();
    if (result.isSuccess) {
      currentUser.value = result.dataOrNull;
      // Save profile to storage
      if (result.dataOrNull != null) {
        GetPrefs.setMap(GetPrefs.userProfile, result.dataOrNull!.toJson());
      }
    } else {
      final error = result.errorOrNull ?? 'Failed to load user';
      print('Error in loadCurrentUser: $error');
      handleError(error);
    }
    setLoading(false);
  }

  /// Fetch user profile from database and update stored profile
  Future<void> _fetchAndUpdateUserProfile() async {
    try {
      final result = await _authService.getCurrentUser();
      if (result.isSuccess && result.dataOrNull != null) {
        currentUser.value = result.dataOrNull;
        GetPrefs.setMap(GetPrefs.userProfile, result.dataOrNull!.toJson());
      }
    } catch (e) {
      print('Error fetching user profile: $e');
    }
  }

  /// Check if user exists by phone number
  Future<bool> checkUserExists(String phoneNumber) async {
    setLoading(true);
    clearError();

    final result = await _authService.checkUserExists(phoneNumber);

    setLoading(false);

    if (result.isSuccess) {
      return result.dataOrNull ?? false;
    } else {
      final error = result.errorOrNull ?? 'Failed to check user';
      print('Error in checkUserExists: $error');
      handleError(error);
      return false;
    }
  }

  /// Generate OTP for signup (new users)
  Future<String?> generateOTP(String phoneNumber) async {
    setLoading(true);
    clearError();

    final result = await _authService.generateOTP(phoneNumber);

    setLoading(false);

    if (result.isSuccess) {
      CommonSnackbar.success('${result.dataOrNull}');
      return result.dataOrNull;
    } else {
      final error = result.errorOrNull ?? 'Failed to generate OTP';
      print('Error in generateOTP: $error');
      handleError(error);
      return null;
    }
  }

  /// Generate OTP for login (existing users)
  Future<String?> generateOTPForLogin(String phoneNumber) async {
    setLoading(true);
    clearError();

    final result = await _authService.generateOTPForLogin(phoneNumber);

    setLoading(false);

    if (result.isSuccess) {
      FunctionResponse response = await supabase.functions.invoke(
        'send-otp',
        method: HttpMethod.post,
        headers: {'Content-Type': 'application/json'},
        body: {'phone_number': phoneNumber},
      );

      if (response.status != 200) {
        CommonSnackbar.error('Failed to send OTP');
        return null;
      }

      CommonSnackbar.success('OTP sent successfully');
      return result.dataOrNull;
    } else {
      final error = result.errorOrNull ?? 'Failed to generate OTP for login';
      print('Error in generateOTPForLogin: $error');
      handleError(error);
      return null;
    }
  }

  /// Verify OTP for signup (only verifies, doesn't sign in)
  /// Returns true if OTP is valid, false otherwise
  Future<bool> verifyOTP({
    required String phoneNumber,
    required String otpCode,
  }) async {
    setLoading(true);
    clearError();

    final result = await _authService.verifyOTP(
      phoneNumber: phoneNumber,
      otpCode: otpCode,
    );

    setLoading(false);

    if (result.isSuccess) {
      return true;
    } else {
      final error = result.errorOrNull ?? 'OTP verification failed';
      print('Error in verifyOTP: $error');
      handleError(error);
      return false;
    }
  }

  /// Verify OTP and sign in to get session tokens
  /// Returns true if successful, false otherwise
  /// Saves session tokens and user profile to storage
  Future<bool> verifyOTPAndSignIn({
    required String phoneNumber,
    required String otpCode,
  }) async {
    setLoading(true);
    clearError();

    final result = await _authService.verifyOTPAndSignIn(
      phoneNumber: phoneNumber,
      otpCode: otpCode,
    );

    setLoading(false);

    if (result.isSuccess) {
      final sessionData = result.dataOrNull;
      if (sessionData != null) {
        // Save session tokens and profile
        await _saveSession(sessionData);

        // After successful OTP verification & sign-in, ensure the auth user's
        // email is confirmed via the Edge Function in AuthService.
        final accessToken = sessionData['access_token'] as String?;
        if (accessToken != null) {
          await _authService.confirmCurrentAuthUserEmail(
            accessToken: accessToken,
          );
        } else {
          // Fallback: try without explicit token (AuthService will resolve one)
          await _authService.confirmCurrentAuthUserEmail();
        }

        // Update current user
        if (sessionData['user'] != null) {
          try {
            final userModel = UserModel.fromJson(sessionData['user']);
            currentUser.value = userModel;
            // Ensure profile is saved to storage
            GetPrefs.setMap(GetPrefs.userProfile, userModel.toJson());
          } catch (e) {
            print('Error parsing user profile: $e');
          }
        }
        isAuthenticated.value = true;
        return true;
      }
      return false;
    } else {
      final error = result.errorOrNull ?? 'OTP verification and sign in failed';
      print('Error in verifyOTPAndSignIn: $error');
      handleError(error);
      return false;
    }
  }

  /// Save session tokens and user profile to storage
  Future<void> _saveSession(Map<String, dynamic> sessionData) async {
    print('💾 Saving session to local storage...');

    final accessToken = sessionData['access_token'] as String?;
    final refreshToken = sessionData['refresh_token'] as String?;
    final expiresAt = sessionData['expires_at'] as int?;
    final user = sessionData['user'] as Map<String, dynamic>?;

    if (accessToken != null) {
      GetPrefs.setString(GetPrefs.accessToken, accessToken);
      print('  ✓ Access token saved');
    }
    if (refreshToken != null) {
      GetPrefs.setString(GetPrefs.refreshToken, refreshToken);
      print('  ✓ Refresh token saved');
    }
    if (expiresAt != null) {
      GetPrefs.setInt(GetPrefs.expiresAt, expiresAt);
      final expiresAtDate = DateTime.fromMillisecondsSinceEpoch(
        expiresAt * 1000,
      );
      print('  ✓ Token expires at: $expiresAtDate');
    }
    if (user != null) {
      GetPrefs.setMap(GetPrefs.userProfile, user);
      print('  ✓ User profile saved: ${user['phone_number']}');
    }
    GetPrefs.setBool(GetPrefs.isLoggedIn, true);
    print('✅ Session saved successfully');
  }

  /// Check if user is authenticated by verifying stored session
  /// Returns true if session is valid, false otherwise
  Future<bool> checkSessionStatus() async {
    try {
      print('🔍 Checking stored session...');

      // First check if Supabase has a valid session (auto-persisted)
      final hasSupabaseSession = await _authService.restoreSession();
      if (hasSupabaseSession) {
        print('  ✓ Supabase session restored');
        // Load user profile from storage
        final userProfile = GetPrefs.getMap(GetPrefs.userProfile);
        if (userProfile.isNotEmpty) {
          try {
            currentUser.value = UserModel.fromJson(userProfile);
            print('  ✓ User profile loaded from storage');
          } catch (e) {
            print('  ⚠ Error parsing stored user profile: $e');
            // If stored profile is invalid, fetch from database
            await loadCurrentUser();
          }
        } else {
          print('  ⚠ No stored profile, fetching from database');
          // No stored profile, fetch from database
          await loadCurrentUser();
        }
        isAuthenticated.value = true;
        return true;
      }

      print('  ⚠ No Supabase session, checking stored tokens');
      // No Supabase session, check stored tokens
      final accessToken = GetPrefs.getString(GetPrefs.accessToken);
      final expiresAt = GetPrefs.getInt(GetPrefs.expiresAt);

      if (accessToken.isEmpty || expiresAt == 0) {
        print('  ❌ No stored tokens found');
        return false;
      }

      // Check if token is expired
      final expiresAtDateTime = DateTime.fromMillisecondsSinceEpoch(
        expiresAt * 1000,
      );
      final now = DateTime.now();

      if (now.isAfter(expiresAtDateTime)) {
        print('  ⚠ Token expired, attempting to refresh');
        // Token expired, try to refresh
        final refreshToken = GetPrefs.getString(GetPrefs.refreshToken);
        if (refreshToken.isNotEmpty) {
          try {
            final refreshed = await _authService.refreshSession();
            if (refreshed) {
              print('  ✓ Session refreshed successfully');
              // Update stored tokens after refresh
              final currentSession = SupabaseService.client.auth.currentSession;
              if (currentSession != null) {
                // Get user profile from storage to preserve it
                final userProfile = GetPrefs.getMap(GetPrefs.userProfile);
                await _saveSession({
                  'access_token': currentSession.accessToken,
                  'refresh_token': currentSession.refreshToken,
                  'expires_at': currentSession.expiresAt,
                  'user': userProfile.isNotEmpty ? userProfile : null,
                });
                // Reload user profile
                if (userProfile.isNotEmpty) {
                  try {
                    currentUser.value = UserModel.fromJson(userProfile);
                  } catch (e) {
                    print('Error parsing user profile after refresh: $e');
                  }
                }
              }
              isAuthenticated.value = true;
              return true;
            }
          } catch (e) {
            print('  ❌ Error refreshing session: $e');
          }
        }
        print('  ❌ Refresh failed, clearing session');
        // Refresh failed, clear session
        await clearSession();
        return false;
      }

      print('  ✓ Token is still valid');
      // Token is still valid
      return true;
    } catch (e) {
      print('❌ Error in checkSessionStatus: $e');
      return false;
    }
  }

  /// Clear session data
  Future<void> clearSession() async {
    GetPrefs.remove(GetPrefs.accessToken);
    GetPrefs.remove(GetPrefs.refreshToken);
    GetPrefs.remove(GetPrefs.expiresAt);
    GetPrefs.remove(GetPrefs.userProfile);
    GetPrefs.setBool(GetPrefs.isLoggedIn, false);
    currentUser.value = null;
    isAuthenticated.value = false;
    await _authService.signOut();
  }

  /// Get user details by phone number (returns status, role, etc.)
  /// Returns Map with user details or null if user not found
  Future<Map<String, dynamic>?> getUserDetailsByPhone(
    String phoneNumber,
  ) async {
    setLoading(true);
    clearError();

    final result = await _authService.getUserDetailsByPhone(phoneNumber);

    setLoading(false);

    if (result.isSuccess) {
      return result.dataOrNull;
    } else {
      final error = result.errorOrNull ?? 'Failed to get user details';
      print('Error in getUserDetailsByPhone: $error');
      handleError(error);
      return null;
    }
  }

  Future<UserModel?> getUserDetailsByUserId(String userId) async {
    final response = await SupabaseService.client
        .from('users')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response != null) {
      return UserModel.fromJson(response);
    } else {
      return null;
    }
  }

  /// Create a new admin user in the database
  /// Returns Result with success or error message
  Future<Result<UserModel>> createAdminUser(String phoneNumber) async {
    setLoading(true);
    clearError();

    final result = await _authService.createAdminUser(phoneNumber: phoneNumber);

    setLoading(false);

    if (result.isSuccess) {
      print(
        'Admin user created successfully: ${result.dataOrNull?.phoneNumber}',
      );
      return result;
    } else {
      final error = result.errorOrNull ?? 'Failed to create admin user';
      print('Error in createAdminUser: $error');
      handleError(error);
      return result;
    }
  }

  /// Save user profile data
  /// Updates the user profile in the database by matching phone number
  /// Returns true if successful, false otherwise
  Future<bool> saveProfile({
    required String phoneNumber,
    required Map<String, dynamic> profileData,
  }) async {
    setLoading(true);
    clearError();

    final result = await _authService.saveProfile(
      phoneNumber: phoneNumber,
      profileData: profileData,
    );

    setLoading(false);

    if (result.isSuccess) {
      // Update current user if it matches
      if (currentUser.value?.phoneNumber == phoneNumber ||
          currentUser.value?.phoneNumber.replaceAll(RegExp(r'\D'), '') ==
              phoneNumber.replaceAll(RegExp(r'\D'), '')) {
        currentUser.value = result.dataOrNull;
        if (result.dataOrNull != null) {
          GetPrefs.setMap(GetPrefs.userProfile, result.dataOrNull!.toJson());
        }
      }
      return true;
    } else {
      final error = result.errorOrNull ?? 'Failed to save profile';
      print('Error in saveProfile: $error');
      handleError(error);
      return false;
    }
  }

  /// Enroll user by creating Supabase Auth account and signing them in
  /// This is called after profile completion during signup
  /// Creates the Supabase Auth user, confirms email, signs them in, and saves session
  Future<Result<UserModel>> enrollUser({required String phoneNumber}) async {
    setLoading(true);
    clearError();

    final result = await _authService.enrollUser(phoneNumber: phoneNumber);

    setLoading(false);

    if (result.isSuccess) {
      currentUser.value = result.dataOrNull;
      isAuthenticated.value = true;

      // Save profile and session
      if (result.dataOrNull != null) {
        GetPrefs.setMap(GetPrefs.userProfile, result.dataOrNull!.toJson());
        GetPrefs.setBool(GetPrefs.isLoggedIn, true);

        // Get current session from Supabase
        final currentSession = SupabaseService.client.auth.currentSession;
        if (currentSession != null) {
          await _saveSession({
            'access_token': currentSession.accessToken,
            'refresh_token': currentSession.refreshToken,
            'expires_at': currentSession.expiresAt,
            'user': result.dataOrNull!.toJson(),
          });
        }
      }

      print('User enrolled successfully: ${result.dataOrNull?.phoneNumber}');
      return result;
    } else {
      final error = result.errorOrNull ?? 'Failed to enroll user';
      print('Error in enrollUser: $error');
      handleError(error);
      return result;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    print('🚪 Signing out...');
    setLoading(true);

    // Deactivate FCM tokens for the user before clearing session
    if (currentUser.value != null) {
      try {
        await _authService.deactivateUserPushTokens(
          userId: currentUser.value!.id,
        );
        print('✓ FCM tokens deactivated for user');
      } catch (e) {
        print('⚠ Error deactivating FCM tokens: $e');
        // Continue with logout even if token deactivation fails
      }
    }

    // Clear session and profile
    await clearSession();

    // Also call service sign out
    final result = await _authService.signOut();

    if (result.isSuccess) {
      print('✅ Sign out successful');
      currentUser.value = null;
      isAuthenticated.value = false;
    } else {
      final error = result.errorOrNull ?? 'Sign out failed';
      print('⚠ Error in signOut: $error');
      // Still clear local state even if service call fails
      currentUser.value = null;
      isAuthenticated.value = false;
    }

    setLoading(false);

    // Navigate to login screen
    Get.offAllNamed(Routes.LOGIN);
    print('👋 Redirected to login screen');
  }

  Future<bool> editProfile({
    String? name,
    String? lastName,
    Uint8List? fileBytes,
  }) async {
    if (currentUser.value == null) {
      handleError('User not logged in');
      return false;
    }

    setLoading(true);
    clearError();

    final phoneNumber = currentUser.value!.phoneNumber;
    final userId = currentUser.value!.id;

    try {
      final Map<String, dynamic> updateData = {};

      // Combine first and last name into full_name
      if (name != null || lastName != null) {
        final fullName =
            '${name ?? currentUser.value?.fullName?.split(' ').first ?? ''} '
                    '${lastName ?? currentUser.value?.fullName?.split(' ').last ?? ''}'
                .trim();
        updateData['full_name'] = fullName;
      }

      if (fileBytes != null) {
        final mediaUrl = await StorageService.uploadMediaBytes(
          bytes: fileBytes,
          userId: currentUser.value?.id ?? '',
          bucketName: 'profile_pictures',
          mediaType: MediaType.image,
          customFileName: currentUser.value?.id ?? '',
        );
        updateData['profile_picture_url'] = mediaUrl;
      }

      if (updateData.isEmpty) {
        setLoading(false);
        handleError('No data to update');
        return false;
      }

      final response = await SupabaseService.client
          .from('users')
          .update(updateData)
          .eq('id', userId)
          .select()
          .single();

      currentUser.value = UserModel.fromJson(response);

      GetPrefs.setMap(GetPrefs.userProfile, currentUser.value!.toJson());

      setLoading(false);
      CommonSnackbar.success('Profile updated successfully');
      return true;
    } catch (e) {
      setLoading(false);
      handleError('Error updating profile: $e');
      return false;
    }
  }
}
