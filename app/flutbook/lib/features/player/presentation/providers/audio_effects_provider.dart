// lib/features/player/presentation/providers/audio_effects_provider.dart
import 'package:flutbook/core/error/exceptions.dart';
import 'package:flutbook/core/provider/providers.dart'
    show audioEffectsRepositoryProvider, audioEffectsUsecaseProvider;
import 'package:flutbook/features/player/domain/entities/audio_effect.dart';
import 'package:flutbook/features/player/domain/repositories/audio_effects_repository.dart';
import 'package:flutbook/features/player/domain/usecases/audio_effects_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State class representing the current audio effects state.
class AudioEffectsState {
  const AudioEffectsState({
    required this.effects,
    required this.currentEffect,
    required this.isLoading,
    this.errorMessage,
  });

  /// Creates an initial audio effects state with default values.
  factory AudioEffectsState.initial() {
    return const AudioEffectsState(
      effects: [],
      currentEffect: null,
      isLoading: false,
    );
  }

  final List<AudioEffect> effects;
  final AudioEffect? currentEffect;
  final bool isLoading;
  final String? errorMessage;

  AudioEffectsState copyWith({
    List<AudioEffect>? effects,
    AudioEffect? currentEffect,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AudioEffectsState(
      effects: effects ?? this.effects,
      currentEffect: currentEffect ?? this.currentEffect,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Main audio effects provider that manages the state and logic for audio effects operations.
final audioEffectsProvider = NotifierProvider<AudioEffectsNotifier, AudioEffectsState>(
  AudioEffectsNotifier.new,
);

/// Notifier class that manages the audio effects state and business logic.
class AudioEffectsNotifier extends Notifier<AudioEffectsState> {
  // Dependencies
  late AudioEffectsUsecase _audioEffectsUsecase;
  late AudioEffectsRepository _audioEffectsRepository;

  @override
  AudioEffectsState build() {
    try {
      // Initialize use cases directly from providers
      _audioEffectsUsecase = ref.read(audioEffectsUsecaseProvider);
      final audioEffectsRepoAsync = ref.read(audioEffectsRepositoryProvider);
      _audioEffectsRepository =
          audioEffectsRepoAsync.value ??
          (throw UninitializedDatasourceException(
            'Audio effects repository not initialized',
          ));

      return AudioEffectsState.initial();
    } catch (e) {
      // Handle initialization errors
      return AudioEffectsState(
        effects: [],
        currentEffect: null,
        isLoading: false,
        errorMessage: ErrorHandler.handlePlaybackException(e),
      );
    }
  }

  /// Load all audio effects
  Future<void> loadAudioEffects() async {
    state = state.copyWith(isLoading: true);

    try {
      final effects = await _audioEffectsUsecase.getAllAudioEffects();
      final currentEffect = await _audioEffectsUsecase.getEnabledAudioEffect();
      state = state.copyWith(
        effects: effects,
        currentEffect: currentEffect,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load audio effects: $e',
      );
    }
  }

  /// Create a new audio effect preset
  Future<void> createAudioEffect({
    required String name,
    required bool isEnabled,
    required double bassBoost,
    required double trebleBoost,
    required Map<String, double> eqBands,
    String? presetName,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      final effect = await _audioEffectsUsecase.createAudioEffect(
        name: name,
        isEnabled: isEnabled,
        bassBoost: bassBoost,
        trebleBoost: trebleBoost,
        eqBands: eqBands,
        presetName: presetName,
      );

      // Add the new effect to the list
      final updatedEffects = [...state.effects, effect];
      state = state.copyWith(
        effects: updatedEffects,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to create audio effect: $e',
      );
    }
  }

  /// Delete an audio effect
  Future<void> deleteAudioEffect(String effectId) async {
    state = state.copyWith(isLoading: true);

    try {
      await _audioEffectsUsecase.deleteAudioEffect(effectId);

      // Remove the effect from the list
      final updatedEffects = state.effects.where((effect) => effect.id != effectId).toList();

      // If the deleted effect was the current effect, clear it
      AudioEffect? updatedCurrentEffect = state.currentEffect;
      if (state.currentEffect?.id == effectId) {
        updatedCurrentEffect = null;
      }

      state = state.copyWith(
        effects: updatedEffects,
        currentEffect: updatedCurrentEffect,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to delete audio effect: $e',
      );
    }
  }

  /// Set the current audio effect
  Future<void> setCurrentAudioEffect(String effectId) async {
    state = state.copyWith(isLoading: true);

    try {
      await _audioEffectsUsecase.setAudioEffectEnabled(effectId);
      final effect = await _audioEffectsUsecase.getAudioEffectById(effectId);
      state = state.copyWith(
        currentEffect: effect,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to set current audio effect: $e',
      );
    }
  }

  /// Update bass boost for the current effect
  Future<void> updateBassBoost(double bassBoost) async {
    if (state.currentEffect == null) return;

    try {
      await _audioEffectsUsecase.updateBassBoost(
        state.currentEffect!.id,
        bassBoost,
      );

      // Reload the effect to get updated data
      final updatedEffect = await _audioEffectsUsecase.getAudioEffectById(
        state.currentEffect!.id,
      );
      if (updatedEffect != null) {
        final updatedEffects = state.effects.map((effect) {
          return effect.id == updatedEffect.id ? updatedEffect : effect;
        }).toList();

        state = state.copyWith(
          effects: updatedEffects,
          currentEffect: updatedEffect,
        );
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to update bass boost: $e',
      );
    }
  }

  /// Update treble boost for the current effect
  Future<void> updateTrebleBoost(double trebleBoost) async {
    if (state.currentEffect == null) return;

    try {
      await _audioEffectsUsecase.updateTrebleBoost(
        state.currentEffect!.id,
        trebleBoost,
      );

      // Reload the effect to get updated data
      final updatedEffect = await _audioEffectsUsecase.getAudioEffectById(
        state.currentEffect!.id,
      );
      if (updatedEffect != null) {
        final updatedEffects = state.effects.map((effect) {
          return effect.id == updatedEffect.id ? updatedEffect : effect;
        }).toList();

        state = state.copyWith(
          effects: updatedEffects,
          currentEffect: updatedEffect,
        );
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to update treble boost: $e',
      );
    }
  }

  /// Update EQ bands for the current effect
  Future<void> updateEqBands(Map<String, double> eqBands) async {
    if (state.currentEffect == null) return;

    try {
      await _audioEffectsUsecase.updateEqBands(
        state.currentEffect!.id,
        eqBands,
      );

      // Reload the effect to get updated data
      final updatedEffect = await _audioEffectsUsecase.getAudioEffectById(
        state.currentEffect!.id,
      );
      if (updatedEffect != null) {
        final updatedEffects = state.effects.map((effect) {
          return effect.id == updatedEffect.id ? updatedEffect : effect;
        }).toList();

        state = state.copyWith(
          effects: updatedEffects,
          currentEffect: updatedEffect,
        );
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to update EQ bands: $e',
      );
    }
  }

  /// Reset the current audio effect to default values
  Future<void> resetCurrentEffect() async {
    if (state.currentEffect == null) return;

    try {
      await _audioEffectsUsecase.resetAudioEffect(state.currentEffect!.id);

      // Reload the effect to get updated data
      final updatedEffect = await _audioEffectsUsecase.getAudioEffectById(
        state.currentEffect!.id,
      );
      if (updatedEffect != null) {
        final updatedEffects = state.effects.map((effect) {
          return effect.id == updatedEffect.id ? updatedEffect : effect;
        }).toList();

        state = state.copyWith(
          effects: updatedEffects,
          currentEffect: updatedEffect,
        );
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to reset audio effect: $e',
      );
    }
  }

  /// Disable all audio effects
  Future<void> disableAllEffects() async {
    try {
      await _audioEffectsUsecase.disableAllAudioEffects();
      state = state.copyWith(
        
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to disable all effects: $e',
      );
    }
  }

  /// Clear any error message from the audio effects state.
  void clearError() {
    state = state.copyWith();
  }
}

/// Provider for all audio effects.
final audioEffectsListProvider = FutureProvider<List<AudioEffect>>((ref) async {
  final audioEffectsRepoAsync = ref.watch(audioEffectsRepositoryProvider);
  return audioEffectsRepoAsync.when(
    loading: () => <AudioEffect>[],
    error: (error, stackTrace) => <AudioEffect>[],
    data: (repo) {
      return repo.getAllAudioEffects();
    },
  );
});
