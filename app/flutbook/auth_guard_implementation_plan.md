# Auth Guard Implementation Plan

## Overview
The Auth Guard will protect routes in the Flutbook application by checking authentication status and redirecting users appropriately. This implementation will integrate with the existing `AppRouter` and `AuthProvider`.

## Requirements Analysis

### Route Categories (from TASK_CARDS.md)
- **Public routes**: `/`, `/auth`, `/splash` - accessible to anyone
- **Protected routes**: `/settings`, `/sync`, `/profile` - require full authentication
- **Any Auth routes**: `/library`, `/playback`, `/directory` - accessible to both authenticated and anonymous users

### Key Functionality
1. Check authentication status from `AuthProvider`
2. Redirect unauthenticated users to `/auth`
3. Allow anonymous users access to library/player routes
4. Require full authentication for protected routes
5. Integrate with existing `AppRouter`

## Implementation Plan

### Step 1: Create AuthGuard Class
**File**: `lib/app/router/auth_guard.dart`

```dart
class AuthGuard {
  // Method to check if route can be activated
  static bool canActivate(String route, AuthState authState) {
    // Public routes - always allow
    if (isPublicRoute(route)) return true;

    // Protected routes - require full authentication
    if (isProtectedRoute(route)) {
      return authState.isAuthenticated && authState.userProfile != null;
    }

    // Any Auth routes - allow if authenticated (including anonymous)
    if (isAnyAuthRoute(route)) {
      return authState.isAuthenticated;
    }

    // Default: redirect to auth
    return false;
  }

  // Helper methods to categorize routes
  static bool isPublicRoute(String route) {
    return ['/', '/auth', '/splash'].contains(route);
  }

  static bool isProtectedRoute(String route) {
    return ['/settings', '/sync', '/profile'].contains(route);
  }

  static bool isAnyAuthRoute(String route) {
    return ['/library', '/playback', '/directory'].contains(route);
  }
}
```

### Step 2: Integrate AuthGuard with AppRouter
**File**: `lib/app/router/app_router.dart`

Modify the `generateRoute` method to use AuthGuard:

```dart
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Get current auth state (will need to access Riverpod)
    final authState = getAuthState(); // Implementation needed

    // Check if route can be activated
    final canActivate = AuthGuard.canActivate(settings.name ?? '/', authState);

    // If cannot activate, redirect to auth
    if (!canActivate && settings.name != '/auth') {
      return MaterialPageRoute(builder: (_) => const LoginPage());
    }

    // Existing route generation logic
    switch (settings.name) {
      // ... existing cases
    }
  }
}
```

### Step 3: Access AuthState in Router
Since the router is not a widget, we need a way to access the current auth state. Options:

**Option A**: Pass auth state as parameter (requires app refactoring)
**Option B**: Use a static accessor (not ideal for Riverpod)
**Option C**: Create a router provider that can access auth state

**Recommended**: Option C - Create a router provider:

```dart
final routerProvider = Provider<AppRouter>((ref) {
  final authState = ref.watch(authProvider);
  return AppRouter(authState);
});
```

### Step 4: Update App Initialization
**File**: `lib/app/view/app.dart`

Modify to use the router provider:

```dart
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp(
      title: 'Flutbook',
      theme: AppTheme.lightTheme,
      // ... other config
      onGenerateRoute: router.generateRoute,
    );
  }
}
```

### Step 5: Handle Edge Cases
1. **Splash screen**: Should not require auth guard
2. **Auth page**: Should not redirect to itself
3. **Anonymous users**: Should have limited access
4. **Route not found**: Should redirect to appropriate page

### Step 6: Testing Strategy
1. Test public routes are always accessible
2. Test protected routes redirect when unauthenticated
3. Test any auth routes work for anonymous users
4. Test full auth routes work for logged-in users
5. Test redirect logic doesn't create infinite loops

## Implementation Timeline

1. **Create AuthGuard class** (30 min)
2. **Modify AppRouter** (1 hour)
3. **Create router provider** (30 min)
4. **Update app initialization** (15 min)
5. **Test all scenarios** (1 hour)
6. **Fix any issues** (30 min)

**Total estimated time**: 3.5 hours

## Dependencies
- `AuthProvider` (Task 2.4) - COMPLETE
- `AppRouter` - EXISTS
- Riverpod for state management - EXISTS

## Integration Points
- `AppRouter.generateRoute()` - Main integration point
- `AuthProvider` - For authentication state
- `LoginPage` - Redirect target for unauthenticated users

## Potential Challenges
1. Accessing Riverpod state outside widget tree
2. Avoiding redirect loops
3. Handling anonymous vs full authentication
4. Maintaining clean architecture patterns

## Success Criteria
- ✅ Public routes accessible to anyone
- ✅ Protected routes require full authentication
- ✅ Any auth routes work for anonymous users
- ✅ Unauthenticated users redirected to /auth
- ✅ No infinite redirect loops
- ✅ Works with existing AppRouter
- ✅ Clean code following project patterns