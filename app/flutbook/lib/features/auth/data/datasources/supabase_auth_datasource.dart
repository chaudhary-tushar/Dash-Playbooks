/// Supabase authentication datasource for Flutbook.
///
/// This datasource replaces Firebase Auth with Supabase Auth, providing:
/// - Email/password authentication
/// - Google OAuth sign-in
/// - Anonymous authentication
/// - User profile management
/// - Authentication state persistence
library;

import 'package:flutbook/core/config/app_config.dart';
import 'package:flutbook/features/auth/domain/entities/auth_result.dart';
import 'package:flutbook/features/auth/domain/entities/user_profile.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase authentication datasource implementation.
///
/// Handles all authentication operations using Supabase Auth.
/// Provides the same interface as the Firebase datasource for easy migration.
class SupabaseAuthDatasource {
  /// Create a new SupabaseAuthDatasource.
  ///
  /// [supabase] - The Supabase client instance
  /// [configProvider] - Configuration provider for app settings
  SupabaseAuthDatasource({
    required SupabaseClient supabase,
    required ConfigProvider configProvider,
  }) : _supabase = supabase,
       _configProvider = configProvider;
  final SupabaseClient _supabase;
  final ConfigProvider _configProvider;

  /// Get the current configuration
  AppConfig get _config => _configProvider.config;

  /// Signs in with email and password
  Future<AuthResult> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user != null) {
        final userProfile = UserProfile(
          id: user.id,
          email: user.email ?? email,
          displayName:
              (user.userMetadata?['full_name'] as String?) ??
              (user.userMetadata?['name'] as String?),
          authMethod: 'email_password',
          syncEnabled: true,
        );

        return AuthResult(
          success: true,
          userId: user.id,
          user: userProfile,
        );
      } else {
        return const AuthResult(
          success: false,
          errorMessage: 'Authentication failed: No user returned',
        );
      }
    } on AuthException catch (e) {
      return AuthResult(
        success: false,
        errorMessage: mapAuthError(e.message),
      );
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'Failed to sign in: $e',
      );
    }
  }

  /// Signs up with email and password
  Future<AuthResult> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user != null) {
        final userProfile = UserProfile(
          id: user.id,
          email: user.email ?? email,
          displayName:
              (user.userMetadata?['full_name'] as String?) ??
              (user.userMetadata?['name'] as String?),
          authMethod: 'email_password',
          syncEnabled: true,
        );

        return AuthResult(
          success: true,
          userId: user.id,
          user: userProfile,
        );
      } else {
        return const AuthResult(
          success: false,
          errorMessage: 'Account creation failed: No user returned',
        );
      }
    } on AuthException catch (e) {
      return AuthResult(
        success: false,
        errorMessage: mapAuthError(e.message),
      );
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'Failed to create account: $e',
      );
    }
  }

  /// Unified authentication method that attempts login first and creates account if user does not exist
  Future<AuthResult> authenticateWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      // First try to sign in with existing credentials
      final signInResponse = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = signInResponse.user;
      if (user != null) {
        // User exists and signed in successfully
        final userProfile = UserProfile(
          id: user.id,
          email: user.email ?? email,
          displayName:
              (user.userMetadata?['full_name'] as String?) ??
              (user.userMetadata?['name'] as String?),
          authMethod: 'email_password',
          syncEnabled: true,
        );

        return AuthResult(
          success: true,
          userId: user.id,
          user: userProfile,
        );
      } else {
        // This shouldn't happen in normal cases - user should exist if login succeeds
        return const AuthResult(
          success: false,
          errorMessage: 'Authentication failed: No user returned',
        );
      }
    } on AuthException catch (e) {
      // Check if the error is due to user not existing
      if (e.message.contains('Invalid login credentials') ||
          e.message.contains('User not found') ||
          e.message.contains('does not exist')) {
        // User doesn't exist, so let's create an account
        try {
          final signUpResponse = await _supabase.auth.signUp(
            email: email,
            password: password,
          );

          final user = signUpResponse.user;
          if (user != null) {
            // Successfully created new user
            final userProfile = UserProfile(
              id: user.id,
              email: user.email ?? email,
              displayName:
                  (user.userMetadata?['full_name'] as String?) ??
                  (user.userMetadata?['name'] as String?),
              authMethod: 'email_password',
              syncEnabled: true,
            );

            return AuthResult(
              success: true,
              userId: user.id,
              user: userProfile,
            );
          } else {
            return const AuthResult(
              success: false,
              errorMessage: 'Account creation failed: No user returned',
            );
          }
        } on AuthException catch (signUpError) {
          return AuthResult(
            success: false,
            errorMessage: mapAuthError(signUpError.message),
          );
        } catch (signUpError) {
          return AuthResult(
            success: false,
            errorMessage: 'Failed to create account: $signUpError',
          );
        }
      } else {
        // Some other authentication error occurred
        return AuthResult(
          success: false,
          errorMessage: mapAuthError(e.message),
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'Authentication failed: $e',
      );
    }
  }

  /// Signs in with Google OAuth
  Future<AuthResult> signInWithGoogle() async {
    if (!_config.auth.enableGoogleAuth) {
      return const AuthResult(
        success: false,
        errorMessage: 'Google authentication is not enabled',
      );
    }

    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: _getRedirectUrl(),
      );

      final user = _supabase.auth.currentUser;
      if (user != null) {
        final userProfile = UserProfile(
          id: user.id,
          email: user.email ?? '',
          displayName:
              (user.userMetadata?['full_name'] as String?) ??
              (user.userMetadata?['name'] as String?),
          authMethod: 'google_oauth',
          syncEnabled: true,
        );

        return AuthResult(
          success: true,
          userId: user.id,
          user: userProfile,
        );
      } else {
        return const AuthResult(
          success: false,
          errorMessage: 'Google authentication failed: No user returned',
        );
      }
    } on AuthException catch (e) {
      return AuthResult(
        success: false,
        errorMessage: mapAuthError(e.message),
      );
    } on Exception catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'Google sign in failed: $e',
      );
    }
  }

  /// Signs in anonymously
  Future<AuthResult> anonymousSignIn() async {
    if (!_config.auth.enableAnonymousAuth) {
      return const AuthResult(
        success: false,
        errorMessage: 'Anonymous authentication is not enabled',
      );
    }

    try {
      final response = await _supabase.auth.signInAnonymously();

      final user = response.user;
      if (user != null) {
        final userProfile = UserProfile(
          id: user.id,
          email: 'anonymous@${user.id}', // Anonymous users don't have emails
          displayName: 'Anonymous User',
          authMethod: 'anonymous',
          syncEnabled: true,
        );

        return AuthResult(
          success: true,
          userId: user.id,
          user: userProfile,
        );
      } else {
        return const AuthResult(
          success: false,
          errorMessage: 'Anonymous authentication failed: No user returned',
        );
      }
    } on AuthException catch (e) {
      return AuthResult(
        success: false,
        errorMessage: mapAuthError(e.message),
      );
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'Failed to sign in anonymously: $e',
      );
    }
  }

  /// Signs in anonymously and returns User object
  Future<User> signInAnonymously() async {
    try {
      final response = await _supabase.auth.signInAnonymously();
      final user = response.user;
      if (user == null) {
        throw Exception('Anonymous sign in failed: No user returned');
      }
      return user;
    } on AuthException catch (e) {
      throw Exception(
        'Failed to sign in anonymously: ${mapAuthError(e.message)}',
      );
    } catch (e) {
      throw Exception('Failed to sign in anonymously: $e');
    }
  }

  /// Signs in with email and password
  Future<User> signInWithEmail(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) {
        throw Exception('Sign in failed: No user returned');
      }
      return user;
    } on AuthException catch (e) {
      throw Exception(
        'Failed to sign in with email: ${mapAuthError(e.message)}',
      );
    } catch (e) {
      throw Exception('Failed to sign in with email: $e');
    }
  }

  /// Signs out the current user
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  /// Gets the current authenticated user
  Future<UserProfile?> getCurrentUser() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      return UserProfile(
        id: user.id,
        email: user.email ?? '',
        displayName:
            (user.userMetadata?['full_name'] as String?) ??
            (user.userMetadata?['name'] as String?),
        authMethod: _getAuthMethod(user),
        syncEnabled: true,
      );
    }
    return null;
  }

  /// Gets the current Supabase user
  User? getCurrentSupabaseUser() {
    return _supabase.auth.currentUser;
  }

  /// Listens to authentication state changes
  Stream<User?> authStateChanges() {
    return _supabase.auth.onAuthStateChange.map((event) => event.session?.user);
  }

  /// Refreshes the current session
  Future<void> refreshSession() async {
    await _supabase.auth.refreshSession();
  }

  /// Updates user email
  Future<AuthResult> updateEmail(String email) async {
    try {
      await _supabase.auth.updateUser(UserAttributes(email: email));
      return const AuthResult(success: true);
    } on AuthException catch (e) {
      return AuthResult(
        success: false,
        errorMessage: mapAuthError(e.message),
      );
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'Failed to update email: $e',
      );
    }
  }

  /// Updates user password
  Future<AuthResult> updatePassword(String password) async {
    try {
      await _supabase.auth.updateUser(UserAttributes(password: password));
      return const AuthResult(success: true);
    } on AuthException catch (e) {
      return AuthResult(
        success: false,
        errorMessage: mapAuthError(e.message),
      );
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'Failed to update password: $e',
      );
    }
  }

  /// Maps Supabase error messages to user-friendly messages
  String mapAuthError(String? errorCode) {
    if (errorCode == null) {
      return 'Authentication failed. Please try again.';
    }

    switch (errorCode.toLowerCase()) {
      case 'invalid_credentials':
        return 'Invalid email or password.';
      case 'email_not_confirmed':
        return 'Please confirm your email address.';
      case 'email_already_in_use':
        return 'An account with this email already exists.';
      case 'weak_password':
        return 'Password is too weak.';
      case 'invalid_email':
        return 'Email is invalid.';
      case 'user_not_found':
        return 'No user found with this email.';
      case 'too_many_requests':
        return 'Too many requests. Please try again later.';
      case 'network_error':
        return 'Network error. Please check your connection.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  /// Determines the authentication method from user metadata
  String _getAuthMethod(User user) {
    final provider = user.appMetadata['provider'] as String?;
    if (provider != null) {
      return provider;
    }

    // Check if user has email (password-based auth)
    if (user.email != null) {
      return 'email_password';
    }

    // Check if user has phone
    if (user.phone != null) {
      return 'phone';
    }

    return 'unknown';
  }

  /// Gets the appropriate redirect URL for OAuth
  String _getRedirectUrl() {
    // For web, use current origin
    if (kIsWeb) {
      return '${Uri.base.origin}/auth/callback';
    }

    // For mobile, use deep link
    return 'io.supabase.flutbook://auth/callback';
  }
}
