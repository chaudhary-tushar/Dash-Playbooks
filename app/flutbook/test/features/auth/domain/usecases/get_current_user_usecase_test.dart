import 'package:flutbook/features/auth/domain/entities/user_profile.dart';
import 'package:flutbook/features/auth/domain/repositories/user_repository.dart';
import 'package:flutbook/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock class for UserRepository
class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late GetCurrentUserUsecase getCurrentUserUsecase;
  late MockUserRepository mockRepository;

  setUp(() {
    mockRepository = MockUserRepository();
    getCurrentUserUsecase = GetCurrentUserUsecase(mockRepository);
  });

  // Test data
  final validUserProfile = UserProfile(
    id: 'user123',
    email: 'test@example.com',
    displayName: 'Test User',
    authMethod: 'email_password',
    syncEnabled: true,
  );

  group('GetCurrentUserUsecase', () {
    test('should return UserProfile when user is authenticated', () async {
      // Arrange
      when(
        () => mockRepository.getCurrentUser(),
      ).thenAnswer((_) async => validUserProfile);

      // Act
      final result = await getCurrentUserUsecase.call();

      // Assert
      expect(result, equals(validUserProfile));
      verify(() => mockRepository.getCurrentUser()).called(1);
    });

    test('should return null when no user is authenticated', () async {
      // Arrange
      when(() => mockRepository.getCurrentUser()).thenAnswer((_) async => null);

      // Act
      final result = await getCurrentUserUsecase.call();

      // Assert
      expect(result, isNull);
      verify(() => mockRepository.getCurrentUser()).called(1);
    });

    test('should return null when repository throws exception', () async {
      // Arrange
      when(
        () => mockRepository.getCurrentUser(),
      ).thenThrow(Exception('Database error'));

      // Act
      final result = await getCurrentUserUsecase.call();

      // Assert
      expect(result, isNull);
      verify(() => mockRepository.getCurrentUser()).called(1);
    });

    test('should handle various error types gracefully', () async {
      // Arrange
      final errorTypes = [
        Exception('Generic error'),
        Error(),
        ArgumentError('Invalid argument'),
        StateError('Invalid state'),
      ];

      for (final error in errorTypes) {
        when(() => mockRepository.getCurrentUser()).thenThrow(error);

        // Act
        final result = await getCurrentUserUsecase.call();

        // Assert
        expect(result, isNull);
        verify(() => mockRepository.getCurrentUser()).called(1);

        // Reset mock for next iteration
        reset(mockRepository);
        when(
          () => mockRepository.getCurrentUser(),
        ).thenAnswer((_) async => validUserProfile);
      }
    });
  });
}
