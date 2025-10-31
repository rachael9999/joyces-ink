import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import './supabase_service.dart';

class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();

  AuthService._();

  // Get Supabase client with initialization check
  SupabaseClient get _client {
    try {
      if (!SupabaseService.instance.isInitialized) {
        throw Exception('Supabase service is not initialized');
      }
      return SupabaseService.instance.client;
    } catch (e) {
      throw Exception('Failed to access Supabase client: $e');
    }
  }

  // Get current user with enhanced null safety
  User? get currentUser {
    try {
      if (!SupabaseService.instance.isInitialized) {
        return null;
      }
      final client = _client;
      return client.auth.currentUser;
    } catch (e) {
      return null;
    }
  }

  // Check if user is signed in with comprehensive validation
  bool get isSignedIn {
    try {
      if (!SupabaseService.instance.isInitialized) {
        return false;
      }

      final user = currentUser;
      if (user == null) return false;

      // Additional null safety checks
      final userId = user.id;
      final userEmail = user.email;

      return userId.isNotEmpty && userEmail != null && userEmail.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      // Check if email already exists in user_profiles table to give fast feedback.
      // Note: Some setups may not store email in user_profiles; this is a best-effort check.
      try {
        final existing = await _client
            .from('user_profiles')
            .select('id')
            .eq('email', email)
            .maybeSingle();

        if (existing != null && existing is Map && existing['id'] != null) {
          throw Exception('An account with this email already exists.');
        }
      } catch (_) {
        // Non-fatal: if the user_profiles table doesn't exist or query fails,
        // we'll fall back to allowing the signUp call to surface an error.
      }

      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName, 'role': 'free'},
      );

      // Check if user was created successfully
      if (response.user == null) {
        throw Exception('Registration failed. Please try again.');
      }

      return response;
    } on AuthException catch (error) {
      // Handle specific Supabase auth errors
      String errorMessage;
      switch (error.statusCode) {
        case '400':
          if (error.message.contains('User already registered')) {
            errorMessage =
                'An account with this email already exists. Please try logging in instead.';
          } else if (error.message.contains('Password should be')) {
            errorMessage = 'Password must be at least 6 characters long.';
          } else if (error.message.contains('Unable to validate email')) {
            errorMessage = 'Please enter a valid email address.';
          } else {
            errorMessage =
                'Registration failed. Please check your information and try again.';
          }
          break;
        case '422':
          if (error.message.contains('email')) {
            errorMessage = 'Please enter a valid email address.';
          } else if (error.message.contains('password')) {
            errorMessage = 'Password must be at least 6 characters long.';
          } else {
            errorMessage =
                'Invalid registration data. Please check your information.';
          }
          break;
        case '429':
          errorMessage =
              'Too many registration attempts. Please wait a moment and try again.';
          break;
        default:
          errorMessage = 'Registration failed: ${error.message}';
      }
      throw Exception(errorMessage);
    } catch (error) {
      // Handle any other errors
      if (error.toString().contains('NetworkException') ||
          error.toString().contains('SocketException')) {
        throw Exception(
          'Network error. Please check your internet connection and try again.',
        );
      } else if (error.toString().contains('TimeoutException')) {
        throw Exception('Request timed out. Please try again.');
      } else {
        throw Exception('Registration failed. Please try again later.');
      }
    }
  }

  // Sign in with Google (OAuth)
  Future<void> signInWithGoogle({String? redirectTo}) async {
    try {
      // Use supabase_flutter's OAuth flow. On web this will redirect.
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        // If no explicit redirect is provided, compute a sensible default
        // that matches Supabase Auth -> Settings -> Site URL/Redirect URLs.
        redirectTo: redirectTo ?? _defaultRedirectTo(),
      );
    } catch (error) {
      throw Exception('Google sign-in failed: $error');
    }
  }

  // Sign in with Apple (OAuth)
  Future<void> signInWithApple({String? redirectTo}) async {
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: redirectTo ?? _defaultRedirectTo(),
      );
    } catch (error) {
      throw Exception('Apple sign-in failed: $error');
    }
  }

  // Compute a default redirectTo URL that works across platforms.
  // - Web: return the current app origin + path (no fragment), e.g. http://localhost:12345/ or https://app.example.com/
  //        This must be listed in Supabase Auth -> Settings -> Site URL or Additional Redirect URLs.
  // - Mobile/Desktop: use a custom scheme deep link. This app ships with io.supabase.flutter
  //        configured in iOS Info.plist. Ensure Android intent-filters match if targeting Android.
  String _defaultRedirectTo() {
    if (kIsWeb) {
      // Remove auth fragments, keep scheme/host/port/path so sub-path hosting works.
      final base = Uri.base.removeFragment();
      final cleaned = Uri(
        scheme: base.scheme,
        host: base.host,
        port: base.hasPort ? base.port : null,
        path: base.path, // include path in case the app is hosted under a subdirectory
      ).toString();
      return cleaned;
    }

    // Default deep link scheme used by supabase_flutter examples and this app's iOS config.
    // Make sure this value is added to Supabase Auth -> Redirect URLs: io.supabase.flutter://login-callback
    return 'io.supabase.flutter://login-callback';
  }

  // Sign in with email and password - Enhanced null safety and error handling
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Check initialization state first
      if (!SupabaseService.instance.isInitialized) {
        throw Exception(
          'Authentication service is not ready. Please restart the app.',
        );
      }

      // Validate inputs with null safety
      final trimmedEmail = email.trim();
      final trimmedPassword = password.trim();

      if (trimmedEmail.isEmpty || trimmedPassword.isEmpty) {
        throw Exception('Email and password cannot be empty.');
      }

      // Additional email validation
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(trimmedEmail)) {
        throw Exception('Please enter a valid email address.');
      }

      // Get client with null safety
      final client = _client;

      final response = await client.auth.signInWithPassword(
        email: trimmedEmail,
        password: trimmedPassword,
      );

      // Comprehensive response validation with detailed null checks
      if (response.user == null) {
        throw Exception(
          'Invalid login credentials. Please check your email and password.',
        );
      }

      if (response.session == null) {
        throw Exception('Authentication session could not be established.');
      }

      // Enhanced user validation with null safety
      final user = response.user!;
      final session = response.session!;

      // Check all critical user properties
      if (user.id.isEmpty) {
        throw Exception('User authentication failed - invalid user ID.');
      }

      if (user.email == null || user.email!.isEmpty) {
        throw Exception('User authentication failed - invalid email.');
      }

      if (session.accessToken.isEmpty) {
        throw Exception(
          'Authentication session failed - invalid access token.',
        );
      }

      return response;
    } on AuthException catch (error) {
      // Handle specific Supabase auth errors with null safety
      String errorMessage;
      final statusCode = error.statusCode;
      final message = error.message;

      switch (statusCode) {
        case '400':
          if (message.contains('Invalid login credentials')) {
            errorMessage = 'Invalid email or password. Please try again.';
          } else if (message.contains('Email not confirmed')) {
            errorMessage =
                'Please confirm your email address before logging in.';
          } else if (message.contains('Too many requests')) {
            errorMessage =
                'Too many login attempts. Please wait a moment and try again.';
          } else {
            errorMessage =
                'Login failed. Please check your credentials and try again.';
          }
          break;
        case '422':
          errorMessage = 'Please enter a valid email address.';
          break;
        case '429':
          errorMessage =
              'Too many login attempts. Please wait a moment and try again.';
          break;
        case '500':
          errorMessage = 'Server error. Please try again later.';
          break;
        default:
          errorMessage = 'Login failed: $message';
      }
      throw Exception(errorMessage);
    } catch (error) {
      // Handle any other errors with enhanced null safety
      final errorString = error.toString();

      // Check for common network/connectivity issues
      if (errorString.contains('NetworkException') ||
          errorString.contains('SocketException') ||
          errorString.contains('Connection failed')) {
        throw Exception(
          'Network error. Please check your internet connection and try again.',
        );
      } else if (errorString.contains('TimeoutException') ||
          errorString.contains('timeout')) {
        throw Exception('Request timed out. Please try again.');
      } else if (errorString.contains('FormatException')) {
        throw Exception('Invalid response format. Please try again.');
      } else if (errorString.contains('Failed to access Supabase client')) {
        throw Exception(
          'Authentication service is unavailable. Please restart the app.',
        );
      } else {
        // Log the actual error for debugging but show user-friendly message
        throw Exception('Login failed. Please try again later.');
      }
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (error) {
      throw Exception('Sign-out failed: $error');
    }
  }

  // Get user profile data with enhanced null safety
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final user = currentUser;
      if (user == null || user.id.isEmpty) {
        return null;
      }

      final response =
          await _client
              .from('user_profiles')
              .select()
              .eq('id', user.id)
              .maybeSingle();

      return response;
    } catch (error) {
      final errorString = error.toString();
      if (errorString.contains('PGRST116')) {
        // No rows returned - user profile doesn't exist
        return null;
      }
      throw Exception('Get user profile failed: $error');
    }
  }

  // Update user profile with enhanced null safety
  Future<Map<String, dynamic>> updateUserProfile({
    String? fullName,
    String? bio,
    String? avatarUrl,
    int? dailyGoal,
  }) async {
    try {
      final user = currentUser;
      if (user == null || user.id.isEmpty) {
        throw Exception('User not authenticated');
      }

      final updates = <String, dynamic>{};
      if (fullName != null && fullName.isNotEmpty)
        updates['full_name'] = fullName;
      if (bio != null) updates['bio'] = bio;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      if (dailyGoal != null) updates['daily_goal'] = dailyGoal;

      updates['updated_at'] = DateTime.now().toIso8601String();

      final response =
          await _client
              .from('user_profiles')
              .update(updates)
              .eq('id', user.id)
              .select()
              .single();

      return response;
    } catch (error) {
      throw Exception('Update profile failed: $error');
    }
  }

  // Listen to auth state changes with null safety
  Stream<AuthState> get authStateChanges {
    try {
      return _client.auth.onAuthStateChange;
    } catch (e) {
      // Return empty stream if there's an error
      return const Stream.empty();
    }
  }

  // Change password with enhanced validation
  Future<void> updatePassword(String newPassword) async {
    try {
      if (newPassword.trim().isEmpty || newPassword.length < 6) {
        throw Exception('Password must be at least 6 characters long.');
      }

      await _client.auth.updateUser(
        UserAttributes(password: newPassword.trim()),
      );
    } catch (error) {
      throw Exception('Password update failed: $error');
    }
  }

  // Change email with enhanced validation
  Future<void> updateEmail(String newEmail) async {
    try {
      if (newEmail.trim().isEmpty || !newEmail.contains('@')) {
        throw Exception('Please enter a valid email address.');
      }

      await _client.auth.updateUser(UserAttributes(email: newEmail.trim()));
    } catch (error) {
      throw Exception('Email update failed: $error');
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      final trimmedEmail = email.trim();
      if (trimmedEmail.isEmpty) {
        throw Exception('Please enter your email address.');
      }
      // Basic email validation
      if (!RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(trimmedEmail)) {
        throw Exception('Please enter a valid email address.');
      }

      // Use a deep link redirect so the app can handle the recovery in-app
      const redirectUri = 'io.supabase.flutter://reset-callback';
      await _client.auth.resetPasswordForEmail(
        trimmedEmail,
        redirectTo: redirectUri,
      );
    } on AuthException catch (error) {
      String message;
      switch (error.statusCode) {
        case '400':
          if (error.message.contains('Email not found') ||
              error.message.contains('User not found')) {
            message =
                'We could not find an account with that email. Please check and try again.';
          } else if (error.message.contains('Unable to validate email')) {
            message = 'Please enter a valid email address.';
          } else {
            message = 'Could not send reset email. Please try again.';
          }
          break;
        case '429':
          message =
              'Too many requests. Please wait a moment and try again.';
          break;
        default:
          message = 'Password reset failed: ${error.message}';
      }
      throw Exception(message);
    } catch (e) {
      final s = e.toString();
      if (s.contains('NetworkException') ||
          s.contains('SocketException')) {
        throw Exception(
          'Network error. Please check your internet connection and try again.',
        );
      }
      throw Exception('Could not send reset email. Please try again later.');
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      if (!isSignedIn) throw Exception('User not authenticated');

      // Note: This would need to be implemented via an Edge Function
      // as Supabase doesn't allow direct user deletion from client
      throw Exception(
        'Account deletion must be implemented via admin function',
      );
    } catch (error) {
      throw Exception('Account deletion failed: $error');
    }
  }
}
