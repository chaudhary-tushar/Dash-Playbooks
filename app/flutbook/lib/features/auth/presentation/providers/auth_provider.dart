import 'package:flutbook/core/provider/providers.dart';
import 'package:flutbook/features/auth/data/services/session_manager.dart';
import 'package:flutbook/features/auth/data/services/user_profile_service.dart';
import 'package:flutbook/features/auth/domain/entities/user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Auth State class to represent the authentication state
class AuthState {
  const AuthState({
    this.isAuthenticated = false,
    this.userProfile,
    this.isLoading = false,
    this.errorMessage,
  });

  final bool isAuthenticated;
  final UserProfile? userProfile;
  final bool isLoading;
  final String? errorMessage;

  AuthState copyWith({
    bool? isAuthenticated,
    UserProfile? userProfile,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userProfile: userProfile ?? this.userProfile,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AuthState &&
        other.isAuthenticated == isAuthenticated &&
        other.userProfile == userProfile &&
        other.isLoading == isLoading &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode {
    return isAuthenticated.hashCode ^
        userProfile.hashCode ^
        isLoading.hashCode ^
        errorMessage.hashCode;
  }
}

// AuthNotifier class that extends Notifier for Riverpod 3.x
class AuthNotifier extends Notifier<AuthState> {
  final SessionManager _sessionManager = SessionManager();

  @override
  AuthState build() {
    // Initialize with loading state and check current user
    ref.onDispose(() {
      // Cleanup if needed
    });

    // Check current user after provider initialization
    // Using Future.microtask to defer the check until after the provider is fully set up
    Future.microtask(() async {
      try {
        await checkCurrentUser();
      } catch (e, stackTrace) {
        print('Error in AuthNotifier build checkCurrentUser: $e');
        print('Stack trace: $stackTrace');
        // Handle initialization errors gracefully
        // If session has expired, set to a non-authenticated state
        if (ref.mounted) {
          // Set to a default non-authenticated state to allow development flow
          state = const AuthState();
        }
      }
    });

    // Start with loading state, but avoid calls if they would fail
    return const AuthState(isLoading: true);
  }

  // Check current user on initialization
  Future<void> checkCurrentUser() async {
    try {
      // Check if session has expired
      final isExpired = await _sessionManager.isSessionExpired();
      if (isExpired) {
        // Session has expired, clear any existing session data
        await _sessionManager.clearSession();
        if (ref.mounted) {
          state = const AuthState();
        }
        return;
      }

      // If we're in development bypass mode, skip checks
      if (state.isAuthenticated &&
          state.userProfile?.authMethod == 'development') {
        return; // Already in dev mode, don't try to re-check
      }

      // First, try to get user from ISAR to see if we have a local user
      // Use a try-catch around the async provider access
      final userProfileService = await _getUserProfileService();
      final localUser = await userProfileService.getCurrentUserProfile();

      if (localUser != null) {
        // We have a user in ISAR, now verify with Supabase
        final user = await _getCurrentUser();

        if (user != null && user.id == localUser.id) {
          // User exists in both ISAR and Supabase, authentication is valid
          if (ref.mounted) {
            state = AuthState(
              isAuthenticated: true,
              userProfile: user,
            );
          }
        } else {
          // User doesn't exist in Supabase anymore, clear local data
          await userProfileService.deleteAllUserProfiles();
          if (ref.mounted) {
            state = const AuthState();
          }
        }
      } else {
        // No user in ISAR, set to non-authenticated
        if (ref.mounted) {
          state = const AuthState();
        }
      }
    } catch (e, stackTrace) {
      // Log the error with stack trace for debugging
      print('Error in checkCurrentUser: $e');
      print('Stack trace: $stackTrace');

      if (ref.mounted) {
        // For development purposes, don't set the error state permanently
        // as it will block the development bypass
        state = const AuthState();
      }
    }
  }

  // Helper method to safely get user profile service with error handling
  Future<UserProfileService> _getUserProfileService() async {
    try {
      return await ref.read(userProfileServiceProvider.future);
    } catch (e) {
      print('Error getting user profile service: $e');
      rethrow;
    }
  }

  // Helper method to safely get current user with error handling
  Future<UserProfile?> _getCurrentUser() async {
    try {
      final usecase = ref.read(getCurrentUserUsecaseProvider);
      return await usecase();
    } catch (e) {
      print('Error getting current user: $e');
      rethrow;
    }
  }

  // Authenticate with email and password (unified login/signup)
  Future<void> authenticate(String email, String password) async {
    if (!ref.mounted) return;
    state = state.copyWith(isLoading: true);

    try {
      final usecase = ref.read(authenticateUsecaseProvider);
      final result = await usecase(email: email, password: password);

      if (result.success) {
        final usercase = ref.read(getCurrentUserUsecaseProvider);
        final user = await usercase();
        if (ref.mounted) {
          state = AuthState(
            isAuthenticated: true,
            userProfile: user,
          );
          // Set session expiry for 7-30 days
          await _setSessionExpiry();
        }
      } else {
        if (ref.mounted) {
          state = state.copyWith(
            isAuthenticated: false,
            isLoading: false,
            errorMessage: result.errorMessage,
          );
        }
      }
    } catch (e) {
      if (ref.mounted) {
        state = state.copyWith(
          isAuthenticated: false,
          isLoading: false,
          errorMessage: 'Authentication failed: $e',
        );
      }
    }
  }

  // Login with email and password (kept for backward compatibility)
  @Deprecated('Use authenticate() instead')
  Future<void> login(String email, String password) async {
    await authenticate(email, password);
  }

  // Signup with email and password (kept for backward compatibility)
  @Deprecated('Use authenticate() instead')
  Future<void> signup(String email, String password) async {
    await authenticate(email, password);
  }

  // Login anonymously
  Future<void> loginAnonymously() async {
    if (!ref.mounted) return;
    state = state.copyWith(isLoading: true);

    try {
      final usecase = ref.read(anonymousLoginUsecaseProvider);
      final result = await usecase();

      if (result.success) {
        final usercase = ref.read(getCurrentUserUsecaseProvider);
        final user = await usercase();
        if (ref.mounted) {
          state = AuthState(
            isAuthenticated: true,
            userProfile: user,
          );
          // Set session expiry for 7-30 days
          await _setSessionExpiry();
        }
      } else {
        if (ref.mounted) {
          state = state.copyWith(
            isAuthenticated: false,
            isLoading: false,
            errorMessage: result.errorMessage,
          );
        }
      }
    } catch (e) {
      if (ref.mounted) {
        state = state.copyWith(
          isAuthenticated: false,
          isLoading: false,
          errorMessage: 'Anonymous login failed: $e',
        );
      }
    }
  }

  // Logout
  Future<void> logout() async {
    if (!ref.mounted) return;
    state = state.copyWith(isLoading: true);

    try {
      final usecase = ref.read(logoutUsecaseProvider);
      await usecase();
      // Clear session data
      await _sessionManager.clearSession();
      if (ref.mounted) {
        state = const AuthState();
      }
    } catch (e) {
      if (ref.mounted) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Logout failed: $e',
        );
      }
    }
  }

  // Set session expiry for 7-30 days
  Future<void> _setSessionExpiry() async {
    final now = DateTime.now();
    final expiryDate = _sessionManager.calculateExpiryDate(now);
    await _sessionManager.setSessionExpiry(expiryDate);
  }

  // Get current user profile
  UserProfile? getCurrentUser() {
    return state.userProfile;
  }

  // Check if user is authenticated
  bool isAuthenticated() {
    return state.isAuthenticated;
  }

  // Sign in with Google
  Future<void> signInWithGoogle() async {
    if (!ref.mounted) return;
    state = state.copyWith(isLoading: true);

    try {
      final usecase = ref.read(googleSigninUsecaseProvider);
      final result = await usecase();

      if (result.success) {
        final usercase = ref.read(getCurrentUserUsecaseProvider);
        final user = await usercase();
        if (ref.mounted) {
          state = AuthState(
            isAuthenticated: true,
            userProfile: user,
          );
          // Set session expiry for 7-30 days
          await _setSessionExpiry();
        }
      } else {
        if (ref.mounted) {
          state = state.copyWith(
            isAuthenticated: false,
            isLoading: false,
            errorMessage: result.errorMessage,
          );
        }
      }
    } catch (e) {
      if (ref.mounted) {
        state = state.copyWith(
          isAuthenticated: false,
          isLoading: false,
          errorMessage: 'Google sign in failed: $e',
        );
      }
    }
  }

  // Method for development purposes to bypass authentication
  Future<void> loginAsDevelopmentUser() async {
    if (!ref.mounted) return;

    // Create a development user profile
    final devUser = UserProfile(
      id: 'dev_user_123',
      email: 'dev@example.com',
      authMethod: 'development',
      syncEnabled: false,
    );

    // Set the state as authenticated with development user
    state = AuthState(
      isAuthenticated: true,
      userProfile: devUser,
    );
    // Set session expiry for 7-30 days
    await _setSessionExpiry();
  }
}

// Riverpod provider for auth state
final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
