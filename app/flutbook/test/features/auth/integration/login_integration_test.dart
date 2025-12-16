import 'package:flutbook/core/provider/providers.dart';
import 'package:flutbook/features/auth/domain/entities/auth_result.dart';
import 'package:flutbook/features/auth/domain/entities/user_profile.dart';
import 'package:flutbook/features/auth/domain/repositories/user_repository.dart';
import 'package:flutbook/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutbook/features/auth/presentation/pages/login_page.dart';
import 'package:flutbook/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutbook/features/auth/presentation/providers/login_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes
class MockUserRepository extends Mock implements UserRepository {}

class MockLoginUsecase extends Mock implements LoginUsecase {}

void main() {
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

  final testUserProfile = UserProfile(
    id: 'user123',
    email: validEmail,
    authMethod: 'email',
    syncEnabled: true,
  );

  group('Login Integration Tests', () {
    // Test the complete integration between LoginUsecase and LoginProvider
    test(
      'LoginUsecase + LoginProvider integration test - successful login',
      () async {
        // Arrange
        final mockRepository = MockUserRepository();
        final loginUsecase = LoginUsecase(mockRepository);

        when(
          () => mockRepository.signInWithEmailAndPassword(
            validEmail,
            validPassword,
          ),
        ).thenAnswer((_) async => successAuthResult);

        final container = ProviderContainer(
          overrides: [
            loginUsecaseProvider.overrideWithValue(loginUsecase),
          ],
        );

        // Act
        await container
            .read(loginProvider.notifier)
            .login(validEmail, validPassword);
        final loginState = container.read(loginProvider);

        // Assert
        expect(loginState.isLoading, isFalse);
        expect(loginState.hasError, isFalse);
        expect(loginState.value, isNotNull);
        expect(loginState.value?.id, 'user123');
        expect(loginState.value?.email, validEmail);

        verify(
          () => mockRepository.signInWithEmailAndPassword(
            validEmail,
            validPassword,
          ),
        ).called(1);
      },
    );

    test(
      'LoginUsecase + LoginProvider integration test - failed login',
      () async {
        // Arrange
        final mockRepository = MockUserRepository();
        final loginUsecase = LoginUsecase(mockRepository);

        when(
          () => mockRepository.signInWithEmailAndPassword(
            validEmail,
            'wrongpassword',
          ),
        ).thenAnswer((_) async => failureAuthResult);

        final container = ProviderContainer(
          overrides: [
            loginUsecaseProvider.overrideWithValue(loginUsecase),
          ],
        );

        // Act
        await container
            .read(loginProvider.notifier)
            .login(validEmail, 'wrongpassword');
        final loginState = container.read(loginProvider);

        // Assert
        expect(loginState.isLoading, isFalse);
        expect(loginState.hasError, isTrue);
        expect(loginState.error, isNotNull);
        expect(loginState.value, isNull);

        verify(
          () => mockRepository.signInWithEmailAndPassword(
            validEmail,
            'wrongpassword',
          ),
        ).called(1);
      },
    );

    test(
      'LoginUsecase + LoginProvider integration test - email validation',
      () async {
        // Arrange
        final mockRepository = MockUserRepository();
        final loginUsecase = LoginUsecase(mockRepository);

        final container = ProviderContainer(
          overrides: [
            loginUsecaseProvider.overrideWithValue(loginUsecase),
          ],
        );

        // Act - try to login with invalid email
        await container
            .read(loginProvider.notifier)
            .login(invalidEmail, validPassword);
        final loginState = container.read(loginProvider);

        // Assert
        expect(loginState.hasError, isTrue);
        expect(loginState.error.toString(), contains('Invalid email format'));

        // Verify that repository was never called due to validation failure
        verifyNever(
          () => mockRepository.signInWithEmailAndPassword(any(), any()),
        );
      },
    );

    test(
      'LoginUsecase + LoginProvider integration test - password validation',
      () async {
        // Arrange
        final mockRepository = MockUserRepository();
        final loginUsecase = LoginUsecase(mockRepository);

        final container = ProviderContainer(
          overrides: [
            loginUsecaseProvider.overrideWithValue(loginUsecase),
          ],
        );

        // Act - try to login with short password
        await container
            .read(loginProvider.notifier)
            .login(validEmail, shortPassword);
        final loginState = container.read(loginProvider);

        // Assert
        expect(loginState.hasError, isTrue);
        expect(
          loginState.error.toString(),
          contains('Password must be at least 6 characters'),
        );

        // Verify that repository was never called due to validation failure
        verifyNever(
          () => mockRepository.signInWithEmailAndPassword(any(), any()),
        );
      },
    );

    test(
      'LoginUsecase + LoginProvider integration test - empty fields validation',
      () async {
        // Arrange
        final mockRepository = MockUserRepository();
        final loginUsecase = LoginUsecase(mockRepository);

        final container = ProviderContainer(
          overrides: [
            loginUsecaseProvider.overrideWithValue(loginUsecase),
          ],
        );

        // Test empty email
        await container
            .read(loginProvider.notifier)
            .login(emptyEmail, validPassword);
        var loginState = container.read(loginProvider);
        expect(loginState.hasError, isTrue);
        expect(loginState.error.toString(), contains('Email cannot be empty'));

        // Test empty password
        await container
            .read(loginProvider.notifier)
            .login(validEmail, emptyPassword);
        loginState = container.read(loginProvider);
        expect(loginState.hasError, isTrue);
        expect(
          loginState.error.toString(),
          contains('Password cannot be empty'),
        );

        // Verify that repository was never called due to validation failures
        verifyNever(
          () => mockRepository.signInWithEmailAndPassword(any(), any()),
        );
      },
    );

    test(
      'LoginUsecase + LoginProvider integration test - exception handling',
      () async {
        // Arrange
        final mockRepository = MockUserRepository();
        final loginUsecase = LoginUsecase(mockRepository);

        when(
          () => mockRepository.signInWithEmailAndPassword(
            validEmail,
            validPassword,
          ),
        ).thenThrow(Exception('Network error'));

        final container = ProviderContainer(
          overrides: [
            loginUsecaseProvider.overrideWithValue(loginUsecase),
          ],
        );

        // Act
        await container
            .read(loginProvider.notifier)
            .login(validEmail, validPassword);
        final loginState = container.read(loginProvider);

        // Assert
        expect(loginState.isLoading, isFalse);
        expect(loginState.hasError, isTrue);
        expect(loginState.error, isNotNull);
        expect(loginState.error.toString(), contains('Network error'));

        verify(
          () => mockRepository.signInWithEmailAndPassword(
            validEmail,
            validPassword,
          ),
        ).called(1);
      },
    );

    test(
      'LoginUsecase + LoginProvider integration test - state transitions',
      () async {
        // Arrange
        final mockRepository = MockUserRepository();
        final loginUsecase = LoginUsecase(mockRepository);

        // Create a slow response to test state transitions
        final slowFuture = Future<AuthResult>.delayed(
          const Duration(milliseconds: 100),
          () => successAuthResult,
        );

        when(
          () => mockRepository.signInWithEmailAndPassword(
            validEmail,
            validPassword,
          ),
        ).thenAnswer((_) => slowFuture);

        final container = ProviderContainer(
          overrides: [
            loginUsecaseProvider.overrideWithValue(loginUsecase),
          ],
        );

        // Test initial state
        var loginState = container.read(loginProvider);
        expect(loginState.isLoading, isTrue); // Initial loading state

        // Act - start login
        final future = container
            .read(loginProvider.notifier)
            .login(validEmail, validPassword);

        // Check loading state during authentication
        loginState = container.read(loginProvider);
        expect(loginState.isLoading, isTrue);

        // Wait for completion
        await future;
        loginState = container.read(loginProvider);

        // Assert final state
        expect(loginState.isLoading, isFalse);
        expect(loginState.hasError, isFalse);
        expect(loginState.value, isNotNull);
      },
    );
  });

  group('Login UI + Provider Integration Tests', () {
    // Helper function to create LoginPage widget with mocked provider
    Widget createLoginPageWithMocks(ProviderContainer container) {
      return UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: LoginPage(),
        ),
      );
    }

    testWidgets(
      'LoginPage + LoginProvider integration test - successful login flow',
      (
        WidgetTester tester,
      ) async {
        // Arrange
        final mockLoginUsecase = MockLoginUsecase();

        when(
          () => mockLoginUsecase.call(
            email: validEmail,
            password: validPassword,
          ),
        ).thenAnswer((_) async => successAuthResult);

        final container = ProviderContainer(
          overrides: [
            loginUsecaseProvider.overrideWithValue(mockLoginUsecase),
          ],
        );

        await tester.pumpWidget(createLoginPageWithMocks(container));

        // Act - enter valid credentials and submit
        await tester.enterText(find.bySemanticsLabel('Email'), validEmail);
        await tester.enterText(
          find.bySemanticsLabel('Password'),
          validPassword,
        );
        await tester.tap(find.text('Login'));
        await tester.pump();

        // Wait for async operation to complete
        await tester.pump(const Duration(milliseconds: 300));

        // Assert - check that login was called
        verify(
          () => mockLoginUsecase.call(
            email: validEmail,
            password: validPassword,
          ),
        ).called(1);

        // Check that provider state is updated
        final loginState = container.read(loginProvider);
        expect(loginState.isLoading, isFalse);
        expect(loginState.hasError, isFalse);
        expect(loginState.value, isNotNull);
      },
    );

    testWidgets(
      'LoginPage + LoginProvider integration test - error handling flow',
      (
        WidgetTester tester,
      ) async {
        // Arrange
        final mockLoginUsecase = MockLoginUsecase();

        when(
          () => mockLoginUsecase.call(
            email: validEmail,
            password: 'wrongpassword',
          ),
        ).thenAnswer((_) async => failureAuthResult);

        final container = ProviderContainer(
          overrides: [
            loginUsecaseProvider.overrideWithValue(mockLoginUsecase),
          ],
        );

        await tester.pumpWidget(createLoginPageWithMocks(container));

        // Act - enter invalid credentials and submit
        await tester.enterText(find.bySemanticsLabel('Email'), validEmail);
        await tester.enterText(
          find.bySemanticsLabel('Password'),
          'wrongpassword',
        );
        await tester.tap(find.text('Login'));
        await tester.pump();

        // Wait for async operation to complete
        await tester.pump(const Duration(milliseconds: 300));

        // Assert - check that login was called
        verify(
          () => mockLoginUsecase.call(
            email: validEmail,
            password: 'wrongpassword',
          ),
        ).called(1);

        // Check that provider state shows error
        final loginState = container.read(loginProvider);
        expect(loginState.isLoading, isFalse);
        expect(loginState.hasError, isTrue);

        // Check that error message is displayed in UI
        expect(find.text('Invalid credentials'), findsOneWidget);
      },
    );

    testWidgets(
      'LoginPage + LoginProvider integration test - validation errors',
      (
        WidgetTester tester,
      ) async {
        // Arrange
        final mockLoginUsecase = MockLoginUsecase();

        final container = ProviderContainer(
          overrides: [
            loginUsecaseProvider.overrideWithValue(mockLoginUsecase),
          ],
        );

        await tester.pumpWidget(createLoginPageWithMocks(container));

        // Test invalid email
        await tester.enterText(find.bySemanticsLabel('Email'), invalidEmail);
        await tester.enterText(
          find.bySemanticsLabel('Password'),
          validPassword,
        );
        await tester.tap(find.text('Login'));
        await tester.pump();

        // Assert - should show validation error
        expect(find.text('Please enter a valid email address'), findsOneWidget);

        // Test short password
        await tester.enterText(find.bySemanticsLabel('Email'), validEmail);
        await tester.enterText(
          find.bySemanticsLabel('Password'),
          shortPassword,
        );
        await tester.tap(find.text('Login'));
        await tester.pump();

        // Assert - should show validation error
        expect(
          find.text('Password must be at least 6 characters'),
          findsOneWidget,
        );

        // Verify that usecase was never called due to validation failures
        verifyNever(
          () => mockLoginUsecase.call(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        );
      },
    );

    testWidgets('LoginPage + LoginProvider integration test - loading state', (
      WidgetTester tester,
    ) async {
      // Arrange
      final mockLoginUsecase = MockLoginUsecase();

      // Create a slow response to test loading state
      final slowFuture = Future<AuthResult>.delayed(
        const Duration(milliseconds: 200),
        () => successAuthResult,
      );

      when(
        () => mockLoginUsecase.call(
          email: validEmail,
          password: validPassword,
        ),
      ).thenAnswer((_) => slowFuture);

      final container = ProviderContainer(
        overrides: [
          loginUsecaseProvider.overrideWithValue(mockLoginUsecase),
        ],
      );

      await tester.pumpWidget(createLoginPageWithMocks(container));

      // Act - enter valid credentials and submit
      await tester.enterText(find.bySemanticsLabel('Email'), validEmail);
      await tester.enterText(find.bySemanticsLabel('Password'), validPassword);
      await tester.tap(find.text('Login'));
      await tester.pump();

      // Check loading state immediately after login
      final loadingState = container.read(loginProvider);
      expect(loadingState.isLoading, isTrue);

      // Wait for completion
      await tester.pump(const Duration(milliseconds: 250));

      // Check final state
      final finalState = container.read(loginProvider);
      expect(finalState.isLoading, isFalse);
      expect(finalState.hasError, isFalse);
      expect(finalState.value, isNotNull);
    });
  });

  group('Complete Authentication Flow Tests', () {
    test('Complete authentication flow - success scenario', () async {
      // Arrange
      final mockRepository = MockUserRepository();
      final loginUsecase = LoginUsecase(mockRepository);

      when(
        () => mockRepository.signInWithEmailAndPassword(
          validEmail,
          validPassword,
        ),
      ).thenAnswer((_) async => successAuthResult);

      final container = ProviderContainer(
        overrides: [
          loginUsecaseProvider.overrideWithValue(loginUsecase),
        ],
      );

      // Act - simulate complete login flow
      final result = await container
          .read(loginProvider.notifier)
          .login(validEmail, validPassword);

      // Assert
      expect(result, isNotNull);
      expect(result?.id, 'user123');
      expect(result?.email, validEmail);

      final loginState = container.read(loginProvider);
      expect(loginState.isLoading, isFalse);
      expect(loginState.hasError, isFalse);
      expect(loginState.value, isNotNull);
      expect(loginState.value?.id, 'user123');
      expect(loginState.value?.email, validEmail);
      expect(loginState.value?.authMethod, 'email');
      expect(loginState.value?.syncEnabled, isTrue);

      verify(
        () => mockRepository.signInWithEmailAndPassword(
          validEmail,
          validPassword,
        ),
      ).called(1);
    });

    test('Complete authentication flow - error scenario', () async {
      // Arrange
      final mockRepository = MockUserRepository();
      final loginUsecase = LoginUsecase(mockRepository);

      when(
        () => mockRepository.signInWithEmailAndPassword(
          validEmail,
          'wrongpassword',
        ),
      ).thenAnswer((_) async => failureAuthResult);

      final container = ProviderContainer(
        overrides: [
          loginUsecaseProvider.overrideWithValue(loginUsecase),
        ],
      );

      // Act - simulate failed login flow
      final result = await container
          .read(loginProvider.notifier)
          .login(validEmail, 'wrongpassword');

      // Assert
      expect(result, isNull);

      final loginState = container.read(loginProvider);
      expect(loginState.isLoading, isFalse);
      expect(loginState.hasError, isTrue);
      expect(loginState.error, isNotNull);
      expect(loginState.error.toString(), contains('Invalid credentials'));
      expect(loginState.value, isNull);

      verify(
        () => mockRepository.signInWithEmailAndPassword(
          validEmail,
          'wrongpassword',
        ),
      ).called(1);
    });

    test('Complete authentication flow - validation failure', () async {
      // Arrange
      final mockRepository = MockUserRepository();
      final loginUsecase = LoginUsecase(mockRepository);

      final container = ProviderContainer(
        overrides: [
          loginUsecaseProvider.overrideWithValue(loginUsecase),
        ],
      );

      // Act - simulate validation failure
      final result = await container
          .read(loginProvider.notifier)
          .login(invalidEmail, validPassword);

      // Assert
      expect(result, isNull);

      final loginState = container.read(loginProvider);
      expect(loginState.isLoading, isFalse);
      expect(loginState.hasError, isTrue);
      expect(loginState.error, isNotNull);
      expect(loginState.error.toString(), contains('Invalid email format'));
      expect(loginState.value, isNull);

      // Verify repository was never called
      verifyNever(
        () => mockRepository.signInWithEmailAndPassword(any(), any()),
      );
    });
  });

  group('Error Handling Across All Layers Tests', () {
    test('Error handling - repository throws exception', () async {
      // Arrange
      final mockRepository = MockUserRepository();
      final loginUsecase = LoginUsecase(mockRepository);

      when(
        () => mockRepository.signInWithEmailAndPassword(
          validEmail,
          validPassword,
        ),
      ).thenThrow(Exception('Database connection failed'));

      final container = ProviderContainer(
        overrides: [
          loginUsecaseProvider.overrideWithValue(loginUsecase),
        ],
      );

      // Act
      final result = await container
          .read(loginProvider.notifier)
          .login(validEmail, validPassword);

      // Assert
      expect(result, isNull);

      final loginState = container.read(loginProvider);
      expect(loginState.isLoading, isFalse);
      expect(loginState.hasError, isTrue);
      expect(loginState.error, isNotNull);
      expect(
        loginState.error.toString(),
        contains('Database connection failed'),
      );
      expect(loginState.value, isNull);
    });

    test('Error handling - usecase validation errors', () async {
      // Arrange
      final mockRepository = MockUserRepository();
      final loginUsecase = LoginUsecase(mockRepository);

      final container = ProviderContainer(
        overrides: [
          loginUsecaseProvider.overrideWithValue(loginUsecase),
        ],
      );

      // Test empty email
      var result = await container
          .read(loginProvider.notifier)
          .login(emptyEmail, validPassword);

      var loginState = container.read(loginProvider);
      expect(loginState.hasError, isTrue);
      expect(loginState.error.toString(), contains('Email cannot be empty'));

      // Test empty password
      result = await container
          .read(loginProvider.notifier)
          .login(validEmail, emptyPassword);

      loginState = container.read(loginProvider);
      expect(loginState.hasError, isTrue);
      expect(loginState.error.toString(), contains('Password cannot be empty'));

      // Test short password
      result = await container
          .read(loginProvider.notifier)
          .login(validEmail, shortPassword);

      loginState = container.read(loginProvider);
      expect(loginState.hasError, isTrue);
      expect(
        loginState.error.toString(),
        contains('Password must be at least 6 characters'),
      );

      // Verify repository was never called
      verifyNever(
        () => mockRepository.signInWithEmailAndPassword(any(), any()),
      );
    });

    test('Error handling - null auth result', () async {
      // Arrange
      final mockRepository = MockUserRepository();
      final loginUsecase = LoginUsecase(mockRepository);

      when(
        () => mockRepository.signInWithEmailAndPassword(
          validEmail,
          validPassword,
        ),
      ).thenAnswer(
        (_) async =>
            const AuthResult(success: false, errorMessage: 'Null result'),
      );

      final container = ProviderContainer(
        overrides: [
          loginUsecaseProvider.overrideWithValue(loginUsecase),
        ],
      );

      // Act
      final result = await container
          .read(loginProvider.notifier)
          .login(validEmail, validPassword);

      // Assert
      expect(result, isNull);

      final loginState = container.read(loginProvider);
      expect(loginState.isLoading, isFalse);
      expect(loginState.hasError, isTrue);
      expect(loginState.error, isNotNull);
      expect(
        loginState.error.toString(),
        contains('Null result'),
      );
      expect(loginState.value, isNull);
    });
  });

  group('State Management and Transitions Tests', () {
    test('State management - initial loading state', () {
      // Arrange
      final mockLoginUsecase = MockLoginUsecase();

      final container = ProviderContainer(
        overrides: [
          loginUsecaseProvider.overrideWithValue(mockLoginUsecase),
        ],
      );

      // Act
      final loginState = container.read(loginProvider);

      // Assert
      expect(loginState.isLoading, isTrue);
      expect(loginState.value, isNull);
      expect(loginState.hasError, isFalse);
    });

    test('State management - loading during authentication', () async {
      // Arrange
      final mockLoginUsecase = MockLoginUsecase();

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

      final container = ProviderContainer(
        overrides: [
          loginUsecaseProvider.overrideWithValue(mockLoginUsecase),
        ],
      );

      // Act - start login
      final future = container
          .read(loginProvider.notifier)
          .login(validEmail, validPassword);

      // Check state during authentication
      final loadingState = container.read(loginProvider);

      // Assert loading state
      expect(loadingState.isLoading, isTrue);
      expect(loadingState.value, isNull);
      expect(loadingState.hasError, isFalse);

      // Wait for completion
      await future;

      // Check final state
      final finalState = container.read(loginProvider);
      expect(finalState.isLoading, isFalse);
      expect(finalState.hasError, isFalse);
      expect(finalState.value, isNotNull);
    });

    test('State management - error state persistence', () async {
      // Arrange
      final mockLoginUsecase = MockLoginUsecase();

      when(
        () => mockLoginUsecase.call(
          email: validEmail,
          password: 'wrongpassword',
        ),
      ).thenAnswer((_) async => failureAuthResult);

      final container = ProviderContainer(
        overrides: [
          loginUsecaseProvider.overrideWithValue(mockLoginUsecase),
        ],
      );

      // Act - first failed login
      await container
          .read(loginProvider.notifier)
          .login(validEmail, 'wrongpassword');

      // Check error state
      var loginState = container.read(loginProvider);
      expect(loginState.hasError, isTrue);
      expect(loginState.error, isNotNull);

      // Act - second failed login
      await container
          .read(loginProvider.notifier)
          .login(validEmail, 'wrongpassword');

      // Check error state after second attempt
      loginState = container.read(loginProvider);
      expect(loginState.hasError, isTrue);
      expect(loginState.error, isNotNull);
    });

    test('State management - successful state after error', () async {
      // Arrange
      final mockLoginUsecase = MockLoginUsecase();

      when(
        () => mockLoginUsecase.call(
          email: validEmail,
          password: 'wrongpassword',
        ),
      ).thenAnswer((_) async => failureAuthResult);

      when(
        () => mockLoginUsecase.call(
          email: validEmail,
          password: validPassword,
        ),
      ).thenAnswer((_) async => successAuthResult);

      final container = ProviderContainer(
        overrides: [
          loginUsecaseProvider.overrideWithValue(mockLoginUsecase),
        ],
      );

      // Act - first failed login
      await container
          .read(loginProvider.notifier)
          .login(validEmail, 'wrongpassword');

      // Check error state
      var loginState = container.read(loginProvider);
      expect(loginState.hasError, isTrue);

      // Act - successful login
      await container
          .read(loginProvider.notifier)
          .login(validEmail, validPassword);

      // Check success state
      loginState = container.read(loginProvider);
      expect(loginState.hasError, isFalse);
      expect(loginState.value, isNotNull);
    });

    test('State management - state reset on new login attempt', () async {
      // Arrange
      final mockLoginUsecase = MockLoginUsecase();

      when(
        () => mockLoginUsecase.call(
          email: validEmail,
          password: validPassword,
        ),
      ).thenAnswer((_) async => successAuthResult);

      final container = ProviderContainer(
        overrides: [
          loginUsecaseProvider.overrideWithValue(mockLoginUsecase),
        ],
      );

      // Act - first successful login
      await container
          .read(loginProvider.notifier)
          .login(validEmail, validPassword);

      // Check success state
      var loginState = container.read(loginProvider);
      expect(loginState.value, isNotNull);

      // Act - second login attempt (should reset to loading state)
      final future = container
          .read(loginProvider.notifier)
          .login(validEmail, validPassword);

      // Check loading state during second attempt
      loginState = container.read(loginProvider);
      expect(loginState.isLoading, isTrue);

      // Wait for completion
      await future;

      // Check final state
      loginState = container.read(loginProvider);
      expect(loginState.isLoading, isFalse);
      expect(loginState.value, isNotNull);
    });
  });
}
