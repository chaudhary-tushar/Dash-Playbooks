/// Tests for SupabaseAuthDatasource
///
/// These tests verify that the Supabase authentication datasource
/// provides the same functionality as the Firebase implementation.
library;

import 'package:flutbook/core/config/app_config.dart';
import 'package:flutbook/features/auth/data/datasources/supabase_auth_datasource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Mock classes for testing
class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockUser extends Mock implements User {}

class MockConfigProvider extends Mock implements ConfigProvider {}

class MockAppConfig extends Mock implements AppConfig {}

class MockAuthConfig extends Mock implements AuthConfig {}

void main() {
  late SupabaseAuthDatasource datasource;
  late MockSupabaseClient mockSupabase;
  late MockConfigProvider mockConfigProvider;
  late MockAppConfig mockAppConfig;
  late MockAuthConfig mockAuthConfig;

  setUp(() {
    mockSupabase = MockSupabaseClient();
    mockConfigProvider = MockConfigProvider();
    mockAppConfig = MockAppConfig();
    mockAuthConfig = MockAuthConfig();

    when(() => mockConfigProvider.config).thenReturn(mockAppConfig);
    when(() => mockAppConfig.auth).thenReturn(mockAuthConfig);

    datasource = SupabaseAuthDatasource(
      supabase: mockSupabase,
      configProvider: mockConfigProvider,
    );
  });

  group('SupabaseAuthDatasource', () {
    group('signInWithEmailAndPassword', () {
      const email = 'test@example.com';
      const password = 'password123';

      test('should return success result when login succeeds', () async {
        // Arrange
        final mockUser = MockUser();
        final mockResponse = AuthResponse(user: mockUser);
        when(
          () => mockSupabase.auth.signInWithPassword(
            email: email,
            password: password,
          ),
        ).thenAnswer((_) async => mockResponse);
        when(() => mockUser.id).thenReturn('user-id');
        when(() => mockUser.email).thenReturn(email);
        when(() => mockUser.userMetadata).thenReturn({
          'full_name': 'Test User',
        });

        // Act
        final result = await datasource.signInWithEmailAndPassword(
          email,
          password,
        );

        // Assert
        expect(result.success, isTrue);
        expect(result.userId, equals('user-id'));
        expect(result.user, isNotNull);
        expect(result.user?.email, equals(email));
        expect(result.user?.displayName, equals('Test User'));
      });

      test('should return error result when login fails', () async {
        // Arrange
        when(
          () => mockSupabase.auth.signInWithPassword(
            email: email,
            password: password,
          ),
        ).thenThrow(const AuthException('Invalid credentials'));

        // Act
        final result = await datasource.signInWithEmailAndPassword(
          email,
          password,
        );

        // Assert
        expect(result.success, isFalse);
        expect(result.errorMessage, contains('Invalid credentials'));
      });

      test('should return error result when no user returned', () async {
        // Arrange
        final mockResponse = AuthResponse();
        when(
          () => mockSupabase.auth.signInWithPassword(
            email: email,
            password: password,
          ),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await datasource.signInWithEmailAndPassword(
          email,
          password,
        );

        // Assert
        expect(result.success, isFalse);
        expect(result.errorMessage, contains('No user returned'));
      });
    });

    group('signUpWithEmailAndPassword', () {
      const email = 'newuser@example.com';
      const password = 'password123';

      test('should return success result when registration succeeds', () async {
        // Arrange
        final mockUser = MockUser();
        final mockResponse = AuthResponse(user: mockUser);
        when(
          () => mockSupabase.auth.signUp(
            email: email,
            password: password,
          ),
        ).thenAnswer((_) async => mockResponse);
        when(() => mockUser.id).thenReturn('new-user-id');
        when(() => mockUser.email).thenReturn(email);

        // Act
        final result = await datasource.signUpWithEmailAndPassword(
          email,
          password,
        );

        // Assert
        expect(result.success, isTrue);
        expect(result.userId, equals('new-user-id'));
        expect(result.user?.email, equals(email));
      });

      test('should return error result when registration fails', () async {
        // Arrange
        when(
          () => mockSupabase.auth.signUp(
            email: email,
            password: password,
          ),
        ).thenThrow(const AuthException('Email already in use'));

        // Act
        final result = await datasource.signUpWithEmailAndPassword(
          email,
          password,
        );

        // Assert
        expect(result.success, isFalse);
        expect(result.errorMessage, contains('Email already in use'));
      });
    });

    group('signInWithGoogle', () {
      test(
        'should return success result when Google sign-in succeeds',
        () async {
          // Arrange
          when(() => mockAuthConfig.enableGoogleAuth).thenReturn(true);
          final mockUser = MockUser();
          when(() => mockSupabase.auth.currentUser).thenReturn(mockUser);
          when(() => mockUser.id).thenReturn('google-user-id');
          when(() => mockUser.email).thenReturn('google@example.com');
          when(() => mockUser.userMetadata).thenReturn({
            'full_name': 'Google User',
          });

          // Act
          final result = await datasource.signInWithGoogle();

          // Assert
          expect(result.success, isTrue);
          expect(result.userId, equals('google-user-id'));
          expect(result.user?.authMethod, equals('google_oauth'));
        },
      );

      test('should return error when Google auth is disabled', () async {
        // Arrange
        when(() => mockAuthConfig.enableGoogleAuth).thenReturn(false);

        // Act
        final result = await datasource.signInWithGoogle();

        // Assert
        expect(result.success, isFalse);
        expect(result.errorMessage, contains('not enabled'));
      });

      test('should return error when Google sign-in fails', () async {
        // Arrange
        when(() => mockAuthConfig.enableGoogleAuth).thenReturn(true);
        when(() => mockSupabase.auth.currentUser).thenReturn(null);

        // Act
        final result = await datasource.signInWithGoogle();

        // Assert
        expect(result.success, isFalse);
        expect(result.errorMessage, contains('No user returned'));
      });
    });

    group('anonymousSignIn', () {
      test(
        'should return success result when anonymous sign-in succeeds',
        () async {
          // Arrange
          when(() => mockAuthConfig.enableAnonymousAuth).thenReturn(true);
          final mockUser = MockUser();
          final mockResponse = AuthResponse(user: mockUser);
          when(
            () => mockSupabase.auth.signInAnonymously(),
          ).thenAnswer((_) async => mockResponse);
          when(() => mockUser.id).thenReturn('anonymous-user-id');

          // Act
          final result = await datasource.anonymousSignIn();

          // Assert
          expect(result.success, isTrue);
          expect(result.userId, equals('anonymous-user-id'));
          expect(result.user?.displayName, equals('Anonymous User'));
          expect(result.user?.authMethod, equals('anonymous'));
        },
      );

      test('should return error when anonymous auth is disabled', () async {
        // Arrange
        when(() => mockAuthConfig.enableAnonymousAuth).thenReturn(false);

        // Act
        final result = await datasource.anonymousSignIn();

        // Assert
        expect(result.success, isFalse);
        expect(result.errorMessage, contains('not enabled'));
      });

      test('should return error when anonymous sign-in fails', () async {
        // Arrange
        when(() => mockAuthConfig.enableAnonymousAuth).thenReturn(true);
        when(
          () => mockSupabase.auth.signInAnonymously(),
        ).thenThrow(const AuthException('Anonymous sign-in failed'));

        // Act
        final result = await datasource.anonymousSignIn();

        // Assert
        expect(result.success, isFalse);
        expect(result.errorMessage, contains('Anonymous sign-in failed'));
      });
    });

    group('signOut', () {
      test('should sign out successfully', () async {
        // Arrange
        when(() => mockSupabase.auth.signOut()).thenAnswer((_) async {});

        // Act
        await datasource.signOut();

        // Assert
        verify(() => mockSupabase.auth.signOut()).called(1);
      });
    });

    group('getCurrentUser', () {
      test('should return current user when authenticated', () async {
        // Arrange
        final mockUser = MockUser();
        when(() => mockSupabase.auth.currentUser).thenReturn(mockUser);
        when(() => mockUser.id).thenReturn('current-user-id');
        when(() => mockUser.email).thenReturn('current@example.com');
        when(() => mockUser.userMetadata).thenReturn({
          'full_name': 'Current User',
        });

        // Act
        final result = await datasource.getCurrentUser();

        // Assert
        expect(result, isNotNull);
        expect(result?.id, equals('current-user-id'));
        expect(result?.email, equals('current@example.com'));
        expect(result?.displayName, equals('Current User'));
      });

      test('should return null when not authenticated', () async {
        // Arrange
        when(() => mockSupabase.auth.currentUser).thenReturn(null);

        // Act
        final result = await datasource.getCurrentUser();

        // Assert
        expect(result, isNull);
      });
    });

    group('authStateChanges', () {
      test('should return auth state stream', () async {
        // Arrange
        final stream = Stream<AuthState>.fromIterable([]);
        when(() => mockSupabase.auth.onAuthStateChange).thenReturn(stream);

        // Act
        final result = datasource.authStateChanges();

        // Assert
        expect(result, isA<Stream<User?>>());
      });
    });

    group('mapAuthError', () {
      test('should map invalid credentials error', () {
        // Act
        final result = datasource.mapAuthError('invalid_credentials');

        // Assert
        expect(result, contains('Invalid email or password'));
      });

      test('should map email not confirmed error', () {
        // Act
        final result = datasource.mapAuthError('email_not_confirmed');

        // Assert
        expect(result, contains('Please confirm your email address'));
      });

      test('should map email already in use error', () {
        // Act
        final result = datasource.mapAuthError('email_already_in_use');

        // Assert
        expect(result, contains('An account with this email already exists'));
      });

      test('should map weak password error', () {
        // Act
        final result = datasource.mapAuthError('weak_password');

        // Assert
        expect(result, contains('Password is too weak'));
      });

      test('should map invalid email error', () {
        // Act
        final result = datasource.mapAuthError('invalid_email');

        // Assert
        expect(result, contains('Email is invalid'));
      });

      test('should map user not found error', () {
        // Act
        final result = datasource.mapAuthError('user_not_found');

        // Assert
        expect(result, contains('No user found with this email'));
      });

      test('should map too many requests error', () {
        // Act
        final result = datasource.mapAuthError('too_many_requests');

        // Assert
        expect(result, contains('Too many requests'));
      });

      test('should map network error', () {
        // Act
        final result = datasource.mapAuthError('network_error');

        // Assert
        expect(result, contains('Network error'));
      });

      test('should return default error message for unknown errors', () {
        // Act
        final result = datasource.mapAuthError('unknown_error');

        // Assert
        expect(result, contains('Authentication failed'));
      });

      test('should return default error message for null error', () {
        // Act
        final result = datasource.mapAuthError(null);

        // Assert
        expect(result, contains('Authentication failed'));
      });
    });
  });
}
