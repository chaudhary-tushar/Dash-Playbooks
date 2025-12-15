import 'package:flutbook/features/auth/domain/repositories/user_repository.dart';
import 'package:flutbook/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock class for UserRepository
class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late LoginUsecase loginUsecase;
  late MockUserRepository mockRepository;

  setUp(() {
    mockRepository = MockUserRepository();
    loginUsecase = LoginUsecase(mockRepository);
  });

  // Test data
  const validEmail = 'test@example.com';
  const invalidEmail = 'invalid-email';
  const emptyEmail = '';
  const validPassword = 'password123';
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

  group('LoginUsecase', () {
    test('should return AuthResult with userId on successful login', () async {
      // Arrange
      when(
        () => mockRepository.signInWithEmailAndPassword(
          validEmail,
          validPassword,
        ),
      ).thenAnswer((_) async => successAuthResult);

      // Act
      final result = await loginUsecase.call(
        email: validEmail,
        password: validPassword,
      );

      // Assert
      expect(result.success, true);
      expect(result.userId, 'user123');
      expect(result.errorMessage, isNull);
      verify(
        () => mockRepository.signInWithEmailAndPassword(
          validEmail,
          validPassword,
        ),
      ).called(1);
    });

    test(
      'should return error message on failed login with wrong password',
      () async {
        // Arrange
        when(
          () => mockRepository.signInWithEmailAndPassword(
            validEmail,
            'wrongpassword',
          ),
        ).thenAnswer((_) async => failureAuthResult);

        // Act
        final result = await loginUsecase.call(
          email: validEmail,
          password: 'wrongpassword',
        );

        // Assert
        expect(result.success, false);
        expect(result.errorMessage, 'Invalid credentials');
        expect(result.userId, isNull);
        verify(
          () => mockRepository.signInWithEmailAndPassword(
            validEmail,
            'wrongpassword',
          ),
        ).called(1);
      },
    );

    test(
      'should return error for invalid email format (RFC 5322 validation)',
      () async {
        // Act
        final result = await loginUsecase.call(
          email: invalidEmail,
          password: validPassword,
        );

        // Assert
        expect(result.success, false);
        expect(result.errorMessage, 'Invalid email format');
        expect(result.userId, isNull);
        verifyNever(
          () => mockRepository.signInWithEmailAndPassword(any(), any()),
        );
      },
    );

    test('should return error for empty email', () async {
      // Act
      final result = await loginUsecase.call(
        email: emptyEmail,
        password: validPassword,
      );

      // Assert
      expect(result.success, false);
      expect(result.errorMessage, 'Email cannot be empty');
      expect(result.userId, isNull);
      verifyNever(
        () => mockRepository.signInWithEmailAndPassword(any(), any()),
      );
    });

    test('should return error for empty password', () async {
      // Act
      final result = await loginUsecase.call(
        email: validEmail,
        password: emptyPassword,
      );

      // Assert
      expect(result.success, false);
      expect(result.errorMessage, 'Password cannot be empty');
      expect(result.userId, isNull);
      verifyNever(
        () => mockRepository.signInWithEmailAndPassword(any(), any()),
      );
    });

    test(
      'should return error for short password (less than 6 characters)',
      () async {
        // Act
        final result = await loginUsecase.call(
          email: validEmail,
          password: shortPassword,
        );

        // Assert
        expect(result.success, false);
        expect(result.errorMessage, 'Password must be at least 6 characters');
        expect(result.userId, isNull);
        verifyNever(
          () => mockRepository.signInWithEmailAndPassword(any(), any()),
        );
      },
    );

    test(
      'should validate basic email format patterns',
      () async {
        // Test clearly invalid email formats
        final invalidEmails = [
          'plainaddress',
          '@missingusername.com',
        ];

        for (final email in invalidEmails) {
          final result = await loginUsecase.call(
            email: email,
            password: validPassword,
          );
          expect(result.success, false);
          expect(result.errorMessage, 'Invalid email format');
        }

        // Test that the standard valid email format passes validation
        // Setup mock for the valid email test
        when(
          () => mockRepository.signInWithEmailAndPassword(validEmail, validPassword),
        ).thenAnswer((_) async => successAuthResult);

        final result = await loginUsecase.call(
          email: validEmail,
          password: validPassword,
        );
        expect(result.success, true);
      },
    );
  });
}
