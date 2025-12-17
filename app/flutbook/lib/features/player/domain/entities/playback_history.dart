// lib/features/player/domain/entities/playback_history.dart
import 'dart:convert';

class PlaybackHistory {
  PlaybackHistory({
    required this.audiobookId,
    required this.position,
    required this.duration,
    required this.playedAt,
  });

  factory PlaybackHistory.fromMap(Map<String, dynamic> map) {
    return PlaybackHistory(
      audiobookId: map['audiobookId'] as String? ?? '',
      position: Duration(
        milliseconds: (map['position'] as num?)?.toInt() ?? 0,
      ),
      duration: Duration(
        milliseconds: (map['duration'] as num?)?.toInt() ?? 0,
      ),
      playedAt: DateTime.fromMillisecondsSinceEpoch(
        (map['playedAt'] as num?)?.toInt() ??
            DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  factory PlaybackHistory.fromJson(String source) =>
      PlaybackHistory.fromMap(json.decode(source) as Map<String, dynamic>);

  final String audiobookId;
  final Duration position;
  final Duration duration;
  final DateTime playedAt;

  PlaybackHistory copyWith({
    String? audiobookId,
    Duration? position,
    Duration? duration,
    DateTime? playedAt,
  }) {
    return PlaybackHistory(
      audiobookId: audiobookId ?? this.audiobookId,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      playedAt: playedAt ?? this.playedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'audiobookId': audiobookId,
      'position': position.inMilliseconds,
      'duration': duration.inMilliseconds,
      'playedAt': playedAt.millisecondsSinceEpoch,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'PlaybackHistory(audiobookId: $audiobookId, position: $position, duration: $duration, playedAt: $playedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlaybackHistory &&
        other.audiobookId == audiobookId &&
        other.playedAt == playedAt;
  }

  @override
  int get hashCode => audiobookId.hashCode ^ playedAt.hashCode;
}
