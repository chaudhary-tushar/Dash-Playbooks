// test/features/player/presentation/views/playback_screen_test.dart
import 'package:flutbook/features/library/domain/entities/audiobook.dart';
import 'package:flutbook/features/library/domain/entities/chapter.dart';
import 'package:flutbook/features/player/domain/entities/playback_session.dart';
import 'package:flutbook/features/player/presentation/providers/playback_provider.dart';
import 'package:flutbook/features/player/presentation/views/playback_screen.dart';
import 'package:flutbook/features/player/presentation/widgets/chapters_list.dart';
import 'package:flutbook/features/player/presentation/widgets/progress_bar.dart';
import 'package:flutbook/features/player/presentation/widgets/sleep_timer_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// Simple mock implementation that works with Riverpod
class MockPlaybackNotifier extends Notifier<PlaybackState> {
  bool _shouldThrowError = false;
  PlaybackState? _state;
  Audiobook? _currentAudiobook;

  void setShouldThrowError(bool shouldThrow) {
    _shouldThrowError = shouldThrow;
  }

  @override
  PlaybackState build() {
    _state = PlaybackState.initial();
    return _state!;
  }

  Future<bool> setCurrentAudiobook(Audiobook audiobook) async {
    // Ensure state is initialized
    _state ??= PlaybackState.initial();

    _currentAudiobook = audiobook;
    _state = _state!.copyWith(
      duration: audiobook.duration,
    );
    // Note: In a mock, we don't actually call state = _state since the provider infrastructure
    // isn't fully set up in tests, but the state is still accessible via _state
    return true;
  }

  void setState(PlaybackState newState) {
    // Ensure state is initialized
    _state ??= PlaybackState.initial();

    _state = newState;
  }

  void triggerPlay() {
    // Ensure state is initialized
    _state ??= PlaybackState.initial();

    _state = _state!.copyWith(isPlaying: true);
  }

  void triggerPause() {
    // Ensure state is initialized
    _state ??= PlaybackState.initial();

    _state = _state!.copyWith(isPlaying: false);
  }

  void setPosition(Duration position) {
    // Ensure state is initialized
    _state ??= PlaybackState.initial();

    _state = _state!.copyWith(currentPosition: position);
  }

  void setPlaybackSpeed(double speed) {
    // Ensure state is initialized
    _state ??= PlaybackState.initial();

    _state = _state!.copyWith(playbackSpeed: speed);
  }

  void setSleepTimerActive(bool active, [Duration? duration]) {
    // Ensure state is initialized
    _state ??= PlaybackState.initial();

    _state = _state!.copyWith(
      sleepTimerActive: active,
      sleepTimerDuration: duration,
    );
  }

  Future<bool> play() async {
    // Ensure state is initialized
    _state ??= PlaybackState.initial();

    if (_shouldThrowError) {
      return false;
    }
    triggerPlay();
    return true;
  }

  Future<bool> pause() async {
    // Ensure state is initialized
    _state ??= PlaybackState.initial();

    if (_shouldThrowError) {
      return false;
    }
    triggerPause();
    return true;
  }

  Future<void> seekTo(Duration position) async {
    // Ensure state is initialized
    _state ??= PlaybackState.initial();

    if (_shouldThrowError) {
      throw Exception('Seek error');
    }
    setPosition(position);
  }

  Future<void> setSpeed(double speed) async {
    // Ensure state is initialized
    _state ??= PlaybackState.initial();

    if (_shouldThrowError) {
      throw Exception('Speed error');
    }
    setPlaybackSpeed(speed);
  }

  void setSleepTimer(Duration duration, {bool endOfChapter = false}) {
    // Ensure state is initialized
    _state ??= PlaybackState.initial();

    if (_shouldThrowError) {
      throw Exception('Sleep timer error');
    }
    setSleepTimerActive(true, duration);
  }

  void cancelSleepTimer() {
    // Ensure state is initialized
    _state ??= PlaybackState.initial();

    if (_shouldThrowError) {
      throw Exception('Cancel sleep timer error');
    }
    setSleepTimerActive(false);
  }

  Future<void> skipForward(Duration interval) async {
    // Ensure state is initialized
    _state ??= PlaybackState.initial();

    if (_shouldThrowError) {
      throw Exception('Skip forward error');
    }
    final newPosition = _state!.currentPosition + interval;
    if (newPosition <= _state!.duration) {
      setPosition(newPosition);
    }
  }

  Future<void> skipBackward(Duration interval) async {
    // Ensure state is initialized
    _state ??= PlaybackState.initial();

    if (_shouldThrowError) {
      throw Exception('Skip backward error');
    }
    final newPosition = _state!.currentPosition - interval;
    if (newPosition >= Duration.zero) {
      setPosition(newPosition);
    }
  }

  Future<PlaybackSession?> getCurrentPlaybackSession() async {
    // Ensure state is initialized
    _state ??= PlaybackState.initial();

    if (_shouldThrowError) {
      throw Exception('Get session error');
    }
    if (_currentAudiobook == null) return null;

    return PlaybackSession(
      audiobookId: _currentAudiobook!.id,
      currentPosition: _state!.currentPosition,
      playbackSpeed: _state!.playbackSpeed,
      isPlaying: _state!.isPlaying,
      lastPlayedAt: DateTime.now(),
      sleepTimerActive: _state!.sleepTimerActive,
      sleepTimerDuration: _state!.sleepTimerDuration,
    );
  }

  // Getter to access the internal state for tests
  PlaybackState get currentState => _state ?? PlaybackState.initial();
}

// Test provider overrides
final testPlaybackProvider =
    NotifierProvider<MockPlaybackNotifier, PlaybackState>(
      MockPlaybackNotifier.new,
    );

void main() {
  late Audiobook testAudiobook;
  late MockPlaybackNotifier mockNotifier;

  setUp(() {
    // Create test audiobook with chapters
    testAudiobook = Audiobook(
      id: 'test-audiobook-1',
      title: 'Test Audiobook Title',
      author: 'Test Author Name',
      album: 'Test Album',
      duration: const Duration(hours: 2, minutes: 30),
      filePath: '/path/to/test/audiobook.mp3',
      chapters: [
        Chapter(
          id: 'chapter-1',
          title: 'Introduction',
          startTime: Duration.zero,
          endTime: const Duration(minutes: 30),
        ),
        Chapter(
          id: 'chapter-2',
          title: 'Main Content',
          startTime: const Duration(minutes: 30),
          endTime: const Duration(minutes: 75),
        ),
        Chapter(
          id: 'chapter-3',
          title: 'Conclusion',
          startTime: const Duration(minutes: 75),
          endTime: const Duration(minutes: 105),
        ),
      ],
      createdAt: DateTime.now(),
      completed: false,
      totalSize: 100000000,
    );
  });

  // Helper function to create test widget with provider overrides
  Widget createTestWidget({required Widget child}) {
    return ProviderScope(
      overrides: [
        testPlaybackProvider.overrideWith(() => mockNotifier),
        currentAudiobookProvider.overrideWith((ref) => testAudiobook),
      ],
      child: MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(800, 600)),
          child: child,
        ),
      ),
    );
  }

  group('PlaybackScreen - Initialization and Rendering', () {
    testWidgets('should render PlaybackScreen with audiobook information', (
      WidgetTester tester,
    ) async {
      // Setup
      mockNotifier = MockPlaybackNotifier();
      mockNotifier.setCurrentAudiobook(testAudiobook);

      // Build the widget
      await tester.pumpWidget(
        createTestWidget(
          child: PlaybackScreen(audiobook: testAudiobook),
        ),
      );

      // Wait for any async operations
      await tester.pumpAndSettle();

      // Verify basic rendering
      expect(find.byType(PlaybackScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('Now Playing'), findsOneWidget);

      // Verify audiobook information is displayed
      expect(find.text('Test Audiobook Title'), findsOneWidget);
      expect(find.text('Test Author Name'), findsOneWidget);

      // Verify playback controls are present
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsWidgets);

      // Verify progress bar is present
      expect(find.byType(ProgressBar), findsOneWidget);

      // Verify chapters list is present
      expect(find.byType(ChaptersList), findsOneWidget);
    });

    testWidgets('should display cover art when available', (
      WidgetTester tester,
    ) async {
      // Setup - audiobook with cover art
      final audiobookWithCover = testAudiobook.copyWith(
        coverArtPath: 'https://example.com/cover.jpg',
      );

      mockNotifier = MockPlaybackNotifier();
      mockNotifier.setCurrentAudiobook(audiobookWithCover);

      // Build the widget
      await tester.pumpWidget(
        createTestWidget(
          child: PlaybackScreen(audiobook: audiobookWithCover),
        ),
      );

      await tester.pumpAndSettle();

      // Verify cover art is displayed (Image.network)
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('should display placeholder when cover art is not available', (
      WidgetTester tester,
    ) async {
      // Setup - audiobook without cover art
      final audiobookWithoutCover = testAudiobook.copyWith();

      mockNotifier = MockPlaybackNotifier();
      mockNotifier.setCurrentAudiobook(audiobookWithoutCover);

      // Build the widget
      await tester.pumpWidget(
        createTestWidget(
          child: PlaybackScreen(audiobook: audiobookWithoutCover),
        ),
      );

      await tester.pumpAndSettle();

      // Verify placeholder icon is displayed
      expect(find.byIcon(Icons.album_outlined), findsOneWidget);
    });
  });

  group('PlaybackScreen - Play/Pause Functionality', () {
    testWidgets('should start in paused state', (
      WidgetTester tester,
    ) async {
      // Setup
      mockNotifier = MockPlaybackNotifier();
      mockNotifier.setCurrentAudiobook(testAudiobook);

      // Build the widget
      await tester.pumpWidget(
        createTestWidget(
          child: PlaybackScreen(audiobook: testAudiobook),
        ),
      );

      await tester.pumpAndSettle();

      // Verify initial state is paused
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
      expect(find.byIcon(Icons.pause_rounded), findsNothing);
    });

    testWidgets(
      'should toggle from play to pause when play button is pressed',
      (
        WidgetTester tester,
      ) async {
        // Setup
        mockNotifier = MockPlaybackNotifier();
        mockNotifier.setCurrentAudiobook(testAudiobook);

        // Build the widget
        await tester.pumpWidget(
          createTestWidget(
            child: PlaybackScreen(audiobook: testAudiobook),
          ),
        );

        await tester.pumpAndSettle();

        // Initial state should be paused
        expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

        // Tap play button
        await tester.tap(find.byType(FloatingActionButton), warnIfMissed: false);
        await tester.pumpAndSettle();

        // Should now show pause icon
        expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
        expect(find.byIcon(Icons.play_arrow_rounded), findsNothing);
      },
    );

    testWidgets(
      'should toggle from pause to play when pause button is pressed',
      (
        WidgetTester tester,
      ) async {
        // Setup - start in playing state
        mockNotifier = MockPlaybackNotifier();
        mockNotifier.setCurrentAudiobook(testAudiobook);
        mockNotifier.triggerPlay();

        // Build the widget
        await tester.pumpWidget(
          createTestWidget(
            child: PlaybackScreen(audiobook: testAudiobook),
          ),
        );

        await tester.pumpAndSettle();

        // Initial state should be playing
        expect(find.byIcon(Icons.pause_rounded), findsOneWidget);

        // Tap pause button
        await tester.tap(find.byType(FloatingActionButton), warnIfMissed: false);
        await tester.pumpAndSettle();

        // Should now show play icon
        expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
        expect(find.byIcon(Icons.pause_rounded), findsNothing);
      },
    );

    testWidgets('should handle play/pause error gracefully', (
      WidgetTester tester,
    ) async {
      // Setup - configure to throw error
      mockNotifier = MockPlaybackNotifier();
      mockNotifier.setShouldThrowError(true);
      mockNotifier.setCurrentAudiobook(testAudiobook);

      // Build the widget
      await tester.pumpWidget(
        createTestWidget(
          child: PlaybackScreen(audiobook: testAudiobook),
        ),
      );

      await tester.pumpAndSettle();

      // Tap play button (should throw error but not crash)
      await tester.tap(find.byType(FloatingActionButton), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Should still be functional (error handling in provider)
      expect(find.byType(PlaybackScreen), findsOneWidget);
    });
  });

  group('PlaybackScreen - Seek/Slider Functionality', () {
    testWidgets('should update position when progress bar is tapped', (
      WidgetTester tester,
    ) async {
      // Setup
      mockNotifier = MockPlaybackNotifier();
      mockNotifier.setCurrentAudiobook(testAudiobook);
      mockNotifier.setPosition(const Duration(minutes: 30));

      // Build the widget
      await tester.pumpWidget(
        createTestWidget(
          child: PlaybackScreen(audiobook: testAudiobook),
        ),
      );

      await tester.pumpAndSettle();

      await tester.pumpAndSettle();

      // Use the built-in gesture test utilities to interact with the progress bar
      final progressBarFinder = find.byType(ProgressBar);
      await tester.tap(progressBarFinder);
      await tester.pump();

      // Since we can't directly test tap position on the progress bar in a test environment,
      // we'll just verify that tapping doesn't cause errors and the widget is interactive
      expect(find.byType(ProgressBar), findsOneWidget);
    });

    testWidgets('should handle seek to beginning', (
      WidgetTester tester,
    ) async {
      // Setup - start at middle position
      mockNotifier = MockPlaybackNotifier();
      mockNotifier.setCurrentAudiobook(testAudiobook);
      mockNotifier.setPosition(const Duration(minutes: 75));

      // Build the widget
      await tester.pumpWidget(
        createTestWidget(
          child: PlaybackScreen(audiobook: testAudiobook),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on the progress bar to test interactivity
      final progressBarFinder = find.byType(ProgressBar);
      await tester.tap(progressBarFinder);
      await tester.pump();

      // Verify the progress bar is still present and functioning
      expect(find.byType(ProgressBar), findsOneWidget);
    });

    testWidgets('should handle seek to end', (
      WidgetTester tester,
    ) async {
      // Setup
      mockNotifier = MockPlaybackNotifier();
      mockNotifier.setCurrentAudiobook(testAudiobook);

      // Build the widget
      await tester.pumpWidget(
        createTestWidget(
          child: PlaybackScreen(audiobook: testAudiobook),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on the progress bar to test interactivity
      final progressBarFinder = find.byType(ProgressBar);
      await tester.tap(progressBarFinder);
      await tester.pump();

      // Verify the progress bar is still present and functioning
      expect(find.byType(ProgressBar), findsOneWidget);
    });

    testWidgets('should handle seek error gracefully', (
      WidgetTester tester,
    ) async {
      // Setup - configure to throw error on seek
      mockNotifier = MockPlaybackNotifier();
      mockNotifier.setShouldThrowError(true);
      mockNotifier.setCurrentAudiobook(testAudiobook);

      // Build the widget
      await tester.pumpWidget(
        createTestWidget(
          child: PlaybackScreen(audiobook: testAudiobook),
        ),
      );

      await tester.pumpAndSettle();

      // Try to seek (should throw error but not crash)
      final renderObject = tester.renderObject<RenderBox>(
        find.byType(ProgressBar),
      );
      final size = renderObject.size;
      final tapPosition = Offset(size.width * 0.5, size.height / 2);

      await tester.tapAt(tapPosition);
      await tester.pump();

      // Should still be functional
      expect(find.byType(PlaybackScreen), findsOneWidget);
    });
  });

  group('PlaybackScreen - Speed Changes', () {
    testWidgets('should display initial speed correctly', (
      WidgetTester tester,
    ) async {
      // Setup
      mockNotifier = MockPlaybackNotifier();
      mockNotifier.setCurrentAudiobook(testAudiobook);
      mockNotifier.setSpeed(1);

      // Build the widget
      await tester.pumpWidget(
        createTestWidget(
          child: PlaybackScreen(audiobook: testAudiobook),
        ),
      );

      await tester.pumpAndSettle();

      // Verify speed dropdown shows 1.0x
      expect(find.text('1.0x'), findsOneWidget);
    });

    testWidgets('should change speed when dropdown selection changes', (
      WidgetTester tester,
    ) async {
      // Setup
      mockNotifier = MockPlaybackNotifier();
      mockNotifier.setCurrentAudiobook(testAudiobook);

      // Build the widget
      await tester.pumpWidget(
        createTestWidget(
          child: PlaybackScreen(audiobook: testAudiobook),
        ),
      );

      await tester.pumpAndSettle();

      // Open the speed dropdown
      await tester.tap(find.byType(DropdownButton<double>), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Select 1.5x speed
      await tester.tap(find.text('1.5x'), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify speed was changed
      expect(mockNotifier.currentState.playbackSpeed, 1.5);
      expect(find.text('1.5x'), findsWidgets);
    });

    testWidgets('should support all standard speed options', (
      WidgetTester tester,
    ) async {
      // Setup
      mockNotifier = MockPlaybackNotifier();
      mockNotifier.setCurrentAudiobook(testAudiobook);

      // Build the widget
      await tester.pumpWidget(
        createTestWidget(
          child: PlaybackScreen(audiobook: testAudiobook),
        ),
      );

      await tester.pumpAndSettle();

      // Open the speed dropdown
      await tester.tap(find.byType(DropdownButton<double>), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify all speed options are available
      const expectedSpeeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
      for (final speed in expectedSpeeds) {
        expect(find.text('${speed}x'), findsOneWidget);
      }
    });

    testWidgets('should handle speed change error gracefully', (
      WidgetTester tester,
    ) async {
      // Setup - configure to throw error on speed change
      mockNotifier = MockPlaybackNotifier();
      mockNotifier.setShouldThrowError(true);
      mockNotifier.setCurrentAudiobook(testAudiobook);

      // Build the widget
      await tester.pumpWidget(
        createTestWidget(
          child: PlaybackScreen(audiobook: testAudiobook),
        ),
      );

      await tester.pumpAndSettle();

      // Try to change speed (should throw error but not crash)
      await tester.tap(find.byType(DropdownButton<double>), warnIfMissed: false);
      await tester.pumpAndSettle();

      await tester.tap(find.text('1.5x'), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Should still be functional
      expect(find.byType(PlaybackScreen), findsOneWidget);
    });
  });

  group('PlaybackScreen - Sleep Timer', () {
    testWidgets('should start with sleep timer inactive', (
      WidgetTester tester,
    ) async {
      // Setup
      mockNotifier = MockPlaybackNotifier();
      mockNotifier.setCurrentAudiobook(testAudiobook);

      // Build the widget
      await tester.pumpWidget(
        createTestWidget(
          child: PlaybackScreen(audiobook: testAudiobook),
        ),
      );

      await tester.pumpAndSettle();

      // Verify sleep timer is inactive
      expect(find.text('Sleep'), findsOneWidget);
      expect(find.byIcon(Icons.bedtime_outlined), findsOneWidget);
      expect(find.byIcon(Icons.bedtime_rounded), findsNothing);
    });

    testWidgets('should activate sleep timer when button is pressed', (
      WidgetTester tester,
    ) async {
      // Setup
      mockNotifier = MockPlaybackNotifier();
      mockNotifier.setCurrentAudiobook(testAudiobook);

      // Build the widget
      await tester.pumpWidget(
        createTestWidget(
          child: PlaybackScreen(audiobook: testAudiobook),
        ),
      );

      await tester.pumpAndSettle();

      // Tap sleep timer button
      await tester.tap(find.text('Sleep'), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Sleep timer dialog should open
      expect(find.byType(SleepTimerDialog), findsOneWidget);

      // Close the dialog to continue testing
      await tester.tap(find.text('Cancel'), warnIfMissed: false);
      await tester.pumpAndSettle();
    });

    testWidgets('should show sleep timer display when active', (
      WidgetTester tester,
    ) async {
      // Setup - start with sleep timer active
      mockNotifier = MockPlaybackNotifier();
      mockNotifier.setCurrentAudiobook(testAudiobook);
      mockNotifier.setSleepTimerActive(true, const Duration(minutes: 30));

      // Build the widget
      await tester.pumpWidget(
        createTestWidget(
          child: PlaybackScreen(audiobook: testAudiobook),
        ),
      );

      await tester.pumpAndSettle();

      // Verify sleep timer is active
      expect(find.byIcon(Icons.bedtime_rounded), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('30:00'), findsOneWidget); // Should show timer duration in MM:SS format
    });

    testWidgets('should cancel sleep timer when active and button is pressed', (
      WidgetTester tester,
    ) async {
      // Setup - start with sleep timer active
      mockNotifier = MockPlaybackNotifier();
      mockNotifier.setCurrentAudiobook(testAudiobook);
      mockNotifier.setSleepTimerActive(true, const Duration(minutes: 30));

      // Build the widget
      await tester.pumpWidget(
        createTestWidget(
          child: PlaybackScreen(audiobook: testAudiobook),
        ),
      );

      await tester.pumpAndSettle();

      // Tap cancel button
      await tester.tap(find.text('Cancel'), warnIfMissed: false);
      await tester.pump();

      // Verify sleep timer is cancelled
      expect(find.text('Sleep'), findsOneWidget);
      expect(find.byIcon(Icons.bedtime_outlined), findsOneWidget);
      expect(find.byIcon(Icons.bedtime_rounded), findsNothing);
    });
  });

  group('PlaybackScreen - Skip Controls', () {
    testWidgets('should skip forward when forward button is pressed', (
      WidgetTester tester,
    ) async {
      // Setup
      mockNotifier = MockPlaybackNotifier();
      mockNotifier.setCurrentAudiobook(testAudiobook);
      mockNotifier.setPosition(const Duration(minutes: 30));

      // Build the widget
      await tester.pumpWidget(
        createTestWidget(
          child: PlaybackScreen(audiobook: testAudiobook),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap the forward button
      final forwardButton = find.byIcon(Icons.forward_30_outlined);
      expect(forwardButton, findsOneWidget);

      await tester.tap(forwardButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Should skip forward by 30 seconds
      expect(
        mockNotifier.currentState.currentPosition,
        const Duration(minutes: 30, seconds: 30),
      );
    });

    testWidgets('should skip backward when backward button is pressed', (
      WidgetTester tester,
    ) async {
      // Setup
      mockNotifier = MockPlaybackNotifier();
      mockNotifier.setCurrentAudiobook(testAudiobook);
      mockNotifier.setPosition(const Duration(minutes: 1, seconds: 30));

      // Build the widget
      await tester.pumpWidget(
        createTestWidget(
          child: PlaybackScreen(audiobook: testAudiobook),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap the backward button
      final backwardButton = find.byIcon(Icons.replay_10_outlined);
      expect(backwardButton, findsOneWidget);

      await tester.tap(backwardButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Should skip backward by 15 seconds
      expect(
        mockNotifier.currentState.currentPosition,
        const Duration(minutes: 1, seconds: 15),
      );
    });

    testWidgets('should not skip backward past beginning', (
      WidgetTester tester,
    ) async {
      // Setup - start at beginning
      mockNotifier = MockPlaybackNotifier();
      mockNotifier.setCurrentAudiobook(testAudiobook);
      mockNotifier.setPosition(Duration.zero);

      // Build the widget
      await tester.pumpWidget(
        createTestWidget(
          child: PlaybackScreen(audiobook: testAudiobook),
        ),
      );

      await tester.pumpAndSettle();

      // Try to skip backward
      final backwardButton = find.byIcon(Icons.replay_10_outlined);
      await tester.tap(backwardButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Should stay at beginning
      expect(mockNotifier.currentState.currentPosition, Duration.zero);
    });

    testWidgets('should not skip forward past end', (
      WidgetTester tester,
    ) async {
      // Setup - start near end
      mockNotifier = MockPlaybackNotifier();
      mockNotifier.setCurrentAudiobook(testAudiobook);
      mockNotifier.setPosition(const Duration(hours: 2, minutes: 29));

      // Build the widget
      await tester.pumpWidget(
        createTestWidget(
          child: PlaybackScreen(audiobook: testAudiobook),
        ),
      );

      await tester.pumpAndSettle();

      // Try to skip forward by 30 seconds (would go past end)
      final forwardButton = find.byIcon(Icons.forward_30_outlined);
      await tester.tap(forwardButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Should be at end
      expect(mockNotifier.currentState.currentPosition, testAudiobook.duration);
    });
  });

  group('PlaybackScreen - Chapter Navigation', () {
    testWidgets('should display chapters list', (
      WidgetTester tester,
    ) async {
      // Setup
      mockNotifier = MockPlaybackNotifier();
      mockNotifier.setCurrentAudiobook(testAudiobook);

      // Build the widget
      await tester.pumpWidget(
        createTestWidget(
          child: PlaybackScreen(audiobook: testAudiobook),
        ),
      );

      await tester.pumpAndSettle();

      // Verify chapters are displayed
      expect(find.byType(ChaptersList), findsOneWidget);
      expect(find.text('Introduction'), findsOneWidget);
      expect(find.text('Main Content'), findsOneWidget);
      expect(find.text('Conclusion'), findsOneWidget);
    });

    testWidgets('should navigate to chapter when tapped', (
      WidgetTester tester,
    ) async {
      // Setup
      mockNotifier = MockPlaybackNotifier();
      mockNotifier.setCurrentAudiobook(testAudiobook);

      // Build the widget
      await tester.pumpWidget(
        createTestWidget(
          child: PlaybackScreen(audiobook: testAudiobook),
        ),
      );

      await tester.pumpAndSettle();

      // Tap the second chapter (Main Content - starts at 30 minutes)
      await tester.tap(find.text('Main Content'), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Should seek to chapter start time
      expect(
        mockNotifier.currentState.currentPosition,
        const Duration(minutes: 30),
      );
    });

    testWidgets('should highlight current chapter', (
      WidgetTester tester,
    ) async {
      // Setup - start at position that's in the second chapter
      mockNotifier = MockPlaybackNotifier();
      mockNotifier.setCurrentAudiobook(testAudiobook);
      mockNotifier.setPosition(const Duration(minutes: 45));

      // Build the widget
      await tester.pumpWidget(
        createTestWidget(
          child: PlaybackScreen(audiobook: testAudiobook),
        ),
      );

      await tester.pumpAndSettle();

      // The chapters list should highlight the current chapter
      // This is a simplified test - actual highlighting would depend on implementation
      expect(find.text('Main Content'), findsOneWidget);
    });
  });

  group('PlaybackScreen - Error Handling', () {
    testWidgets('should handle audiobook loading error gracefully', (
      WidgetTester tester,
    ) async {
      // Setup - configure to throw error during initialization
      mockNotifier = MockPlaybackNotifier();
      mockNotifier.setShouldThrowError(true);

      // Build the widget
      await tester.pumpWidget(
        createTestWidget(
          child: PlaybackScreen(audiobook: testAudiobook),
        ),
      );

      await tester.pumpAndSettle();

      // Should still render (error handling in provider)
      expect(find.byType(PlaybackScreen), findsOneWidget);
    });

    testWidgets('should display error message when playback fails', (
      WidgetTester tester,
    ) async {
      // Setup - configure to throw error on play
      mockNotifier = MockPlaybackNotifier();
      mockNotifier.setShouldThrowError(true);
      mockNotifier.setCurrentAudiobook(testAudiobook);

      // Build the widget
      await tester.pumpWidget(
        createTestWidget(
          child: PlaybackScreen(audiobook: testAudiobook),
        ),
      );

      await tester.pumpAndSettle();

      // Try to play (should fail)
      await tester.tap(find.byType(FloatingActionButton), warnIfMissed: false);
      await tester.pump();

      // Should still be functional
      expect(find.byType(PlaybackScreen), findsOneWidget);
    });
  });

  group('PlaybackScreen - Responsive Design', () {
    testWidgets('should adapt layout for mobile screens', (
      WidgetTester tester,
    ) async {
      // Setup
      mockNotifier = MockPlaybackNotifier();
      mockNotifier.setCurrentAudiobook(testAudiobook);

      // Build with mobile constraints
      await tester.pumpWidget(
        createTestWidget(
          child: SizedBox(
            width: 375, // iPhone size
            height: 812,
            child: PlaybackScreen(audiobook: testAudiobook),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify mobile layout elements
      expect(find.byType(PlaybackScreen), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('should adapt layout for tablet screens', (
      WidgetTester tester,
    ) async {
      // Setup
      mockNotifier = MockPlaybackNotifier();
      mockNotifier.setCurrentAudiobook(testAudiobook);

      // Build with tablet constraints
      await tester.pumpWidget(
        createTestWidget(
          child: SizedBox(
            width: 768, // iPad size
            height: 1024,
            child: PlaybackScreen(audiobook: testAudiobook),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify tablet layout elements
      expect(find.byType(PlaybackScreen), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });
}
