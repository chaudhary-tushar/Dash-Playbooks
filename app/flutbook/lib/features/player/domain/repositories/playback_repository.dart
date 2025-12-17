// lib/domain/repositories/playback_repository.dart
import 'package:flutbook/features/player/domain/entities/playback_history.dart';
import 'package:flutbook/features/player/domain/entities/playback_session.dart';

abstract class PlaybackRepository {
  /// Gets the current playback session for an audiobook
  Future<PlaybackSession?> getPlaybackSession(String audiobookId);

  /// Updates the current playback position
  Future<void> updatePlaybackPosition(String audiobookId, Duration position);

  /// Saves playback session state
  Future<void> savePlaybackSession(PlaybackSession session);

  /// Gets all playback sessions
  Future<List<PlaybackSession>> getAllPlaybackSessions();

  /// Marks an audiobook as completed
  Future<void> markAudiobookAsCompleted(String audiobookId);

  /// Updates playback speed preference
  Future<void> updatePlaybackSpeed(String audiobookId, double speed);

  /// Saves playback history entry
  Future<void> savePlaybackHistory(PlaybackHistory history);

  /// Gets playback history for a specific audiobook
  Future<List<PlaybackHistory>> getPlaybackHistory(String audiobookId);

  /// Gets all playback history entries
  Future<List<PlaybackHistory>> getAllPlaybackHistory();

  /// Clears all playback history
  Future<void> clearPlaybackHistory();

  /// Gets the last played position for an audiobook
  Future<Duration?> getLastPlayedPosition(String audiobookId);

  /// Gets total playback time for an audiobook
  Future<Duration> getTotalPlaybackTime(String audiobookId);
}
