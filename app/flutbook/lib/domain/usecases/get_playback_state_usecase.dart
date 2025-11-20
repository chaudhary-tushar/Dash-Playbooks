// lib/domain/usecases/get_playback_state_usecase.dart

abstract class GetPlaybackStateUseCase {
  /// Gets the current playback state for an audiobook
  Future<PlaybackState> execute(String audiobookId);

  /// Updates playback position
  Future<void> updatePosition(String audiobookId, Duration newPosition);

  /// Updates playback speed
  Future<void> updateSpeed(String audiobookId, double speed);

  /// Starts sleep timer
  Future<void> startSleepTimer(String audiobookId, Duration duration);

  /// Cancels sleep timer
  Future<void> cancelSleepTimer(String audiobookId);
}

class PlaybackState {
  const PlaybackState({
    required this.audiobookId,
    required this.currentPosition,
    required this.totalDuration,
    required this.isPlaying,
    required this.playbackSpeed,
    required this.hasSleepTimer,
    required this.chapterMarkers,
    this.remainingSleepTime,
  });
  final String audiobookId;
  final Duration currentPosition;
  final Duration totalDuration;
  final bool isPlaying;
  final double playbackSpeed;
  final bool hasSleepTimer;
  final Duration? remainingSleepTime;
  final List<ChapterMarker> chapterMarkers;
}

class ChapterMarker {
  const ChapterMarker({
    required this.title,
    required this.position,
  });
  final String title;
  final Duration position;
}
