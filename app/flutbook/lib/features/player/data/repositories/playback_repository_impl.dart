// lib/data/repositories/playback_repository_impl.dart
import 'package:flutbook/core/error/exceptions.dart';
import 'package:flutbook/features/player/data/datasources/playback_local_ds.dart';
import 'package:flutbook/features/player/data/datasources/remote/supabase_playback_sync.dart';
import 'package:flutbook/features/player/domain/entities/playback_history.dart';
import 'package:flutbook/features/player/domain/entities/playback_session.dart';
import 'package:flutbook/features/player/domain/repositories/playback_repository.dart';

class PlaybackRepositoryImpl implements PlaybackRepository {
  // Nullable for anonymous users

  PlaybackRepositoryImpl({
    required PlaybackLocalDatasource localDatasource,
    SupabasePlaybackDatasource? remoteDatasource,
  }) : _localDatasource = localDatasource,
       _remoteDatasource = remoteDatasource {
    _validateInitialization();
  }
  final PlaybackLocalDatasource _localDatasource;
  final SupabasePlaybackDatasource? _remoteDatasource;

  /// Validates that the repository is properly initialized with required datasources
  void _validateInitialization() {
    if (!_localDatasource.isInitialized) {
      throw UninitializedDatasourceException(
        'PlaybackRepository: Local datasource not initialized',
      );
    }
  }

  /// Checks if the repository is initialized and ready for use
  bool get isInitialized => _localDatasource.isInitialized;

  /// Provides graceful degradation when datasource is not available
  /// Returns null or empty results instead of throwing exceptions
  bool get _shouldDegradeGracefully => !_localDatasource.isInitialized;

  /// Validates all dependencies are initialized before performing operations
  void _validateDependencies() {
    if (!isInitialized) {
      throw UninitializedDatasourceException(
        'PlaybackRepository: Cannot perform operations - repository not initialized',
      );
    }

    if (!_localDatasource.isInitialized) {
      throw UninitializedDatasourceException(
        'PlaybackRepository: Local datasource not initialized',
      );
    }
  }

  /// Graceful fallback for when datasource is not initialized
  /// Returns null instead of throwing exception
  Future<PlaybackSession?> _getPlaybackSessionWithFallback(
    String audiobookId,
  ) async {
    try {
      if (_shouldDegradeGracefully) {
        print(
          'Warning: Playback datasource not initialized, returning null session',
        );
        return null;
      }
      return await _localDatasource.getPlaybackSession(audiobookId);
    } catch (e) {
      print('Error getting playback session: $e');
      return null;
    }
  }

  @override
  Future<PlaybackSession?> getPlaybackSession(String audiobookId) async {
    return _getPlaybackSessionWithFallback(audiobookId);
  }

  @override
  Future<void> updatePlaybackPosition(
    String audiobookId,
    Duration position,
  ) async {
    try {
      _validateDependencies();

      final existingSession = await getPlaybackSession(audiobookId);
      final playbackSpeed = existingSession?.playbackSpeed ?? 1.0;
      final sleepTimerActive = existingSession?.sleepTimerActive ?? false;
      final sleepTimerDuration = existingSession?.sleepTimerDuration;

      final updatedSession = PlaybackSession(
        audiobookId: audiobookId,
        currentPosition: position,
        playbackSpeed: playbackSpeed,
        isPlaying: existingSession?.isPlaying ?? false,
        lastPlayedAt: DateTime.now(),
        sleepTimerActive: sleepTimerActive,
        sleepTimerDuration: sleepTimerDuration,
      );

      await savePlaybackSession(updatedSession);

      // If authenticated, sync the update
      if (_remoteDatasource != null) {
        try {
          await _remoteDatasource.uploadPlaybackSession(updatedSession);
        } catch (e) {
          print('Warning: Could not sync playback position to remote: $e');
          // Continue anyway, local storage is primary
        }
      }
    } catch (e) {
      throw StorageException(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<void> savePlaybackSession(PlaybackSession session) async {
    try {
      if (_shouldDegradeGracefully) {
        print(
          'Warning: Playback datasource not initialized, cannot save session',
        );
        return; // Graceful degradation - don't throw, just log
      }
      await _localDatasource.savePlaybackSession(session);
    } catch (e) {
      print('Error saving playback session: $e');
      // Graceful degradation - don't throw, just log
    }
  }

  @override
  Future<List<PlaybackSession>> getAllPlaybackSessions() async {
    try {
      if (_shouldDegradeGracefully) {
        print(
          'Warning: Playback datasource not initialized, returning empty list',
        );
        return [];
      }
      return await _localDatasource.getAllPlaybackSessions();
    } catch (e) {
      print('Error getting all playback sessions: $e');
      return [];
    }
  }

  @override
  Future<void> markAudiobookAsCompleted(String audiobookId) async {
    try {
      _validateDependencies();

      final session = await getPlaybackSession(audiobookId);

      if (session != null) {
        final updatedSession = session.copyWith(
          currentPosition: Duration(
            milliseconds:
                session.currentPosition.inMilliseconds, // Keep current position
          ),
        );

        await savePlaybackSession(updatedSession);
      } else {
        // Create new session if one doesn't exist
        final newSession = PlaybackSession(
          audiobookId: audiobookId,
          currentPosition: Duration.zero,
          playbackSpeed: 1,
          isPlaying: false,
          lastPlayedAt: DateTime.now(),
          sleepTimerActive: false,
        );

        await savePlaybackSession(newSession);
      }
    } catch (e) {
      throw StorageException(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<void> updatePlaybackSpeed(String audiobookId, double speed) async {
    try {
      _validateDependencies();

      final existingSession = await getPlaybackSession(audiobookId);

      final updatedSession = PlaybackSession(
        audiobookId: audiobookId,
        currentPosition: existingSession?.currentPosition ?? Duration.zero,
        playbackSpeed: speed,
        isPlaying: existingSession?.isPlaying ?? false,
        lastPlayedAt: DateTime.now(),
        sleepTimerActive: existingSession?.sleepTimerActive ?? false,
        sleepTimerDuration: existingSession?.sleepTimerDuration,
      );

      await savePlaybackSession(updatedSession);

      // If authenticated, sync the update
      if (_remoteDatasource != null) {
        try {
          await _remoteDatasource.uploadPlaybackSession(updatedSession);
        } catch (e) {
          print('Warning: Could not sync playback speed to remote: $e');
          // Continue anyway, local storage is primary
        }
      }
    } catch (e) {
      throw StorageException(ErrorHandler.handleException(e));
    }
  }

  /// Updates sleep timer settings for an audiobook
  Future<void> updateSleepTimer(
    String audiobookId, {
    bool? active,
    Duration? duration,
  }) async {
    try {
      _validateDependencies();

      final existingSession = await getPlaybackSession(audiobookId);

      final updatedSession = PlaybackSession(
        audiobookId: audiobookId,
        currentPosition: existingSession?.currentPosition ?? Duration.zero,
        playbackSpeed: existingSession?.playbackSpeed ?? 1.0,
        isPlaying: existingSession?.isPlaying ?? false,
        lastPlayedAt: DateTime.now(),
        sleepTimerActive: active ?? existingSession?.sleepTimerActive ?? false,
        sleepTimerDuration: duration ?? existingSession?.sleepTimerDuration,
      );

      await savePlaybackSession(updatedSession);
    } catch (e) {
      throw StorageException(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<void> savePlaybackHistory(PlaybackHistory history) async {
    try {
      if (_shouldDegradeGracefully) {
        print(
          'Warning: Playback datasource not initialized, cannot save history',
        );
        return; // Graceful degradation - don't throw, just log
      }
      await _localDatasource.savePlaybackHistory(history);
    } catch (e) {
      print('Error saving playback history: $e');
      // Graceful degradation - don't throw, just log
    }
  }

  @override
  Future<List<PlaybackHistory>> getPlaybackHistory(String audiobookId) async {
    try {
      if (_shouldDegradeGracefully) {
        print(
          'Warning: Playback datasource not initialized, returning empty history',
        );
        return [];
      }
      return await _localDatasource.getPlaybackHistory(audiobookId);
    } catch (e) {
      print('Error getting playback history: $e');
      return [];
    }
  }

  @override
  Future<List<PlaybackHistory>> getAllPlaybackHistory() async {
    try {
      if (_shouldDegradeGracefully) {
        print(
          'Warning: Playback datasource not initialized, returning empty history',
        );
        return [];
      }
      return await _localDatasource.getAllPlaybackHistory();
    } catch (e) {
      print('Error getting all playback history: $e');
      return [];
    }
  }

  @override
  Future<void> clearPlaybackHistory() async {
    try {
      if (_shouldDegradeGracefully) {
        print(
          'Warning: Playback datasource not initialized, cannot clear history',
        );
        return; // Graceful degradation - don't throw, just log
      }
      await _localDatasource.clearPlaybackHistory();
    } catch (e) {
      print('Error clearing playback history: $e');
      // Graceful degradation - don't throw, just log
    }
  }

  @override
  Future<Duration?> getLastPlayedPosition(String audiobookId) async {
    try {
      if (_shouldDegradeGracefully) {
        print(
          'Warning: Playback datasource not initialized, returning null position',
        );
        return null;
      }
      return await _localDatasource.getLastPlayedPosition(audiobookId);
    } catch (e) {
      print('Error getting last played position: $e');
      return null;
    }
  }

  @override
  Future<Duration> getTotalPlaybackTime(String audiobookId) async {
    try {
      if (_shouldDegradeGracefully) {
        print(
          'Warning: Playback datasource not initialized, returning zero duration',
        );
        return Duration.zero;
      }
      return await _localDatasource.getTotalPlaybackTime(audiobookId);
    } catch (e) {
      print('Error getting total playback time: $e');
      return Duration.zero;
    }
  }
}
