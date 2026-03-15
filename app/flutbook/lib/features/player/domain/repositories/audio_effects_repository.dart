// lib/features/player/domain/repositories/audio_effects_repository.dart
import 'package:flutbook/features/player/domain/entities/audio_effect.dart';

abstract class AudioEffectsRepository {
  /// Creates a new audio effect preset
  Future<AudioEffect> createAudioEffect({
    required String name,
    required bool isEnabled,
    required double bassBoost,
    required double trebleBoost,
    required Map<String, double> eqBands,
    String? presetName,
  });

  /// Gets all audio effect presets
  Future<List<AudioEffect>> getAllAudioEffects();

  /// Gets a specific audio effect by ID
  Future<AudioEffect?> getAudioEffectById(String effectId);

  /// Gets the currently enabled audio effect
  Future<AudioEffect?> getEnabledAudioEffect();

  /// Deletes a specific audio effect
  Future<bool> deleteAudioEffect(String effectId);

  /// Updates an existing audio effect
  Future<AudioEffect> updateAudioEffect({
    required String effectId,
    String? name,
    bool? isEnabled,
    double? bassBoost,
    double? trebleBoost,
    Map<String, double>? eqBands,
    String? presetName,
  });

  /// Sets an audio effect as enabled (and disables all others)
  Future<void> setAudioEffectEnabled(String effectId);

  /// Disables all audio effects
  Future<void> disableAllAudioEffects();

  /// Updates bass boost for an audio effect
  Future<void> updateBassBoost(String effectId, double bassBoost);

  /// Updates treble boost for an audio effect
  Future<void> updateTrebleBoost(String effectId, double trebleBoost);

  /// Updates EQ bands for an audio effect
  Future<void> updateEqBands(String effectId, Map<String, double> eqBands);

  /// Resets an audio effect to default values
  Future<void> resetAudioEffect(String effectId);
}
