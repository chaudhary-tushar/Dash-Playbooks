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

## 📝 Notes

- This document is a living document and should be updated as progress is made
- Use status indicators: ✅ (Complete), ⏳ (In Progress), [ ] (Pending), ❌ (Blocked)
- Link to specific files using the provided path references
- Each task should have clear acceptance criteria before marking complete
- Regular code reviews ensure quality before task completion

---

**Last Updated:** January 27, 2026
**Version:** 2.0
**Status:** MVP Complete! 🎉
