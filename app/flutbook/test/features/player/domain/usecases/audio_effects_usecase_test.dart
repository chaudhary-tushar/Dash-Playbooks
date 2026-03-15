// test/features/player/domain/usecases/audio_effects_usecase_test.dart
import 'package:flutbook/features/player/domain/entities/audio_effect.dart';
import 'package:flutbook/features/player/domain/repositories/audio_effects_repository.dart';
import 'package:flutbook/features/player/domain/usecases/audio_effects_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAudioEffectsRepository extends Mock implements AudioEffectsRepository {}

void main() {
  late AudioEffectsUsecase usecase;
  late MockAudioEffectsRepository mockRepository;

  setUp(() {
    mockRepository = MockAudioEffectsRepository();
    usecase = AudioEffectsUsecase(mockRepository);
  });

  group('AudioEffectsUsecase', () {
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

    group('createAudioEffect', () {
      test('should create audio effect successfully', () async {
        // Arrange
        when(
          () => mockRepository.createAudioEffect(
            name: any(named: 'name'),
            isEnabled: any(named: 'isEnabled'),
            bassBoost: any(named: 'bassBoost'),
            trebleBoost: any(named: 'trebleBoost'),
            eqBands: any(named: 'eqBands'),
          ),
        ).thenAnswer((_) async => testEffect);

        // Act
        final result = await usecase.createAudioEffect(
          name: 'Test Effect',
          isEnabled: true,
          bassBoost: 0.5,
          trebleBoost: 0.3,
          eqBands: {'60Hz': 2.0, '230Hz': 1.5, '910Hz': 0.0, '3.6kHz': -1.0, '14kHz': 2.5},
        );

        // Assert
        expect(result, equals(testEffect));
        verify(
          () => mockRepository.createAudioEffect(
            name: 'Test Effect',
            isEnabled: true,
            bassBoost: 0.5,
            trebleBoost: 0.3,
            eqBands: {'60Hz': 2.0, '230Hz': 1.5, '910Hz': 0.0, '3.6kHz': -1.0, '14kHz': 2.5},
          ),
        ).called(1);
      });

      test('should throw exception when repository fails', () async {
        // Arrange
        when(
          () => mockRepository.createAudioEffect(
            name: any(named: 'name'),
            isEnabled: any(named: 'isEnabled'),
            bassBoost: any(named: 'bassBoost'),
            trebleBoost: any(named: 'trebleBoost'),
            eqBands: any(named: 'eqBands'),
          ),
        ).thenThrow(Exception('Database error'));

        // Act & Assert
        expect(
          () => usecase.createAudioEffect(
            name: 'Test Effect',
            isEnabled: true,
            bassBoost: 0.5,
            trebleBoost: 0.3,
            eqBands: {'60Hz': 2.0},
          ),
          throwsException,
        );
      });
    });

    group('getAllAudioEffects', () {
      test('should return list of audio effects', () async {
        // Arrange
        final effects = [testEffect];
        when(() => mockRepository.getAllAudioEffects()).thenAnswer((_) async => effects);

        // Act
        final result = await usecase.getAllAudioEffects();

        // Assert
        expect(result, equals(effects));
        verify(() => mockRepository.getAllAudioEffects()).called(1);
      });

      test('should return empty list when no effects exist', () async {
        // Arrange
        when(() => mockRepository.getAllAudioEffects()).thenAnswer((_) async => []);

        // Act
        final result = await usecase.getAllAudioEffects();

        // Assert
        expect(result, isEmpty);
      });
    });

    group('getAudioEffectById', () {
      test('should return audio effect when found', () async {
        // Arrange
        when(() => mockRepository.getAudioEffectById('1')).thenAnswer((_) async => testEffect);

        // Act
        final result = await usecase.getAudioEffectById('1');

        // Assert
        expect(result, equals(testEffect));
        verify(() => mockRepository.getAudioEffectById('1')).called(1);
      });

      test('should return null when effect not found', () async {
        // Arrange
        when(() => mockRepository.getAudioEffectById('999')).thenAnswer((_) async => null);

        // Act
        final result = await usecase.getAudioEffectById('999');

        // Assert
        expect(result, isNull);
      });
    });

    group('updateAudioEffect', () {
      test('should update audio effect successfully', () async {
        // Arrange
        final updatedEffect = testEffect.copyWith(name: 'Updated Effect');
        when(
          () => mockRepository.updateAudioEffect(
            effectId: any(named: 'effectId'),
            name: any(named: 'name'),
            isEnabled: any(named: 'isEnabled'),
            bassBoost: any(named: 'bassBoost'),
            trebleBoost: any(named: 'trebleBoost'),
            eqBands: any(named: 'eqBands'),
            presetName: any(named: 'presetName'),
          ),
        ).thenAnswer((_) async => updatedEffect);

        // Act
        final result = await usecase.updateAudioEffect(
          effectId: '1',
          name: 'Updated Effect',
        );

        // Assert
        expect(result, equals(updatedEffect));
        verify(
          () => mockRepository.updateAudioEffect(
            effectId: '1',
            name: 'Updated Effect',
          ),
        ).called(1);
      });
    });

    group('deleteAudioEffect', () {
      test('should delete audio effect successfully', () async {
        // Arrange
        when(() => mockRepository.deleteAudioEffect('1')).thenAnswer((_) async => true);

        // Act
        final result = await usecase.deleteAudioEffect('1');

        // Assert
        expect(result, isTrue);
        verify(() => mockRepository.deleteAudioEffect('1')).called(1);
      });

      test('should return false when deletion fails', () async {
        // Arrange
        when(() => mockRepository.deleteAudioEffect('1')).thenAnswer((_) async => false);

        // Act
        final result = await usecase.deleteAudioEffect('1');

        // Assert
        expect(result, isFalse);
      });
    });

    group('setAudioEffectEnabled', () {
      test('should enable audio effect successfully', () async {
        // Arrange
        when(() => mockRepository.setAudioEffectEnabled('1')).thenAnswer((_) async {});

        // Act
        await usecase.setAudioEffectEnabled('1');

        // Assert
        verify(() => mockRepository.setAudioEffectEnabled('1')).called(1);
      });
    });

    group('disableAllAudioEffects', () {
      test('should disable all audio effects successfully', () async {
        // Arrange
        when(() => mockRepository.disableAllAudioEffects()).thenAnswer((_) async {});

        // Act
        await usecase.disableAllAudioEffects();

        // Assert
        verify(() => mockRepository.disableAllAudioEffects()).called(1);
      });
    });

    group('getEnabledAudioEffect', () {
      test('should return enabled effect when one exists', () async {
        // Arrange
        when(() => mockRepository.getEnabledAudioEffect()).thenAnswer((_) async => testEffect);

        // Act
        final result = await usecase.getEnabledAudioEffect();

        // Assert
        expect(result, equals(testEffect));
        verify(() => mockRepository.getEnabledAudioEffect()).called(1);
      });

      test('should return null when no effect is enabled', () async {
        // Arrange
        when(() => mockRepository.getEnabledAudioEffect()).thenAnswer((_) async => null);

        // Act
        final result = await usecase.getEnabledAudioEffect();

        // Assert
        expect(result, isNull);
      });
    });

    group('updateBassBoost', () {
      test('should update bass boost successfully', () async {
        // Arrange
        when(() => mockRepository.updateBassBoost('1', 0.8)).thenAnswer((_) async {});

        // Act
        await usecase.updateBassBoost('1', 0.8);

        // Assert
        verify(() => mockRepository.updateBassBoost('1', 0.8)).called(1);
      });
    });

    group('updateTrebleBoost', () {
      test('should update treble boost successfully', () async {
        // Arrange
        when(() => mockRepository.updateTrebleBoost('1', 0.6)).thenAnswer((_) async {});

        // Act
        await usecase.updateTrebleBoost('1', 0.6);

        // Assert
        verify(() => mockRepository.updateTrebleBoost('1', 0.6)).called(1);
      });
    });

    group('updateEqBands', () {
      test('should update EQ bands successfully', () async {
        // Arrange
        final eqBands = {'60Hz': 3.0, '230Hz': 2.0};
        when(() => mockRepository.updateEqBands('1', eqBands)).thenAnswer((_) async {});

        // Act
        await usecase.updateEqBands('1', eqBands);

        // Assert
        verify(() => mockRepository.updateEqBands('1', eqBands)).called(1);
      });
    });

    group('resetAudioEffect', () {
      test('should reset effect to default successfully', () async {
        // Arrange
        when(() => mockRepository.resetAudioEffect('1')).thenAnswer((_) async {});

        // Act
        await usecase.resetAudioEffect('1');

        // Assert
        verify(() => mockRepository.resetAudioEffect('1')).called(1);
      });
    });
  });
}
