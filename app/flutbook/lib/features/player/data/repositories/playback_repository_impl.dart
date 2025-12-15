// lib/data/repositories/playback_repository_impl.dart
import 'package:flutbook/core/error/exceptions.dart';
import 'package:flutbook/features/player/data/datasources/playback_local_ds.dart';
import 'package:flutbook/features/player/data/datasources/remote/firebase_playback_sync.dart';
import 'package:flutbook/features/player/domain/entities/playback_session.dart';
import 'package:flutbook/features/player/domain/repositories/playback_repository.dart';

class PlaybackRepositoryImpl implements PlaybackRepository {
  // Nullable for anonymous users

  PlaybackRepositoryImpl({
    required PlaybackLocalDatasource localDatasource,
    PlaybackRemoteDatasource? remoteDatasource,
  }) : _localDatasource = localDatasource,
       _remoteDatasource = remoteDatasource;
  final PlaybackLocalDatasource _localDatasource;
  final PlaybackRemoteDatasource? _remoteDatasource;

  @override
  Future<PlaybackSession?> getPlaybackSession(String audiobookId) async {
    try {
      return await _localDatasource.getPlaybackSession(audiobookId);
    } catch (e) {
      throw StorageException(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<void> updatePlaybackPosition(
    String audiobookId,
    Duration position,
  ) async {
    try {
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
      await _localDatasource.savePlaybackSession(session);
    } catch (e) {
      throw StorageException(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<List<PlaybackSession>> getAllPlaybackSessions() async {
    try {
      // In the current implementation, we'll get all sessions from the local datasource
      // This would require extending the local datasource interface to support this
      // For now, we'll return an empty list until we implement this functionality
      return [];
    } catch (e) {
      throw StorageException(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<void> markAudiobookAsCompleted(String audiobookId) async {
    try {
      final session = await getPlaybackSession(audiobookId);

      if (session != null) {
        final updatedSession = session.copyWith(
          currentPosition: Duration(
            milliseconds: session.currentPosition.inMilliseconds, // Keep current position
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
}
