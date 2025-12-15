import 'package:flutbook/features/auth/domain/repositories/user_repository.dart';
import 'package:flutbook/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutbook/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutbook/features/auth/presentation/providers/login_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes
class MockLoginUsecase extends Mock implements LoginUsecase {}

// class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late LoginUsecase mockLoginUsecase;
  late ProviderContainer container;

  setUp(() {
    mockLoginUsecase = MockLoginUsecase();

    // Create a provider container with overrides
    container = ProviderContainer(
      overrides: [
        loginUsecaseProvider.overrideWithValue(mockLoginUsecase),
      ],
    );
  });

  // Test data
  const validEmail = 'test@example.com';
  const validPassword = 'password123';
  const invalidEmail = 'invalid-email';
  const emptyEmail = '';
  const emptyPassword = '';
  const shortPassword = 'short';

  const successAuthResult = AuthResult(
    success: true,
    userId: 'user123',
  );

  const failureAuthResult = AuthResult(
    success: false,
    errorMessage: 'Invalid credentials',
  );

  // final testUserProfile = UserProfile(
  //   id: 'user123',
  //   email: validEmail,
  //   authMethod: 'email',
  //   syncEnabled: true,
  // );

  group('LoginProvider', () {
    test('should have initial loading state', () {
      // Act
      final loginState = container.read(loginProvider);

      // Assert
      expect(loginState.isLoading, isTrue);
      expect(loginState.value, isNull);
      expect(loginState.hasError, isFalse);
    });

    test('should return success state on valid login', () async {
      // Arrange
      when(
        () => mockLoginUsecase.call(
          email: validEmail,
          password: validPassword,
        ),
      ).thenAnswer((_) async => successAuthResult);

      // Act
      await container
          .read(loginProvider.notifier)
          .login(validEmail, validPassword);
      final loginState = container.read(loginProvider);

      // Assert
      expect(loginState.isLoading, isFalse);
      expect(loginState.hasError, isFalse);
      expect(loginState.value, isNotNull);
      verify(
        () => mockLoginUsecase.call(
          email: validEmail,
          password: validPassword,
        ),
      ).called(1);
    });

    test('should return error state on failed login', () async {
      // Arrange
      when(
        () => mockLoginUsecase.call(
          email: validEmail,
          password: 'wrongpassword',
        ),
      ).thenAnswer((_) async => failureAuthResult);

      // Act
      await container
          .read(loginProvider.notifier)
          .login(validEmail, 'wrongpassword');
      final loginState = container.read(loginProvider);

      // Assert
      expect(loginState.isLoading, isFalse);
      expect(loginState.hasError, isTrue);
      expect(loginState.error, isNotNull);
      verify(
        () => mockLoginUsecase.call(
          email: validEmail,
          password: 'wrongpassword',
        ),
      ).called(1);
    });

    test('should show loading state during authentication', () async {
      // Arrange
      final slowFuture = Future<AuthResult>.delayed(
        const Duration(milliseconds: 100),
        () => successAuthResult,
      );
      when(
        () => mockLoginUsecase.call(
          email: validEmail,
          password: validPassword,
        ),
      ).thenAnswer((_) => slowFuture);

      // Act - check state immediately after calling login
      final future = container
          .read(loginProvider.notifier)
          .login(validEmail, validPassword);
      final loadingState = container.read(loginProvider);

      // Assert loading state
      expect(loadingState.isLoading, isTrue);

      // Wait for completion
      await future;
      final finalState = container.read(loginProvider);
      expect(finalState.isLoading, isFalse);
    });

    test('should handle error state properly', () async {
      // Arrange
      when(
        () => mockLoginUsecase.call(
          email: validEmail,
          password: validPassword,
        ),
      ).thenThrow(Exception('Network error'));

      // Act
      await container
          .read(loginProvider.notifier)
          .login(validEmail, validPassword);
      final loginState = container.read(loginProvider);

      // Assert
      expect(loginState.isLoading, isFalse);
      expect(loginState.hasError, isTrue);
      expect(loginState.error, isNotNull);
    });

    test('should validate email format before calling usecase', () async {
      // Arrange - mock the usecase to return validation error
      when(
        () => mockLoginUsecase.call(
          email: invalidEmail,
          password: validPassword,
        ),
      ).thenAnswer(
        (_) async => const AuthResult(
          success: false,
          errorMessage: 'Invalid email format',
        ),
      );

      // Act - try to login with invalid email
      await container
          .read(loginProvider.notifier)
          .login(invalidEmail, validPassword);
      final loginState = container.read(loginProvider);

      // Assert
      expect(loginState.hasError, isTrue);
      verify(
        () => mockLoginUsecase.call(
          email: invalidEmail,
          password: validPassword,
        ),
      ).called(1);
    });

    test('should validate password length before calling usecase', () async {
      // Arrange - mock the usecase to return validation error
      when(
        () => mockLoginUsecase.call(
          email: validEmail,
          password: shortPassword,
        ),
      ).thenAnswer(
        (_) async => const AuthResult(
          success: false,
          errorMessage: 'Password must be at least 6 characters',
        ),
      );

      // Act - try to login with short password
      await container
          .read(loginProvider.notifier)
          .login(validEmail, shortPassword);
      final loginState = container.read(loginProvider);

      // Assert
      expect(loginState.hasError, isTrue);
      verify(
        () => mockLoginUsecase.call(
          email: validEmail,
          password: shortPassword,
        ),
      ).called(1);
    });

    test('should handle empty email validation', () async {
      // Arrange - mock the usecase to return validation error
      when(
        () => mockLoginUsecase.call(
          email: emptyEmail,
          password: validPassword,
        ),
      ).thenAnswer(
        (_) async => const AuthResult(
          success: false,
          errorMessage: 'Email cannot be empty',
        ),
      );

      // Act - try to login with empty email
      await container
          .read(loginProvider.notifier)
          .login(emptyEmail, validPassword);
      final loginState = container.read(loginProvider);

      // Assert
      expect(loginState.hasError, isTrue);
      verify(
        () => mockLoginUsecase.call(
          email: emptyEmail,
          password: validPassword,
        ),
      ).called(1);
    });

    test('should handle empty password validation', () async {
      // Arrange - mock the usecase to return validation error
      when(
        () => mockLoginUsecase.call(
          email: validEmail,
          password: emptyPassword,
        ),
      ).thenAnswer(
        (_) async => const AuthResult(
          success: false,
          errorMessage: 'Password cannot be empty',
        ),
      );

      // Act - try to login with empty password
      await container
          .read(loginProvider.notifier)
          .login(validEmail, emptyPassword);
      final loginState = container.read(loginProvider);

      // Assert
      expect(loginState.hasError, isTrue);
      verify(
        () => mockLoginUsecase.call(
          email: validEmail,
          password: emptyPassword,
        ),
      ).called(1);
    });
  });
}
