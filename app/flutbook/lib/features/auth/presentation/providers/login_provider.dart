import 'package:flutbook/features/auth/domain/entities/user_profile.dart';
import 'package:flutbook/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutbook/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutbook/core/provider/providers.dart';

/// Login Notifier class that manages authentication state
class LoginNotifier extends Notifier<AsyncValue<UserProfile>> {
  @override
  AsyncValue<UserProfile> build() {
    return const AsyncValue.loading();
  }

  /// Attempts to login with email and password
  /// Returns the UserProfile on success, or null on failure
  Future<UserProfile?> login(String email, String password) async {
    // Set loading state
    state = const AsyncValue.loading();

    try {
      // Use AsyncValue.guard to handle the login operation
      final authResult = await AsyncValue.guard(
        () => _loginUsecase.call(email: email, password: password),
      );

      // Check if the login was successful
      if (authResult.hasError) {
        // If there's an error, update state and return null
        state = AsyncValue.error(authResult.error!, StackTrace.current);
        return null;
      }

      // Get the AuthResult value
      final result = authResult.value;
      if (result == null) {
        // If result is null (shouldn't happen), create an error state
        state = AsyncValue.error(
          Exception('Login failed: null result'),
          StackTrace.current,
        );
        return null;
      }

      if (!result.success) {
        // If login failed, create an error state
        final errorMessage = result.errorMessage ?? 'Login failed';
        state = AsyncValue.error(Exception(errorMessage), StackTrace.current);
        return null;
      }

      // On successful login, get the user profile
      // For now, we'll create a basic user profile from the auth result
      final userProfile = UserProfile(
        id: result.userId ?? email,
        email: email,
        authMethod: 'email',
        syncEnabled: true, // Default to true for email auth
      );

      // Update state with the user profile
      state = AsyncValue.data(userProfile);

      return userProfile;
    } catch (e) {
      // Handle any errors and update state
      state = AsyncValue.error(e, StackTrace.current);
      return null;
    }
  }

  /// Gets the current LoginUsecase from the provider
  LoginUsecase get _loginUsecase => ref.read(loginUsecaseProvider);
}

/// Provider for LoginNotifier
final loginProvider = NotifierProvider<LoginNotifier, AsyncValue<UserProfile>>(
  LoginNotifier.new,
);
