Subject: PHASE ASSIGNMENT: Phase 5 - AUDIO PLAYBACK

Hi Agent,

You're assigned to Phase 5 AUDIO PLAYBACK
Priority: CRITICAL | Estimated Time: 1 Hours
Status: Partially Implemented
PHASE 5 UNDERSTANINGS -
take everything mark completed with scrutiny and recheck every implementations of the task by running flutter test and fklutter analyze also read the files created to see if they do what was intended for them and then upate the progress tracking files with correct info
### Phase 5: Audio Playback (3/10)

| Task | Status | Est. Hours |
|------|--------|-----------|
| 5.1: Audio Service Setup | ⏳ 50% | 3 |
| 5.2: Playback Provider | ⏳ 60% (FIXED) | 2 |
| 5.3: Playback Screen UI | ⏳ 50% | 3 |
| 5.4: Play/Pause Controls | ⏳ 70% | 1 |
| 5.5: Seek/Slider | [ ] Pending | 2 |
| 5.6: Speed Control | [ ] Pending | 2 |
| 5.7: Sleep Timer | [ ] Pending | 2 |
| 5.8: Playback History | [ ] Pending | 2 |
| 5.9: Chapters Display | [ ] Pending | 2 |
| 5.10: Playback Tests | [ ] Pending | 3 |

**Total Est. Time:** 22-24 hours

---
TASK order - 5.1->5.2->5.3->5.4->5.5->5.6->5.7->5.8->5.9->5.10
Here's what you need to know:

Display and manage the user's audiobook library.
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
✅ Progress tracking files have been updated in the Documentatino folder.

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



**Key Pattern:** See IMPLEMENTATION_SUMMARY.md, "Use Case Pattern" section


**Time Estimate:** 18 hours total (2-3 hours each task)

---
