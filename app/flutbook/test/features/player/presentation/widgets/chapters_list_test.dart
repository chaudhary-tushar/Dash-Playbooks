// test/features/player/presentation/widgets/chapters_list_test.dart
import 'package:flutbook/features/library/domain/entities/audiobook.dart';
import 'package:flutbook/features/library/domain/entities/chapter.dart';
import 'package:flutbook/features/player/presentation/widgets/chapters_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChaptersList Widget Tests', () {
    // Test data
    final testChapters = [
      Chapter(
        id: 'chapter1',
        title: 'Introduction',
        startTime: Duration.zero,
        endTime: const Duration(minutes: 5),
      ),
      Chapter(
        id: 'chapter2',
        title: 'Main Content',
        startTime: const Duration(minutes: 5),
        endTime: const Duration(minutes: 20),
      ),
      Chapter(
        id: 'chapter3',
        title: 'Conclusion',
        startTime: const Duration(minutes: 20),
        endTime: const Duration(minutes: 25),
      ),
    ];

    final testAudiobook = Audiobook(
      id: 'test-book',
      title: 'Test Audiobook',
      author: 'Test Author',
      album: 'Test Album',
      duration: const Duration(minutes: 25),
      filePath: '/test/path.mp3',
      chapters: testChapters,
      createdAt: DateTime.now(),
      completed: false,
      totalSize: 1000,
    );

    testWidgets('ChaptersList displays chapters correctly', (
      WidgetTester tester,
    ) async {
      // Track chapter taps
      Chapter? tappedChapter;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChaptersList(
              audiobook: testAudiobook,
              currentPosition: Duration.zero,
              onChapterTap: (chapter) => tappedChapter = chapter,
            ),
          ),
        ),
      );

      // Verify all chapters are displayed
      expect(find.text('Introduction'), findsOneWidget);
      expect(find.text('Main Content'), findsOneWidget);
      expect(find.text('Conclusion'), findsOneWidget);

      // Verify chapter durations are displayed
      expect(find.text('00:00 - 05:00'), findsOneWidget);
      expect(find.text('05:00 - 20:00'), findsOneWidget);
      expect(find.text('20:00 - 25:00'), findsOneWidget);

      // Verify chapter numbers are displayed
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('ChaptersList highlights current chapter', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChaptersList(
              audiobook: testAudiobook,
              currentPosition: const Duration(minutes: 7), // During chapter 2
              onChapterTap: (chapter) {},
            ),
          ),
        ),
      );

      // Find the ListTile for chapter 2 (Main Content)
      final chapter2Finder = find.byWidgetPredicate(
        (widget) =>
            widget is ListTile &&
            widget.title is Text &&
            (widget.title! as Text).data == 'Main Content',
      );

      expect(chapter2Finder, findsOneWidget);

      final chapter2Tile = tester.widget<ListTile>(chapter2Finder);

      // Verify it's highlighted (has primary color)
      expect(
        chapter2Tile.title is Text &&
            (chapter2Tile.title! as Text).style?.fontWeight == FontWeight.bold,
        isTrue,
      );
    });

    testWidgets('ChaptersList handles tap-to-jump functionality', (
      WidgetTester tester,
    ) async {
      Chapter? tappedChapter;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChaptersList(
              audiobook: testAudiobook,
              currentPosition: Duration.zero,
              onChapterTap: (chapter) => tappedChapter = chapter,
            ),
          ),
        ),
      );

      // Tap on the second chapter
      await tester.tap(find.text('Main Content'));
      await tester.pump();

      // Verify the correct chapter was tapped
      expect(tappedChapter?.id, equals('chapter2'));
      expect(tappedChapter?.title, equals('Main Content'));
      expect(tappedChapter?.startTime, equals(const Duration(minutes: 5)));
    });

    testWidgets('ChaptersList shows empty state when no chapters', (
      WidgetTester tester,
    ) async {
      final emptyAudiobook = testAudiobook.copyWith(chapters: []);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChaptersList(
              audiobook: emptyAudiobook,
              currentPosition: Duration.zero,
              onChapterTap: (chapter) {},
            ),
          ),
        ),
      );

      // Verify empty state message is shown
      expect(
        find.text('No chapters available for this audiobook'),
        findsOneWidget,
      );
    });

    testWidgets('ChaptersList displays chapter duration correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChaptersList(
              audiobook: testAudiobook,
              currentPosition: Duration.zero,
              onChapterTap: (chapter) {},
            ),
          ),
        ),
      );

      // Verify duration formatting
      expect(
        find.text('00:00 - 05:00'),
        findsOneWidget,
      ); // Short duration (no hours)
      expect(
        find.text('05:00 - 20:00'),
        findsOneWidget,
      ); // Medium duration (no hours)
      expect(
        find.text('20:00 - 25:00'),
        findsOneWidget,
      ); // Longer duration (no hours)
    });

    testWidgets('ChaptersList provides smooth navigation', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Container(height: 500), // Some content above
                  SizedBox(
                    height: 300, // Fixed height for chapters list
                    child: ChaptersList(
                      audiobook: testAudiobook,
                      currentPosition: Duration.zero,
                      onChapterTap: (chapter) {},
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Verify the ListView is scrollable and has the right physics
      final listView = tester.widget<ListView>(find.byType(ListView));
      expect(listView.physics, isA<NeverScrollableScrollPhysics>());
      expect(listView.shrinkWrap, isTrue);
    });
  });
}
