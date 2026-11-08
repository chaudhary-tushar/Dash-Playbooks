// lib/features/player/data/models/audio_effect_model.dart
import 'dart:convert';

import 'package:flutbook/features/player/domain/entities/audio_effect.dart' as domain;
import 'package:isar_community/isar.dart';

part 'audio_effect_model.g.dart';

@collection
class AudioEffectModel {
  // Empty constructor for Isar
  AudioEffectModel();

  // Constructor from domain entity
  AudioEffectModel.fromDomain(domain.AudioEffect effect) {
    domainId = effect.id;
    name = effect.name;
    isEnabled = effect.isEnabled;
    bassBoost = effect.bassBoost;
    trebleBoost = effect.trebleBoost;
    eqBandsJson = _mapToJson(effect.eqBands);
    presetName = effect.presetName;
    createdAt = effect.createdAt;
    updatedAt = effect.updatedAt;
  }

  Id id = Isar.autoIncrement;

  // Domain ID (UUID string)
  late String domainId;

  late String name;

  late bool isEnabled;

  late double bassBoost;

  late double trebleBoost;

  // Store EQ bands as JSON string for Isar compatibility
  late String eqBandsJson;

  String? presetName;

  late DateTime createdAt;

  late DateTime updatedAt;

  // Convert to domain entity
  domain.AudioEffect toDomain() {
    return domain.AudioEffect(
      id: domainId,
      name: name,
      isEnabled: isEnabled,
      bassBoost: bassBoost,
      trebleBoost: trebleBoost,
      eqBands: _jsonToMap(eqBandsJson),
      presetName: presetName,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // Helper to convert Map to JSON string
  String _mapToJson(Map<String, double> map) {
    return jsonEncode(map);
  }

  // Helper to convert JSON string to Map
  Map<String, double> _jsonToMap(String json) {
    try {
      final decoded = jsonDecode(json);
      if (decoded is Map) {
        return decoded.map(
          (key, value) =>
              MapEntry(key.toString(), (value as num?)?.toDouble() ?? 0.0),
        );
      }
    } catch (_) {
      // Fall through with an empty map on malformed input.
    }
    return <String, double>{};
  }
}
