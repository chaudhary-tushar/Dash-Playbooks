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
│ Status: [ ] TODO / [ ] IN PROGRESS / [ ] COMPLETE          │
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
│ Status: [ ] TODO / [ ] IN PROGRESS / [ ] COMPLETE          │
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
│ Status: [ ] TODO / [ ] IN PROGRESS / [ ] COMPLETE          │
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
│ Status: [ ] TODO / [ ] IN PROGRESS / [ ] COMPLETE          │
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
│ Status: [ ] TODO / [ ] IN PROGRESS / [ ] COMPLETE          │
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
│ Status: [ ] TODO / [ ] IN PROGRESS / [ ] COMPLETE          │
├─────────────────────────────────────────────────────────────┤
│ FILE TO UPDATE:                                             │
│ lib/features/library/presentation/views/library_screen.dart│
│                                                             │
│ UI REQUIREMENTS:                                            │
│ [ ] Displays audiobooks in grid or list                    │
│ [ ] Grid view: cover art, title, author, progress         │
│ [ ] List view: detailed information                        │
│ [ ] Search functionality (in app bar)                      │
│ [ ] Filter buttons (all/reading/completed)                 │
│ [ ] Sort options (name/date/progress)                      │
│ [ ] Empty state: "Scan Directory" button                   │
│ [ ] Pull-to-refresh capability                             │
│ [ ] Responsive on all screen sizes                         │
│                                                             │
│ ACCEPTANCE CRITERIA:                                        │
│ [x] Displays audiobooks in grid                            │
│ [ ] Grid shows cover, title, author, progress              │
│ [ ] Filter buttons present                                 │
│ [ ] Sort options present                                   │
│ [ ] Empty state handled                                    │
│ [ ] Responsive design                                      │
│ [ ] No navigation errors when tapping                      │
│ [ ] Pull-to-refresh works                                  │
│                                                             │
│ CHECKLIST:                                                  │
│ [ ] Make ConsumerWidget                                    │
│ [ ] Watch library provider                                 │
│ [ ] Build grid view                                        │
│ [ ] Show loading state                                     │
│ [ ] Show empty state                                       │
│ [ ] Add search button to app bar                           │
│ [ ] Add filter/sort buttons                                │
│ [ ] Add pull-to-refresh                                    │
│ [ ] Test on multiple screen sizes                          │
│ [ ] Build succeeds                                         │
│ [ ] Commit & mark complete                                 │
└─────────────────────────────────────────────────────────────┘
```

---

# 📋 PHASE 5: AUDIO PLAYBACK

---

## TASK 5.1: Fix Audio Service Handler (CRITICAL FIX)

```
┌─────────────────────────────────────────────────────────────┐
│ PHASE 5, TASK 5.1: Fix Audio Service Handler               │
├─────────────────────────────────────────────────────────────┤
│ Priority: 🔴 CRITICAL BUILD ERROR                           │
│ Estimated Time: 1-2 hours                                   │
│ Dependencies: None (can fix in parallel)                    │
│ Status: [ ] TODO / [ ] IN PROGRESS / [ ] COMPLETE          │
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

## TASK 5.2: Create Playback Provider

```
┌─────────────────────────────────────────────────────────────┐
│ PHASE 5, TASK 5.2: Finalize Playback Provider              │
├─────────────────────────────────────────────────────────────┤
│ Priority: 🟡 HIGH (state management)                        │
│ Estimated Time: 2 hours                                     │
│ Dependencies: Task 5.1 (audio service)                     │
│ Status: ⏳ 60% COMPLETE (FIXED TODAY)                        │
│ Status: [ ] TODO / [x] IN PROGRESS / [ ] COMPLETE          │
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

## TASK 5.3: Create Playback Screen

```
┌─────────────────────────────────────────────────────────────┐
│ PHASE 5, TASK 5.3: Create Playback Screen UI               │
├─────────────────────────────────────────────────────────────┤
│ Priority: 🔴 CRITICAL (main feature)                        │
│ Estimated Time: 3 hours                                     │
│ Dependencies: Task 5.2 (provider)                          │
│ Status: [ ] TODO / [ ] IN PROGRESS / [ ] COMPLETE          │
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
**Status:** Ready to Deploy
**Update:** Daily as tasks complete
