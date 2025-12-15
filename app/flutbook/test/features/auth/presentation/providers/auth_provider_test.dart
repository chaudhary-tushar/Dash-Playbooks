import 'package:flutbook/core/provider/providers.dart';
import 'package:flutbook/features/auth/domain/entities/auth_result.dart';
import 'package:flutbook/features/auth/domain/entities/user_profile.dart';
import 'package:flutbook/features/auth/domain/repositories/user_repository.dart';
import 'package:flutbook/features/auth/domain/usecases/anonymous_login_usecase.dart';
import 'package:flutbook/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:flutbook/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutbook/features/auth/domain/usecases/logout_usecase.dart';
import 'package:flutbook/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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
        anonymousLoginUsecaseProvider.overrideWithValue(
          mockAnonymousLoginUsecase,
        ),
        logoutUsecaseProvider.overrideWithValue(mockLogoutUsecase),
        getCurrentUserUsecaseProvider.overrideWithValue(
          mockGetCurrentUserUsecase,
        ),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('AuthNotifier - Initial State', () {
    test('should initialize with loading state', () {
      final container = ProviderContainer(
        overrides: [
          userRepositoryProvider.overrideWithValue(mockUserRepository),
          loginUsecaseProvider.overrideWithValue(mockLoginUsecase),
          anonymousLoginUsecaseProvider.overrideWithValue(
            mockAnonymousLoginUsecase,
          ),
          logoutUsecaseProvider.overrideWithValue(mockLogoutUsecase),
          getCurrentUserUsecaseProvider.overrideWithValue(
            mockGetCurrentUserUsecase,
          ),
        ],
        observers: [],
      );

      final authState = container.read(authProvider);
      expect(authState.isLoading, true);
      expect(authState.isAuthenticated, false);
      container.dispose();
    });
  });

  group('AuthNotifier - Login', () {
    test('should update state on successful login', () async {
      const email = 'test@example.com';
      const password = 'password123';

      when(() => mockLoginUsecase(email: email, password: password)).thenAnswer(
        (_) async => const AuthResult(success: true, userId: 'test-id'),
      );

      when(() => mockGetCurrentUserUsecase()).thenAnswer((_) async => testUser);

      final authNotifier = container.read(authProvider.notifier);
      await authNotifier.login(email, password);

      final state = container.read(authProvider);

      expect(state.isAuthenticated, true);
      expect(state.userProfile, testUser);
      expect(state.isLoading, false);
      expect(state.errorMessage, isNull);

      verify(
        () => mockLoginUsecase(email: email, password: password),
      ).called(1);
      verify(
        () => mockGetCurrentUserUsecase(),
      ).called(1); // Called once during login
    });

    test('should update state with error on failed login', () async {
      const email = 'test@example.com';
      const password = 'wrong-password';

      when(() => mockLoginUsecase(email: email, password: password)).thenAnswer(
        (_) async => const AuthResult(
          success: false,
          errorMessage: 'Invalid credentials',
        ),
      );

      final authNotifier = container.read(authProvider.notifier);
      await authNotifier.login(email, password);

      final state = container.read(authProvider);

      expect(state.isAuthenticated, false);
      expect(state.userProfile, isNull);
      expect(state.isLoading, false);
      expect(state.errorMessage, 'Invalid credentials');

      verify(
        () => mockLoginUsecase(email: email, password: password),
      ).called(1);
      verifyNever(
        () => mockGetCurrentUserUsecase(),
      ); // Not called on failed login
    });
  });

  group('AuthNotifier - Anonymous Login', () {
    test('should update state on successful anonymous login', () async {
      when(() => mockAnonymousLoginUsecase()).thenAnswer(
        (_) async => const AuthResult(success: true, userId: 'anon-id'),
      );

      when(() => mockGetCurrentUserUsecase()).thenAnswer((_) async => testUser);

      final authNotifier = container.read(authProvider.notifier);
      await authNotifier.loginAnonymously();

      final state = container.read(authProvider);

      expect(state.isAuthenticated, true);
      expect(state.userProfile, testUser);
      expect(state.isLoading, false);
      expect(state.errorMessage, isNull);

      verify(() => mockAnonymousLoginUsecase()).called(1);
      verify(
        () => mockGetCurrentUserUsecase(),
      ).called(1); // Called once during login
    });

    test('should update state with error on failed anonymous login', () async {
      when(() => mockAnonymousLoginUsecase()).thenAnswer(
        (_) async => const AuthResult(
          success: false,
          errorMessage: 'Anonymous login failed',
        ),
      );

      final authNotifier = container.read(authProvider.notifier);
      await authNotifier.loginAnonymously();

      final state = container.read(authProvider);

      expect(state.isAuthenticated, false);
      expect(state.userProfile, isNull);
      expect(state.isLoading, false);
      expect(state.errorMessage, 'Anonymous login failed');

      verify(() => mockAnonymousLoginUsecase()).called(1);
      verifyNever(
        () => mockGetCurrentUserUsecase(),
      ); // Not called on failed login
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
      container.read(authProvider.notifier).state = AuthState(
        isAuthenticated: true,
        userProfile: testUser,
      );

      final currentUser = authNotifier.getCurrentUser();
      expect(currentUser, testUser);
    });

    test('should return null when no user is authenticated', () {
      final authNotifier = container.read(authProvider.notifier);
      // Manually set the state to have no user
      container.read(authProvider.notifier).state = const AuthState();

      final currentUser = authNotifier.getCurrentUser();
      expect(currentUser, isNull);
    });

    test('should return authentication status', () {
      final authNotifier = container.read(authProvider.notifier);
      // Manually set the state to be authenticated
      container.read(authProvider.notifier).state = const AuthState(
        isAuthenticated: true,
      );

      final isAuthenticated = authNotifier.isAuthenticated();
      expect(isAuthenticated, true);
    });

    test('should return false when user is not authenticated', () {
      final authNotifier = container.read(authProvider.notifier);
      // Manually set the state to not be authenticated
      container.read(authProvider.notifier).state = const AuthState();

      final isAuthenticated = authNotifier.isAuthenticated();
      expect(isAuthenticated, false);
    });
  });

  group('AuthNotifier - State Transitions', () {
    test(
      'should transition from loading to authenticated on successful login',
      () async {
        const email = 'test@example.com';
        const password = 'password123';

        when(
          () => mockLoginUsecase(email: email, password: password),
        ).thenAnswer(
          (_) async => const AuthResult(success: true, userId: 'test-id'),
        );

        when(
          () => mockGetCurrentUserUsecase(),
        ).thenAnswer((_) async => testUser);

        final authNotifier = container.read(authProvider.notifier);

        // Initial state should be loading
        expect(authNotifier.state.isLoading, true);

        await authNotifier.login(email, password);

        // After login, should be authenticated and not loading
        final state = container.read(authProvider);
        expect(state.isLoading, false);
        expect(state.isAuthenticated, true);
        expect(state.userProfile, testUser);
        expect(state.errorMessage, isNull);
      },
    );

    test('should transition from loading to error on failed login', () async {
      const email = 'test@example.com';
      const password = 'wrong-password';

      when(() => mockLoginUsecase(email: email, password: password)).thenAnswer(
        (_) async => const AuthResult(
          success: false,
          errorMessage: 'Invalid credentials',
        ),
      );

      final authNotifier = container.read(authProvider.notifier);

      // Initial state should be loading
      expect(authNotifier.state.isLoading, true);

      await authNotifier.login(email, password);

      // After failed login, should have error and not be loading
      final state = container.read(authProvider);
      expect(state.isLoading, false);
      expect(state.isAuthenticated, false);
      expect(state.userProfile, isNull);
      expect(state.errorMessage, 'Invalid credentials');
    });

    test(
      'should transition from authenticated to unauthenticated on logout',
      () async {
        // First, set up an authenticated state
        when(
          () => mockGetCurrentUserUsecase(),
        ).thenAnswer((_) async => testUser);

        final authNotifier = container.read(authProvider.notifier);
        container.read(authProvider.notifier).state = AuthState(
          isAuthenticated: true,
          userProfile: testUser,
        );

        when(() => mockLogoutUsecase()).thenAnswer((_) async => Future.value());

        // Before logout
        expect(authNotifier.state.isAuthenticated, true);
        expect(authNotifier.state.userProfile, testUser);

        await authNotifier.logout();

        // After logout
        final state = container.read(authProvider);
        expect(state.isAuthenticated, false);
        expect(state.userProfile, isNull);
        expect(state.isLoading, false);
        expect(state.errorMessage, isNull);
      },
    );
  });

  group('AuthNotifier - Edge Cases', () {
    test('should handle empty email and password gracefully', () async {
      const email = '';
      const password = '';

      when(() => mockLoginUsecase(email: email, password: password)).thenAnswer(
        (_) async => const AuthResult(
          success: false,
          errorMessage: 'Email and password cannot be empty',
        ),
      );

      final authNotifier = container.read(authProvider.notifier);
      await authNotifier.login(email, password);

      final state = container.read(authProvider);
      expect(state.isAuthenticated, false);
      expect(state.errorMessage, 'Email and password cannot be empty');
    });

    test('should handle network exceptions during login', () async {
      const email = 'test@example.com';
      const password = 'password123';

      when(
        () => mockLoginUsecase(email: email, password: password),
      ).thenThrow(Exception('Network error'));

      final authNotifier = container.read(authProvider.notifier);
      await authNotifier.login(email, password);

      final state = container.read(authProvider);
      expect(state.isAuthenticated, false);
      expect(state.isLoading, false);
      expect(state.errorMessage, 'Login failed: Exception: Network error');
    });

    test('should handle exceptions during anonymous login', () async {
      when(
        () => mockAnonymousLoginUsecase(),
      ).thenThrow(Exception('Anonymous login network error'));

      final authNotifier = container.read(authProvider.notifier);
      await authNotifier.loginAnonymously();

      final state = container.read(authProvider);
      expect(state.isAuthenticated, false);
      expect(state.isLoading, false);
      expect(
        state.errorMessage,
        'Anonymous login failed: Exception: Anonymous login network error',
      );
    });

    test('should handle exceptions during logout', () async {
      when(
        () => mockLogoutUsecase(),
      ).thenThrow(Exception('Logout network error'));

      final authNotifier = container.read(authProvider.notifier);
      await authNotifier.logout();

      final state = container.read(authProvider);
      expect(state.isAuthenticated, false);
      expect(state.isLoading, false);
      expect(
        state.errorMessage,
        'Logout failed: Exception: Logout network error',
      );
    });

    test(
      'should handle null user profile from getCurrentUserUsecase',
      () async {
        when(() => mockAnonymousLoginUsecase()).thenAnswer(
          (_) async => const AuthResult(success: true, userId: 'anon-id'),
        );

        when(() => mockGetCurrentUserUsecase()).thenAnswer((_) async => null);

        final authNotifier = container.read(authProvider.notifier);
        await authNotifier.loginAnonymously();

        final state = container.read(authProvider);
        expect(state.isAuthenticated, true);
        expect(state.userProfile, isNull);
        expect(state.isLoading, false);
        expect(state.errorMessage, isNull);
      },
    );
  });

  group('AuthNotifier - Initialization and _checkCurrentUser', () {
    test('should check current user on initialization', () async {
      when(() => mockGetCurrentUserUsecase()).thenAnswer((_) async => testUser);

      final container = ProviderContainer(
        overrides: [
          userRepositoryProvider.overrideWithValue(mockUserRepository),
          loginUsecaseProvider.overrideWithValue(mockLoginUsecase),
          anonymousLoginUsecaseProvider.overrideWithValue(
            mockAnonymousLoginUsecase,
          ),
          logoutUsecaseProvider.overrideWithValue(mockLogoutUsecase),
          getCurrentUserUsecaseProvider.overrideWithValue(
            mockGetCurrentUserUsecase,
          ),
        ],
        observers: [],
      );

      // Manually trigger the initial check for testing
      final authNotifier = container.read(authProvider.notifier);
      await authNotifier.checkCurrentUser();

      final authState = container.read(authProvider);
      expect(authState.isAuthenticated, true);
      expect(authState.userProfile, testUser);
      expect(authState.isLoading, false);
      expect(authState.errorMessage, isNull);

      verify(() => mockGetCurrentUserUsecase()).called(1);
      container.dispose();
    });

    test('should handle exception during initial current user check', () async {
      when(
        () => mockGetCurrentUserUsecase(),
      ).thenThrow(Exception('Initial check failed'));

      final container = ProviderContainer(
        overrides: [
          userRepositoryProvider.overrideWithValue(mockUserRepository),
          loginUsecaseProvider.overrideWithValue(mockLoginUsecase),
          anonymousLoginUsecaseProvider.overrideWithValue(
            mockAnonymousLoginUsecase,
          ),
          logoutUsecaseProvider.overrideWithValue(mockLogoutUsecase),
          getCurrentUserUsecaseProvider.overrideWithValue(
            mockGetCurrentUserUsecase,
          ),
        ],
        observers: [],
      );

      // Manually trigger the initial check for testing
      final authNotifier = container.read(authProvider.notifier);
      await authNotifier.checkCurrentUser();

      final authState = container.read(authProvider);
      expect(authState.isAuthenticated, false);
      expect(authState.userProfile, isNull);
      expect(authState.isLoading, false);
      expect(authState.errorMessage, 'Exception: Initial check failed');

      verify(() => mockGetCurrentUserUsecase()).called(1);
      container.dispose();
    });

    test('should handle null user during initial current user check', () async {
      when(() => mockGetCurrentUserUsecase()).thenAnswer((_) async => null);

      final container = ProviderContainer(
        overrides: [
          userRepositoryProvider.overrideWithValue(mockUserRepository),
          loginUsecaseProvider.overrideWithValue(mockLoginUsecase),
          anonymousLoginUsecaseProvider.overrideWithValue(
            mockAnonymousLoginUsecase,
          ),
          logoutUsecaseProvider.overrideWithValue(mockLogoutUsecase),
          getCurrentUserUsecaseProvider.overrideWithValue(
            mockGetCurrentUserUsecase,
          ),
        ],
        observers: [],
      );

      // Manually trigger the initial check for testing
      final authNotifier = container.read(authProvider.notifier);
      await authNotifier.checkCurrentUser();

      final authState = container.read(authProvider);
      expect(authState.isAuthenticated, false);
      expect(authState.userProfile, isNull);
      expect(authState.isLoading, false);
      expect(authState.errorMessage, isNull);

      verify(() => mockGetCurrentUserUsecase()).called(1);
      container.dispose();
    });
  });
}
