// test/features/player/presentation/widgets/playback_controls_test.dart
import 'package:flutbook/features/player/presentation/widgets/playback_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaybackControls Widget Tests', () {
    testWidgets('PlaybackControls displays correctly with all speed options', (
      WidgetTester tester,
    ) async {
      // Build our widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlaybackControls(
              isPlaying: false,
              playbackSpeed: 1,
              sleepTimerActive: false,
              sleepTimerDuration: Duration.zero,
              onPlayPause: () {},
              onSpeedChanged: (speed) {},
              onSleepTimerToggle: ({required bool value}) {},
              onSkipForward: (duration) {},
              onSkipBackward: (duration) {},
            ),
          ),
        ),
      );

      // Verify the widget is displayed
      expect(find.byType(PlaybackControls), findsOneWidget);

      // Verify speed control dropdown exists
      expect(find.byType(DropdownButton<double>), findsOneWidget);

      // Verify all required speed options are present
      final dropdownButton = tester.widget<DropdownButton<double>>(
        find.byType(DropdownButton<double>),
      );
      final speedOptions = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

      expect(dropdownButton.items?.length, speedOptions.length);

      if (dropdownButton.items != null) {
        for (var i = 0; i < speedOptions.length; i++) {
          expect(dropdownButton.items![i].value, speedOptions[i]);
          expect(dropdownButton.items![i].child, isA<Text>());
          expect(
            (dropdownButton.items![i].child as Text).data,
            '${speedOptions[i]}x',
          );
        }
      }
    });

    testWidgets('PlaybackControls shows current speed correctly', (
      WidgetTester tester,
    ) async {
      // Test with different initial speeds
      const testSpeeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

      for (final speed in testSpeeds) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PlaybackControls(
                isPlaying: false,
                playbackSpeed: speed,
                sleepTimerActive: false,
                sleepTimerDuration: Duration.zero,
                onPlayPause: () {},
                onSpeedChanged: (speed) {},
                onSleepTimerToggle: ({required bool value}) {},
                onSkipForward: (duration) {},
                onSkipBackward: (duration) {},
              ),
            ),
          ),
        );

        // Verify the current speed is displayed
        final dropdownButton = tester.widget<DropdownButton<double>>(
          find.byType(DropdownButton<double>),
        );
        expect(dropdownButton.value, speed);
      }
    });

    testWidgets('PlaybackControls calls onSpeedChanged when speed is changed', (
      WidgetTester tester,
    ) async {
      double? lastCalledSpeed;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlaybackControls(
              isPlaying: false,
              playbackSpeed: 1,
              sleepTimerActive: false,
              sleepTimerDuration: Duration.zero,
              onPlayPause: () {},
              onSpeedChanged: (speed) {
                lastCalledSpeed = speed;
              },
              onSleepTimerToggle: ({required bool value}) {},
              onSkipForward: (duration) {},
              onSkipBackward: (duration) {},
            ),
          ),
        ),
      );

      // Open the dropdown
      await tester.tap(find.byType(DropdownButton<double>));
      await tester.pumpAndSettle();

      // Select a different speed (1.5x)
      await tester.tap(find.text('1.5x').last);
      await tester.pumpAndSettle();

      // Verify the callback was called with the correct speed
      expect(lastCalledSpeed, 1.5);
    });

    testWidgets('PlaybackControls shows play/pause button correctly', (
      WidgetTester tester,
    ) async {
      // Test playing state
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlaybackControls(
              isPlaying: true,
              playbackSpeed: 1,
              sleepTimerActive: false,
              sleepTimerDuration: Duration.zero,
              onPlayPause: () {},
              onSpeedChanged: (speed) {},
              onSleepTimerToggle: ({required bool value}) {},
              onSkipForward: (duration) {},
              onSkipBackward: (duration) {},
            ),
          ),
        ),
      );

      // Should show pause icon when playing
      expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsNothing);

      // Test paused state
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlaybackControls(
              isPlaying: false,
              playbackSpeed: 1,
              sleepTimerActive: false,
              sleepTimerDuration: Duration.zero,
              onPlayPause: () {},
              onSpeedChanged: (speed) {},
              onSleepTimerToggle: ({required bool value}) {},
              onSkipForward: (duration) {},
              onSkipBackward: (duration) {},
            ),
          ),
        ),
      );

      // Should show play icon when paused
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
      expect(find.byIcon(Icons.pause_rounded), findsNothing);
    });
  });
}
