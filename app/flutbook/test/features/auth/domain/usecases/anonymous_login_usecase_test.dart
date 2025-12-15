import 'package:flutbook/features/auth/domain/repositories/user_repository.dart';
import 'package:flutbook/features/auth/domain/usecases/anonymous_login_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock class for UserRepository
class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late AnonymousLoginUsecase anonymousLoginUsecase;
  late MockUserRepository mockRepository;

  setUp(() {
    mockRepository = MockUserRepository();
    anonymousLoginUsecase = AnonymousLoginUsecase(mockRepository);
  });

  const successAuthResult = AuthResult(
    success: true,
    userId: 'anonymous-user-id-123',
  );

  const failureAuthResult = AuthResult(
    success: false,
    errorMessage: 'Anonymous login failed',
  );

  group('AnonymousLoginUsecase', () {
    test('should return AuthResult with user profile on successful anonymous login', () async {
      // Arrange
      when(
        () => mockRepository.anonymousSignIn(),
      ).thenAnswer((_) async => successAuthResult);

      // Act
      final result = await anonymousLoginUsecase.call();

      // Assert
      expect(result.success, true);
      expect(result.userId, 'anonymous-user-id-123');
      expect(result.errorMessage, isNull);
      verify(
        () => mockRepository.anonymousSignIn(),
      ).called(1);
    });

    test('should return error message on failed anonymous login', () async {
      // Arrange
      when(
        () => mockRepository.anonymousSignIn(),
      ).thenAnswer((_) async => failureAuthResult);

      // Act
      final result = await anonymousLoginUsecase.call();

      // Assert
      expect(result.success, false);
      expect(result.errorMessage, 'Anonymous login failed');
      expect(result.userId, isNull);
      verify(
        () => mockRepository.anonymousSignIn(),
      ).called(1);
    });

    test('should not require any parameters for anonymous login', () async {
      // Arrange - No parameters needed for anonymous login
      when(
        () => mockRepository.anonymousSignIn(),
      ).thenAnswer((_) async => successAuthResult);

      // Act - Calling without any parameters should work
      final result = await anonymousLoginUsecase.call();

      // Assert - Success should be returned
      expect(result.success, true);
      verify(
        () => mockRepository.anonymousSignIn(),
      ).called(1);
    });

    test('should handle repository exceptions gracefully', () async {
      // Arrange
      when(
        () => mockRepository.anonymousSignIn(),
      ).thenThrow(Exception('Network error'));

      // Act
      final result = await anonymousLoginUsecase.call();

      // Assert
      expect(result.success, false);
      expect(result.errorMessage, contains('Anonymous login failed'));
      expect(result.userId, isNull);
    });

    test('should return valid AuthResult when repository returns success', () async {
      // Arrange
      when(
        () => mockRepository.anonymousSignIn(),
      ).thenAnswer((_) async => const AuthResult(
        success: true,
        userId: 'some-anonymous-id',
        errorMessage: null,
      ));

      // Act
      final result = await anonymousLoginUsecase.call();

      // Assert
      expect(result.success, true);
      expect(result.userId, 'some-anonymous-id');
      expect(result.errorMessage, isNull);
    });
  });
}