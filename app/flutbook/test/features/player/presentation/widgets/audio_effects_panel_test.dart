// test/features/player/presentation/widgets/audio_effects_panel_test.dart
import 'package:flutbook/features/player/domain/entities/audio_effect.dart';
import 'package:flutbook/features/player/presentation/providers/audio_effects_provider.dart';
import 'package:flutbook/features/player/presentation/widgets/audio_effects_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAudioEffectsNotifier extends Mock implements AudioEffectsNotifier {}

void main() {
  late MockAudioEffectsNotifier mockNotifier;

  setUp(() {
    mockNotifier = MockAudioEffectsNotifier();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        audioEffectsProvider.overrideWith(() => mockNotifier),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: AudioEffectsPanel(),
        ),
      ),
    );
  }

  group('AudioEffectsPanel', () {
    testWidgets('should display audio effects panel', (tester) async {
      // Arrange
      when(() => mockNotifier.state).thenReturn(
        const AudioEffectsState(
          effects: [],
          currentEffect: null,
          isLoading: false,
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Audio Effects'), findsOneWidget);
      expect(find.text('Presets'), findsOneWidget);
      expect(find.text('Bass Boost'), findsOneWidget);
      expect(find.text('Treble Boost'), findsOneWidget);
      expect(find.text('Equalizer'), findsOneWidget);
    });

    testWidgets('should display preset chips', (tester) async {
      // Arrange
      when(() => mockNotifier.state).thenReturn(
        const AudioEffectsState(
          effects: [],
          currentEffect: null,
          isLoading: false,
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Default'), findsOneWidget);
      expect(find.text('Music'), findsOneWidget);
      expect(find.text('Podcast'), findsOneWidget);
      expect(find.text('Bass Boost'), findsOneWidget);
      expect(find.text('Treble Boost'), findsOneWidget);
    });

    testWidgets('should display bass boost slider', (tester) async {
      // Arrange
      when(() => mockNotifier.state).thenReturn(
        const AudioEffectsState(
          effects: [],
          currentEffect: null,
          isLoading: false,
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(Slider), findsWidgets);
    });

    testWidgets('should display treble boost slider', (tester) async {
      // Arrange
      when(() => mockNotifier.state).thenReturn(
        const AudioEffectsState(
          effects: [],
          currentEffect: null,
          isLoading: false,
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(Slider), findsWidgets);
    });

    testWidgets('should display equalizer bands', (tester) async {
      // Arrange
      final testEffect = AudioEffect(
        id: '1',
        name: 'Test Effect',
        isEnabled: true,
        bassBoost: 0.5,
        trebleBoost: 0.3,
        eqBands: {'60Hz': 2.0, '230Hz': 1.5, '910Hz': 0.0, '3.6kHz': -1.0, '14kHz': 2.5},
        presetName: 'Test Preset',
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      );

      when(() => mockNotifier.state).thenReturn(
        AudioEffectsState(
          effects: [testEffect],
          currentEffect: testEffect,
          isLoading: false,
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('60Hz'), findsOneWidget);
      expect(find.text('230Hz'), findsOneWidget);
      expect(find.text('910Hz'), findsOneWidget);
      expect(find.text('3.6kHz'), findsOneWidget);
      expect(find.text('14kHz'), findsOneWidget);
    });

    testWidgets('should display reset button', (tester) async {
      // Arrange
      when(() => mockNotifier.state).thenReturn(
        const AudioEffectsState(
          effects: [],
          currentEffect: null,
          isLoading: false,
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Reset to Default'), findsOneWidget);
    });

    testWidgets('should show loading indicator when loading', (tester) async {
      // Arrange
      when(() => mockNotifier.state).thenReturn(
        const AudioEffectsState(
          effects: [],
          currentEffect: null,
          isLoading: true,
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show error message when error occurs', (tester) async {
      // Arrange
      when(() => mockNotifier.state).thenReturn(
        const AudioEffectsState(
          effects: [],
          currentEffect: null,
          isLoading: false,
          errorMessage: 'Failed to load audio effects',
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Failed to load audio effects'), findsOneWidget);
    });
  });
}
