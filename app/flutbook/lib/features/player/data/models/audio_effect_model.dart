// lib/features/player/data/models/audio_effect_model.dart
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
    final entries = map.entries.map((e) => '"${e.key}":${e.value}').join(',');
    return '{$entries}';
  }

  // Helper to convert JSON string to Map
  Map<String, double> _jsonToMap(String json) {
    final map = <String, double>{};
    // Simple JSON parsing for our specific format
    final cleaned = json.replaceAll('{', '').replaceAll('}', '');
    if (cleaned.isEmpty) return map;

    final pairs = cleaned.split(',');
    for (final pair in pairs) {
      final parts = pair.split(':');
      if (parts.length == 2) {
        final key = parts[0].replaceAll('"', '').trim();
        final value = double.tryParse(parts[1].trim()) ?? 0.0;
        map[key] = value;
      }
    }
    return map;
  }
}
