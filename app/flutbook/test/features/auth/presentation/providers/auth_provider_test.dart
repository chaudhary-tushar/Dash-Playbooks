import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutbook/features/auth/domain/entities/auth_result.dart';
import 'package:flutbook/features/auth/domain/entities/user_profile.dart';
import 'package:flutbook/features/auth/domain/repositories/user_repository.dart';
import 'package:flutbook/features/auth/domain/usecases/anonymous_login_usecase.dart';
import 'package:flutbook/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:flutbook/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutbook/features/auth/domain/usecases/logout_usecase.dart';
import 'package:flutbook/features/auth/presentation/providers/auth_provider.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes for testing
class MockUserRepository extends Mock implements UserRepository {}

class MockLoginUsecase extends Mock implements LoginUsecase {}

class MockAnonymousLoginUsecase extends Mock implements AnonymousLoginUsecase {}

class MockLogoutUsecase extends Mock implements LogoutUsecase {}

class MockGetCurrentUserUsecase extends Mock implements GetCurrentUserUsecase {}

void main() {
  late MockUserRepository mockUserRepository;
  late MockLoginUsecase mockLoginUsecase;
  late MockAnonymousLoginUsecase mockAnonymousLoginUsecase;
  late MockLogoutUsecase mockLogoutUsecase;
  late MockGetCurrentUserUsecase mockGetCurrentUserUsecase;
  late ProviderContainer container;

  // Test user profile
  final testUser = UserProfile(
    id: 'test-user-id',
    email: 'test@example.com',
    displayName: 'Test User',
    authMethod: 'email_password',
    syncEnabled: true,
  );

  setUp(() {
    mockUserRepository = MockUserRepository();
    mockLoginUsecase = MockLoginUsecase();
    mockAnonymousLoginUsecase = MockAnonymousLoginUsecase();
    mockLogoutUsecase = MockLogoutUsecase();
    mockGetCurrentUserUsecase = MockGetCurrentUserUsecase();

    container = ProviderContainer(
      overrides: [
        userRepositoryProvider.overrideWithValue(mockUserRepository),
        loginUsecaseProvider.overrideWithValue(mockLoginUsecase),
        anonymousLoginUsecaseProvider.overrideWithValue(mockAnonymousLoginUsecase),
        logoutUsecaseProvider.overrideWithValue(mockLogoutUsecase),
        getCurrentUserUsecaseProvider.overrideWithValue(mockGetCurrentUserUsecase),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('AuthNotifier - Initial State', () {
    test('should initialize with loading state', () {
      final authNotifier = AuthNotifier();
      final container = ProviderContainer(
        overrides: [
          userRepositoryProvider.overrideWithValue(mockUserRepository),
          loginUsecaseProvider.overrideWithValue(mockLoginUsecase),
          anonymousLoginUsecaseProvider.overrideWithValue(mockAnonymousLoginUsecase),
          logoutUsecaseProvider.overrideWithValue(mockLogoutUsecase),
          getCurrentUserUsecaseProvider.overrideWithValue(mockGetCurrentUserUsecase),
        ],
        child: const Placeholder(),
      );

      final authState = container.read(authProvider.notifier).build();
      expect(authState.isLoading, true);
      expect(authState.isAuthenticated, false);
      container.dispose();
    });
  });

  group('AuthNotifier - Login', () {
    test('should update state on successful login', () async {
      const email = 'test@example.com';
      const password = 'password123';

      when(() => mockLoginUsecase(email: email, password: password))
          .thenAnswer((_) async => const AuthResult(success: true, userId: 'test-id'));

      when(() => mockGetCurrentUserUsecase()).thenAnswer((_) async => testUser);

      final authNotifier = container.read(authProvider.notifier);
      await authNotifier.login(email, password);

      final state = container.read(authProvider);

      expect(state.isAuthenticated, true);
      expect(state.userProfile, testUser);
      expect(state.isLoading, false);
      expect(state.errorMessage, isNull);

      verify(() => mockLoginUsecase(email: email, password: password)).called(1);
      verify(() => mockGetCurrentUserUsecase()).called(1);
    });

    test('should update state with error on failed login', () async {
      const email = 'test@example.com';
      const password = 'wrong-password';

      when(() => mockLoginUsecase(email: email, password: password))
          .thenAnswer((_) async => const AuthResult(
                success: false,
                errorMessage: 'Invalid credentials',
              ));

      final authNotifier = container.read(authProvider.notifier);
      await authNotifier.login(email, password);

      final state = container.read(authProvider);

      expect(state.isAuthenticated, false);
      expect(state.userProfile, isNull);
      expect(state.isLoading, false);
      expect(state.errorMessage, 'Invalid credentials');

      verify(() => mockLoginUsecase(email: email, password: password)).called(1);
      verifyNever(() => mockGetCurrentUserUsecase());
    });
  });

  group('AuthNotifier - Anonymous Login', () {
    test('should update state on successful anonymous login', () async {
      when(() => mockAnonymousLoginUsecase())
          .thenAnswer((_) async => const AuthResult(success: true, userId: 'anon-id'));

      when(() => mockGetCurrentUserUsecase()).thenAnswer((_) async => testUser);

      final authNotifier = container.read(authProvider.notifier);
      await authNotifier.loginAnonymously();

      final state = container.read(authProvider);

      expect(state.isAuthenticated, true);
      expect(state.userProfile, testUser);
      expect(state.isLoading, false);
      expect(state.errorMessage, isNull);

      verify(() => mockAnonymousLoginUsecase()).called(1);
      verify(() => mockGetCurrentUserUsecase()).called(1);
    });

    test('should update state with error on failed anonymous login', () async {
      when(() => mockAnonymousLoginUsecase())
          .thenAnswer((_) async => const AuthResult(
                success: false,
                errorMessage: 'Anonymous login failed',
              ));

      final authNotifier = container.read(authProvider.notifier);
      await authNotifier.loginAnonymously();

      final state = container.read(authProvider);

      expect(state.isAuthenticated, false);
      expect(state.userProfile, isNull);
      expect(state.isLoading, false);
      expect(state.errorMessage, 'Anonymous login failed');

      verify(() => mockAnonymousLoginUsecase()).called(1);
      verifyNever(() => mockGetCurrentUserUsecase());
    });
  });

  group('AuthNotifier - Logout', () {
    test('should update state on successful logout', () async {
      when(() => mockLogoutUsecase()).thenAnswer((_) async => Future.value());

      final authNotifier = container.read(authProvider.notifier);
      await authNotifier.logout();

      final state = container.read(authProvider);

      expect(state.isAuthenticated, false);
      expect(state.userProfile, isNull);
      expect(state.isLoading, false);
      expect(state.errorMessage, isNull);

      verify(() => mockLogoutUsecase()).called(1);
    });

    test('should update state with error on failed logout', () async {
      when(() => mockLogoutUsecase()).thenThrow(Exception('Network error'));

      final authNotifier = container.read(authProvider.notifier);
      await authNotifier.logout();

      final state = container.read(authProvider);

      expect(state.isAuthenticated, false);
      expect(state.userProfile, isNull);
      expect(state.isLoading, false);
      expect(state.errorMessage, 'Logout failed: Exception: Network error');

      verify(() => mockLogoutUsecase()).called(1);
    });
  });

  group('AuthNotifier - Get Current User and Auth Status', () {
    test('should return current user profile', () {
      final authNotifier = container.read(authProvider.notifier);
      // Manually set the state to have a user
      container
          .read(authProvider.notifier)
          .state = const AuthState(isAuthenticated: true, userProfile: null);

      final currentUser = authNotifier.getCurrentUser();
      expect(currentUser, isNull);
    });

    test('should return authentication status', () {
      final authNotifier = container.read(authProvider.notifier);
      // Manually set the state to be authenticated
      container
          .read(authProvider.notifier)
          .state = const AuthState(isAuthenticated: true);

      final isAuthenticated = authNotifier.isAuthenticated();
      expect(isAuthenticated, true);
    });
  });
}