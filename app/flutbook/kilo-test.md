Subject: PHASE ASSIGNMENT: Phase 2, Task 2.6 - Create Auth Guard

Hi Agent,

You're assigned to PHASE 2: AUTHENTICATION
Priority: CRITICAL | Estimated Time: 6 Hours
Status: Partially Implemented
Here's what you need to know:
## 🔐 Phase 2: Authentication (8 Tasks)

> **Status:** ⏳ ~40% Complete
> **Estimated Time:** 3-4 days
> **Priority:** Critical (Gate to App)
> **Dependencies:** Phase 1 Complete

User authentication with Firebase supporting both email/password and anonymous login.

### Task 2.1: Create Login Use Case

**Status:** [ ] Pending
**File:** `lib/features/auth/domain/usecases/login_usecase.dart` (NEW)

**Description:**
Create a domain use case for handling user login with email/password credentials.

**Acceptance Criteria:**
- [ ] Use case accepts email and password parameters
- [ ] Returns `AuthResult` with user profile on success
- [ ] Returns error message on failure
- [ ] Validates input before login attempt
- [ ] Has unit tests with 80%+ coverage

**Code Example:**
```dart
import 'package:flutbook/features/auth/domain/repositories/user_repository.dart';

class LoginUseCase {
  LoginUseCase(this._userRepository);

  final UserRepository _userRepository;

  Future<AuthResult> call(String email, String password) async {
    // Validate
    if (email.isEmpty || password.isEmpty) {
      return AuthResult.failure('Email and password required');
    }

    // Execute
    return await _userRepository.loginWithEmail(email, password);
  }
}
```

---

### Task 2.2: Create Anonymous Login Use Case

**Status:** [ ] Pending
**File:** `lib/features/auth/domain/usecases/anonymous_login_usecase.dart` (NEW)

**Description:**
Create a use case for anonymous login allowing users to try the app without account setup.

**Acceptance Criteria:**
- [ ] No parameters required for anonymous login
- [ ] Returns `AuthResult` with anonymous user profile
- [ ] Generates unique session ID for tracking
- [ ] Has unit tests

**Code Example:**
```dart
class AnonymousLoginUseCase {
  AnonymousLoginUseCase(this._userRepository);

  final UserRepository _userRepository;

  Future<AuthResult> call() async {
    return await _userRepository.loginAnonymously();
  }
}
```

---

### Task 2.3: Update Firebase Auth Datasource

**Status:** [ ] Pending
**File:** `lib/features/auth/data/datasources/firebase_auth_datasource.dart`

**Description:**
Extend Firebase authentication datasource to support anonymous login.

**Acceptance Criteria:**
- [ ] `signInAnonymously()` method implemented
- [ ] Returns User with anonymous flag set
- [ ] Error handling for network failures
- [ ] Firebase console configured for anonymous auth

**Code Example:**
```dart
class FirebaseAuthDatasource {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<User> signInAnonymously() async {
    final userCredential = await _firebaseAuth.signInAnonymously();
    return userCredential.user!;
  }

  Future<User> signInWithEmail(String email, String password) async {
    final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user!;
  }
}
```

---

### Task 2.4: Create Auth State Provider

**Status:** [ ] Pending
**File:** `lib/features/auth/presentation/providers/auth_provider.dart` (NEW)

**Description:**
Create a Riverpod provider for managing authentication state across the app.

**Acceptance Criteria:**
- [ ] Riverpod `StateNotifier` or `AsyncNotifier` pattern
- [ ] Exposes `isAuthenticated` boolean
- [ ] Manages login/logout state
- [ ] Persists auth state to local storage
- [ ] Has getter for current user profile

**Code Example:**
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authProvider = StateNotifierProvider.autoDispose<
    AuthNotifier,
    AsyncValue<AuthState>
>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  return AuthNotifier(userRepository);
});

class AuthNotifier extends StateNotifier<AsyncValue<AuthState>> {
  AuthNotifier(this._userRepository) : super(const AsyncValue.loading());

  final UserRepository _userRepository;

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    final result = await _userRepository.loginWithEmail(email, password);
    // Handle result and update state
  }

  Future<void> loginAnonymously() async {
    state = const AsyncValue.loading();
    final result = await _userRepository.loginAnonymously();
    // Handle result and update state
  }
}
```

---

### Task 2.5: Enhance Login Page UI

**Status:** ⏳ ~50% Complete
**File:** `lib/features/auth/presentation/login.dart`

**Description:**
Add UI elements for email/password login and anonymous login button.

**Acceptance Criteria:**
- [ ] Email text field with validation
- [ ] Password text field with masking
- [ ] Login button (email/password)
- [ ] Anonymous login button (prominent)
- [ ] Error message display
- [ ] Loading state during authentication
- [ ] Responsive layout (mobile/tablet/desktop)
- [ ] No console errors

**Code Example:**
```dart
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Email field
            TextField(
              decoration: InputDecoration(
                label: const Text('Email'),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            // Password field
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                label: const Text('Password'),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24),
            // Login button
            ElevatedButton(
              onPressed: () { /* Handle login */ },
              child: const Text('Login'),
            ),
            SizedBox(height: 16),
            // Anonymous login button
            OutlinedButton(
              onPressed: () { /* Handle anonymous login */ },
              child: const Text('Continue as Guest'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### Task 2.6: Create Auth Guard

**Status:** [ ] Pending
**File:** `lib/app/router/auth_guard.dart` (NEW)

**Description:**
Implement route guard to protect screens that require authentication.

**Acceptance Criteria:**
- [ ] Checks if user is authenticated before allowing route
- [ ] Redirects to login if not authenticated
- [ ] Anonymous users can access library/player
- [ ] Settings/Sync features redirect if not logged in
- [ ] Guards work with `AppRouter`

**Code Example:**
```dart
class AuthGuard {
  AuthGuard(this._userRepository);

  final UserRepository _userRepository;

  Future<bool> canActivate(String routeName) async {
    final user = await _userRepository.getCurrentUser();

    // Public routes
    if (['/', '/auth', '/library', '/playback'].contains(routeName)) {
      return true;
    }

    // Protected routes require login
    return user != null && !user.isAnonymous;
  }
}
```

---

### Task 2.7: Integrate Auth with App Router

**Status:** [ ] Pending
**File:** `lib/app/router/app_router.dart`

**Description:**
Update router to use auth guard and redirect based on authentication state.

**Acceptance Criteria:**
- [ ] Routes check authentication status
- [ ] Unauthenticated users redirect to `/auth`
- [ ] Authenticated users can access all routes
- [ ] Anonymous users access limited routes
- [ ] No console errors

---

### Task 2.8: Add Authentication Tests

**Status:** [ ] Pending
**Files:**
- `test/features/auth/domain/usecases/login_usecase_test.dart`
- `test/features/auth/presentation/providers/auth_provider_test.dart`

**Description:**
Create unit and widget tests for authentication flows.

**Acceptance Criteria:**
- [ ] Test successful email login
- [ ] Test failed login (wrong password)
- [ ] Test anonymous login
- [ ] Test state persistence
- [ ] Test logout functionality
- [ ] 80%+ code coverage for auth feature

---

here are the task cards whcih have bben partially implimented , you nned to run flutter analyze and tests for the Authentication feature in the flutter app and the tasks need to be completed in this Plan order: 2.1 → 2.2 → 2.3 → 2.4 → 2.5 → 2.6 → 2.7 → 2.8
# 📋 PHASE 2: AUTHENTICATION

---

## TASK 2.1: Login Use Case

```
┌─────────────────────────────────────────────────────────────┐
│ PHASE 2, TASK 2.1: Create Login Use Case                   │
├─────────────────────────────────────────────────────────────┤
│ Priority: 🔴 CRITICAL (blocks Phase 2)                      │
│ Estimated Time: 2-3 hours                                   │
│ Dependencies: None (start immediately)                      │
│ Status: [ ] TODO / [ ] IN PROGRESS / [ ] COMPLETE          │
├─────────────────────────────────────────────────────────────┤
│ FILE TO CREATE:                                             │
│ lib/features/auth/domain/usecases/login_usecase.dart       │
│                                                             │
│ DESCRIPTION:                                                │
│ Create a domain use case for user login with email/password │
│                                                             │
│ ACCEPTANCE CRITERIA:                                        │
│ [ ] Use case accepts email and password parameters         │
│ [ ] Returns AuthResult with user profile on success        │
│ [ ] Returns error message on failure                       │
│ [ ] Validates input before login attempt                   │
│ [ ] Has unit tests with 80%+ coverage                      │
│                                                             │
│ FILES NEEDED:                                               │
│ - test/features/auth/domain/usecases/login_usecase_test.dart
│                                                             │
│ REFERENCE:                                                  │
│ See: plan-flutbookMVP.prompt.md (Task 2.1)                │
│ Pattern: IMPLEMENTATION_SUMMARY.md (Use Case Pattern)      │
│                                                             │
│ CHECKLIST:                                                  │
│ [ ] Read task description in prompt file                   │
│ [ ] Create test file with all test cases                   │
│ [ ] Write use case class                                   │
│ [ ] Validate email and password                            │
│ [ ] Call repository login method                           │
│ [ ] Return AuthResult                                      │
│ [ ] Run tests: flutter test test/features/auth/            │
│ [ ] Code coverage 80%+                                     │
│ [ ] No build errors: flutter analyze                       │
│ [ ] Commit with message                                    │
│ [ ] Mark complete in MVP_STATUS.md                         │
└─────────────────────────────────────────────────────────────┘
```

---

## TASK 2.2: Anonymous Login Use Case

```
┌─────────────────────────────────────────────────────────────┐
│ PHASE 2, TASK 2.2: Anonymous Login Use Case                │
├─────────────────────────────────────────────────────────────┤
│ Priority: 🔴 HIGH (blocks Phase 2)                          │
│ Estimated Time: 1 hour                                      │
│ Dependencies: Task 2.1 (same structure)                     │
│ Status: [ ] TODO / [ ] IN PROGRESS / [ ] COMPLETE          │
├─────────────────────────────────────────────────────────────┤
│ FILE TO CREATE:                                             │
│ lib/features/auth/domain/usecases/anonymous_login_usecase.dart
│                                                             │
│ DESCRIPTION:                                                │
│ Create use case for anonymous (guest) login                │
│                                                             │
│ ACCEPTANCE CRITERIA:                                        │
│ [ ] No parameters required                                 │
│ [ ] Returns AuthResult with anonymous user profile         │
│ [ ] Generates unique session ID                            │
│ [ ] Has unit tests                                         │
│                                                             │
│ NOTES:                                                      │
│ - Similar to Task 2.1 but without validation               │
│ - Must generate unique session ID for tracking             │
│ - Test successful anonymous login                          │
│                                                             │
│ CHECKLIST:                                                  │
│ [ ] Copy Task 2.1 structure                                │
│ [ ] Remove validation logic                                │
│ [ ] Add session ID generation (UUID)                       │
│ [ ] Create test file                                       │
│ [ ] Run tests: flutter test test/features/auth/            │
│ [ ] No build errors                                        │
│ [ ] Commit & mark complete                                 │
└─────────────────────────────────────────────────────────────┘
```

---

## TASK 2.3: Firebase Auth Datasource

```
┌─────────────────────────────────────────────────────────────┐
│ PHASE 2, TASK 2.3: Update Firebase Auth Datasource         │
├─────────────────────────────────────────────────────────────┤
│ Priority: 🔴 CRITICAL (integration)                         │
│ Estimated Time: 2 hours                                     │
│ Dependencies: Tasks 2.1, 2.2                               │
│ Status: [ ] TODO / [ ] IN PROGRESS / [x] COMPLETE          │
├─────────────────────────────────────────────────────────────┤
│ FILE TO UPDATE:                                             │
│ lib/features/auth/data/datasources/firebase_auth_datasource.dart
│                                                             │
│ DESCRIPTION:                                                │
│ Extend Firebase authentication to support both methods     │
│                                                             │
│ METHODS TO ADD:                                             │
│ [ ] signInAnonymously() → Future<User>                     │
│ [ ] signInWithEmail(email, password) → Future<User>        │
│                                                             │
│ ACCEPTANCE CRITERIA:                                        │
│ [ ] Anonymous login implemented                            │
│ [ ] Email/password login implemented                       │
│ [ ] Returns User with all fields                           │
│ [ ] Error handling for network failures                    │
│ [ ] Firebase console configured                            │
│                                                             │
│ CHECKLIST:                                                  │
│ [ ] Review existing Firebase setup                         │
│ [ ] Add signInAnonymously() method                         │
│ [ ] Add signInWithEmail() method                           │
│ [ ] Handle Firebase exceptions                             │
│ [ ] Test with firebase emulator or staging                │
│ [ ] Build succeeds                                         │
│ [ ] Commit & mark complete                                 │
└─────────────────────────────────────────────────────────────┘
```

---

## TASK 2.4: Auth State Provider

```
┌─────────────────────────────────────────────────────────────┐
│ PHASE 2, TASK 2.4: Create Auth State Provider              │
├─────────────────────────────────────────────────────────────┤
│ Priority: 🔴 CRITICAL (state management)                    │
│ Estimated Time: 2-3 hours                                   │
│ Dependencies: Tasks 2.1, 2.2, 2.3                          │
│ Status: [ ] TODO / [ ] IN PROGRESS / [ ] COMPLETE          │
├─────────────────────────────────────────────────────────────┤
│ FILE TO CREATE:                                             │
│ lib/features/auth/presentation/providers/auth_provider.dart│
│                                                             │
│ DESCRIPTION:                                                │
│ Create Riverpod provider for managing authentication state  │
│                                                             │
│ REQUIREMENTS:                                               │
│ [ ] NotifierProvider pattern (Riverpod 3.x)               │
│ [ ] Exposes isAuthenticated boolean                        │
│ [ ] Manages login/logout state                             │
│ [ ] Persists auth state to local storage                   │
│ [ ] Has getter for current user profile                    │
│                                                             │
│ METHODS NEEDED:                                             │
│ - login(email, password) → Future<void>                    │
│ - loginAnonymously() → Future<void>                        │
│ - logout() → Future<void>                                  │
│ - getCurrentUser() → User?                                 │
│ - isAuthenticated() → bool                                 │
│                                                             │
│ ARCHITECTURE:                                               │
│ Provider pattern from IMPLEMENTATION_SUMMARY.md             │
│ Use NotifierProvider (NOT StateNotifierProvider!)           │
│                                                             │
│ CHECKLIST:                                                  │
│ [ ] Create AuthNotifier class                              │
│ [ ] Implement build() method                               │
│ [ ] Add login() method                                     │
│ [ ] Add loginAnonymously() method                          │
│ [ ] Add logout() method                                    │
│ [ ] Create AuthState class                                 │
│ [ ] Write tests for all methods                            │
│ [ ] Build succeeds (0 new errors)                          │
│ [ ] Commit & mark complete                                 │
└─────────────────────────────────────────────────────────────┘
```

---

## TASK 2.5: Login Page UI

```
┌─────────────────────────────────────────────────────────────┐
│ PHASE 2, TASK 2.5: Enhance Login Page UI                   │
├─────────────────────────────────────────────────────────────┤
│ Priority: 🟡 HIGH (user-facing)                             │
│ Estimated Time: 2 hours                                     │
│ Dependencies: Tasks 2.1-2.4 (auth logic)                   │
│ Status: [ ] TODO / [ ] IN PROGRESS / [x] COMPLETE          │
├─────────────────────────────────────────────────────────────┤
│ FILE TO UPDATE:                                             │
│ lib/features/auth/presentation/login.dart                  │
│                                                             │
│ UI ELEMENTS NEEDED:                                         │
│ [ ] Email text field with validation                       │
│ [ ] Password text field with masking                       │
│ [ ] Login button (email/password)                          │
│ [ ] Anonymous login button (prominent)                     │
│ [ ] Error message display                                  │
│ [ ] Loading indicator during auth                          │
│ [ ] Responsive layout (mobile/tablet/desktop)              │
│                                                             │
│ ACCEPTANCE CRITERIA:                                        │
│ [ ] Both login methods implemented                         │
│ [ ] Proper input validation                                │
│ [ ] Error handling and display                             │
│ [ ] Loading states shown                                   │
│ [ ] Responsive design                                      │
│ [ ] No console errors                                      │
│                                                             │
│ CHECKLIST:                                                  │
│ [ ] Make login a ConsumerStatefulWidget                    │
│ [ ] Add email/password text fields                         │
│ [ ] Add login button (calls provider)                      │
│ [ ] Add anonymous login button                             │
│ [ ] Show error messages                                    │
│ [ ] Show loading indicator                                 │
│ [ ] Test on multiple screen sizes                          │
│ [ ] Build succeeds                                         │
│ [ ] Commit & mark complete                                 │
└─────────────────────────────────────────────────────────────┘
```

---

## TASK 2.6: Auth Guard

```
┌─────────────────────────────────────────────────────────────┐
│ PHASE 2, TASK 2.6: Create Auth Guard                       │
├─────────────────────────────────────────────────────────────┤
│ Priority: 🟡 HIGH (security)                                │
│ Estimated Time: 2 hours                                     │
│ Dependencies: Task 2.4 (auth provider)                     │
│ Status: [ ] TODO / [ ] IN PROGRESS / [x] COMPLETE          │
├─────────────────────────────────────────────────────────────┤
│ FILE TO CREATE:                                             │
│ lib/app/router/auth_guard.dart                             │
│                                                             │
│ DESCRIPTION:                                                │
│ Route guard to protect screens requiring authentication    │
│                                                             │
│ LOGIC:                                                      │
│ - Public routes: allow anyone                              │
│ - Protected routes: require logged-in user                 │
│ - Anonymous users: access library/player only              │
│                                                             │
│ ROUTE CATEGORIES:                                           │
│ Public:    '/', '/auth', '/splash'                         │
│ Protected: '/settings', '/sync', '/profile'                │
│ Any Auth:  '/library', '/playback', '/directory'           │
│                                                             │
│ ACCEPTANCE CRITERIA:                                        │
│ [ ] Checks authentication status                           │
│ [ ] Redirects unauthenticated to /auth                     │
│ [ ] Anonymous users access library/player                  │
│ [ ] Protected routes require full auth                     │
│ [ ] Works with AppRouter                                   │
│                                                             │
│ CHECKLIST:                                                  │
│ [ ] Create AuthGuard class                                 │
│ [ ] Implement canActivate() method                         │
│ [ ] Define route categories                                │
│ [ ] Check auth status from provider                        │
│ [ ] Return true/false                                      │
│ [ ] Test with different auth states                        │
│ [ ] Commit & mark complete                                 │
└─────────────────────────────────────────────────────────────┘
```

---

## TASK 2.7: Router Integration

```
┌─────────────────────────────────────────────────────────────┐
│ PHASE 2, TASK 2.7: Integrate Auth with Router              │
├─────────────────────────────────────────────────────────────┤
│ Priority: 🟡 HIGH (navigation)                              │
│ Estimated Time: 1-2 hours                                   │
│ Dependencies: Tasks 2.4, 2.6                               │
│ Status: [ ] TODO / [ ] IN PROGRESS / [ ] COMPLETE          │
├─────────────────────────────────────────────────────────────┤
│ FILE TO UPDATE:                                             │
│ lib/app/router/app_router.dart                             │
│                                                             │
│ REQUIREMENTS:                                               │
│ [ ] Routes check authentication status                     │
│ [ ] Unauthenticated users redirect to /auth               │
│ [ ] Auth guard applied to protected routes                 │
│ [ ] Navigation from splash to auth works                   │
│ [ ] Navigation after login to library works                │
│ [ ] Logout redirects to auth                               │
│                                                             │
│ FLOW:                                                       │
│ Splash → (3 sec) → Auth → (login) → Library → Playback    │
│                     ↓                                       │
│              (anonymous) → Library                          │
│                                                             │
│ ACCEPTANCE CRITERIA:                                        │
│ [ ] Routes use auth guard                                  │
│ [ ] Redirects work correctly                               │
│ [ ] No stack overflow                                      │
│ [ ] No infinite loops                                      │
│ [ ] Route names match                                      │
│ [ ] No console errors                                      │
│                                                             │
│ CHECKLIST:                                                  │
│ [ ] Add auth guard to router config                        │
│ [ ] Update route definitions                               │
│ [ ] Test navigation from splash                            │
│ [ ] Test login redirect                                    │
│ [ ] Test anonymous access                                  │
│ [ ] Test protected routes                                  │
│ [ ] Build succeeds                                         │
│ [ ] Commit & mark complete                                 │
└─────────────────────────────────────────────────────────────┘
```

---

## TASK 2.8: Auth Tests

```
┌─────────────────────────────────────────────────────────────┐
│ PHASE 2, TASK 2.8: Add Authentication Tests                │
├─────────────────────────────────────────────────────────────┤
│ Priority: 🟡 MEDIUM (quality assurance)                     │
│ Estimated Time: 3 hours                                     │
│ Dependencies: Tasks 2.1-2.7                                │
│ Status: [ ] TODO / [ ] IN PROGRESS / [x] COMPLETE          │
├─────────────────────────────────────────────────────────────┤
│ FILES TO CREATE:                                            │
│ test/features/auth/domain/usecases/login_usecase_test.dart │
│ test/features/auth/presentation/providers/auth_provider_test.dart
│                                                             │
│ TEST COVERAGE NEEDED:                                       │
│ [ ] Test successful email login                            │
│ [ ] Test failed login (wrong password)                     │
│ [ ] Test anonymous login                                   │
│ [ ] Test state persistence                                 │
│ [ ] Test logout functionality                              │
│ [ ] Test input validation                                  │
│ [ ] Test error handling                                    │
│ [ ] Test provider state changes                            │
│                                                             │
│ ACCEPTANCE CRITERIA:                                        │
│ [ ] All login flows tested                                 │
│ [ ] All error cases tested                                 │
│ [ ] 80%+ code coverage                                     │
│ [ ] All tests passing                                      │
│ [ ] Proper test organization                               │
│                                                             │
│ CHECKLIST:                                                  │
│ [ ] Create test files                                      │
│ [ ] Write login success test                               │
│ [ ] Write login failure test                               │
│ [ ] Write anonymous login test                             │
│ [ ] Write validation tests                                 │
│ [ ] Write state persistence tests                          │
│ [ ] Run tests: flutter test test/features/auth/            │
│ [ ] Check coverage: flutter test --coverage                │
│ [ ] Coverage >= 80%                                        │
│ [ ] All tests passing                                      │
│ [ ] Commit & mark complete                                 │
└─────────────────────────────────────────────────────────────┘
```

---

YOU MUST keep updating the MVP_STATUS.md , current_progress.txt and Work_completed.md files after completing eack task and then generate a complete report on the auth feature in a amrkdown format explaining the test results coverage reports and progress , if something has noit been implimented in the phase work on its completiion use @/documentation/DOCUMENTATION_INDEX.md file for correctly se3arching the docs , work on 100% implimentation of the above tasks
## 💻 Code Standards

### File Structure

```
feature/
├── domain/
│   ├── entities/          # Data models (no dependencies)
│   ├── repositories/      # Interfaces (abstract)
│   └── usecases/          # Business logic (one per file)
├── data/
│   ├── datasources/       # Firebase, Isar, APIs (local & remote)
│   ├── models/            # JSON serializable versions
│   └── repositories/      # Implement domain interfaces
└── presentation/
    ├── providers/         # Riverpod state management
    ├── views/             # Full screens
    └── widgets/           # Reusable UI components
```

### Naming Conventions

```dart
// Use Cases
class LoginUseCase { }
class GetAudiobooksUseCase { }

// Providers (Riverpod)
final loginUseCaseProvider = Provider((ref) => ...);
final authProvider = NotifierProvider<AuthNotifier, AuthState>(...);

// Entities
class User { }
class Audiobook { }

// Repositories
abstract class UserRepository { }
class UserRepositoryImpl implements UserRepository { }

// Datasources
class FirebaseAuthDatasource { }
class AudiobookLocalDatasource { }
```

### Import Organization

```dart
// 1. Dart imports
import 'dart:async';

// 2. Flutter imports
import 'package:flutter/material.dart';

// 3. Package imports
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 4. Relative imports (project)
import 'package:flutbook/features/auth/domain/entities/user.dart';
```

### Testing

```dart
// Location: test/features/[feature]/[layer]/[file]_test.dart
// Example: test/features/auth/domain/usecases/login_usecase_test.dart

void main() {
  group('LoginUseCase', () {
    // Setup
    late LoginUseCase useCase;
    late MockUserRepository mockUserRepository;

    setUp(() {
      mockUserRepository = MockUserRepository();
      useCase = LoginUseCase(mockUserRepository);
    });

    // Test
    test('should return user on successful login', () async {
      // Arrange
      when(mockUserRepository.loginWithEmail(any, any))
          .thenAnswer((_) async => mockUser);

      // Act
      final result = await useCase('test@test.com', 'password');

      // Assert
      expect(result.isSuccess, true);
      verify(mockUserRepository.loginWithEmail('test@test.com', 'password'))
          .called(1);
    });
  });
}
```

## 🧪 Testing Requirements

### Minimum Coverage Per Feature

- **Use Cases:** 100% (all paths tested)
- **Repositories:** 80%+ (happy path + errors)
- **Providers:** 80%+ (state changes, errors)
- **Screens:** 60%+ (navigation, interactions)
- **Widgets:** 60%+ (rendering, callbacks)

### Test Types Required

```
Domain Layer:
  ✓ Unit tests for use cases
  ✓ Test success and failure paths
  ✓ Test validation logic

Data Layer:
  ✓ Mock Firebase/Isar calls
  ✓ Test data transformation
  ✓ Test error handling

Presentation Layer:
  ✓ Widget tests for screens
  ✓ Provider state tests
  ✓ Navigation tests
```

### Running Tests

```bash
# All tests
flutter test

# Specific feature
flutter test test/features/auth/

# With coverage
flutter test --coverage

# View coverage report
genhtml coverage/lcov.info -o coverage/
open coverage/index.html

# Watch mode (auto-rerun)
flutter test --watch
```

---


## Files You'll Need
1. START_HERE.md
2. AGENT_INSTRUCTIONS.md
3. IMPLEMENTATION_SUMMARY.md (Phase 2 section)
 more files with specific documentation can be found in the ./documentation folder
Deadline: 6 hours from now
Update MVP_STATUS.md CURRENT_PROGRESS.txt, README_CURRENT_STATE.md and TASK_CARDS.md when complete
```

### Agent is Successful When:

✅ All assigned tasks are complete
✅ All acceptance criteria marked [x]
✅ All tests passing (100% for domain, 80%+ for others)
✅ Zero new build errors introduced
✅ Code follows established patterns
✅ Documentation updated
✅ No breaking changes to existing code
✅ Code reviewed by another agent/human
✅ Ready to merge without rework

---
📞 BLOCKERS:
- Ask in chat if stuck
- Check AGENT_INSTRUCTIONS.md first
- See DOCUMENTATION_INDEX.md for other docs

Questions? See DOCUMENTATION_INDEX.md

## Quick Links

@MVP_STATUS.md
@TASK_CARDS.md
@AGENT_INSTRUCTIONS.md
@START_HERE.md
### Phase 2: Authentication (CRITICAL - Start Here!)

**Files to Create:**
```
lib/features/auth/
├── domain/
│   └── usecases/
│       ├── login_usecase.dart (NEW - Task 2.1)
│       └── anonymous_login_usecase.dart (NEW - Task 2.2)
├── data/
│   └── datasources/
│       └── firebase_auth_datasource.dart (UPDATE - Task 2.3)
└── presentation/
    ├── providers/
    │   └── auth_provider.dart (NEW - Task 2.4)
    └── login.dart (UPDATE - Task 2.5)

lib/app/
├── router/
│   └── auth_guard.dart (NEW - Task 2.6)
```

**Task Order:**
1. **Task 2.1** - LoginUseCase (email validation)
2. **Task 2.2** - AnonymousLoginUseCase (guest login)
3. **Task 2.3** - Update Firebase datasource
4. **Task 2.4** - AuthProvider (Riverpod state)
5. **Task 2.5** - Login page UI
6. **Task 2.6** - Auth guard for routes
7. **Task 2.7** - Router integration
8. **Task 2.8** - Tests

**Key Pattern:** See IMPLEMENTATION_SUMMARY.md, "Use Case Pattern" section

**Tests Location:** `test/features/auth/domain/usecases/`

**Time Estimate:** 18 hours total (2-3 hours each task)

---
