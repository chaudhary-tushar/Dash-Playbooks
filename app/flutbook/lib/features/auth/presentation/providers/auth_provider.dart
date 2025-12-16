import 'package:flutbook/core/provider/providers.dart';
import 'package:flutbook/features/auth/domain/entities/user_profile.dart';
import 'package:flutbook/features/auth/domain/repositories/user_repository.dart';
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
    // Initialize with loading state
    ref.onDispose(() {
      // Cleanup if needed
    });

    return const AuthState(isLoading: true);
  }

  UserRepository get _userRepository => ref.read(userRepositoryProvider);

  // Check current user on initialization
  Future<void> checkCurrentUser() async {
    try {
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
        state = AuthState(
          errorMessage: e.toString(),
        );
      }
    }
  }

  // Login with email and password
  Future<void> login(String email, String password) async {
    if (!ref.mounted) return;
    state = state.copyWith(isLoading: true);

    try {
      final usecase = ref.read(loginUsecaseProvider);
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
          errorMessage: 'Login failed: $e',
        );
      }
    }
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
}

// Riverpod provider for auth state
final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
