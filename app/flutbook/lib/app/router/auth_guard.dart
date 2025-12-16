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

    // Check if user is authenticated
    if (!authState.isAuthenticated) {
      // Unauthenticated users get redirected to auth page
      return false;
    }

    // Anonymous users have limited access
    if (isAnonymousUser(authState) && !isAnonymousAllowedRoute(route)) {
      // Anonymous users can only access limited routes
      return false;
    }

    // Authenticated users (not anonymous) can access protected routes
    if (isProtectedRoute(route) && !isAnonymousUser(authState)) {
      return true;
    }

    // For routes accessible by any authenticated user (including anonymous)
    if (isAnyAuthRoute(route)) {
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
    return authState.userProfile?.authMethod == 'anonymous';
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
