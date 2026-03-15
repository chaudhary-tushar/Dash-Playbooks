// lib/features/player/domain/usecases/audio_effects_usecase.dart
import 'package:flutbook/features/player/domain/entities/audio_effect.dart';
import 'package:flutbook/features/player/domain/repositories/audio_effects_repository.dart';

class AudioEffectsUsecase {
  AudioEffectsUsecase(this.repository);

  final AudioEffectsRepository repository;

  /// Creates a new audio effect preset
  Future<AudioEffect> createAudioEffect({
    required String name,
    required bool isEnabled,
    required double bassBoost,
    required double trebleBoost,
    required Map<String, double> eqBands,
    String? presetName,
  }) async {
    return repository.createAudioEffect(
      name: name,
      isEnabled: isEnabled,
      bassBoost: bassBoost,
      trebleBoost: trebleBoost,
      eqBands: eqBands,
      presetName: presetName,
    );
  }

  /// Gets all audio effect presets
  Future<List<AudioEffect>> getAllAudioEffects() async {
    return repository.getAllAudioEffects();
  }

  /// Gets a specific audio effect by ID
  Future<AudioEffect?> getAudioEffectById(String effectId) async {
    return repository.getAudioEffectById(effectId);
  }

  /// Gets the currently enabled audio effect
  Future<AudioEffect?> getEnabledAudioEffect() async {
    return repository.getEnabledAudioEffect();
  }

  /// Deletes a specific audio effect
  Future<bool> deleteAudioEffect(String effectId) async {
    return repository.deleteAudioEffect(effectId);
  }

  /// Updates an existing audio effect
  Future<AudioEffect> updateAudioEffect({
    required String effectId,
    String? name,
    bool? isEnabled,
    double? bassBoost,
    double? trebleBoost,
    Map<String, double>? eqBands,
    String? presetName,
  }) async {
    return repository.updateAudioEffect(
      effectId: effectId,
      name: name,
      isEnabled: isEnabled,
      bassBoost: bassBoost,
      trebleBoost: trebleBoost,
      eqBands: eqBands,
      presetName: presetName,
    );
  }

  /// Sets an audio effect as enabled (and disables all others)
  Future<void> setAudioEffectEnabled(String effectId) async {
    await repository.setAudioEffectEnabled(effectId);
  }

  /// Disables all audio effects
  Future<void> disableAllAudioEffects() async {
    await repository.disableAllAudioEffects();
  }

  /// Updates bass boost for an audio effect
  Future<void> updateBassBoost(String effectId, double bassBoost) async {
    await repository.updateBassBoost(effectId, bassBoost);
  }

  /// Updates treble boost for an audio effect
  Future<void> updateTrebleBoost(String effectId, double trebleBoost) async {
    await repository.updateTrebleBoost(effectId, trebleBoost);
  }

  /// Updates EQ bands for an audio effect
  Future<void> updateEqBands(String effectId, Map<String, double> eqBands) async {
    await repository.updateEqBands(effectId, eqBands);
  }

  /// Resets an audio effect to default values
  Future<void> resetAudioEffect(String effectId) async {
    await repository.resetAudioEffect(effectId);
  }
}
