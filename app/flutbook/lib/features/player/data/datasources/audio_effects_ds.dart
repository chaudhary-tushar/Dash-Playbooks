// lib/features/player/data/datasources/audio_effects_ds.dart
import 'package:flutbook/core/error/exceptions.dart';
import 'package:flutbook/features/player/data/models/audio_effect_model.dart';
import 'package:isar_community/isar.dart';

class AudioEffectsDatasource {
  AudioEffectsDatasource(this._isar) {
    validateInitialization();
  }
  final Isar _isar;

  void validateInitialization() {
    if (!_isar.isOpen) {
      throw UninitializedDatasourceException('Isar database is not open');
    }
  }

  /// Checks if the datasource is initialized and ready for use
  bool get isInitialized => _isar.isOpen;

  /// Creates a new audio effect preset
  Future<AudioEffectModel> createAudioEffect(AudioEffectModel effect) async {
    validateInitialization();

    return _isar.writeTxn(() async {
      // Set the ID to auto-increment (0 means let Isar assign it)
      effect.id = Isar.autoIncrement;
      await _isar.audioEffectModels.put(effect);
      return effect;
    });
  }

  /// Gets all audio effect presets
  Future<List<AudioEffectModel>> getAllAudioEffects() async {
    validateInitialization();
    return _isar.audioEffectModels.where().findAll();
  }

  /// Gets a specific audio effect by ID
  Future<AudioEffectModel?> getAudioEffectById(int effectId) async {
    validateInitialization();
    return _isar.audioEffectModels.get(effectId);
  }

  /// Gets audio effect by domain ID
  Future<AudioEffectModel?> getAudioEffectByDomainId(String domainId) async {
    validateInitialization();
    return _isar.audioEffectModels.filter().domainIdEqualTo(domainId).findFirst();
  }

  /// Gets the currently enabled audio effect
  Future<AudioEffectModel?> getEnabledAudioEffect() async {
    validateInitialization();
    return _isar.audioEffectModels.filter().isEnabledEqualTo(true).findFirst();
  }

  /// Deletes a specific audio effect
  Future<bool> deleteAudioEffect(int effectId) async {
    validateInitialization();
    return _isar.writeTxn(() async {
      final result = await _isar.audioEffectModels.delete(effectId);
      return result;
    });
  }

  /// Updates an existing audio effect
  Future<AudioEffectModel> updateAudioEffect(AudioEffectModel effect) async {
    validateInitialization();

    return _isar.writeTxn(() async {
      await _isar.audioEffectModels.put(effect);
      return effect;
    });
  }

  /// Sets an audio effect as enabled (and disables all others)
  Future<void> setAudioEffectEnabled(int effectId) async {
    validateInitialization();

    await _isar.writeTxn(() async {
      // First, disable all audio effects
      final allEffects = await _isar.audioEffectModels.where().findAll();
      for (final effect in allEffects) {
        effect.isEnabled = false;
        await _isar.audioEffectModels.put(effect);
      }

      // Then enable the specified effect
      final effect = await _isar.audioEffectModels.get(effectId);
      if (effect != null) {
        effect.isEnabled = true;
        await _isar.audioEffectModels.put(effect);
      }
    });
  }

  /// Disables all audio effects
  Future<void> disableAllAudioEffects() async {
    validateInitialization();

    await _isar.writeTxn(() async {
      final allEffects = await _isar.audioEffectModels.where().findAll();
      for (final effect in allEffects) {
        effect.isEnabled = false;
        await _isar.audioEffectModels.put(effect);
      }
    });
  }

  /// Updates bass boost for an audio effect
  Future<void> updateBassBoost(int effectId, double bassBoost) async {
    validateInitialization();

    await _isar.writeTxn(() async {
      final effect = await _isar.audioEffectModels.get(effectId);
      if (effect != null) {
        effect.bassBoost = bassBoost.clamp(0.0, 1.0);
        effect.updatedAt = DateTime.now();
        await _isar.audioEffectModels.put(effect);
      }
    });
  }

  /// Updates treble boost for an audio effect
  Future<void> updateTrebleBoost(int effectId, double trebleBoost) async {
    validateInitialization();

    await _isar.writeTxn(() async {
      final effect = await _isar.audioEffectModels.get(effectId);
      if (effect != null) {
        effect.trebleBoost = trebleBoost.clamp(0.0, 1.0);
        effect.updatedAt = DateTime.now();
        await _isar.audioEffectModels.put(effect);
      }
    });
  }

  /// Updates EQ bands for an audio effect
  Future<void> updateEqBands(int effectId, Map<String, double> eqBands) async {
    validateInitialization();

    await _isar.writeTxn(() async {
      final effect = await _isar.audioEffectModels.get(effectId);
      if (effect != null) {
        // Convert map to JSON string
        final entries = eqBands.entries.map((e) => '"${e.key}":${e.value}').join(',');
        effect.eqBandsJson = '{$entries}';
        effect.updatedAt = DateTime.now();
        await _isar.audioEffectModels.put(effect);
      }
    });
  }

  /// Resets an audio effect to default values
  Future<void> resetAudioEffect(int effectId) async {
    validateInitialization();

    await _isar.writeTxn(() async {
      final effect = await _isar.audioEffectModels.get(effectId);
      if (effect != null) {
        effect.bassBoost = 0.0;
        effect.trebleBoost = 0.0;
        effect.eqBandsJson = '{"60Hz":0.0,"230Hz":0.0,"910Hz":0.0,"3.6kHz":0.0,"14kHz":0.0}';
        effect.updatedAt = DateTime.now();
        await _isar.audioEffectModels.put(effect);
      }
    });
  }
}
