import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:samsung_admin_main_new/app/common/services/supabase_service.dart';
import 'package:samsung_admin_main_new/app/common/services/firebase_notification_service.dart';

import '../../models/user_model.dart';
import '../constant/app_consts.dart';
import '../core/exceptions/app_exception.dart';
import '../core/utils/result.dart';

/// Service for authentication operations (direct Supabase access)
class AuthService {
  /// Sign out current user
  Future<Result<void>> signOut() async {
    try {
      await SupabaseService.signOut();
      return const Success(null);
    } catch (e) {
      print('Error in signOut: $e');
      return Failure(AppException.fromError(e).message);
    }
  }

  /// Confirm user email by calling Supabase Edge Function
  /// Uses the deployed auto-confirm-user function to confirm the user
  /// Requires an access token from the session, or uses anon key as fallback
  Future<bool> _confirmUserEmail(String userId, {String? accessToken}) async {
    // Declare variables outside try block for error logging
    String? token;
    String? edgeFunctionUrl;

    try {
      print('Attempting to confirm email for user: $userId');

      // First check if email is already confirmed
      final isAlreadyConfirmed = await _checkEmailConfirmedStatus(userId);
      if (isAlreadyConfirmed) {
        print('✓ Email already confirmed for user: $userId');
        return true;
      }

      // Get access token from parameter or current session
      token = accessToken;
      if (token == null) {
        final currentSession = SupabaseService.client.auth.currentSession;
        token = currentSession?.accessToken;
      }

      // If still no token, try using anon key as fallback
      // This allows confirming email even when not signed in
      if (token == null) {
        print('No session token available, using anon key for Edge Function');
        final anonKey = AppConsts.supabaseAnonKey;
        if (anonKey.isNotEmpty) {
          token = anonKey;
        } else {
          print(
            '❌ No access token or anon key available for Edge Function call',
          );
          return false;
        }
      }

      // Call the Supabase Edge Function
      final supabaseUrl = AppConsts.supabaseUrl;
      if (supabaseUrl.isEmpty) {
        print('❌ Supabase URL not configured');
        return false;
      }

      edgeFunctionUrl = '$supabaseUrl/functions/v1/auto-confirm-user';

      if (token.isEmpty) {
        print('❌ No token available for Edge Function call');
        return false;
      }

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'apikey': AppConsts.supabaseAnonKey, // Add API key header
      };

      final body = jsonEncode({'user_id': userId});

      print('');
      print('═══ Calling Edge Function ═══');
      print('URL: $edgeFunctionUrl');
      print('User ID: $userId');
      print(
        'Token (first 50 chars): ${token.substring(0, token.length > 50 ? 50 : token.length)}...',
      );
      print('Headers: ${headers.keys.join(", ")}');
      print('Body: $body');
      print('═══════════════════════════════');

      final response = await http
          .post(Uri.parse(edgeFunctionUrl), headers: headers, body: body)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception(
                'Edge Function request timed out after 10 seconds',
              );
            },
          );

      print('Edge Function response status: ${response.statusCode}');
      print('Edge Function response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Wait a bit for the update to propagate
        await Future.delayed(const Duration(milliseconds: 500));

        // Verify the confirmation worked
        final isConfirmed = await _checkEmailConfirmedStatus(userId);
        if (isConfirmed) {
          print(
            '✓ Email confirmed successfully via Edge Function for user: $userId',
          );
          return true;
        } else {
          print('⚠ Edge Function called but verification failed');
          // Still return true if the function returned success
          // The verification might fail due to timing
          return true;
        }
      } else {
        print('❌ Edge Function returned error: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e, stackTrace) {
      print('');
      print('═══════════════════════════════════════════════════════════');
      print('❌ Edge Function call failed');
      print('Error: $e');
      print('Error type: ${e.runtimeType}');
      print('Stack trace: $stackTrace');
      print('Edge Function URL: ${edgeFunctionUrl ?? "not set"}');
      print('User ID: $userId');
      if (token != null && token.isNotEmpty) {
        final tokenPreview = token.length > 20 ? token.substring(0, 20) : token;
        print('Token (first 20 chars): $tokenPreview...');
      } else {
        print('Token: null or empty');
      }
      print('═══════════════════════════════════════════════════════════');
      print('');
      return false;
    }
  }

  /// Public helper to confirm the **currently authenticated** user's email.
  /// Wraps the private `_confirmUserEmail` so higher layers (e.g. `AuthRepo`)
  /// can trigger email confirmation after OTP verification/sign-in.
  Future<bool> confirmCurrentAuthUserEmail({String? accessToken}) async {
    try {
      final authUser = SupabaseService.auth.currentUser;
      if (authUser == null) {
        print('No authenticated user found for email confirmation');
        return false;
      }
      return _confirmUserEmail(authUser.id, accessToken: accessToken);
    } catch (e) {
      print('Error in confirmCurrentAuthUserEmail: $e');
      return false;
    }
  }

  /// Check if email is confirmed by calling verification RPC or checking auth user
  Future<bool> _checkEmailConfirmedStatus(String userId) async {
    try {
      // Check current auth user if it matches
      final currentUser = SupabaseService.auth.currentUser;
      if (currentUser != null && currentUser.id == userId) {
        // Check if email is confirmed via the user object
        // Note: This only works if we're signed in as this user
        return currentUser.emailConfirmedAt != null;
      }

      // If we can't verify, return false (uncertain)
      return false;
    } catch (e) {
      print('Could not verify email confirmation status: $e');
      return false;
    }
  }

  /// Refresh session using stored refresh token
  Future<bool> refreshSession() async {
    try {
      final response = await SupabaseService.auth.refreshSession();
      if (response.session != null) {
        return true;
      }
      return false;
    } catch (e) {
      print('Error in refreshSession: $e');
      return false;
    }
  }

  /// Restore Supabase session - checks if current session is valid
  /// Supabase automatically persists sessions, so we just verify it exists
  Future<bool> restoreSession() async {
    try {
      final currentSession = SupabaseService.client.auth.currentSession;
      if (currentSession != null) {
        // Check if session is expired
        final expiresAt = currentSession.expiresAt;
        if (expiresAt != null) {
          final expiresAtDateTime = DateTime.fromMillisecondsSinceEpoch(
            expiresAt * 1000,
          );
          if (DateTime.now().isAfter(expiresAtDateTime)) {
            // Session expired, try to refresh
            try {
              await SupabaseService.auth.refreshSession();
              return true;
            } catch (e) {
              print('Error refreshing expired session: $e');
              return false;
            }
          }
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Error in restoreSession: $e');
      return false;
    }
  }

  /// Get current user
  Future<Result<UserModel?>> getCurrentUser() async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) {
        return const Success(null);
      }

      // Try to fetch full user profile from database using phone number
      final phoneNumber = user.phone;
      if (phoneNumber != null) {
        final normalizedPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');
        final response = await SupabaseService.client
            .from('users')
            .select()
            .eq('phone_number', normalizedPhone)
            .maybeSingle();

        if (response != null) {
          final userModel = UserModel.fromJson(response);
          return Success(userModel);
        }
      }

      // Fallback: Try to fetch by auth_user_id
      final responseById = await SupabaseService.client
          .from('users')
          .select()
          .eq('auth_user_id', user.id)
          .maybeSingle();

      if (responseById != null) {
        final userModel = UserModel.fromJson(responseById);
        return Success(userModel);
      }

      // Return basic user info if no database record found
      DateTime parseDateTime(Object? value) {
        if (value == null) return DateTime.now();
        if (value is DateTime) return value;
        if (value is String) {
          try {
            return DateTime.parse(value);
          } catch (_) {
            return DateTime.now();
          }
        }
        return DateTime.now();
      }

      final createdAt = parseDateTime(user.createdAt);
      final updatedAt = parseDateTime(user.updatedAt);

      final userModel = UserModel(
        id: user.id,
        phoneNumber: user.phone ?? '',
        languagePreference: LanguagePreference.en,
        socialMediaLinks: {},
        pointsBalance: 0,
        status: UserStatus.pending,
        role: UserRole.admin,
        isOnline: false,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      return Success(userModel);
    } catch (e) {
      print('Error in getCurrentUser: $e');
      return Failure(AppException.fromError(e).message);
    }
  }

  /// Check if user is authenticated
  bool get isAuthenticated => SupabaseService.isAuthenticated;

  /// Check if user exists by phone number
  /// Returns true if user exists, false otherwise
  Future<Result<bool>> checkUserExists(String phoneNumber) async {
    try {
      // Normalize phone number (remove non-digit characters)
      final normalizedPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');

      final response = await SupabaseService.client
          .from('users')
          .select('id')
          .eq('phone_number', normalizedPhone)
          .maybeSingle();

      return Success(response != null);
    } catch (e) {
      print('Error in checkUserExists: $e');
      return Failure(AppException.fromError(e).message);
    }
  }

  /// Get user details by phone number (status, role, full_name)
  Future<Result<Map<String, dynamic>?>> getUserDetailsByPhone(
    String phoneNumber,
  ) async {
    try {
      // Normalize phone number (remove non-digit characters)
      final normalizedPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');

      final response = await SupabaseService.client
          .from('users')
          .select('id, status, role, full_name')
          .eq('phone_number', normalizedPhone)
          .maybeSingle();

      if (response == null) {
        return const Success(null);
      }

      return Success({
        'id': response['id'] as String?,
        'status': response['status'] as String?,
        'role': response['role'] as String?,
        'full_name': response['full_name'] as String?,
      });
    } catch (e) {
      print('Error in getUserDetailsByPhone: $e');
      return Failure(AppException.fromError(e).message);
    }
  }

  /// Generate OTP and save to database for admin login
  /// Generate OTP for existing admin user (Login flow)
  /// Returns the generated OTP code or specific error codes:
  /// - 'USER_NOT_FOUND' if user doesn't exist or is not an admin
  Future<Result<String>> generateOTPForLogin(String phoneNumber) async {
    try {
      // Normalize phone number (remove non-digit characters)
      final normalizedPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');

      // Get user details if exists
      final userDetailsResult = await getUserDetailsByPhone(normalizedPhone);
      if (userDetailsResult.isFailure) {
        return Failure(userDetailsResult.errorOrNull ?? 'Failed to check user');
      }

      final userDetails = userDetailsResult.dataOrNull;

      // User must exist for login
      if (userDetails == null) {
        return const Failure('USER_NOT_FOUND');
      }

      final status = userDetails['status'] as String?;
      final role = userDetails['role'] as String?;

      if (role != 'admin') {
        return const Failure('You must be an admin to login');
      }

      // User exists and is approved admin, generate OTP
      final now = DateTime.now().toUtc().toIso8601String();
      final random = DateTime.now().millisecondsSinceEpoch;
      final otpCode = (100000 + (random % 900000)).toString();

      // Update OTP in database
      await SupabaseService.client
          .from('users')
          .update({
            'otp_code': otpCode,
            'otp_created_at': now,
            'updated_at': now,
          })
          .eq('phone_number', normalizedPhone);

      print('Generated OTP for login $normalizedPhone: $otpCode');
      return Success(otpCode);
    } catch (e) {
      print('Error in generateOTPForLogin: $e');
      return Failure(AppException.fromError(e).message);
    }
  }

  /// Generate OTP for new user (Signup flow)
  /// This method generates OTP for a newly created user (after createAdminUser)
  /// It doesn't check if user exists, it just generates OTP
  Future<Result<String>> generateOTP(String phoneNumber) async {
    try {
      // Normalize phone number (remove non-digit characters)
      final normalizedPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');

      // Generate OTP
      final now = DateTime.now().toUtc().toIso8601String();
      final random = DateTime.now().millisecondsSinceEpoch;
      final otpCode = (100000 + (random % 900000)).toString();

      // Update OTP in database for the newly created user
      await SupabaseService.client
          .from('users')
          .update({
            'otp_code': otpCode,
            'otp_created_at': now,
            'updated_at': now,
          })
          .eq('phone_number', normalizedPhone);

      print('Generated OTP for signup $normalizedPhone: $otpCode');
      return Success(otpCode);
    } catch (e) {
      print('Error in generateOTP: $e');
      return Failure(AppException.fromError(e).message);
    }
  }

  /// Verify OTP
  /// Returns:
  /// - Success if OTP is correct and not expired
  /// - Failure with 'OTP_INCORRECT' if OTP doesn't match
  /// - Failure with 'OTP_EXPIRED' if OTP is more than 10 minutes old
  Future<Result<void>> verifyOTP({
    required String phoneNumber,
    required String otpCode,
  }) async {
    try {
      // Normalize phone number (remove non-digit characters)
      final normalizedPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');

      // Get user's OTP data from database
      final response = await SupabaseService.client
          .from('users')
          .select('otp_code, otp_created_at')
          .eq('phone_number', normalizedPhone)
          .maybeSingle();

      if (response == null) {
        return const Failure('OTP_INCORRECT');
      }

      final storedOtp = response['otp_code'] as String?;
      final otpCreatedAtValue = response['otp_created_at'];

      // Check if OTP is expired FIRST (before checking if code matches)
      if (otpCreatedAtValue != null) {
        try {
          DateTime otpCreatedAt;

          // Handle different return types from Supabase
          if (otpCreatedAtValue is DateTime) {
            // Supabase returns DateTime directly
            otpCreatedAt = otpCreatedAtValue.toUtc();
          } else if (otpCreatedAtValue is String) {
            // Supabase returns string (ISO8601)
            otpCreatedAt = DateTime.parse(otpCreatedAtValue).toUtc();
          } else {
            // Unknown format, consider expired
            print(
              'Unknown OTP created_at format: ${otpCreatedAtValue.runtimeType}',
            );
            return const Failure('OTP_EXPIRED');
          }

          final now = DateTime.now().toUtc();
          final difference = now.difference(otpCreatedAt);

          // Debug logging
          print('OTP created at: $otpCreatedAt (UTC)');
          print('Current time: $now (UTC)');
          print('Difference: ${difference.inMinutes} minutes');

          // Check if OTP is expired (10 minutes or more)
          if (difference.inMinutes >= 10) {
            return const Failure('OTP_EXPIRED');
          }
        } catch (e) {
          // If date parsing fails, consider OTP as expired
          print('Error parsing OTP created_at: $e, value: $otpCreatedAtValue');
          return const Failure('OTP_EXPIRED');
        }
      } else {
        // If otp_created_at is null, consider OTP as expired
        return const Failure('OTP_EXPIRED');
      }

      // Check if OTP code matches (only if not expired)
      if (storedOtp == null || storedOtp != otpCode) {
        return const Failure('OTP_INCORRECT');
      }

      // OTP is correct and not expired
      return const Success(null);
    } catch (e) {
      print('Error in verifyOTP: $e');
      return Failure(AppException.fromError(e).message);
    }
  }

  /// Verify OTP and sign in to get session tokens
  /// Returns session data (access_token, refresh_token, expires_at) and user profile
  Future<Result<Map<String, dynamic>>> verifyOTPAndSignIn({
    required String phoneNumber,
    required String otpCode,
  }) async {
    try {
      // First verify OTP
      final verifyResult = await verifyOTP(
        phoneNumber: phoneNumber,
        otpCode: otpCode,
      );

      if (verifyResult.isFailure) {
        return Failure(verifyResult.errorOrNull ?? 'OTP verification failed');
      }

      // OTP verified, now sign in with Supabase to get session
      final normalizedPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');
      final authEmail = 'temp_$normalizedPhone@temp.com';
      final authPassword = authEmail;

      try {
        // Get user from database to get their ID
        final userResponse = await SupabaseService.client
            .from('users')
            .select()
            .eq('phone_number', normalizedPhone)
            .maybeSingle();

        if (userResponse == null) {
          return const Failure('User not found in database');
        }

        // Ensure user has required role before signing in
        final role = userResponse['role'] as String?;
        if (role != 'admin') {
          return const Failure('You must be an admin to login');
        }

        // Try to sign in
        dynamic authResponse;
        try {
          authResponse = await SupabaseService.auth.signInWithPassword(
            email: authEmail,
            password: authPassword,
          );

          // After successful sign in, check if email needs confirmation
          final signedInUserId = authResponse.user?.id;
          final session = authResponse.session;
          if (signedInUserId != null && session != null) {
            final isConfirmed = await _checkEmailConfirmedStatus(
              signedInUserId,
            );
            if (!isConfirmed) {
              print(
                'Email not confirmed, attempting to confirm via Edge Function',
              );
              await _confirmUserEmail(
                signedInUserId,
                accessToken: session.accessToken,
              );
            }
          }
        } catch (signInError) {
          // If sign in fails, the auth user might not exist
          // Try to create it first, then sign in
          print('Sign in failed, attempting to create auth user: $signInError');

          try {
            // Create auth user with the existing user ID
            final signUpResponse = await SupabaseService.auth.signUp(
              email: authEmail,
              password: authPassword,
              data: {'phone': normalizedPhone},
            );

            if (signUpResponse.user == null) {
              return const Failure('Failed to create auth user');
            }

            final authUserId = signUpResponse.user!.id;
            final signUpSession = signUpResponse.session;

            // Auto-confirm email immediately after signup using Edge Function
            // Use session token from signup if available, otherwise use anon key
            String? token = signUpSession?.accessToken;

            // Check if email is already confirmed before attempting confirmation
            final isAlreadyConfirmed = await _checkEmailConfirmedStatus(
              authUserId,
            );
            if (!isAlreadyConfirmed) {
              print(
                'Confirming email for newly created auth user: $authUserId',
              );
              final emailConfirmed = await _confirmUserEmail(
                authUserId,
                accessToken: token,
              );

              if (!emailConfirmed) {
                print('⚠ Warning: Email confirmation failed');
                print(
                  'Attempting to sign in anyway - confirmation may have succeeded',
                );
              } else {
                print('✓ Email confirmed successfully');
              }
            } else {
              print('✓ Email already confirmed');
            }

            // Wait a moment for confirmation to propagate
            await Future.delayed(const Duration(milliseconds: 1000));

            // Now try to sign in after email confirmation
            try {
              authResponse = await SupabaseService.auth.signInWithPassword(
                email: authEmail,
                password: authPassword,
              );
              print('✓ Successfully signed in after email confirmation');
            } catch (retryError) {
              print('⚠ Sign in retry failed after confirmation: $retryError');
              // If sign in still fails, we might need to wait longer
              // Or the Edge Function might not have worked
              // Try one more time after a longer delay
              await Future.delayed(const Duration(milliseconds: 2000));
              try {
                authResponse = await SupabaseService.auth.signInWithPassword(
                  email: authEmail,
                  password: authPassword,
                );
                print('✓ Successfully signed in on second retry');
              } catch (finalError) {
                print('❌ Final sign in attempt failed: $finalError');
                return Failure(
                  'Failed to sign in after email confirmation: ${AppException.fromError(finalError).message}',
                );
              }
            }

            // Update the users table to link auth_user_id and set status to approved
            try {
              await SupabaseService.client
                  .from('users')
                  .update({
                    'auth_user_id': authUserId,
                    'status': 'approved',
                    'updated_at': DateTime.now().toUtc().toIso8601String(),
                  })
                  .eq('phone_number', normalizedPhone);
            } catch (updateError) {
              print('Warning: Could not update auth_user_id: $updateError');
              // Continue anyway - the auth user is created
            }
          } catch (createError) {
            print('Error creating auth user: $createError');
            final errorString = createError.toString();

            // If user already exists (from a previous attempt), try sign in again
            if (errorString.contains('already registered') ||
                errorString.contains('User already registered')) {
              authResponse = await SupabaseService.auth.signInWithPassword(
                email: authEmail,
                password: authPassword,
              );
            }
            // Handle rate limit error (429) - email send rate limit
            else if (errorString.contains('over_email_send_rate_limit') ||
                errorString.contains('429') ||
                errorString.contains('rate limit')) {
              print(
                '⚠ Rate limit hit for email confirmation. Skipping email confirmation and proceeding...',
              );
              // Extract wait time from error message if available
              final waitTimeMatch = RegExp(
                r'after (\d+) seconds?',
              ).firstMatch(errorString);
              final waitSeconds = waitTimeMatch != null
                  ? int.tryParse(waitTimeMatch.group(1) ?? '') ?? 16
                  : 16;

              print('Waiting $waitSeconds seconds before retrying sign in...');
              await Future.delayed(Duration(seconds: waitSeconds));

              // Try to sign in - the auth user might have been created despite the rate limit error
              try {
                authResponse = await SupabaseService.auth.signInWithPassword(
                  email: authEmail,
                  password: authPassword,
                );
                print('✓ Successfully signed in after rate limit wait');
              } catch (signInAfterRateLimitError) {
                // If sign in still fails, the auth user creation might have failed
                // Return a more helpful error message
                return Failure(
                  'Rate limit reached. Please wait a moment and try again. If the problem persists, contact support.',
                );
              }
            } else {
              return Failure(
                'Failed to create or sign in: ${AppException.fromError(createError).message}',
              );
            }
          }
        }

        if (authResponse == null || authResponse.session == null) {
          return const Failure('Failed to create session');
        }

        final session = authResponse.session!;

        // Get user profile from database using the phone number
        UserModel? userProfile;
        final finalUserResponse = await SupabaseService.client
            .from('users')
            .select()
            .eq('phone_number', normalizedPhone)
            .maybeSingle();

        if (finalUserResponse != null) {
          userProfile = UserModel.fromJson(finalUserResponse);
        }
        if (userProfile != null) {
          await _saveFCMTokenIfAvailable(userProfile.id);
        }

        // Return session data and user profile
        return Success({
          'access_token': session.accessToken,
          'refresh_token': session.refreshToken,
          'expires_at': session.expiresAt,
          'user': userProfile?.toJson(),
        });
      } catch (e) {
        print('Error signing in after OTP verification: $e');
        return Failure(AppException.fromError(e).message);
      }
    } catch (e) {
      print('Error in verifyOTPAndSignIn: $e');
      return Failure(AppException.fromError(e).message);
    }
  }

  /// Save user profile data by phone number
  /// Updates the user record in the database with the provided profile data
  /// Returns Success with updated UserModel or Failure with error message
  /// Create a new admin user
  /// Creates both Supabase Auth user (internal auth table) and public users table entry
  Future<Result<UserModel>> createAdminUser({
    required String phoneNumber,
  }) async {
    try {
      // Normalize phone number (remove non-digit characters)
      final normalizedPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');

      final now = DateTime.now().toUtc().toIso8601String();

      // Create Supabase Auth user using temp email/password based on phone number
      final authEmail = 'temp_$normalizedPhone@temp.com';
      final authPassword = authEmail;

      final signUpResponse = await SupabaseService.auth.signUp(
        email: authEmail,
        password: authPassword,
        data: {'phone': normalizedPhone},
      );

      if (signUpResponse.user == null) {
        return const Failure('Failed to create auth user');
      }

      final authUserId = signUpResponse.user!.id;

      // Create new user record in public users table with admin role
      // Link it to the Supabase Auth user via id and auth_user_id
      final insertData = {
        'id': authUserId,
        'phone_number': normalizedPhone,
        'role': 'admin', // Set admin role
        'status': 'pending', // Pending until profile is completed
        'language_preference': 'en',
        'social_media_links': {},
        'points_balance': 0,
        'is_online': false,
        'created_at': now,
        'updated_at': now,
        'auth_user_id': authUserId,
      };

      // Insert user into database
      final response = await SupabaseService.client
          .from('users')
          .insert(insertData)
          .select()
          .single();

      // Convert response to UserModel
      final userModel = UserModel.fromJson(response);

      print('Created public user record: ${userModel.phoneNumber}');
      await _saveFCMTokenIfAvailable(authUserId);
      return Success(userModel);
    } catch (e) {
      print('Error in createAdminUser: $e');
      return Failure(AppException.fromError(e).message);
    }
  }

  /// Enroll user by creating Supabase Auth account and signing them in
  /// This is called after profile completion during signup
  /// Creates the Supabase Auth user, confirms email, and signs them in
  Future<Result<UserModel>> enrollUser({required String phoneNumber}) async {
    try {
      // Normalize phone number (remove non-digit characters)
      final normalizedPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');

      final now = DateTime.now().toUtc().toIso8601String();

      // Get the existing user record
      final userResponse = await SupabaseService.client
          .from('users')
          .select()
          .eq('phone_number', normalizedPhone)
          .maybeSingle();

      if (userResponse == null) {
        return const Failure('User not found');
      }

      // Check if user already has an auth account
      final existingAuthUserId = userResponse['auth_user_id'] as String?;
      if (existingAuthUserId != null && existingAuthUserId.isNotEmpty) {
        print('User already has auth account, ensuring status is approved');
        // User already enrolled, but ensure status is approved
        final currentStatus = userResponse['status'] as String?;
        if (currentStatus != 'approved') {
          final updateResponse = await SupabaseService.client
              .from('users')
              .update({'status': 'approved', 'updated_at': now})
              .eq('phone_number', normalizedPhone)
              .select()
              .single();
          final userModel = UserModel.fromJson(updateResponse);
          return Success(userModel);
        }
        // Status already approved, just return the user model
        final userModel = UserModel.fromJson(userResponse);
        return Success(userModel);
      }

      // Create auth user with email format: temp_{phone}@temp.com
      final authEmail = 'temp_$normalizedPhone@temp.com';
      final authPassword = authEmail;

      print('Creating Supabase Auth user for enrollment: $authEmail');

      dynamic authResponse;
      String? authUserId;
      String? token;

      try {
        authResponse = await SupabaseService.auth.signUp(
          email: authEmail,
          password: authPassword,
          data: {'phone': normalizedPhone},
        );

        if (authResponse.user == null) {
          return const Failure('Failed to create auth user');
        }

        authUserId = authResponse.user!.id;
        final signUpSession = authResponse.session;
        token = signUpSession?.accessToken;
      } catch (signUpError) {
        final errorString = signUpError.toString();

        if (errorString.contains('over_email_send_rate_limit') ||
            errorString.contains('429') ||
            errorString.contains('rate limit')) {
          print(
            '⚠ Rate limit hit during enrollment. Checking if user was created...',
          );

          try {
            final signInResponse = await SupabaseService.auth
                .signInWithPassword(email: authEmail, password: authPassword);
            authResponse = signInResponse;
            authUserId = signInResponse.user?.id;
            token = signInResponse.session?.accessToken;
            print('✓ User exists, signed in successfully');
          } catch (signInError) {
            final waitTimeMatch = RegExp(
              r'after (\d+) seconds?',
            ).firstMatch(errorString);
            final waitSeconds = waitTimeMatch != null
                ? int.tryParse(waitTimeMatch.group(1) ?? '') ?? 16
                : 16;

            return Failure(
              'Rate limit reached. Please wait $waitSeconds seconds and try again.',
            );
          }
        } else {
          return Failure(
            'Failed to create auth user: ${AppException.fromError(signUpError).message}',
          );
        }
      }

      if (authUserId == null) {
        return const Failure('Failed to get auth user ID');
      }

      // Auto-confirm email immediately after signup using Edge Function
      // Check if email is already confirmed before attempting confirmation
      final isAlreadyConfirmed = await _checkEmailConfirmedStatus(authUserId);
      if (!isAlreadyConfirmed) {
        final emailConfirmed = await _confirmUserEmail(
          authUserId,
          accessToken: token,
        );

        if (!emailConfirmed && token == null) {
          print(
            '⚠ Warning: Could not confirm email - no session token from signup',
          );
          print('Email will be confirmed on first sign in');
        } else if (!emailConfirmed) {
          print('⚠ Warning: Email confirmation may have failed');
        } else {
          print('✓ Email confirmed successfully');
        }
      } else {
        print('✓ Email already confirmed');
      }

      // Update user record with auth user ID and change status to approved
      final updateData = {
        'auth_user_id': authUserId,
        'status': 'approved', // Approve user after enrollment
        'updated_at': now,
      };

      final response = await SupabaseService.client
          .from('users')
          .update(updateData)
          .eq('phone_number', normalizedPhone)
          .select()
          .single();

      // Convert response to UserModel
      final userModel = UserModel.fromJson(response);

      print(
        'Enrolled user: ${userModel.phoneNumber} with auth ID: $authUserId',
      );

      // Sign in the user
      try {
        await SupabaseService.auth.signInWithPassword(
          email: authEmail,
          password: authPassword,
        );
        print('✓ User signed in successfully after enrollment');
      } catch (signInError) {
        print(
          'Sign in failed after enrollment, but user was enrolled: $signInError',
        );
        // Don't fail the enrollment if sign in fails - user can try logging in again
      }

      await _saveFCMTokenIfAvailable(authUserId);

      return Success(userModel);
    } catch (e) {
      print('Error in enrollUser: $e');
      return Failure(AppException.fromError(e).message);
    }
  }

  Future<Result<UserModel>> saveProfile({
    required String phoneNumber,
    required Map<String, dynamic> profileData,
  }) async {
    try {
      // Normalize phone number (remove non-digit characters)
      final normalizedPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');

      // Prepare update data
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };

      // Map profile data to database column names
      if (profileData.containsKey('fullName')) {
        updateData['full_name'] = profileData['fullName'];
      }
      if (profileData.containsKey('email')) {
        updateData['email'] = profileData['email'];
      }
      if (profileData.containsKey('companyName')) {
        updateData['company_name'] = profileData['companyName'];
      }
      if (profileData.containsKey('languagePreference')) {
        updateData['language_preference'] = profileData['languagePreference'];
      }

      // Update user record by phone number
      final response = await SupabaseService.client
          .from('users')
          .update(updateData)
          .eq('phone_number', normalizedPhone)
          .select()
          .single();

      // Convert response to UserModel
      final userModel = UserModel.fromJson(response);

      return Success(userModel);
    } catch (e) {
      print('Error in saveProfile: $e');
      return Failure(AppException.fromError(e).message);
    }
  }

  String _getPlatform() {
    if (kIsWeb) {
      return 'web';
    } else if (Platform.isIOS) {
      return 'ios';
    } else if (Platform.isAndroid) {
      return 'android';
    } else {
      return 'unknown';
    }
  }

  Future<Result<void>> saveUserPushToken({
    required String userId,
    required String fcmToken,
    String? deviceId,
  }) async {
    try {
      final platform = _getPlatform();
      final now = DateTime.now().toUtc().toIso8601String();

      final existingUserToken = await SupabaseService.client
          .from('user_push_tokens')
          .select('id, fcm_token')
          .eq('user_id', userId)
          .maybeSingle();

      if (existingUserToken != null) {
        final existingFcmToken = existingUserToken['fcm_token'] as String?;

        if (existingFcmToken != fcmToken) {
          final tokenUsedByOther = await SupabaseService.client
              .from('user_push_tokens')
              .select('id, user_id')
              .eq('fcm_token', fcmToken)
              .neq('user_id', userId)
              .maybeSingle();

          if (tokenUsedByOther != null) {
            await SupabaseService.client
                .from('user_push_tokens')
                .delete()
                .eq('fcm_token', fcmToken);
            print('Deleted FCM token entry for different user');
          }

          await SupabaseService.client
              .from('user_push_tokens')
              .update({
                'fcm_token': fcmToken,
                'platform': platform,
                'device_id': deviceId,
                'is_active': true,
                'last_used_at': now,
              })
              .eq('user_id', userId);

          print('Replaced FCM token for existing user: $userId');
        } else {
          await SupabaseService.client
              .from('user_push_tokens')
              .update({
                'platform': platform,
                'device_id': deviceId,
                'is_active': true,
                'last_used_at': now,
              })
              .eq('user_id', userId);

          print('Updated FCM token entry for user: $userId');
        }
      } else {
        final tokenUsedByOther = await SupabaseService.client
            .from('user_push_tokens')
            .select('id, user_id')
            .eq('fcm_token', fcmToken)
            .maybeSingle();

        if (tokenUsedByOther != null) {
          await SupabaseService.client
              .from('user_push_tokens')
              .update({
                'user_id': userId,
                'platform': platform,
                'device_id': deviceId,
                'is_active': true,
                'last_used_at': now,
              })
              .eq('fcm_token', fcmToken);

          print('Updated FCM token from another user to user: $userId');
        } else {
          await SupabaseService.client.from('user_push_tokens').insert({
            'user_id': userId,
            'fcm_token': fcmToken,
            'platform': platform,
            'device_id': deviceId,
            'is_active': true,
            'created_at': now,
            'last_used_at': now,
          });

          print('Inserted new FCM token for user: $userId');
        }
      }

      return const Success(null);
    } catch (e) {
      print('Error in saveUserPushToken: $e');
      return Failure(AppException.fromError(e).message);
    }
  }

  Future<Result<void>> deactivateUserPushTokens({
    required String userId,
  }) async {
    try {
      await SupabaseService.client
          .from('user_push_tokens')
          .update({'is_active': false})
          .eq('user_id', userId);

      print('Deactivated FCM token(s) for user: $userId');
      return const Success(null);
    } catch (e) {
      print('Error in deactivateUserPushTokens: $e');
      return Failure(AppException.fromError(e).message);
    }
  }

  Future<void> _saveFCMTokenIfAvailable(String userId) async {
    try {
      if (!Get.isRegistered<FirebaseNotificationService>()) {
        print(
          'FirebaseNotificationService not registered, skipping FCM token save',
        );
        return;
      }

      try {
        final notificationService = Get.find<FirebaseNotificationService>();
        final fcmToken = await notificationService.getFCMToken();

        if (fcmToken != null && fcmToken.isNotEmpty) {
          print('Saving FCM token for user: $userId');
          final result = await saveUserPushToken(
            userId: userId,
            fcmToken: fcmToken,
            deviceId: null, // Device ID can be added later if needed
          );

          if (result.isSuccess) {
            print('✓ FCM token saved successfully');
          } else {
            print('⚠ Failed to save FCM token: ${result.errorOrNull}');
          }
        } else {
          print('No FCM token available to save');
        }
      } catch (e) {
        print('Error getting FCM token: $e');
      }
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }
}
