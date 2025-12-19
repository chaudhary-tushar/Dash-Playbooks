# Authentication Refactor Plan

## Overview
This document outlines a comprehensive plan to refactor the authentication system to address the issue where the UI doesn't navigate to another screen when continuing as an anonymous user, instead just reloading the page.

## Root Cause Analysis
Based on the logs analysis:
1. Providers are being disposed and re-added during authentication
2. Auth state is not properly transitioning
3. Navigation is not properly configured after authentication
4. Provider dependencies are unstable during authentication

## Refactor Goals
- Fix provider lifecycle issues during authentication
- Ensure proper state transitions in AuthNotifier
- Implement correct navigation after authentication
- Stabilize provider dependencies

## Phase 1: Provider Lifecycle Fix (Day 1)
### Tasks
1. **Fix Provider Scopes**
   - Review all authentication-related providers to ensure proper scoping
   - Convert any auto-dispose providers to regular providers where appropriate
   - Ensure providers are not recreated unnecessarily during authentication

2. **Review AuthNotifier Implementation**
   - Ensure AuthNotifier extends `Notifier<AuthState>` instead of `StateNotifier<AuthState>`
   - Add proper error handling and state transitions
   - Implement proper loading states during authentication

3. **Implement Proper State Management**
   - Create a comprehensive AuthState class with clear states:
     - `AuthInitial`
     - `AuthLoading`
     - `AuthAuthenticated`
     - `AuthUnauthenticated`
     - `AuthError`

### Acceptance Criteria
- Providers are not disposed and recreated during authentication
- AuthNotifier properly transitions between states
- Loading states are properly displayed during authentication

## Phase 2: Navigation Logic Fix (Day 2)
### Tasks
1. **Update AuthGuard Implementation**
   - Review the canActivate method to ensure proper navigation logic
   - Add proper handling for anonymous users
   - Ensure route protection works correctly

2. **Fix Router Integration**
   - Update app_router.dart to properly handle authentication state
   - Implement proper redirection after login/anonymous login
   - Add navigation logic that respects the current authentication state

3. **Implement Navigation After Authentication**
   - Update AuthNotifier to trigger navigation after successful authentication
   - Ensure anonymous login navigates to the correct screen
   - Add proper error handling for navigation failures

### Acceptance Criteria
- Anonymous login navigates to the correct screen (library)
- Navigation works properly after both email and anonymous login
- Route protection works as expected

## Phase 3: Anonymous Login Enhancement (Day 3)
### Tasks
1. **Enhance Anonymous Login Use Case**
   - Add proper session management for anonymous users
   - Ensure anonymous users have unique identifiers
   - Add proper error handling for anonymous authentication

2. **Update UI Implementation**
   - Review login screen to ensure proper state management
   - Add loading indicators during authentication
   - Improve error message handling

3. **Add Anonymous User Persistence**
   - Implement proper persistence for anonymous user sessions
   - Ensure anonymous state persists across app restarts
   - Add proper cleanup for anonymous sessions

### Acceptance Criteria
- Anonymous users can login and maintain their session
- Anonymous state persists across app restarts
- Navigation works properly for anonymous users

## Phase 4: Testing and Validation (Day 4)
### Tasks
1. **Add Comprehensive Tests**
   - Write tests for provider lifecycle management
   - Test navigation logic for both email and anonymous login
   - Test error handling scenarios
   - Test state transitions in AuthNotifier

2. **Integration Testing**
   - Test complete authentication flows
   - Verify navigation works correctly
   - Test route protection with both authenticated and anonymous users

3. **Performance Testing**
   - Verify providers are not unnecessarily recreated
   - Test app performance during authentication
   - Check for memory leaks

### Acceptance Criteria
- All authentication tests pass with 80%+ coverage
- Navigation works properly in all scenarios
- No performance degradation

## Implementation Steps

### Step 1: Update AuthState Class
```dart
@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = AuthInitial;
  const factory AuthState.loading() = AuthLoading;
  const factory AuthState.authenticated(User user) = AuthAuthenticated;
  const factory AuthState.unauthenticated() = AuthUnauthenticated;
  const factory AuthState.error(String message) = AuthError;
}
```

### Step 2: Refactor AuthNotifier
```dart
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Initialize with loading state or check existing session
    return const AuthState.initial();
  }

  Future<void> login(String email, String password) async {
    state = const AuthState.loading();
    try {
      final result = await ref.read(loginUseCaseProvider)(email, password);
      state = result.fold(
        (error) => AuthState.error(error),
        (user) => AuthState.authenticated(user),
      );
      // Navigate to library after successful login
      if (state is AuthAuthenticated) {
        // Trigger navigation via callback or router provider
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> loginAnonymously() async {
    state = const AuthState.loading();
    try {
      final result = await ref.read(anonymousLoginUseCaseProvider)();
      state = result.fold(
        (error) => AuthState.error(error),
        (user) => AuthState.authenticated(user),
      );
      // Navigate to library after successful anonymous login
      if (state is AuthAuthenticated) {
        // Trigger navigation via callback or router provider
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> logout() async {
    try {
      await ref.read(userRepositoryProvider).logout();
      state = const AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }
}
```

### Step 3: Update Router Integration
- Update `app_router.dart` to listen to auth state changes
- Implement proper navigation after authentication
- Add route guards that work with the new auth state

### Step 4: Update UI Components
- Update login screen to properly consume auth state
- Add loading indicators during authentication
- Implement proper error display

## Testing Plan
1. Unit tests for AuthNotifier state transitions
2. Widget tests for login screen functionality
3. Integration tests for complete authentication flow
4. Navigation tests for both email and anonymous login

## Success Metrics
- Anonymous login navigates to library screen instead of reloading
- No provider disposal/recreation during authentication
- Proper state transitions in AuthNotifier
- 80%+ test coverage for authentication features
- No console errors during authentication flow

## Timeline
- Phase 1: Day 1 (Provider Lifecycle Fix)
- Phase 2: Day 2 (Navigation Logic Fix)
- Phase 3: Day 3 (Anonymous Login Enhancement)
- Phase 4: Day 4 (Testing and Validation)

## Dependencies
- Complete Phase 1 before starting Phase 2
- Phase 4 requires all previous phases to be completed
- Integration with existing router and UI components