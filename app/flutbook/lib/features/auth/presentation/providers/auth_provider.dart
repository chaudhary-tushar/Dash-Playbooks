import 'package:flutbook/core/provider/providers.dart';
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
  @override
  AuthState build() {
    // Initialize with loading state and check current user
    ref.onDispose(() {
      // Cleanup if needed
    });

    // Check current user after provider initialization
    Future.microtask(() async {
      try {
        await checkCurrentUser();
      } catch (e) {
        // Handle Firebase initialization errors gracefully
        // If Firebase is not initialized, set to a non-error state to allow development
        if (ref.mounted) {
          // Set to a default non-authenticated state to allow development flow
          state = const AuthState();
        }
      }
    });

    // Start with loading state, but avoid Firebase calls if they would fail
    return const AuthState(isLoading: true);
  }

  // Check current user on initialization
  Future<void> checkCurrentUser() async {
    // If we're in development bypass mode, skip Firebase checks
    if (state.isAuthenticated &&
        state.userProfile?.authMethod == 'development') {
      return; // Already in dev mode, don't try to re-check
    }

    try {
      // Only access the usecase if it's available (not in error state)
      final usecase = ref.read(getCurrentUserUsecaseProvider);
      final user = await usecase();
      if (ref.mounted) {
        state = AuthState(
          isAuthenticated: user != null,
          userProfile: user,
        );
      }
    } catch (e) {
      if (ref.mounted) {
        // For development purposes, don't set the error state permanently
        // as it will block the development bypass
        state = const AuthState();
      }
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
  }
}

// Riverpod provider for auth state
final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
