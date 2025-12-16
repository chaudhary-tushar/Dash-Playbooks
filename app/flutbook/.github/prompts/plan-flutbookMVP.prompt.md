# 🎯 Flutbook MVP Development Tasks

> **Project:** Flutter Audiobook Player Application
> **Version:** MVP 1.0
> **Last Updated:** December 15, 2025
> **Status:** In Progress (Phases 1-3 ~70% Complete, Phases 4-5 Starting)

---

## 📋 Quick Start Guide

### Prerequisites
```bash
# Flutter & Dart setup
flutter --version
dart --version

# Install dependencies
flutter pub get

# Install code generation tools
flutter pub get && dart run build_runner build --delete-conflicting-outputs
```

### Running the App

```bash
# Development flavor
flutter run --flavor development --target lib/main_development.dart

# Staging flavor
flutter run --flavor staging --target lib/main_staging.dart

# Production flavor
flutter run --flavor production --target lib/main_production.dart

# Web (for testing splash + auth)
flutter run -d chrome --target lib/main_development.dart

# With verbose logging
flutter run -v --flavor development --target lib/main_development.dart
```

### Running Tests

```bash
# All tests with coverage
very_good test --coverage --test-randomize-ordering-seed random

# Single file tests
flutter test test/features/splash/
flutter test test/features/auth/

# View coverage report
genhtml coverage/lcov.info -o coverage/
open coverage/index.html
```

---

## 🎬 Phase 1: Splash Screen (2-3 Tasks)

> **Status:** ✅ ~90% Complete
> **Estimated Time:** 0.5-1 day
> **Priority:** Critical (App Entry Point)

The splash screen is the first screen users see. It initializes the app and navigates to authentication.

### Task 1.1: Finalize Splash Screen UI

**Status:** ✅ Completed
**File:** `lib/features/splash/presentation/view/splash_screen.dart`

**Description:**
Ensure the splash screen displays branding, loading indicator, and handles app initialization.

**Acceptance Criteria:**
- [x] Displays app logo/icon and name
- [x] Shows loading progress indicator
- [x] Automatically navigates to auth after 3 seconds
- [x] Responsive on mobile, tablet, and desktop
- [x] Dark/light theme support
- [x] No navigation errors

**Code Example:**
```dart
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/auth');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.headset, size: 100),
              SizedBox(height: 24),
              Text('Flutbook', style: Theme.of(context).textTheme.headlineMedium),
              SizedBox(height: 48),
              CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

### Task 1.2: Integrate with App Router

**Status:** ✅ Completed
**File:** `lib/app/router/app_router.dart`

**Description:**
Ensure the app router properly routes to the splash screen on app start and auth screen after initialization.

**Acceptance Criteria:**
- [x] `/` route displays `SplashScreen`
- [x] `/auth` route is accessible
- [x] Navigation from splash to auth works
- [x] No stack overflow or infinite loops
- [x] Route names match router configuration

---

### Task 1.3: Error Handling & Fallbacks

**Status:** [ ] Pending
**File:** `lib/features/splash/presentation/view/splash_screen.dart`

**Description:**
Add error handling for initialization failures and provide fallback UI if startup fails.

**Acceptance Criteria:**
- [ ] Try-catch around initialization code
- [ ] Error message displayed if initialization fails
- [ ] Retry button available
- [ ] Logs initialization errors for debugging

**Code Example:**
```dart
@override
void initState() {
  super.initState();
  _initializeApp();
}

Future<void> _initializeApp() async {
  try {
    // Initialize app services
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/auth');
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Initialization failed: $e')),
      );
    }
  }
}
```

---

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

## 📂 Phase 3: Directory Selection & Scanning (6 Tasks)

> **Status:** ✅ ~85% Complete
> **Estimated Time:** 1-2 days
> **Priority:** Critical (Core Functionality)
> **Dependencies:** Phase 1-2 Complete

Allow users to select a directory and scan for audiobooks.

### Task 3.1: Implement Directory Picker for Web

**Status:** ⏳ ~50% Complete
**File:** `lib/features/directory_selection/data/datasources/system_directory_picker_ds.dart`

**Description:**
Extend directory picker to support web platform using `file_picker` plugin.

**Acceptance Criteria:**
- [x] Mobile: Uses native directory picker
- [ ] Web: Uses file picker for audio files
- [ ] Handles permissions gracefully
- [ ] Returns selected directory path
- [ ] Error handling for permission denied

**Code Example:**
```dart
class SystemDirectoryPickerDatasource {
  Future<String?> pickDirectory() async {
    if (kIsWeb) {
      // Web: Use file_picker for audio files
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: true,
      );
      return result?.paths.first;
    } else {
      // Mobile: Use native directory picker
      final result = await getDirectoryPath();
      return result;
    }
  }
}
```

---

### Task 3.2: Enhance Metadata Extraction

**Status:** ✅ Completed
**File:** `lib/features/directory_selection/data/datasources/metadat_extractor_ds.dart`

**Description:**
Improve metadata extraction to capture author, cover art, and chapter information.

**Acceptance Criteria:**
- [x] Extracts title from file/tags
- [x] Extracts duration
- [x] Extracts file size
- [x] Handles ID3 tags when available
- [ ] Extracts cover art from tags (web support)
- [ ] Graceful fallback for missing metadata
- [ ] Performance optimized for large libraries

---

### Task 3.3: Finalize Scan Use Case

**Status:** ✅ Completed
**File:** `lib/features/directory_selection/domain/usecases/scan_library_usecase.dart`

**Description:**
Complete the scanning use case with error handling and result building.

**Acceptance Criteria:**
- [x] Scans directory for audio files
- [x] Extracts metadata for each file
- [x] Saves results to local database
- [x] Returns scan result with summary
- [x] Handles errors gracefully (skip bad files)
- [x] No circular dependencies
- [x] Proper dependency injection

---

### Task 3.4: Add User Input Validation

**Status:** ⏳ ~70% Complete
**File:** `lib/features/directory_selection/presentation/view/directory_selection_screen.dart`

**Description:**
Validate user input and provide clear feedback before scanning.

**Acceptance Criteria:**
- [x] Continue button disabled until directory selected
- [ ] Validate directory exists and is readable
- [x] Show loading indicator during scan
- [ ] Display scan results (files found, errors)
- [ ] Allow retry if scan fails
- [ ] Estimated time display

**Code Example:**
```dart
class DirectorySelectionScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<DirectorySelectionScreen> createState() =>
      _DirectorySelectionScreenState();
}

class _DirectorySelectionScreenState
    extends ConsumerState<DirectorySelectionScreen> {
  String? selectedPath;

  Future<void> _handleContinuePressed() async {
    if (selectedPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a directory')),
      );
      return;
    }

    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Scanning directory...')),
    );

    // Scan
    final scanUseCase = ref.read(scanLibraryUseCaseProvider);
    final result = await scanUseCase.execute(selectedPath!);

    // Navigate
    if (result.scannedFiles > 0) {
      Navigator.pushReplacementNamed(context, '/library');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Directory')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (selectedPath != null) Text('Selected: $selectedPath'),
            ElevatedButton(
              onPressed: () { /* Pick directory */ },
              child: const Text('Browse'),
            ),
            ElevatedButton(
              onPressed: selectedPath != null ? _handleContinuePressed : null,
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### Task 3.5: Handle Storage Permissions

**Status:** [ ] Pending
**File:** `lib/features/directory_selection/data/datasources/system_directory_picker_ds.dart`

**Description:**
Request and handle storage permissions on Android and iOS.

**Acceptance Criteria:**
- [ ] Request permissions before directory access
- [ ] Handle permission denied gracefully
- [ ] Show permission rationale to user
- [ ] Fallback to default directory if needed

---

### Task 3.6: Add Scanning Tests

**Status:** [ ] Pending
**Files:**
- `test/features/directory_selection/domain/usecases/scan_library_usecase_test.dart`
- `test/features/directory_selection/presentation/view/directory_selection_screen_test.dart`

**Description:**
Create tests for scanning workflow.

**Acceptance Criteria:**
- [ ] Test scanning valid directory
- [ ] Test handling invalid directory
- [ ] Test metadata extraction
- [ ] Test database persistence
- [ ] Test error recovery
- [ ] 80%+ code coverage

---

## 📚 Phase 4: Library Management (6 Tasks)

> **Status:** ⏳ ~40% Complete
> **Estimated Time:** 2-3 days
> **Priority:** High (Core UI)
> **Dependencies:** Phase 3 Complete

Display and manage the user's audiobook library.

### Task 4.1: Build Library from Scanned Audiobooks

**Status:** ⏳ ~50% Complete
**File:** `lib/features/library/data/repositories/library_repository_impl.dart`

**Description:**
Implement repository logic to build and organize library from scanned audiobooks.

**Acceptance Criteria:**
- [ ] Query all audiobooks from Isar database
- [ ] Sort by name/date/progress
- [ ] Filter by status (reading/completed/wishlist)
- [ ] Calculate progress for each book
- [ ] Cache results for performance

**Code Example:**
```dart
class LibraryRepositoryImpl implements LibraryRepository {
  LibraryRepositoryImpl(this._localDatasource);

  final AudiobookLocalDatasource _localDatasource;

  Future<List<Audiobook>> getAudiobooks({
    String? sortBy,
    String? filterBy,
  }) async {
    var audiobooks = await _localDatasource.getAllAudiobooks();

    // Filter
    if (filterBy == 'reading') {
      audiobooks = audiobooks
          .where((a) => a.progress < 100)
          .toList();
    } else if (filterBy == 'completed') {
      audiobooks = audiobooks
          .where((a) => a.progress == 100)
          .toList();
    }

    // Sort
    if (sortBy == 'name') {
      audiobooks.sort((a, b) => a.title.compareTo(b.title));
    } else if (sortBy == 'date') {
      audiobooks.sort((a, b) => b.addedAt.compareTo(a.addedAt));
    }

    return audiobooks;
  }
}
```

---

### Task 4.2: Create Library Screen

**Status:** ⏳ ~60% Complete
**File:** `lib/features/library/presentation/views/library_screen.dart`

**Description:**
Implement the main library screen with grid/list view, search, and filters.

**Acceptance Criteria:**
- [x] Displays audiobooks in grid or list
- [ ] Grid view shows cover art, title, author, progress
- [ ] List view shows detailed information
- [ ] Search functionality
- [ ] Filter buttons (all/reading/completed)
- [ ] Sort options (name/date/progress)
- [ ] Empty state with "Scan Directory" button
- [ ] Responsive on all screen sizes
- [ ] Pull-to-refresh capability
- [ ] No navigation errors when tapping books

**Code Example:**
```dart
class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audiobooksAsync = ref.watch(getAudiobooksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () { /* Show search */ },
          ),
        ],
      ),
      body: audiobooksAsync.when(
        data: (audiobooks) {
          if (audiobooks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.book_outlined, size: 64),
                  const SizedBox(height: 16),
                  const Text('No audiobooks found'),
                  ElevatedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/directory'),
                    child: const Text('Scan Directory'),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
            ),
            itemCount: audiobooks.length,
            itemBuilder: (context, index) {
              return AudiobookCard(audiobook: audiobooks[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, st) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
```

---

### Task 4.3: Create Audiobook Card Widget

**Status:** ⏳ ~70% Complete
**File:** `lib/features/library/presentation/widgets/audiobook_card.dart`

**Description:**
Create a reusable card widget to display audiobook information.

**Acceptance Criteria:**
- [x] Shows cover art placeholder or real image
- [x] Displays title and author
- [x] Shows progress indicator
- [ ] Tap navigates to detail screen
- [ ] Long-press shows context menu
- [ ] Smooth animations
- [ ] Error states handled

---

### Task 4.4: Implement Search Functionality

**Status:** [ ] Pending
**File:** `lib/features/library/presentation/providers/library_provider.dart`

**Description:**
Add search to find audiobooks by title, author, or keywords.

**Acceptance Criteria:**
- [ ] Search bar in app bar
- [ ] Real-time search results
- [ ] Case-insensitive search
- [ ] Search across title and author
- [ ] Clear button in search field
- [ ] Debounce for performance

**Code Example:**
```dart
final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredAudiobooksProvider = FutureProvider((ref) async {
  final query = ref.watch(searchQueryProvider);
  final audiobooks = await ref.watch(getAudiobooksProvider.future);

  if (query.isEmpty) return audiobooks;

  final lowerQuery = query.toLowerCase();
  return audiobooks
      .where((book) =>
          book.title.toLowerCase().contains(lowerQuery) ||
          book.author?.toLowerCase().contains(lowerQuery) ?? false)
      .toList();
});
```

---

### Task 4.5: Create Filter and Sort UI

**Status:** [ ] Pending
**File:** `lib/features/library/presentation/views/library_screen.dart`

**Description:**
Add UI controls for filtering and sorting library.

**Acceptance Criteria:**
- [ ] Filter buttons: All/Reading/Completed/Wishlist
- [ ] Sort dropdown: Name/Date Added/Progress
- [ ] View toggle: Grid/List
- [ ] Filters persist during session
- [ ] Visual feedback for active filters

---

### Task 4.6: Add Library Tests

**Status:** [ ] Pending
**Files:**
- `test/features/library/domain/usecases/get_audiobooks_usecase_test.dart`
- `test/features/library/presentation/views/library_screen_test.dart`

**Description:**
Create tests for library functionality.

**Acceptance Criteria:**
- [ ] Test fetching all audiobooks
- [ ] Test filtering
- [ ] Test sorting
- [ ] Test search
- [ ] Test empty state
- [ ] Widget test for library screen
- [ ] 80%+ code coverage

---

## 🎵 Phase 5: Audio Playback (10 Tasks)

> **Status:** ⏳ ~30% Complete
> **Estimated Time:** 4-5 days
> **Priority:** High (Core Feature)
> **Dependencies:** Phase 4 Complete

Implement full audio playback with controls, progress tracking, and state management.

### Task 5.1: Set Up Audio Service

**Status:** ⏳ ~50% Complete
**File:** `lib/features/player/data/datasources/audio_service_handler.dart`

**Description:**
Configure background audio service using `audio_service` and `just_audio` packages.

**Acceptance Criteria:**
- [x] Audio service handler initialized
- [ ] Background playback working
- [ ] Lock screen controls functional
- [ ] Notification integration
- [ ] Audio focus management
- [ ] Proper cleanup on app close

**Code Example:**
```dart
class AudioServiceHandler extends BaseAudioHandler {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  Future<void> play() async {
    await _audioPlayer.play();
  }

  @override
  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  @override
  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  @override
  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  Future<void> setAudioSource(String filePath) async {
    await _audioPlayer.setFilePath(filePath);
  }
}
```

---

### Task 5.2: Create Playback Provider

**Status:** ⏳ ~60% Complete
**File:** `lib/features/player/presentation/providers/playback_provider.dart`

**Description:**
Implement Riverpod provider for playback state management.

**Acceptance Criteria:**
- [x] Manages current audiobook
- [x] Tracks playback position
- [x] Exposes play/pause/seek methods
- [x] Provides playback speed state
- [ ] Sleep timer integration
- [ ] History tracking
- [ ] Persistent playback position

---

### Task 5.3: Create Playback Screen

**Status:** ⏳ ~50% Complete
**File:** `lib/features/player/presentation/views/playback_screen.dart`

**Description:**
Build the playback screen with controls and progress tracking.

**Acceptance Criteria:**
- [x] Displays audiobook cover art
- [x] Shows title and author
- [ ] Progress slider for seeking
- [x] Play/pause button
- [ ] Forward/backward skip buttons (15/30 sec)
- [ ] Playback speed control (0.5x - 2x)
- [ ] Current time and duration display
- [ ] Sleep timer button
- [ ] Playlist/chapters list
- [ ] Responsive layout

**Code Example:**
```dart
class PlaybackScreen extends ConsumerWidget {
  final Audiobook audiobook;

  const PlaybackScreen({required this.audiobook, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playbackState = ref.watch(playbackProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Now Playing')),
      body: Column(
        children: [
          // Cover art
          Container(
            width: 200,
            height: 200,
            color: Colors.grey,
            child: const Icon(Icons.music_note, size: 100),
          ),

          // Title and author
          Text(audiobook.title, style: Theme.of(context).textTheme.headlineSmall),
          Text(audiobook.author ?? 'Unknown'),

          // Progress bar
          Slider(
            value: playbackState.currentPosition.inSeconds.toDouble(),
            max: playbackState.duration?.inSeconds.toDouble() ?? 0,
            onChanged: (value) {
              ref.read(playbackProvider.notifier)
                  .seek(Duration(seconds: value.toInt()));
            },
          ),

          // Time display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatDuration(playbackState.currentPosition)),
              Text(_formatDuration(playbackState.duration ?? Duration.zero)),
            ],
          ),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous),
                onPressed: () => ref.read(playbackProvider.notifier).skipBackward(),
              ),
              FloatingActionButton(
                onPressed: () {
                  if (playbackState.isPlaying) {
                    ref.read(playbackProvider.notifier).pause();
                  } else {
                    ref.read(playbackProvider.notifier).play();
                  }
                },
                child: Icon(playbackState.isPlaying ? Icons.pause : Icons.play_arrow),
              ),
              IconButton(
                icon: const Icon(Icons.skip_next),
                onPressed: () => ref.read(playbackProvider.notifier).skipForward(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds.remainder(60))}';
  }
}
```

---

### Task 5.4: Implement Play/Pause Controls

**Status:** ⏳ ~70% Complete
**File:** `lib/features/player/presentation/providers/playback_notifier.dart`

**Description:**
Implement play/pause functionality with proper state management.

**Acceptance Criteria:**
- [x] Play button starts playback
- [x] Pause button stops playback
- [x] State updates UI in real-time
- [ ] Handles audio focus conflicts
- [ ] No crashes on rapid taps
- [ ] Audio continues in background

---

### Task 5.5: Implement Seek/Slider Functionality

**Status:** [ ] Pending
**File:** `lib/features/player/presentation/widgets/progress_bar.dart`

**Description:**
Add progress slider for seeking through audiobooks.

**Acceptance Criteria:**
- [ ] Slider shows current progress
- [ ] Drag to seek works smoothly
- [ ] Updates playback position
- [ ] Duration displayed correctly
- [ ] No audio glitches on seek
- [ ] Responsive to user input

---

### Task 5.6: Add Playback Speed Control

**Status:** [ ] Pending
**File:** `lib/features/player/presentation/widgets/playback_controls.dart`

**Description:**
Implement playback speed control (0.5x, 0.75x, 1x, 1.25x, 1.5x, 2x).

**Acceptance Criteria:**
- [ ] Speed button shows current speed
- [ ] Tap opens speed picker
- [ ] Speed changes immediately
- [ ] Speed persists for audiobook
- [ ] Audio quality maintained at all speeds

---

### Task 5.7: Implement Sleep Timer

**Status:** [ ] Pending
**File:** `lib/features/player/presentation/providers/playback_provider.dart`

**Description:**
Add sleep timer to stop playback after specified duration.

**Acceptance Criteria:**
- [ ] Sleep timer button in UI
- [ ] Options: 5, 10, 15, 30 min, end of chapter
- [ ] Timer countdown display
- [ ] Notification before stop
- [ ] Cancel timer option
- [ ] Persists across screens

---

### Task 5.8: Add Playback History

**Status:** [ ] Pending
**File:** `lib/features/player/data/repositories/playback_repository_impl.dart`

**Description:**
Track playback history with position, date, and duration.

**Acceptance Criteria:**
- [ ] Save last played position
- [ ] Track playback time per session
- [ ] Persist to Isar database
- [ ] Resume from last position on app restart
- [ ] Clear history option in settings

---

### Task 5.9: Implement Chapters Display

**Status:** [ ] Pending
**File:** `lib/features/player/presentation/widgets/chapters_list.dart` (NEW)

**Description:**
Display and navigate through audiobook chapters.

**Acceptance Criteria:**
- [ ] List chapters extracted from metadata
- [ ] Tap chapter to jump to position
- [ ] Current chapter highlighted
- [ ] Smooth navigation
- [ ] Chapter duration display

---

### Task 5.10: Add Playback Tests

**Status:** [ ] Pending
**Files:**
- `test/features/player/domain/usecases/play_audiobook_usecase_test.dart`
- `test/features/player/presentation/views/playback_screen_test.dart`

**Description:**
Create comprehensive tests for playback functionality.

**Acceptance Criteria:**
- [ ] Test play/pause
- [ ] Test seek/slider
- [ ] Test speed changes
- [ ] Test sleep timer
- [ ] Test history tracking
- [ ] Widget test for playback screen
- [ ] 80%+ code coverage

---

## 📱 Post-MVP Phases (6-9)

These phases are deferred for post-MVP but documented for future planning.

### Phase 6: Advanced Playback Features

- [ ] Bookmarks at specific positions
- [ ] Chapter-based bookmarks
- [ ] Multiple playback queues
- [ ] Up next/Recently played
- [ ] Playback effects (EQ, bass boost)
- [ ] Variable speed sync per book

**Estimated Time:** 3-4 days

---

### Phase 7: Firestore Sync

- [ ] Library sync across devices
- [ ] Playback position sync
- [ ] Reading list management
- [ ] Cloud backup
- [ ] Offline queue
- [ ] Conflict resolution

**Estimated Time:** 4-5 days

---

### Phase 8: Web Support Enhancements

- [ ] Full web directory picker
- [ ] Web audio playback
- [ ] Responsive UI for desktop
- [ ] Web authentication
- [ ] Cross-device sync on web
- [ ] PWA support

**Estimated Time:** 3-4 days

---

### Phase 9: Settings & UI Polish

- [ ] Dark/Light theme toggle
- [ ] Appearance customization
- [ ] Notification preferences
- [ ] Audio format preferences
- [ ] Cache management
- [ ] About/Legal screens
- [ ] Help & FAQ
- [ ] Accessibility features

**Estimated Time:** 2-3 days

---

## ✅ MVP Acceptance Criteria

The MVP is complete when ALL the following criteria are met:

| Criterion | Status | Notes |
|-----------|--------|-------|
| **Splash Screen** | ✅ | Shows on app start, navigates to auth |
| **Authentication** | ⏳ | Email/password and anonymous login working |
| **Directory Selection** | ✅ | User can select directory and scan |
| **Audiobook Scanning** | ✅ | Files scanned, metadata extracted, saved to DB |
| **Library Display** | ⏳ | All audiobooks displayed with search/filter |
| **Playback Controls** | ⏳ | Play, pause, seek, speed, sleep timer |
| **Playback State** | ⏳ | Position persisted, resumes from last position |
| **Background Audio** | [ ] | Audio plays when app minimized |
| **No Crashes** | ⏳ | All features tested, no unhandled exceptions |
| **Web Compatibility** | ⏳ | Splash, auth, and library work on web |
| **Android Support** | ⏳ | Full functionality on Android |
| **iOS Support** | [ ] | Full functionality on iOS |
| **Test Coverage** | ⏳ | 80%+ coverage for all features |
| **Documentation** | ⏳ | README and inline comments complete |

---

## 🔧 Technical Debt & Known Limitations

### Technical Debt

| Item | Priority | Notes |
|------|----------|-------|
| Cover art extraction | Medium | Currently using placeholder, need ID3 tag support |
| Web audio format support | High | Limited format support on web browsers |
| Error logging | Medium | No centralized error tracking (consider Sentry) |
| Analytics | Low | No user behavior tracking (defer to post-MVP) |
| Performance | Medium | Large library loading needs optimization |
| Database migration | Low | No migration strategy for schema changes |

### Known Limitations

1. **Web Directory Access**: Web can only access files via picker, not full directory listing
2. **Audio Formats**: Support limited to formats supported by `just_audio`
3. **DRM Content**: Cannot play DRM-protected audiobooks
4. **Large Libraries**: Performance may degrade with 1000+ audiobooks
5. **Offline Sync**: No offline queue for playing while disconnected from Firestore
6. **iOS Background Audio**: May require additional configuration
7. **Web Notifications**: Limited notification support on web

---

## 📚 Related Documentation

- `ARCHITECTURE_FIX_COMPLETE.md` - Architecture overview
- `SCANNING_FLOW_GUIDE.md` - Scanning workflow details
- `exp_qwen.md` - Directory scanning guide
- `IMPLEMENTATION_SUMMARY.md` - Completed implementations
- `process.md` - High-level feature steps
- `migration_plan.md` - Feature-based architecture migration

---

## 🐛 Troubleshooting

### Common Issues & Solutions

**Issue: "Circular dependency" errors in build**

**Solution:**
1. Clean build: `flutter clean && flutter pub get`
2. Run code generation: `dart run build_runner build --delete-conflicting-outputs`
3. Check `lib/core/provider/providers.dart` exists and is imported

**Issue: Directory selection shows nothing on web**

**Solution:**
1. Ensure `file_picker` package is added to `pubspec.yaml`
2. Update platform-specific code in `system_directory_picker_ds.dart`
3. Test on Chrome with proper permissions

**Issue: Audiobooks not appearing in library after scan**

**Solution:**
1. Check Isar database initialization in `bootstrap.dart`
2. Verify metadata extraction completed without errors
3. Inspect database with `isar_inspector` package
4. Check file permissions and directory path validity

**Issue: Audio not playing in background**

**Solution:**
1. Verify `audio_service` configuration
2. Check manifest permissions (Android)
3. Verify `AudioServiceHandler` is initialized
4. Check app doesn't terminate background task

**Issue: Tests failing with Riverpod errors**

**Solution:**
1. Ensure using `ProviderContainer` for testing
2. Override providers with mocks
3. Use `ProviderContainer.read()` not `ref.read()`
4. Check test setup in `flutter_test` helpers

**Issue: Web app blank after splash**

**Solution:**
1. Check router configuration
2. Verify no blocking errors in console (F12)
3. Test auth initialization on web
4. Check file picker permissions

---

## 📊 Progress Tracking Template

Use this table to track overall MVP progress:

| Phase | Status | Completed | Total | % Complete | Est. Days | Actual Days |
|-------|--------|-----------|-------|-----------|-----------|-------------|
| Phase 1: Splash | ✅ | 3 | 3 | 100% | 0.5 | 0.5 |
| Phase 2: Auth | ⏳ | 2 | 8 | 25% | 3 | 0 |
| Phase 3: Directory | ✅ | 5 | 6 | 83% | 1.5 | 1 |
| Phase 4: Library | ⏳ | 2 | 6 | 33% | 2 | 0 |
| Phase 5: Playback | ⏳ | 3 | 10 | 30% | 4 | 0 |
| **TOTAL MVP** | ⏳ | 15 | 33 | 45% | 11 | 1.5 |

---

## 🎯 Next Steps

1. **Immediate** (Today):
   - [ ] Review this document with team
   - [ ] Set up task tracking (Jira/GitHub Projects)
   - [ ] Assign Phase 2 (Auth) tasks

2. **Short-term** (This week):
   - [ ] Complete all Phase 2 tasks (Auth)
   - [ ] Begin Phase 4 (Library) in parallel
   - [ ] Set up CI/CD for testing

3. **Medium-term** (This month):
   - [ ] Complete Phases 4 & 5
   - [ ] Comprehensive testing & QA
   - [ ] Performance optimization
   - [ ] Documentation finalization

4. **Before MVP Release**:
   - [ ] Alpha testing on real devices
   - [ ] Fix critical bugs
   - [ ] Finalize UI/UX
   - [ ] Release notes preparation

---

## 📝 Notes

- This document is a living document and should be updated as progress is made
- Use status indicators: ✅ (Complete), ⏳ (In Progress), [ ] (Pending), ❌ (Blocked)
- Link to specific files using the provided path references
- Each task should have clear acceptance criteria before marking complete
- Regular code reviews ensure quality before task completion

---

**Last Updated:** December 15, 2025
**Version:** 1.0
**Status:** Active Development
