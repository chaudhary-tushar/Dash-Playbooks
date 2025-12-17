// test/features/player/presentation/widgets/progress_bar_simple_test.dart
import 'package:flutbook/features/player/presentation/widgets/progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ProgressBar renders without errors', (
    WidgetTester tester,
  ) async {
    // Build the ProgressBar widget with basic parameters
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProgressBar(
            currentPosition: const Duration(minutes: 1),
            totalDuration: const Duration(minutes: 10),
            bufferedPosition: const Duration(minutes: 3),
            onSeek: (position) {},
            onSeekStart: () async {},
            onSeekEnd: (position) async {},
          ),
        ),
      ),
    );

    // Verify the progress bar is rendered
    expect(find.byType(ProgressBar), findsOneWidget);
    expect(find.byType(GestureDetector), findsOneWidget);

    // Verify time labels are displayed
    expect(find.text('01:00'), findsOneWidget);
    expect(find.text('10:00'), findsOneWidget);
  });

  testWidgets('ProgressBar handles zero duration', (WidgetTester tester) async {
    // Test with zero duration - should not crash
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProgressBar(
            currentPosition: Duration.zero,
            totalDuration: Duration.zero,
            onSeek: (position) {},
            onSeekStart: () async {},
            onSeekEnd: (position) async {},
          ),
        ),
      ),
    );

    // Should not crash with zero duration
    expect(find.byType(ProgressBar), findsOneWidget);
    expect(find.text('00:00'), findsWidgets);
  });

  testWidgets('ProgressBar shows loading state', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProgressBar(
            currentPosition: const Duration(minutes: 1),
            totalDuration: const Duration(minutes: 5),
            bufferedPosition: const Duration(minutes: 2),
            onSeek: (position) {},
            onSeekStart: () async {},
            onSeekEnd: (position) async {},
            isLoading: true,
          ),
        ),
      ),
    );

    // Should show loading indicator instead of total duration
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('01:00'), findsOneWidget); // Current position still shown
  });

  testWidgets('ProgressBar with chapter markers', (WidgetTester tester) async {
    final chapterMarkers = [
      const Duration(minutes: 1),
      const Duration(minutes: 3),
      const Duration(minutes: 7),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProgressBar(
            currentPosition: const Duration(minutes: 2),
            totalDuration: const Duration(minutes: 10),
            bufferedPosition: const Duration(minutes: 5),
            chapterMarkers: chapterMarkers,
            onSeek: (position) {},
            onSeekStart: () async {},
            onSeekEnd: (position) async {},
          ),
        ),
      ),
    );

    // Should render chapter markers
    expect(find.byType(Positioned), findsWidgets);
    expect(find.text('02:00'), findsOneWidget);
    expect(find.text('10:00'), findsOneWidget);
  });
}
