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
    required PlaybackLocalDatasource? localDatasource,
    SupabasePlaybackDatasource? remoteDatasource,
  }) : _localDatasource = localDatasource,
       _remoteDatasource = remoteDatasource {
    _validateInitialization();
  }
  final PlaybackLocalDatasource? _localDatasource;
  final SupabasePlaybackDatasource? _remoteDatasource;

  /// Validates that the repository is properly initialized with required datasources
  void _validateInitialization() {
    if (_localDatasource == null) {
      throw UninitializedDatasourceException(
        'PlaybackRepository: Local datasource is null',
      );
    }

    if (!_localDatasource.isInitialized) {
      throw UninitializedDatasourceException(
        'PlaybackRepository: Local datasource not initialized',
      );
    }
  }

  /// Checks if the repository is initialized and ready for use
  bool get isInitialized => _localDatasource?.isInitialized ?? false;

  /// Checks if the repository is in error state
  bool get isInErrorState => !isInitialized || _localDatasource == null;

  /// Provides graceful degradation when datasource is not available
  /// Returns null or empty results instead of throwing exceptions
  bool get _shouldDegradeGracefully => _localDatasource == null || !_localDatasource.isInitialized;

  /// Checks if all dependencies are properly initialized
  bool get _areDependenciesInitialized {
    return _localDatasource != null && _localDatasource.isInitialized;
  }

  /// Public method to validate that all dependencies are properly initialized
  /// Throws UninitializedDatasourceException if any dependency is not ready
  void validateDependencies() {
    if (_localDatasource == null) {
      throw UninitializedDatasourceException(
        'PlaybackRepository: Local datasource is null',
      );
    }

    if (!_localDatasource.isInitialized) {
      throw UninitializedDatasourceException(
        'PlaybackRepository: Local datasource not initialized',
      );
    }
  }

  /// Checks if remote datasource is available (for authenticated users)
  bool get _isRemoteAvailable => _remoteDatasource != null;

  /// Validates remote datasource availability before sync operations
  void _validateRemoteDatasource() {
    if (!_isRemoteAvailable) {
      throw UninitializedDatasourceException(
        'PlaybackRepository: Remote datasource not available for sync operations',
      );
    }
  }

  /// Checks if repository is ready for write operations
  /// Validates both local and remote datasources if remote sync is expected
  bool get isReadyForWriteOperations {
    return _areDependenciesInitialized;
  }

  /// Provides detailed initialization status for debugging and monitoring
  /// Returns a map with initialization status of all dependencies
  Map<String, dynamic> getInitializationStatus() {
    return {
      'isInitialized': isInitialized,
      'localDatasourceNull': _localDatasource == null,
      'localDatasourceInitialized': _localDatasource?.isInitialized ?? false,
      'remoteDatasourceAvailable': _isRemoteAvailable,
      'dependenciesInitialized': _areDependenciesInitialized,
      'playbackFeaturesAvailable': _arePlaybackFeaturesAvailable,
      'readyForWriteOperations': isReadyForWriteOperations,
    };
  }

  /// Checks if playback features are available
  /// Returns false if datasources are not initialized or playback is not possible
  bool get _arePlaybackFeaturesAvailable {
    return _areDependenciesInitialized;
  }

  /// Graceful degradation for playback operations
  /// Returns appropriate fallback values when playback features are unavailable
  Future<T> _handlePlaybackUnavailable<T>(
    Future<T> Function() operation,
    T fallbackValue,
  ) async {
    try {
      if (!_arePlaybackFeaturesAvailable) {
        print(
          'Warning: Playback features unavailable, returning fallback value',
        );
        return fallbackValue;
      }
      return await operation();
    } catch (e) {
      print('Error in playback operation: $e');
      return fallbackValue;
    }
  }

  /// Public method to check if playback features are available
  /// Useful for UI components to determine if playback functionality should be enabled
  bool isPlaybackAvailable() {
    return _arePlaybackFeaturesAvailable;
  }

  /// Gets detailed playback feature availability status with reasons
  /// Returns a map with availability status and specific reasons if unavailable
  Map<String, dynamic> getPlaybackFeatureStatus() {
    final status = getInitializationStatus();

    if (status['playbackFeaturesAvailable'] as bool) {
      return {
        'available': true,
        'message': 'Playback features are fully available',
      };
    } else {
      // Determine specific reason for unavailability
      if (status['localDatasourceNull'] as bool) {
        return {
          'available': false,
          'message': 'Playback database not initialized',
          'reason': 'local_datasource_null',
          'suggestion': 'Please close and reopen the app to initialize the database',
        };
      } else if (!(status['localDatasourceInitialized'] as bool)) {
        return {
          'available': false,
          'message': 'Database not ready',
          'reason': 'database_not_ready',
          'suggestion': 'Please wait 10-15 seconds and try again',
        };
      } else {
        return {
          'available': false,
          'message': 'Playback features temporarily unavailable',
          'reason': 'unknown',
          'suggestion': 'Please close and reopen the app, then try again',
        };
      }
    }
  }

  /// Method to handle playback feature unavailability with user notification
  /// Shows appropriate UI feedback when playback features are not available
  Future<T> handlePlaybackFeatureUnavailable<T>(
    Future<T> Function() operation,
    T fallbackValue, {
    bool showWarning = true,
  }) async {
    if (!_arePlaybackFeaturesAvailable) {
      if (showWarning) {
        print('Warning: Playback features are currently unavailable');
      }
      return fallbackValue;
    }

    try {
      return await operation();
    } catch (e) {
      if (showWarning) {
        print('Error in playback feature: $e');
      }
      return fallbackValue;
    }
  }

  /// Validates all dependencies are initialized before performing operations
  void _validateDependencies() {
    if (!isInitialized) {
      throw UninitializedDatasourceException(
        'PlaybackRepository: Cannot perform operations - repository not initialized',
      );
    }

    if (_localDatasource == null || !_localDatasource.isInitialized) {
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

      return await _localDatasource!.getPlaybackSession(audiobookId);
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
      if (_isRemoteAvailable) {
        try {
          await _remoteDatasource!.uploadPlaybackSession(updatedSession);
        } catch (e) {
          print('Warning: Could not sync playback position to remote: $e');
          // Continue anyway, local storage is primary
          throw StorageException(
            'Failed to sync playback position to remote: ${ErrorHandler.handleException(e)}',
          );
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

      await _localDatasource!.savePlaybackSession(session);

      // Also sync to remote if available
      if (_isRemoteAvailable) {
        try {
          await _remoteDatasource!.uploadPlaybackSession(session);
        } catch (e) {
          print('Warning: Could not sync playback session to remote: $e');
          // Continue anyway - local storage is primary
        }
      }
    } catch (e) {
      print('Error saving playback session: $e');
      // Graceful degradation - don't throw, just log
    }
  }

  /// Marks an audiobook as being read (in-progress) by updating its lastPlayedAt
  /// This is called when playback starts to make the book appear in the "Reading" list
  Future<void> markAudiobookAsInProgress(String audiobookId) async {
    try {
      if (_shouldDegradeGracefully) {
        print('Warning: Playback datasource not initialized');
        return;
      }

      // Get the current playback session
      final session = await _localDatasource!.getPlaybackSession(audiobookId);

      if (session != null) {
        // Update the session's lastPlayedAt to now
        final updatedSession = session.copyWith(lastPlayedAt: DateTime.now());
        await _localDatasource!.savePlaybackSession(updatedSession);
        print('[PlaybackRepository] Marked audiobook $audiobookId as in-progress');
      }
    } catch (e) {
      print('[PlaybackRepository] Error marking audiobook as in-progress: $e');
      // Don't throw - this is a side effect
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
      return await _localDatasource!.getAllPlaybackSessions();
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
      if (_isRemoteAvailable) {
        try {
          await _remoteDatasource!.uploadPlaybackSession(updatedSession);
        } catch (e) {
          print('Warning: Could not sync playback speed to remote: $e');
          // Continue anyway, local storage is primary
          throw StorageException(
            'Failed to sync playback speed to remote: ${ErrorHandler.handleException(e)}',
          );
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
      await _localDatasource!.savePlaybackHistory(history);
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
      return await _localDatasource!.getPlaybackHistory(audiobookId);
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
      return await _localDatasource!.getAllPlaybackHistory();
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
      await _localDatasource!.clearPlaybackHistory();
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
      return await _localDatasource!.getLastPlayedPosition(audiobookId);
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
      return await _localDatasource!.getTotalPlaybackTime(audiobookId);
    } catch (e) {
      print('Error getting total playback time: $e');
      return Duration.zero;
    }
  }
}
