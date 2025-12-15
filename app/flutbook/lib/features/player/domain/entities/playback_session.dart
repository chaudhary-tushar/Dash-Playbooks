// lib/domain/entities/playback_session.dart
import 'dart:convert';

class PlaybackSession {
  PlaybackSession({
    required this.audiobookId,
    required this.currentPosition,
    required this.playbackSpeed,
    required this.isPlaying,
    required this.lastPlayedAt,
    required this.sleepTimerActive,
    this.sleepTimerDuration,
  });

  factory PlaybackSession.fromMap(Map<String, dynamic> map) {
    return PlaybackSession(
      audiobookId: map['audiobookId'] as String? ?? '',
      currentPosition: Duration(
        milliseconds: (map['currentPosition'] as num?)?.toInt() ?? 0,
      ),
      playbackSpeed: (map['playbackSpeed'] as num?)?.toDouble() ?? 1.0,
      isPlaying: map['isPlaying'] as bool? ?? false,
      lastPlayedAt: DateTime.fromMillisecondsSinceEpoch(
        (map['lastPlayedAt'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
      ),
      sleepTimerActive: map['sleepTimerActive'] as bool? ?? false,
      sleepTimerDuration: map['sleepTimerDuration'] != null
          ? Duration(milliseconds: map['sleepTimerDuration'] as int)
          : null,
    );
  }

  factory PlaybackSession.fromJson(String source) =>
      PlaybackSession.fromMap(json.decode(source) as Map<String, dynamic>);
  final String audiobookId;
  final Duration currentPosition;
  final double playbackSpeed;
  final bool isPlaying;
  final DateTime lastPlayedAt;
  final bool sleepTimerActive;
  final Duration? sleepTimerDuration;

  PlaybackSession copyWith({
    String? audiobookId,
    Duration? currentPosition,
    double? playbackSpeed,
    bool? isPlaying,
    DateTime? lastPlayedAt,
    bool? sleepTimerActive,
    Duration? sleepTimerDuration,
  }) {
    return PlaybackSession(
      audiobookId: audiobookId ?? this.audiobookId,
      currentPosition: currentPosition ?? this.currentPosition,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      isPlaying: isPlaying ?? this.isPlaying,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      sleepTimerActive: sleepTimerActive ?? this.sleepTimerActive,
      sleepTimerDuration: sleepTimerDuration ?? this.sleepTimerDuration,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'audiobookId': audiobookId,
      'currentPosition': currentPosition.inMilliseconds,
      'playbackSpeed': playbackSpeed,
      'isPlaying': isPlaying,
      'lastPlayedAt': lastPlayedAt.millisecondsSinceEpoch,
      'sleepTimerActive': sleepTimerActive,
      'sleepTimerDuration': sleepTimerDuration?.inMilliseconds,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'PlaybackSession(audiobookId: $audiobookId, currentPosition: $currentPosition, isPlaying: $isPlaying)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlaybackSession && other.audiobookId == audiobookId;
  }

  @override
  int get hashCode => audiobookId.hashCode;
}
