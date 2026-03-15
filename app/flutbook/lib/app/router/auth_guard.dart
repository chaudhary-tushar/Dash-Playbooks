/// Auth Guard implementation for Flutbook application.
/// Provides route protection based on authentication status.
library;

import 'package:flutbook/features/auth/presentation/providers/auth_provider.dart';

class AuthGuard {
  /// Method to check if route can be activated based on authentication status
  static bool canActivate(String route, AuthState authState) {
    // Public routes - always allow access
    if (isPublicRoute(route)) {
      return true;
    }

    // Allow development bypass for specific routes
    if (route == 'dev_directory') {
      return true;
    }

    // If auth is still loading, allow access to prevent UI flickering
    if (authState.isLoading) {
      return true;
    }

    // Check if user is authenticated
    if (!authState.isAuthenticated) {
      // Unauthenticated users can only access public routes (handled above)
      return false;
    }

    // Authenticated users: check specific route permissions
    if (isProtectedRoute(route)) {
      // Protected routes require non-anonymous authentication
      return !isAnonymousUser(authState);
    }

    if (isAnonymousAllowedRoute(route)) {
      // Routes that allow anonymous users
      return true;
    }

    // Default: redirect to auth (shouldn't reach here for known routes)
    return false;
  }

  /// Helper method to check if route is public
  static bool isPublicRoute(String route) {
    return ['/', '/auth', '/splash'].contains(route);
  }

  /// Helper method to check if user is anonymous
  static bool isAnonymousUser(AuthState authState) {
    final authMethod = authState.userProfile?.authMethod;
    return authMethod == 'anonymous' || authMethod == 'development';
  }

  /// Helper method to check if route is protected (requires non-anonymous auth)
  static bool isProtectedRoute(String route) {
    return ['/settings', '/sync', '/profile', '/backup'].contains(route);
  }

  /// Helper method to check if route allows anonymous users
  static bool isAnonymousAllowedRoute(String route) {
    return ['/library', '/playback', '/directory'].contains(route);
  }

  /// Helper method to check if route allows any authentication
  static bool isAnyAuthRoute(String route) {
    return ['/library', '/playback', '/directory'].contains(route);
  }
}
