import 'package:flutbook/features/auth/domain/repositories/user_repository.dart';
import 'package:flutbook/features/auth/domain/usecases/logout_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock class for UserRepository
class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late LogoutUsecase logoutUsecase;
  late MockUserRepository mockRepository;

  setUp(() {
    mockRepository = MockUserRepository();
    logoutUsecase = LogoutUsecase(mockRepository);
  });

  group('LogoutUsecase', () {
    test('should call repository signOut method', () async {
      // Arrange
      when(() => mockRepository.signOut()).thenAnswer((_) async {});

      // Act
      await logoutUsecase.call();

      // Assert
      verify(() => mockRepository.signOut()).called(1);
    });

    test(
      'should complete successfully even when repository throws exception',
      () async {
        // Arrange
        when(
          () => mockRepository.signOut(),
        ).thenThrow(Exception('Logout error'));

        // Act & Assert - should not throw
        expect(() async => logoutUsecase.call(), returnsNormally);

        // Verify that signOut was still called
        verify(() => mockRepository.signOut()).called(1);
      },
    );

    test('should handle various error types gracefully', () async {
      final errorTypes = [
        Exception('Generic error'),
        Error(),
        ArgumentError('Invalid argument'),
        StateError('Invalid state'),
        UnimplementedError('Not implemented'),
      ];

      for (final error in errorTypes) {
        // Arrange
        when(() => mockRepository.signOut()).thenThrow(error);

        // Act & Assert - should not throw
        expect(() async => logoutUsecase.call(), returnsNormally);

        // Verify that signOut was still called
        verify(() => mockRepository.signOut()).called(1);

        // Reset mock for next iteration
        reset(mockRepository);
        when(() => mockRepository.signOut()).thenAnswer((_) async {});
      }
    });

    test('should complete quickly for successful logout', () async {
      // Arrange
      when(() => mockRepository.signOut()).thenAnswer((_) async {});

      // Act
      final stopwatch = Stopwatch()..start();
      await logoutUsecase.call();
      stopwatch.stop();

      // Assert
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      verify(() => mockRepository.signOut()).called(1);
    });
  });
}
