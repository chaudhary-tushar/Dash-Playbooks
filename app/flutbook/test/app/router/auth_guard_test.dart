import 'package:flutbook/app/router/auth_guard.dart';
import 'package:flutbook/features/auth/domain/entities/user_profile.dart';
import 'package:flutbook/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthGuard Tests', () {
    test('Public routes should be accessible when not authenticated', () {
      final authState = const AuthState(
        isAuthenticated: false,
        userProfile: null,
        isLoading: false,
        errorMessage: null,
      );

      expect(AuthGuard.canActivate('/', authState), true);
      expect(AuthGuard.canActivate('/auth', authState), true);
      expect(AuthGuard.canActivate('/splash', authState), true);
    });

    test('Non-public routes should not be accessible when not authenticated', () {
      final authState = const AuthState(
        isAuthenticated: false,
        userProfile: null,
        isLoading: false,
        errorMessage: null,
      );

      expect(AuthGuard.canActivate('/library', authState), false);
      expect(AuthGuard.canActivate('/settings', authState), false);
      expect(AuthGuard.canActivate('/playback', authState), false);
    });

    test('Authenticated users should access protected routes', () {
      final userProfile = UserProfile(
        id: 'user123',
        email: 'test@example.com',
        authMethod: 'email', // Non-anonymous auth method
        syncEnabled: true,
      );
      
      final authState = AuthState(
        isAuthenticated: true,
        userProfile: userProfile,
        isLoading: false,
        errorMessage: null,
      );

      // Should be able to access protected routes with non-anonymous auth
      expect(AuthGuard.canActivate('/settings', authState), true);
      expect(AuthGuard.canActivate('/sync', authState), true);
      expect(AuthGuard.canActivate('/profile', authState), true);
    });

    test('Anonymous users should not access protected routes', () {
      final userProfile = UserProfile(
        id: 'anonymous123',
        email: '',
        authMethod: 'anonymous', // Anonymous auth method
        syncEnabled: false,
      );
      
      final authState = AuthState(
        isAuthenticated: true,
        userProfile: userProfile,
        isLoading: false,
        errorMessage: null,
      );

      // Should NOT be able to access protected routes with anonymous auth
      expect(AuthGuard.canActivate('/settings', authState), false);
      expect(AuthGuard.canActivate('/sync', authState), false);
      expect(AuthGuard.canActivate('/profile', authState), false);
    });

    test('Anonymous users should access library routes', () {
      final userProfile = UserProfile(
        id: 'anonymous123',
        email: '',
        authMethod: 'anonymous', // Anonymous auth method
        syncEnabled: false,
      );
      
      final authState = AuthState(
        isAuthenticated: true,
        userProfile: userProfile,
        isLoading: false,
        errorMessage: null,
      );

      // Should be able to access routes that allow anonymous users
      expect(AuthGuard.canActivate('/library', authState), true);
      expect(AuthGuard.canActivate('/playback', authState), true);
      expect(AuthGuard.canActivate('/directory', authState), true);
    });

    test('Authenticated non-anonymous users should access library routes', () {
      final userProfile = UserProfile(
        id: 'user123',
        email: 'test@example.com',
        authMethod: 'email', // Non-anonymous auth method
        syncEnabled: true,
      );
      
      final authState = AuthState(
        isAuthenticated: true,
        userProfile: userProfile,
        isLoading: false,
        errorMessage: null,
      );

      // Should be able to access routes that allow any authenticated user
      expect(AuthGuard.canActivate('/library', authState), true);
      expect(AuthGuard.canActivate('/playback', authState), true);
      expect(AuthGuard.canActivate('/directory', authState), true);
    });

    test('isPublicRoute helper method works correctly', () {
      expect(AuthGuard.isPublicRoute('/'), true);
      expect(AuthGuard.isPublicRoute('/auth'), true);
      expect(AuthGuard.isPublicRoute('/splash'), true);
      expect(AuthGuard.isPublicRoute('/library'), false);
      expect(AuthGuard.isPublicRoute('/settings'), false);
    });

    test('isAnonymousUser helper method works correctly', () {
      final anonymousProfile = UserProfile(
        id: 'anonymous123',
        email: '',
        authMethod: 'anonymous',
        syncEnabled: false,
      );
      
      final emailProfile = UserProfile(
        id: 'user123',
        email: 'test@example.com',
        authMethod: 'email',
        syncEnabled: true,
      );

      final anonymousState = AuthState(
        isAuthenticated: true,
        userProfile: anonymousProfile,
        isLoading: false,
        errorMessage: null,
      );

      final emailState = AuthState(
        isAuthenticated: true,
        userProfile: emailProfile,
        isLoading: false,
        errorMessage: null,
      );

      expect(AuthGuard.isAnonymousUser(anonymousState), true);
      expect(AuthGuard.isAnonymousUser(emailState), false);
    });
  });
}