import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutbook/features/auth/domain/entities/user_profile.dart';
import 'package:flutbook/features/auth/domain/repositories/user_repository.dart';
import 'package:flutbook/features/auth/domain/usecases/anonymous_login_usecase.dart';
import 'package:flutbook/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutbook/features/auth/domain/usecases/logout_usecase.dart';
import 'package:flutbook/features/auth/domain/usecases/get_current_user_usecase.dart';

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
}

// AuthNotifier class that extends Notifier for Riverpod 3.x
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Initialize with loading state and check current user
    _checkCurrentUser();
    return const AuthState(isLoading: true);
  }

  UserRepository get _userRepository => ref.read(userRepositoryProvider);
  LoginUsecase get _loginUsecase => ref.read(loginUsecaseProvider);
  AnonymousLoginUsecase get _anonymousLoginUsecase => ref.read(anonymousLoginUsecaseProvider);
  LogoutUsecase get _logoutUsecase => ref.read(logoutUsecaseProvider);
  GetCurrentUserUsecase get _getCurrentUserUsecase => ref.read(getCurrentUserUsecaseProvider);

  // Check current user on initialization
  Future<void> _checkCurrentUser() async {
    try {
      final user = await _getCurrentUserUsecase();
      final newState = AuthState(
        isAuthenticated: user != null,
        userProfile: user,
        isLoading: false,
        errorMessage: null,
      );
      state = newState;
    } catch (e) {
      state = AuthState(
        isAuthenticated: false,
        userProfile: null,
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  // Login with email and password
  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final result = await _loginUsecase(email: email, password: password);
      
      if (result.success) {
        final user = await _getCurrentUserUsecase();
        state = AuthState(
          isAuthenticated: true,
          userProfile: user,
          isLoading: false,
          errorMessage: null,
        );
      } else {
        state = state.copyWith(
          isAuthenticated: false,
          isLoading: false,
          errorMessage: result.errorMessage,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        errorMessage: 'Login failed: $e',
      );
    }
  }

  // Login anonymously
  Future<void> loginAnonymously() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final result = await _anonymousLoginUsecase();
      
      if (result.success) {
        final user = await _getCurrentUserUsecase();
        state = AuthState(
          isAuthenticated: true,
          userProfile: user,
          isLoading: false,
          errorMessage: null,
        );
      } else {
        state = state.copyWith(
          isAuthenticated: false,
          isLoading: false,
          errorMessage: result.errorMessage,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        errorMessage: 'Anonymous login failed: $e',
      );
    }
  }

  // Logout
  Future<void> logout() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      await _logoutUsecase();
      state = const AuthState(
        isAuthenticated: false,
        userProfile: null,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Logout failed: $e',
      );
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