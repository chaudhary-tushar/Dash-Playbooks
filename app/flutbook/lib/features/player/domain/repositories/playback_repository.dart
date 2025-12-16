// lib/domain/repositories/playback_repository.dart
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
}
