import 'package:flutbook/features/auth/domain/entities/auth_result.dart';
import 'package:flutbook/features/auth/domain/entities/user_profile.dart';
import 'package:flutbook/features/auth/domain/repositories/user_repository.dart';
import 'package:flutbook/features/auth/domain/usecases/google_signin_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock class for UserRepository
class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late GoogleSigninUsecase googleSigninUsecase;
  late MockUserRepository mockRepository;

  setUp(() {
    mockRepository = MockUserRepository();
    googleSigninUsecase = GoogleSigninUsecase(mockRepository);
  });

  // Test data
  const successAuthResult = AuthResult(
    success: true,
    userId: 'google-user-123',
  );

  const failureAuthResult = AuthResult(
    success: false,
    errorMessage: 'Google sign-in failed',
  );

  group('GoogleSigninUsecase', () {
    test('should return successful AuthResult on Google sign-in', () async {
      // Arrange
      when(
        () => mockRepository.signInWithGoogle(),
      ).thenAnswer((_) async => successAuthResult);

      // Act
      final result = await googleSigninUsecase.call();

      // Assert
      expect(result.success, isTrue);
      expect(result.userId, 'google-user-123');
      expect(result.errorMessage, isNull);
      verify(() => mockRepository.signInWithGoogle()).called(1);
    });

    test('should return failed AuthResult when Google sign-in fails', () async {
      // Arrange
      when(
        () => mockRepository.signInWithGoogle(),
      ).thenAnswer((_) async => failureAuthResult);

      // Act
      final result = await googleSigninUsecase.call();

      // Assert
      expect(result.success, isFalse);
      expect(result.errorMessage, 'Google sign-in failed');
      expect(result.userId, isNull);
      verify(() => mockRepository.signInWithGoogle()).called(1);
    });

    test(
      'should return failed AuthResult when repository throws exception',
      () async {
        // Arrange
        when(
          () => mockRepository.signInWithGoogle(),
        ).thenThrow(Exception('Google sign-in error'));

        // Act
        final result = await googleSigninUsecase.call();

        // Assert
        expect(result.success, isFalse);
        expect(result.errorMessage, contains('Google sign-in error'));
        expect(result.userId, isNull);
        verify(() => mockRepository.signInWithGoogle()).called(1);
      },
    );

    test('should handle various Google sign-in error scenarios', () async {
      final errorScenarios = [
        'Google sign-in was cancelled by user',
        'Network error during Google sign-in',
        'Google authentication failed',
        'Invalid Google credentials',
      ];

      for (final errorMessage in errorScenarios) {
        // Arrange
        final errorResult = AuthResult(
          success: false,
          errorMessage: errorMessage,
        );
        when(
          () => mockRepository.signInWithGoogle(),
        ).thenAnswer((_) async => errorResult);

        // Act
        final result = await googleSigninUsecase.call();

        // Assert
        expect(result.success, isFalse);
        expect(result.errorMessage, errorMessage);
        verify(() => mockRepository.signInWithGoogle()).called(1);

        // Reset mock for next iteration
        reset(mockRepository);
        when(
          () => mockRepository.signInWithGoogle(),
        ).thenAnswer((_) async => successAuthResult);
      }
    });

    test('should return AuthResult with user details when available', () async {
      // Arrange
      final userProfile = UserProfile(
        id: 'google-user-123',
        email: 'google@example.com',
        authMethod: 'google_oauth',
        syncEnabled: true,
      );
      final authResultWithUser = AuthResult(
        success: true,
        userId: 'google-user-123',
        user: userProfile,
      );
      when(
        () => mockRepository.signInWithGoogle(),
      ).thenAnswer((_) async => authResultWithUser);

      // Act
      final result = await googleSigninUsecase.call();

      // Assert
      expect(result.success, isTrue);
      expect(result.userId, 'google-user-123');
      expect(result.user, isNotNull);
      expect(result.user?.authMethod, 'google_oauth');
      verify(() => mockRepository.signInWithGoogle()).called(1);
    });
  });
}
