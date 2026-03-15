// lib/features/player/data/repositories/audio_effects_repository_impl.dart
import 'package:flutbook/core/error/exceptions.dart';
import 'package:flutbook/features/player/data/datasources/audio_effects_ds.dart';
import 'package:flutbook/features/player/data/models/audio_effect_model.dart';
import 'package:flutbook/features/player/domain/entities/audio_effect.dart';
import 'package:flutbook/features/player/domain/repositories/audio_effects_repository.dart';
import 'package:uuid/uuid.dart';

class AudioEffectsRepositoryImpl implements AudioEffectsRepository {
  AudioEffectsRepositoryImpl({required AudioEffectsDatasource localDatasource})
    : _localDatasource = localDatasource {
    validateDependencies();
  }

  final AudioEffectsDatasource _localDatasource;
  final Uuid _uuid = const Uuid();
  bool _isInitialized = false;

  /// Initialize the repository and validate dependencies
  void validateDependencies() {
    if (!_localDatasource.isInitialized) {
      throw UninitializedDatasourceException(
        'AudioEffectsRepository: Local datasource not initialized',
      );
    }
    _isInitialized = true;
  }

  /// Checks if the repository is ready for use
  bool get isInitialized => _isInitialized;

  @override
  Future<AudioEffect> createAudioEffect({
    required String name,
    required bool isEnabled,
    required double bassBoost,
    required double trebleBoost,
    required Map<String, double> eqBands,
    String? presetName,
  }) async {
    if (!isInitialized) {
      throw UninitializedDatasourceException(
        'AudioEffectsRepository: Cannot perform operations - repository not initialized',
      );
    }

    // Validate name
    if (name.isEmpty) {
      throw ArgumentError('name cannot be an empty string');
    }

    try {
      final domainId = _uuid.v4();
      final now = DateTime.now();

      final effectModel = AudioEffectModel()
        ..domainId = domainId
        ..name = name
        ..isEnabled = isEnabled
        ..bassBoost = bassBoost.clamp(0.0, 1.0)
        ..trebleBoost = trebleBoost.clamp(0.0, 1.0)
        ..eqBandsJson = _mapToJson(eqBands)
        ..presetName = presetName
        ..createdAt = now
        ..updatedAt = now;

      final createdModel = await _localDatasource.createAudioEffect(effectModel);
      return createdModel.toDomain();
    } catch (e) {
      throw Exception('Failed to create audio effect: $e');
    }
  }

  @override
  Future<List<AudioEffect>> getAllAudioEffects() async {
    if (!isInitialized) {
      throw UninitializedDatasourceException(
        'AudioEffectsRepository: Cannot perform operations - repository not initialized',
      );
    }

    try {
      final effectModels = await _localDatasource.getAllAudioEffects();
      return effectModels.map((model) => model.toDomain()).toList();
    } catch (e) {
      throw Exception('Failed to get all audio effects: $e');
    }
  }

  @override
  Future<AudioEffect?> getAudioEffectById(String effectId) async {
    if (!isInitialized) {
      throw UninitializedDatasourceException(
        'AudioEffectsRepository: Cannot perform operations - repository not initialized',
      );
    }

    try {
      final effectModel = await _localDatasource.getAudioEffectByDomainId(effectId);
      return effectModel?.toDomain();
    } catch (e) {
      throw Exception('Failed to get audio effect by ID: $e');
    }
  }

  @override
  Future<AudioEffect?> getEnabledAudioEffect() async {
    if (!isInitialized) {
      throw UninitializedDatasourceException(
        'AudioEffectsRepository: Cannot perform operations - repository not initialized',
      );
    }

    try {
      final effectModel = await _localDatasource.getEnabledAudioEffect();
      return effectModel?.toDomain();
    } catch (e) {
      throw Exception('Failed to get enabled audio effect: $e');
    }
  }

  @override
  Future<bool> deleteAudioEffect(String effectId) async {
    if (!isInitialized) {
      throw UninitializedDatasourceException(
        'AudioEffectsRepository: Cannot perform operations - repository not initialized',
      );
    }

    try {
      // First find the model by domain ID
      final effectModel = await _localDatasource.getAudioEffectByDomainId(effectId);
      if (effectModel == null) {
        return false;
      }
      return await _localDatasource.deleteAudioEffect(effectModel.id);
    } catch (e) {
      throw Exception('Failed to delete audio effect: $e');
    }
  }

  @override
  Future<AudioEffect> updateAudioEffect({
    required String effectId,
    String? name,
    bool? isEnabled,
    double? bassBoost,
    double? trebleBoost,
    Map<String, double>? eqBands,
    String? presetName,
  }) async {
    if (!isInitialized) {
      throw UninitializedDatasourceException(
        'AudioEffectsRepository: Cannot perform operations - repository not initialized',
      );
    }

    try {
      // First, get the existing effect
      final existingModel = await _localDatasource.getAudioEffectByDomainId(effectId);
      if (existingModel == null) {
        throw Exception('Audio effect not found');
      }

      // Update the fields
      if (name != null) {
        // Validate name
        if (name.isEmpty) {
          throw ArgumentError('name cannot be an empty string');
        }
        existingModel.name = name;
      }
      if (isEnabled != null) {
        existingModel.isEnabled = isEnabled;
      }
      if (bassBoost != null) {
        existingModel.bassBoost = bassBoost.clamp(0.0, 1.0);
      }
      if (trebleBoost != null) {
        existingModel.trebleBoost = trebleBoost.clamp(0.0, 1.0);
      }
      if (eqBands != null) {
        existingModel.eqBandsJson = _mapToJson(eqBands);
      }
      if (presetName != null) {
        existingModel.presetName = presetName;
      }
      existingModel.updatedAt = DateTime.now();

      final updatedModel = await _localDatasource.updateAudioEffect(existingModel);
      return updatedModel.toDomain();
    } catch (e) {
      throw Exception('Failed to update audio effect: $e');
    }
  }

  @override
  Future<void> setAudioEffectEnabled(String effectId) async {
    if (!isInitialized) {
      throw UninitializedDatasourceException(
        'AudioEffectsRepository: Cannot perform operations - repository not initialized',
      );
    }

    try {
      // First find the model by domain ID
      final effectModel = await _localDatasource.getAudioEffectByDomainId(effectId);
      if (effectModel == null) {
        throw Exception('Audio effect not found');
      }
      await _localDatasource.setAudioEffectEnabled(effectModel.id);
    } catch (e) {
      throw Exception('Failed to set audio effect enabled: $e');
    }
  }

  @override
  Future<void> disableAllAudioEffects() async {
    if (!isInitialized) {
      throw UninitializedDatasourceException(
        'AudioEffectsRepository: Cannot perform operations - repository not initialized',
      );
    }

    try {
      await _localDatasource.disableAllAudioEffects();
    } catch (e) {
      throw Exception('Failed to disable all audio effects: $e');
    }
  }

  @override
  Future<void> updateBassBoost(String effectId, double bassBoost) async {
    if (!isInitialized) {
      throw UninitializedDatasourceException(
        'AudioEffectsRepository: Cannot perform operations - repository not initialized',
      );
    }

    try {
      // First find the model by domain ID
      final effectModel = await _localDatasource.getAudioEffectByDomainId(effectId);
      if (effectModel == null) {
        throw Exception('Audio effect not found');
      }
      await _localDatasource.updateBassBoost(effectModel.id, bassBoost);
    } catch (e) {
      throw Exception('Failed to update bass boost: $e');
    }
  }

  @override
  Future<void> updateTrebleBoost(String effectId, double trebleBoost) async {
    if (!isInitialized) {
      throw UninitializedDatasourceException(
        'AudioEffectsRepository: Cannot perform operations - repository not initialized',
      );
    }

    try {
      // First find the model by domain ID
      final effectModel = await _localDatasource.getAudioEffectByDomainId(effectId);
      if (effectModel == null) {
        throw Exception('Audio effect not found');
      }
      await _localDatasource.updateTrebleBoost(effectModel.id, trebleBoost);
    } catch (e) {
      throw Exception('Failed to update treble boost: $e');
    }
  }

  @override
  Future<void> updateEqBands(String effectId, Map<String, double> eqBands) async {
    if (!isInitialized) {
      throw UninitializedDatasourceException(
        'AudioEffectsRepository: Cannot perform operations - repository not initialized',
      );
    }

    try {
      // First find the model by domain ID
      final effectModel = await _localDatasource.getAudioEffectByDomainId(effectId);
      if (effectModel == null) {
        throw Exception('Audio effect not found');
      }
      await _localDatasource.updateEqBands(effectModel.id, eqBands);
    } catch (e) {
      throw Exception('Failed to update EQ bands: $e');
    }
  }

  @override
  Future<void> resetAudioEffect(String effectId) async {
    if (!isInitialized) {
      throw UninitializedDatasourceException(
        'AudioEffectsRepository: Cannot perform operations - repository not initialized',
      );
    }

    try {
      // First find the model by domain ID
      final effectModel = await _localDatasource.getAudioEffectByDomainId(effectId);
      if (effectModel == null) {
        throw Exception('Audio effect not found');
      }
      await _localDatasource.resetAudioEffect(effectModel.id);
    } catch (e) {
      throw Exception('Failed to reset audio effect: $e');
    }
  }

  /// Helper to convert Map to JSON string
  String _mapToJson(Map<String, double> map) {
    final entries = map.entries.map((e) => '"${e.key}":${e.value}').join(',');
    return '{$entries}';
  }
}
