// lib/features/player/domain/entities/audio_effect.dart
import 'dart:convert';

/// Domain entity representing audio effects settings.
///
/// This entity stores equalizer settings, bass boost, and other audio effects
/// that can be applied to audio playback.
class AudioEffect {
  const AudioEffect({
    required this.id,
    required this.name,
    required this.isEnabled,
    required this.bassBoost,
    required this.trebleBoost,
    required this.eqBands,
    required this.presetName,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates an AudioEffect from a Map
  factory AudioEffect.fromMap(Map<String, dynamic> map) {
    return AudioEffect(
      id: map['id'] as String,
      name: map['name'] as String,
      isEnabled: map['isEnabled'] as bool,
      bassBoost: (map['bassBoost'] as num).toDouble(),
      trebleBoost: (map['trebleBoost'] as num).toDouble(),
      eqBands: Map<String, double>.from(
        (map['eqBands'] as Map).map(
          (key, value) => MapEntry(key as String, (value as num).toDouble()),
        ),
      ),
      presetName: map['presetName'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  /// Creates an AudioEffect from JSON string
  factory AudioEffect.fromJson(String source) =>
      AudioEffect.fromMap(json.decode(source) as Map<String, dynamic>);

  /// Creates a default audio effect with no modifications
  factory AudioEffect.defaultEffect() {
    return AudioEffect(
      id: 'default',
      name: 'Default',
      isEnabled: false,
      bassBoost: 0,
      trebleBoost: 0,
      eqBands: {
        '60Hz': 0.0,
        '230Hz': 0.0,
        '910Hz': 0.0,
        '3.6kHz': 0.0,
        '14kHz': 0.0,
      },
      presetName: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Creates a music preset with enhanced bass and treble
  factory AudioEffect.musicPreset() {
    return AudioEffect(
      id: 'music',
      name: 'Music',
      isEnabled: true,
      bassBoost: 0.3,
      trebleBoost: 0.2,
      eqBands: {
        '60Hz': 4.0,
        '230Hz': 2.0,
        '910Hz': 0.0,
        '3.6kHz': 2.0,
        '14kHz': 4.0,
      },
      presetName: 'Music',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Creates a podcast preset with enhanced mid-range
  factory AudioEffect.podcastPreset() {
    return AudioEffect(
      id: 'podcast',
      name: 'Podcast',
      isEnabled: true,
      bassBoost: 0.1,
      trebleBoost: 0.1,
      eqBands: {
        '60Hz': -2.0,
        '230Hz': 0.0,
        '910Hz': 4.0,
        '3.6kHz': 4.0,
        '14kHz': 0.0,
      },
      presetName: 'Podcast',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Creates a bass boost preset
  factory AudioEffect.bassBoostPreset() {
    return AudioEffect(
      id: 'bass_boost',
      name: 'Bass Boost',
      isEnabled: true,
      bassBoost: 0.6,
      trebleBoost: 0,
      eqBands: {
        '60Hz': 8.0,
        '230Hz': 4.0,
        '910Hz': 0.0,
        '3.6kHz': 0.0,
        '14kHz': 0.0,
      },
      presetName: 'Bass Boost',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Creates a treble boost preset
  factory AudioEffect.trebleBoostPreset() {
    return AudioEffect(
      id: 'treble_boost',
      name: 'Treble Boost',
      isEnabled: true,
      bassBoost: 0,
      trebleBoost: 0.6,
      eqBands: {
        '60Hz': 0.0,
        '230Hz': 0.0,
        '910Hz': 0.0,
        '3.6kHz': 4.0,
        '14kHz': 8.0,
      },
      presetName: 'Treble Boost',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Unique identifier for the audio effect preset
  final String id;

  /// Name of the preset (e.g., "Music", "Podcast", "Custom")
  final String name;

  /// Whether this effect preset is currently enabled
  final bool isEnabled;

  /// Bass boost level (0.0 to 1.0)
  final double bassBoost;

  /// Treble boost level (0.0 to 1.0)
  final double trebleBoost;

  /// Equalizer band gains (frequency -> gain mapping)
  /// Keys are frequency labels (e.g., "60Hz", "230Hz", "910Hz", "3.6kHz", "14kHz")
  /// Values are gain levels (-12.0 to 12.0 dB)
  final Map<String, double> eqBands;

  /// Name of the preset if this is a built-in preset
  final String? presetName;

  /// When this effect preset was created
  final DateTime createdAt;

  /// When this effect preset was last updated
  final DateTime updatedAt;

  /// Creates a copy of this AudioEffect with the given fields replaced
  AudioEffect copyWith({
    String? id,
    String? name,
    bool? isEnabled,
    double? bassBoost,
    double? trebleBoost,
    Map<String, double>? eqBands,
    String? presetName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AudioEffect(
      id: id ?? this.id,
      name: name ?? this.name,
      isEnabled: isEnabled ?? this.isEnabled,
      bassBoost: bassBoost ?? this.bassBoost,
      trebleBoost: trebleBoost ?? this.trebleBoost,
      eqBands: eqBands ?? this.eqBands,
      presetName: presetName ?? this.presetName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Converts AudioEffect to a Map for serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isEnabled': isEnabled,
      'bassBoost': bassBoost,
      'trebleBoost': trebleBoost,
      'eqBands': eqBands,
      'presetName': presetName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Converts AudioEffect to JSON string
  String toJson() => json.encode(toMap());

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AudioEffect &&
        other.id == id &&
        other.name == name &&
        other.isEnabled == isEnabled &&
        other.bassBoost == bassBoost &&
        other.trebleBoost == trebleBoost &&
        other.eqBands == eqBands &&
        other.presetName == presetName;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        isEnabled.hashCode ^
        bassBoost.hashCode ^
        trebleBoost.hashCode ^
        eqBands.hashCode ^
        presetName.hashCode;
  }

  @override
  String toString() {
    return 'AudioEffect(id: $id, name: $name, isEnabled: $isEnabled, '
        'bassBoost: $bassBoost, trebleBoost: $trebleBoost, '
        'eqBands: $eqBands, presetName: $presetName)';
  }

  /// List of all built-in presets
  static List<AudioEffect> get builtInPresets => [
    AudioEffect.defaultEffect(),
    AudioEffect.musicPreset(),
    AudioEffect.podcastPreset(),
    AudioEffect.bassBoostPreset(),
    AudioEffect.trebleBoostPreset(),
  ];
}
