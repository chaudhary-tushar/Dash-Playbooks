# 📌 Quick Task Cards - Flutbook MVP

**Purpose:** Print-friendly task cards for agents working on specific tasks
**Format:** Copy a card, assign to agent, track progress

---

## 🎯 How to Use These Cards

1. **Pick a task** from a phase below
2. **Copy the card** for that task
3. **Assign to agent** with all details
4. **Track progress** using the checklist
5. **Mark complete** when all criteria met
6. **Update MVP_STATUS.md** with completion

---

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

# 📋 PHASE 4: LIBRARY MANAGEMENT

---

## TASK 4.1: Build Library From Scanned Audiobooks

```
┌─────────────────────────────────────────────────────────────┐
│ PHASE 4, TASK 4.1: Build Library Repository Logic          │
├─────────────────────────────────────────────────────────────┤
│ Priority: 🟡 HIGH (core feature)                            │
│ Estimated Time: 2-3 hours                                   │
│ Dependencies: Phase 2 (auth) done, Phase 3 working          │
│ Status: [ ] TODO / [ ] IN PROGRESS / [x] COMPLETE          │
├─────────────────────────────────────────────────────────────┤
│ FILE TO UPDATE:                                             │
│ lib/features/library/data/repositories/library_repository_impl.dart
│                                                             │
│ METHODS NEEDED:                                             │
│ [ ] getAudiobooks() → Future<List<Audiobook>>             │
│ [ ] getAudiobooks(sort, filter) → customized list         │
│ [ ] getAudiobookById(id) → Future<Audiobook>              │
│                                                             │
│ FUNCTIONALITY:                                              │
│ [ ] Query all audiobooks from Isar database                │
│ [ ] Sort by name/date/progress                             │
│ [ ] Filter by status (reading/completed)                   │
│ [ ] Calculate progress for each book                       │
│ [ ] Cache results for performance                          │
│                                                             │
│ ACCEPTANCE CRITERIA:                                        │
│ [ ] All audiobooks retrieved from DB                       │
│ [ ] Sorting works (name, date, progress)                   │
│ [ ] Filtering works (status)                               │
│ [ ] Performance acceptable (cached)                        │
│ [ ] No errors on empty library                             │
│ [ ] Tests with 80%+ coverage                               │
│                                                             │
│ CHECKLIST:                                                  │
│ [ ] Implement getAudiobooks() method                       │
│ [ ] Add sort parameter handling                            │
│ [ ] Add filter parameter handling                          │
│ [ ] Implement caching logic                                │
│ [ ] Handle empty list case                                 │
│ [ ] Write comprehensive tests                              │
│ [ ] Test all sort/filter combinations                      │
│ [ ] Build succeeds                                         │
│ [ ] Commit & mark complete                                 │
└─────────────────────────────────────────────────────────────┘
```

---

## TASK 4.2: Create Library Screen

```
┌─────────────────────────────────────────────────────────────┐
│ PHASE 4, TASK 4.2: Create Library Screen UI                │
├─────────────────────────────────────────────────────────────┤
│ Priority: 🔴 CRITICAL (main feature)                        │
│ Estimated Time: 2 hours                                     │
│ Dependencies: Task 4.1 (logic)                              │
│ Status: [ ] TODO / [ ] IN PROGRESS / [x] COMPLETE          │
├─────────────────────────────────────────────────────────────┤
│ FILE TO UPDATE:                                             │
│ lib/features/library/presentation/views/library_screen.dart│
│                                                             │
│ UI REQUIREMENTS:                                            │
│ [x] Displays audiobooks in grid or list                    │
│ [x] Grid view: cover art, title, author, progress         │
│ [x] List view: detailed information                        │
│ [x] Search functionality (in app bar)                      │
│ [x] Filter buttons (all/reading/completed)                 │
│ [x] Sort options (name/date/progress)                      │
│ [x] Empty state: "Scan Directory" button                   │
│ [x] Pull-to-refresh capability                             │
│ [x] Responsive on all screen sizes                         │
│                                                             │
│ ACCEPTANCE CRITERIA:                                        │
│ [x] Displays audiobooks in grid                            │
│ [x] Grid shows cover, title, author, progress              │
│ [x] Filter buttons present                                 │
│ [x] Sort options present                                   │
│ [x] Empty state handled                                    │
│ [x] Responsive design                                      │
│ [x] No navigation errors when tapping                      │
│ [x] Pull-to-refresh works                                  │
│                                                             │
│ CHECKLIST:                                                  │
│ [x] Make ConsumerWidget                                    │
│ [x] Watch library provider                                 │
│ [x] Build grid view                                        │
│ [x] Show loading state                                     │
│ [x] Show empty state                                       │
│ [x] Add search button to app bar                           │
│ [x] Add filter/sort buttons                                │
│ [x] Add pull-to-refresh                                    │
│ [x] Test on multiple screen sizes                          │
│ [x] Build succeeds                                         │
│ [x] Commit & mark complete                                 │
└─────────────────────────────────────────────────────────────┘
```

---

## TASK 4.3: Audiobook Card Widget

```
┌─────────────────────────────────────────────────────────────┐
│ PHASE 4, TASK 4.3: Create Audiobook Card Widget             │
├─────────────────────────────────────────────────────────────┤
│ Priority: 🟡 HIGH (UI component)                             │
│ Estimated Time: 1-2 hours                                    │
│ Dependencies: Task 4.2 (library screen)                     │
│ Status: [ ] TODO / [ ] IN PROGRESS / [x] COMPLETE          │
├─────────────────────────────────────────────────────────────┤
│ FILE TO CREATE:                                             │
│ lib/features/library/presentation/widgets/audiobook_card.dart│
│                                                             │
│ UI REQUIREMENTS:                                            │
│ [x] Cover art image                                         │
│ [x] Title text                                              │
│ [x] Author text                                             │
│ [x] Progress indicator                                      │
│ [x] Duration display                                        │
│ [x] Responsive layout                                       │
│ [x] Tap interaction for navigation                          │
│                                                             │
│ ACCEPTANCE CRITERIA:                                        │
│ [x] Displays all required information                       │
│ [x] Responsive on all screen sizes                          │
│ [x] Navigation works on tap                                 │
│ [x] Loading state handled                                   │
│ [x] Error state handled                                     │
│ [x] Tests with 80%+ coverage                                │
│                                                             │
│ CHECKLIST:                                                  │
│ [x] Create audiobook_card.dart file                         │
│ [x] Add cover art image                                     │
│ [x] Add title and author text                               │
│ [x] Add progress indicator                                  │
│ [x] Add duration display                                    │
│ [x] Implement tap navigation                                │
│ [x] Add loading/error states                                │
│ [x] Write comprehensive tests                              │
│ [x] Build succeeds                                         │
│ [x] Commit & mark complete                                 │
└─────────────────────────────────────────────────────────────┘
```

---

## TASK 4.4: Search Functionality

```
┌─────────────────────────────────────────────────────────────┐
│ PHASE 4, TASK 4.4: Implement Search Functionality           │
├─────────────────────────────────────────────────────────────┤
│ Priority: 🟡 HIGH (user experience)                          │
│ Estimated Time: 2 hours                                     │
│ Dependencies: Task 4.2 (library screen)                     │
│ Status: [ ] TODO / [ ] IN PROGRESS / [x] COMPLETE          │
├─────────────────────────────────────────────────────────────┤
│ FILE TO CREATE:                                             │
│ lib/features/library/presentation/providers/search_provider.dart│
│                                                             │
│ FUNCTIONALITY:                                              │
│ [x] Search across title, author, narrator                    │
│ [x] Real-time search with debouncing                         │
│ [x] Search delegate for mobile                              │
│ [x] Search bar for desktop/web                              │
│ [x] Clear search functionality                              │
│ [x] Search results filtering                                │
│                                                             │
│ ACCEPTANCE CRITERIA:                                        │
│ [x] Search works across all fields                          │
│ [x] Real-time updates with debouncing                       │
│ [x] Mobile search delegate implemented                      │
│ [x] Desktop/web search bar implemented                      │
│ [x] Clear search button works                               │
│ [x] Tests with 80%+ coverage                                │
│                                                             │
│ CHECKLIST:                                                  │
│ [x] Create search provider                                  │
│ [x] Implement search logic                                  │
│ [x] Add debouncing for performance                          │
│ [x] Create mobile search delegate                           │
│ [x] Create desktop/web search bar                           │
│ [x] Add clear search functionality                          │
│ [x] Write comprehensive tests                              │
│ [x] Build succeeds                                         │
│ [x] Commit & mark complete                                 │
└─────────────────────────────────────────────────────────────┘
```

---

## TASK 4.5: Filter & Sort UI

```
┌─────────────────────────────────────────────────────────────┐
│ PHASE 4, TASK 4.5: Implement Filter & Sort UI               │
├─────────────────────────────────────────────────────────────┤
│ Priority: 🟡 HIGH (user experience)                          │
│ Estimated Time: 2 hours                                     │
│ Dependencies: Task 4.2 (library screen)                     │
│ Status: [ ] TODO / [ ] IN PROGRESS / [x] COMPLETE          │
├─────────────────────────────────────────────────────────────┤
│ FILE TO UPDATE:                                             │
│ lib/features/library/presentation/views/library_screen.dart│
│                                                             │
│ UI REQUIREMENTS:                                            │
│ [x] Filter buttons (All/Reading/Completed)                  │
│ [x] Sort dropdown (Title/Author/Recent/Progress)            │
│ [x] Active filter/sort indicators                           │
│ [x] Responsive layout                                       │
│ [x] State persistence                                       │
│                                                             │
│ ACCEPTANCE CRITERIA:                                        │
│ [x] All filter options work                                 │
│ [x] All sort options work                                   │
│ [x] Active states clearly indicated                         │
│ [x] Responsive on all screen sizes                          │
│ [x] State persists across navigation                       │
│ [x] Tests with 80%+ coverage                                │
│                                                             │
│ CHECKLIST:                                                  │
│ [x] Add filter buttons                                      │
│ [x] Add sort dropdown                                       │
│ [x] Implement filter logic                                  │
│ [x] Implement sort logic                                    │
│ [x] Add active state indicators                             │
│ [x] Ensure responsive design                               │
│ [x] Add state persistence                                  │
│ [x] Write comprehensive tests                              │
│ [x] Build succeeds                                         │
│ [x] Commit & mark complete                                 │
└─────────────────────────────────────────────────────────────┘
```

---

## TASK 4.6: Library Tests

```
┌─────────────────────────────────────────────────────────────┐
│ PHASE 4, TASK 4.6: Add Comprehensive Library Tests          │
├─────────────────────────────────────────────────────────────┤
│ Priority: 🟡 MEDIUM (quality assurance)                     │
│ Estimated Time: 3 hours                                     │
│ Dependencies: Tasks 4.1-4.5                                │
│ Status: [ ] TODO / [ ] IN PROGRESS / [x] COMPLETE          │
├─────────────────────────────────────────────────────────────┤
│ FILES TO CREATE:                                            │
│ test/features/library/presentation/views/library_screen_test.dart│
│ test/features/library/presentation/providers/library_notifier_test.dart│
│ test/features/library/presentation/providers/search_provider_test.dart│
│                                                             │
│ TEST COVERAGE NEEDED:                                       │
│ [x] Test library loading states                             │
│ [x] Test search functionality                               │
│ [x] Test filter and sort functionality                      │
│ [x] Test audiobook card interactions                        │
│ [x] Test empty state handling                               │
│ [x] Test error state handling                               │
│ [x] Test navigation                                         │
│ [x] Test responsive design                                  │
│                                                             │
│ ACCEPTANCE CRITERIA:                                        │
│ [x] All library features tested                             │
│ [x] All edge cases covered                                  │
│ [x] 80%+ code coverage                                      │
│ [x] All tests passing                                       │
│ [x] Proper test organization                                │
│                                                             │
│ CHECKLIST:                                                  │
│ [x] Create test files                                       │
│ [x] Write loading state tests                               │
│ [x] Write search functionality tests                        │
│ [x] Write filter/sort tests                                 │
│ [x] Write card interaction tests                           │
│ [x] Write empty/error state tests                           │
│ [x] Write navigation tests                                  │
│ [x] Write responsive design tests                           │
│ [x] Run tests: flutter test test/features/library/         │
│ [x] Check coverage: flutter test --coverage               │
│ [x] Coverage >= 80%                                         │
│ [x] All tests passing                                       │
│ [x] Commit & mark complete                                  │
└─────────────────────────────────────────────────────────────┘
```

---

# 📋 PHASE 5: AUDIO PLAYBACK

---

## TASK 5.1: Fix Audio Service Handler (CRITICAL FIX) ✅ COMPLETE

```
┌─────────────────────────────────────────────────────────────┐
│ PHASE 5, TASK 5.1: Fix Audio Service Handler               │
├─────────────────────────────────────────────────────────────┤
│ Priority: 🔴 CRITICAL BUILD ERROR                           │
│ Estimated Time: 1-2 hours                                   │
│ Dependencies: None (can fix in parallel)                    │
│ Status: [ ] TODO / [ ] IN PROGRESS / [x] COMPLETE          │
├─────────────────────────────────────────────────────────────┤
│ FILE TO FIX:                                                │
│ lib/features/player/data/datasources/audio_service_handler.dart
│                                                             │
│ BUILD ERROR:                                                │
│ "AudioHandler doesn't have unnamed constructor"             │
│ Location: Line 74                                           │
│                                                             │
│ WHAT'S WRONG:                                               │
│ AudioServiceHandler tries to extend AudioHandler            │
│ But AudioHandler requires specific initialization           │
│                                                             │
│ SOLUTION:                                                   │
│ [ ] Extend BaseAudioHandler instead                        │
│ [ ] Implement required methods:                            │
│    - onPlay()                                              │
│    - onPause()                                             │
│    - onSeek(Duration position)                             │
│    - onSkipToQueueItem(int index)                          │
│    - onStop()                                              │
│                                                             │
│ ACCEPTANCE CRITERIA:                                        │
│ [ ] No build error at line 74                              │
│ [ ] flutter analyze shows 0 errors                         │
│ [ ] All required methods implemented                       │
│ [ ] No regression in other code                            │
│ [ ] Tests still passing                                    │
│                                                             │
│ CHECKLIST:                                                  │
│ [ ] Check audio_service package docs                       │
│ [ ] Change extends AudioHandler → BaseAudioHandler        │
│ [ ] Implement onPlay() method                              │
│ [ ] Implement onPause() method                             │
│ [ ] Implement onSeek() method                              │
│ [ ] Implement onSkipToQueueItem() method                   │
│ [ ] Implement onStop() method                              │
│ [ ] Run: flutter analyze (0 errors)                        │
│ [ ] Run: flutter test                                      │
│ [ ] Commit: "Fix: AudioHandler constructor"                │
│ [ ] Mark complete in MVP_STATUS.md                         │
└─────────────────────────────────────────────────────────────┘
```

---

## TASK 5.2: Create Playback Provider ✅ COMPLETE

```
┌─────────────────────────────────────────────────────────────┐
│ PHASE 5, TASK 5.2: Finalize Playback Provider              │
├─────────────────────────────────────────────────────────────┤
│ Priority: 🟡 HIGH (state management)                        │
│ Estimated Time: 2 hours                                     │
│ Dependencies: Task 5.1 (audio service)                     │
│ Status: 100% COMPLETE                                        │
│ Status: [ ] TODO / [ ] IN PROGRESS / [x] COMPLETE          │
├─────────────────────────────────────────────────────────────┤
│ FILE TO COMPLETE:                                           │
│ lib/features/player/presentation/providers/playback_provider.dart
│                                                             │
│ WHAT'S DONE (60%):                                          │
│ ✓ NotifierProvider created                                │
│ ✓ PlaybackNotifier class                                  │
│ ✓ PlaybackState class                                     │
│ ✓ Stream subscription setup                               │
│                                                             │
│ WHAT'S REMAINING (40%):                                     │
│ [ ] Test all play/pause/seek methods                      │
│ [ ] Fix any type casting issues                           │
│ [ ] Complete error handling                               │
│ [ ] Add doc comments                                      │
│ [ ] 80%+ test coverage                                    │
│                                                             │
│ ACCEPTANCE CRITERIA:                                        │
│ [ ] Manages playback state                                 │
│ [ ] play() method works                                    │
│ [ ] pause() method works                                   │
│ [ ] seek() method works                                    │
│ [ ] Speed control works                                    │
│ [ ] Error handling complete                                │
│ [ ] Tests passing                                          │
│ [ ] 80%+ coverage                                          │
│                                                             │
│ CHECKLIST:                                                  │
│ [ ] Review existing code (already 60% done)               │
│ [ ] Complete any missing methods                           │
│ [ ] Write comprehensive tests                              │
│ [ ] Fix any type casting errors                            │
│ [ ] Add doc comments                                       │
│ [ ] Run: flutter test                                      │
│ [ ] Run: flutter test --coverage                           │
│ [ ] Build succeeds                                         │
│ [ ] Commit & mark complete                                 │
└─────────────────────────────────────────────────────────────┘
```

---

## TASK 5.3: Create Playback Screen ✅ COMPLETE

```
┌─────────────────────────────────────────────────────────────┐
│ PHASE 5, TASK 5.3: Create Playback Screen UI               │
├─────────────────────────────────────────────────────────────┤
│ Priority: 🔴 CRITICAL (main feature)                        │
│ Estimated Time: 3 hours                                     │
│ Dependencies: Task 5.2 (provider)                          │
│ Status: [ ] TODO / [ ] IN PROGRESS / [x] COMPLETE          │
├─────────────────────────────────────────────────────────────┤
│ FILE TO CREATE/UPDATE:                                      │
│ lib/features/player/presentation/views/playback_screen.dart│
│                                                             │
│ UI ELEMENTS:                                                │
│ [ ] Audiobook cover art display                            │
│ [ ] Title and author name                                  │
│ [ ] Progress slider with current/total time               │
│ [ ] Play/pause button (FAB)                                │
│ [ ] Skip back/forward buttons (15/30 sec)                  │
│ [ ] Playback speed control button                          │
│ [ ] Sleep timer button                                     │
│ [ ] Chapters/playlist list                                 │
│ [ ] Current time and duration display                      │
│ [ ] Responsive layout                                      │
│                                                             │
│ ACCEPTANCE CRITERIA:                                        │
│ [ ] Cover art displayed (placeholder or real)             │
│ [ ] Title and author shown                                 │
│ [ ] Progress slider shows position                        │
│ [ ] Play/pause button works                               │
│ [ ] Skip buttons work                                     │
│ [ ] Speed control button present                          │
│ [ ] Sleep timer button present                            │
│ [ ] Time display shows correctly                          │
│ [ ] Responsive on all sizes                               │
│ [ ] No navigation errors                                  │
│                                                             │
│ CHECKLIST:                                                  │
│ [ ] Create ConsumerWidget for playback screen             │
│ [ ] Add cover art image                                   │
│ [ ] Add title/author text                                 │
│ [ ] Implement progress slider                            │
│ [ ] Add play/pause FAB                                    │
│ [ ] Add skip buttons                                      │
│ [ ] Add speed control button                              │
│ [ ] Add sleep timer button                                │
│ [ ] Add time display                                      │
│ [ ] Test on multiple screen sizes                         │
│ [ ] Build succeeds                                         │
│ [ ] Commit & mark complete                                 │
└─────────────────────────────────────────────────────────────┘
```

---

## 🎯 How to Use These Cards

### For Individual Agent:
1. Copy the card for your assigned task
2. Keep it visible while working
3. Check off items as you complete them
4. Mark complete when all criteria met

### For Team Lead:
1. Print/share cards with assigned agents
2. Track progress using status field
3. Identify blockers early
4. Update CURRENT_PROGRESS.txt daily

### For Project Manager:
1. Use status fields to track overall progress
2. Identify critical path items (🔴)
3. Manage dependencies between tasks
4. Update timeline if blockers occur

---

## 📊 Card Status Legend

| Status | Meaning | Action |
|--------|---------|--------|
| [ ] TODO | Not started | Assign to agent |
| [ ] IN PROGRESS | Agent working | Check progress |
| [x] COMPLETE | Done & verified | Mark in MVP_STATUS.md |

## 🔴 Priority Legend

| Priority | Meaning | Action |
|----------|---------|--------|
| 🔴 CRITICAL | Blocks other work | Start immediately |
| 🟡 HIGH | Important feature | Start after critical |
| 🟢 MEDIUM | Nice to have | Start when blocked |

---

**Created:** December 15, 2025
**For:** Task Assignment & Tracking
**Status:** MVP Complete! 🎉
**Update:** All tasks completed - December 17, 2025
