// lib/features/player/domain/usecases/play_audiobook_usecase.dart

import 'package:flutbook/features/library/domain/entities/audiobook.dart';
import 'package:flutbook/features/player/domain/entities/playback_session.dart';
import 'package:flutbook/features/player/domain/repositories/playback_repository.dart';

/// Use case for managing audiobook playback sessions.
///
/// This use case handles the core playback session management including:
/// - Creating and managing playback sessions
/// - Updating playback positions
/// - Managing playback speed preferences
/// - Tracking playback history
/// - Handling playback session persistence
abstract class PlayAudiobookUseCase {
  /// Creates or updates a playback session for the specified audiobook
  ///
  /// Returns: true if session was created/updated successfully, false otherwise
  Future<bool> createPlaybackSession(Audiobook audiobook);

  /// Updates the current playback position for the active audiobook
  ///
  /// Returns: true if position was updated successfully, false otherwise
  Future<bool> updatePlaybackPosition(String audiobookId, Duration position);

  /// Updates the playback speed for the active audiobook
  ///
  /// Returns: true if speed was updated successfully, false otherwise
  Future<bool> updatePlaybackSpeed(String audiobookId, double speed);

  /// Gets the current playback session for the specified audiobook
  ///
  /// Returns: PlaybackSession if found, null otherwise
  Future<PlaybackSession?> getPlaybackSession(String audiobookId);

  /// Gets all playback sessions (history)
  ///
  /// Returns: List of all playback sessions
  Future<List<PlaybackSession>> getAllPlaybackSessions();

  /// Marks an audiobook as completed
  ///
  /// Returns: true if audiobook was marked as completed successfully, false otherwise
  Future<bool> markAudiobookAsCompleted(String audiobookId);

  /// Gets the last played position for the specified audiobook
  ///
  /// Returns: Last played position if available, null otherwise
  Future<Duration?> getLastPlayedPosition(String audiobookId);

  /// Gets total playback time for the specified audiobook
  ///
  /// Returns: Total playback time for the audiobook
  Future<Duration> getTotalPlaybackTime(String audiobookId);
}

/// Implementation of PlayAudiobookUseCase
class PlayAudiobookUseCaseImpl implements PlayAudiobookUseCase {
  /// Creates a new PlayAudiobookUseCaseImpl
  ///
  /// The [playbackRepository] parameter is required for accessing playback session data
  PlayAudiobookUseCaseImpl(this._playbackRepository);
  final PlaybackRepository _playbackRepository;

  @override
  Future<bool> createPlaybackSession(Audiobook audiobook) async {
    try {
      // Create a new playback session for the audiobook
      final session = PlaybackSession(
        audiobookId: audiobook.id,
        currentPosition: Duration.zero,
        playbackSpeed: 1,
        isPlaying: false,
        lastPlayedAt: DateTime.now(),
        sleepTimerActive: false,
      );

      await _playbackRepository.savePlaybackSession(session);
      return true;
    } catch (e) {
      // Handle any errors during session creation
      return false;
    }
  }

  @override
  Future<bool> updatePlaybackPosition(
    String audiobookId,
    Duration position,
  ) async {
    try {
      // Update the playback position
      await _playbackRepository.updatePlaybackPosition(audiobookId, position);
      return true;
    } catch (e) {
      // Handle any errors during position update
      return false;
    }
  }

  @override
  Future<bool> updatePlaybackSpeed(String audiobookId, double speed) async {
    try {
      // Update the playback speed
      await _playbackRepository.updatePlaybackSpeed(audiobookId, speed);
      return true;
    } catch (e) {
      // Handle any errors during speed update
      return false;
    }
  }

  @override
  Future<PlaybackSession?> getPlaybackSession(String audiobookId) async {
    try {
      // Get the playback session for the audiobook
      return await _playbackRepository.getPlaybackSession(audiobookId);
    } catch (e) {
      // Handle any errors during session retrieval
      return null;
    }
  }

  @override
  Future<List<PlaybackSession>> getAllPlaybackSessions() async {
    try {
      // Get all playback sessions
      return await _playbackRepository.getAllPlaybackSessions();
    } catch (e) {
      // Handle any errors during session retrieval
      return [];
    }
  }

  @override
  Future<bool> markAudiobookAsCompleted(String audiobookId) async {
    try {
      // Mark the audiobook as completed
      await _playbackRepository.markAudiobookAsCompleted(audiobookId);
      return true;
    } catch (e) {
      // Handle any errors during completion marking
      return false;
    }
  }

  @override
  Future<Duration?> getLastPlayedPosition(String audiobookId) async {
    try {
      // Get the last played position
      return await _playbackRepository.getLastPlayedPosition(audiobookId);
    } catch (e) {
      // Handle any errors during position retrieval
      return null;
    }
  }

  @override
  Future<Duration> getTotalPlaybackTime(String audiobookId) async {
    try {
      // Get the total playback time
      return await _playbackRepository.getTotalPlaybackTime(audiobookId);
    } catch (e) {
      // Handle any errors during time retrieval
      return Duration.zero;
    }
  }
}
