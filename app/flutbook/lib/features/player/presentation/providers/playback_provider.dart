// lib/presentation/providers/playback_provider.dart
import 'dart:async';

import 'package:flutbook/core/error/exceptions.dart';
import 'package:flutbook/core/provider/providers.dart'
    show libraryRepositoryProvider, playbackRepositoryProvider, playbackLocalDatasourceProvider;
import 'package:flutbook/features/library/domain/entities/audiobook.dart';
import 'package:flutbook/features/library/domain/repositories/library_repository.dart';
import 'package:flutbook/features/player/data/datasources/audio_service_handler.dart';
import 'package:flutbook/features/player/data/datasources/playback_local_ds.dart';
import 'package:flutbook/features/player/data/repositories/playback_repository_impl.dart';
import 'package:flutbook/features/player/domain/entities/playback_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State class representing the current playback state of an audiobook.
///
/// This class contains all the necessary information about the playback state
/// including whether audio is playing, current position, duration, playback speed,
/// sleep timer status, loading state, and any error messages.
class PlaybackState {
  const PlaybackState({
    required this.isPlaying,
    required this.currentPosition,
    required this.duration,
    required this.playbackSpeed,
    required this.sleepTimerActive,
    required this.isLoading,
    this.sleepTimerDuration,
    this.errorMessage,
    this.bufferedPosition,
  });

  /// Creates an initial playback state with default values.
  factory PlaybackState.initial() {
    return const PlaybackState(
      isPlaying: false,
      currentPosition: Duration.zero,
      duration: Duration.zero,
      playbackSpeed: 1,
      sleepTimerActive: false,
      isLoading: false,
    );
  }
  final bool isPlaying;
  final Duration currentPosition;
  final Duration duration;
  final double playbackSpeed;
  final bool sleepTimerActive;
  final Duration? sleepTimerDuration;
  final String? errorMessage;
  final bool isLoading;
  final Duration? bufferedPosition;

  PlaybackState copyWith({
    bool? isPlaying,
    Duration? currentPosition,
    Duration? duration,
    double? playbackSpeed,
    bool? sleepTimerActive,
    Duration? sleepTimerDuration,
    String? errorMessage,
    bool? isLoading,
    Duration? bufferedPosition,
  }) {
    return PlaybackState(
      isPlaying: isPlaying ?? this.isPlaying,
      currentPosition: currentPosition ?? this.currentPosition,
      duration: duration ?? this.duration,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      sleepTimerActive: sleepTimerActive ?? this.sleepTimerActive,
      sleepTimerDuration: sleepTimerDuration ?? this.sleepTimerDuration,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
      bufferedPosition: bufferedPosition ?? this.bufferedPosition,
    );
  }
}

/// Main playback provider that manages the state and logic for audiobook playback.
///
/// This provider handles all playback operations including play, pause, seek,
/// speed control, sleep timer management, and playback session persistence.
final playbackProvider = NotifierProvider<PlaybackNotifier, PlaybackState>(
  PlaybackNotifier.new,
);

/// Notifier class that manages the playback state and business logic.
///
/// This class is responsible for:
/// - Setting up and disposing of audio service resources
/// - Managing playback state changes
/// - Handling playback operations (play, pause, stop, seek)
/// - Managing playback speed and sleep timer
/// - Persisting playback sessions
/// - Error handling and state management
class PlaybackNotifier extends Notifier<PlaybackState> {
  late final AudioServiceHandler _audioService;
  late final PlaybackRepositoryImpl _playbackRepo;
  late final LibraryRepository _libraryRepo;
  late final StreamSubscription<dynamic> _playbackStreamSubscription;
  bool _audioServiceInitialized = false;

  // Retry mechanism state
  int _retryCount = 0;
  static const int _maxRetries = 3;

  // Periodic position saving timer
  Timer? _positionSaveTimer;
  static const Duration _positionSaveInterval = Duration(seconds: 10);

  @override
  PlaybackState build() {
    print('[PlaybackNotifier] build() called. _audioServiceInitialized: $_audioServiceInitialized');

    // If audio service already initialized, return current state
    if (_audioServiceInitialized) {
      print('[PlaybackNotifier] Already initialized, returning current state');
      return state;
    }

    // Determine a safe base state, handling uninitialized state
    PlaybackState baseState;
    try {
      baseState = state;
    } catch (_) {
      baseState = PlaybackState.initial();
    }

    try {
      // Initialize playback repository with proper error handling
      final playbackRepoAsync = ref.watch(playbackRepositoryProvider);

      // Handle different states of the async provider
      return playbackRepoAsync.when(
        loading: () {
          print('[PlaybackNotifier] Repository loading');
          return baseState.copyWith(
            isLoading: true,
          );
        },
        error: (error, stackTrace) {
          print('[PlaybackNotifier] Repository error: $error');
          return baseState.copyWith(
            isLoading: false,
            errorMessage: ErrorHandler.handlePlaybackException(error),
          );
        },
        data: (playbackRepo) {
          print('[PlaybackNotifier] Repository data received, initializing audio service');
          _playbackRepo = playbackRepo;

          // Initialize library repository for preferred speed storage
          final libraryRepoAsync = ref.watch(libraryRepositoryProvider);
          _libraryRepo = libraryRepoAsync.when(
            loading: () => throw UninitializedDatasourceException('Library repository loading'),
            error: (error, stackTrace) =>
                throw UninitializedDatasourceException('Library repository error: $error'),
            data: (repo) => repo,
          );

          // Get playback datasource synchronously with future access
          final playbackDatasourceAsync = ref.watch(playbackLocalDatasourceProvider);
          final playbackDatasource = playbackDatasourceAsync.when(
            loading: () => throw UninitializedDatasourceException('Playback datasource loading'),
            error: (error, stackTrace) =>
                throw UninitializedDatasourceException('Playback datasource error: $error'),
            data: (datasource) => datasource,
          );

          // Initialize audio service after repository is ready to avoid circular dependency
          _audioService = AudioServiceHandler(
            playbackDatasource: playbackDatasource,
          );

          // Listen to playback state changes from audio service
          _playbackStreamSubscription = _audioService.getPlaybackStateStream().listen(
            (playbackState) {
              print(
                '[PlaybackNotifier] Received playback state update: isPlaying=${playbackState.isPlaying}, position=${playbackState.currentPosition}',
              );
              state = state.copyWith(
                isPlaying: playbackState.isPlaying,
                currentPosition: playbackState.currentPosition,
                playbackSpeed: playbackState.playbackSpeed,
                sleepTimerActive: playbackState.sleepTimerActive,
                bufferedPosition: playbackState.bufferedPosition,
                isLoading: false,
              );
            },
            onError: (Object error) {
              print('[PlaybackNotifier] Stream error: $error');
              state = state.copyWith(
                errorMessage: ErrorHandler.handlePlaybackException(error),
                isLoading: false,
              );
            },
          );

          ref.onDispose(() {
            print('[PlaybackNotifier] Disposing resources');
            _positionSaveTimer?.cancel();
            _playbackStreamSubscription.cancel();
            _audioService.dispose();
          });

          _audioServiceInitialized = true;
          print('[PlaybackNotifier] Audio service initialized');
          return PlaybackState.initial();
        },
      );
    } catch (e) {
      // Handle initialization errors
      print('[PlaybackNotifier] Build exception: $e');
      return baseState.copyWith(
        isLoading: false,
        errorMessage: ErrorHandler.handlePlaybackException(e),
      );
    }
  }

  /// Sets the current audiobook to play and loads any saved playback position.
  ///
  /// This method:
  /// 1. Sets the audiobook in the audio service
  /// 2. Loads any saved playback session from the repository
  /// 3. Restores the playback position and settings if available
  /// 4. Updates the playback state accordingly
  /// 5. Handles repository errors gracefully with fallback behavior
  ///
  /// Returns: true if successful, false if failed with graceful degradation
  Future<bool> setCurrentAudiobook(Audiobook audiobook) async {
    print('[PlaybackNotifier] setCurrentAudiobook() called for book: ${audiobook.id}');
    state = state.copyWith(isLoading: true);
    try {
      // Attempt to load audio source
      print('[PlaybackNotifier] Calling _audioService.setCurrentAudiobook()');
      await _audioService.setCurrentAudiobook(audiobook);
      print('[PlaybackNotifier] Audio source set successfully');

      // Load saved playback position if available with error handling
      try {
        final savedSession = await _playbackRepo.getPlaybackSession(
          audiobook.id,
        );

        // Load preferred speed for this audiobook
        double preferredSpeed = 1;
        try {
          preferredSpeed = await _libraryRepo.getPreferredSpeed(audiobook.id);
          print(
            '[PlaybackNotifier] Loaded preferred speed: $preferredSpeed for audiobook: ${audiobook.id}',
          );
        } catch (e) {
          print('[PlaybackNotifier] Could not load preferred speed, using default: $e');
        }

        if (savedSession != null) {
          print(
            '[PlaybackNotifier] Found saved session, seeking to ${savedSession.currentPosition}',
          );
          await _audioService.seekTo(savedSession.currentPosition);
          // Use preferred speed if available, otherwise use saved session speed
          final speedToUse = preferredSpeed != 1.0 ? preferredSpeed : savedSession.playbackSpeed;
          await _audioService.setSpeed(speedToUse);
          state = state.copyWith(
            currentPosition: savedSession.currentPosition,
            duration: audiobook.duration,
            playbackSpeed: speedToUse,
            sleepTimerActive: savedSession.sleepTimerActive,
            sleepTimerDuration: savedSession.sleepTimerDuration,
          );

          // If sleep timer was active, restart it
          if (savedSession.sleepTimerActive && savedSession.sleepTimerDuration != null) {
            _audioService.setSleepTimer(savedSession.sleepTimerDuration!);
          }
        } else {
          print('[PlaybackNotifier] No saved session, using default duration');
          // Use preferred speed if available
          if (preferredSpeed != 1.0) {
            await _audioService.setSpeed(preferredSpeed);
          }
          state = state.copyWith(
            duration: audiobook.duration,
            playbackSpeed: preferredSpeed,
          );
        }
      } catch (e) {
        // Graceful degradation - continue with default values
        print('[PlaybackNotifier] Error loading saved session: $e');
        state = state.copyWith(
          duration: audiobook.duration,
          errorMessage: ErrorHandler.handlePlaybackException(e),
        );
        return false;
      }

      print('[PlaybackNotifier] setCurrentAudiobook() completed successfully');
      return true;
    } catch (e) {
      // Catch errors from audio source loading
      print('[PlaybackNotifier] setCurrentAudiobook() failed: $e');
      state = state.copyWith(
        errorMessage: ErrorHandler.handlePlaybackException(e),
        isLoading: false,
      );
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Starts or resumes playback.
  ///
  /// Returns: true if successful, false if failed with graceful degradation
  Future<bool> play() async {
    print('[PlaybackNotifier] play() called');
    try {
      await _audioService.play();
      print('[PlaybackNotifier] _audioService.play() completed, updating state to playing');
      state = state.copyWith(
        isPlaying: true,
      );

      // Start periodic position saving
      _startPeriodicPositionSave();

      // Mark the audiobook as in-progress so it appears in the "Reading" list
      // This is done in the background to avoid blocking playback
      Future.microtask(() async {
        try {
          final currentAudiobook = ref.read(currentAudiobookProvider);
          if (currentAudiobook != null) {
            print('[PlaybackNotifier] Marking audiobook as in-progress: ${currentAudiobook.title}');
            await _playbackRepo.markAudiobookAsInProgress(currentAudiobook.id);
          }
        } catch (e) {
          print('[PlaybackNotifier] Error marking audiobook as in-progress: $e');
          // Silently fail - don't disrupt playback
        }
      });

      return true;
    } catch (e) {
      print('[PlaybackNotifier] play() failed: $e');
      state = state.copyWith(
        errorMessage: ErrorHandler.handlePlaybackException(e),
      );
      return false;
    }
  }

  /// Pauses playback.
  ///
  /// Returns: true if successful, false if failed with graceful degradation
  Future<bool> pause() async {
    try {
      await _audioService.pause();
      state = state.copyWith(
        isPlaying: false,
      );

      // Stop periodic position saving and save current position
      _stopPeriodicPositionSave();
      await _saveCurrentPosition();

      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: ErrorHandler.handlePlaybackException(e),
      );
      return false;
    }
  }

  /// Stops playback completely.
  ///
  /// Throws: Exception if there's an error stopping playback
  Future<void> stop() async {
    try {
      await _audioService.stop();
      state = state.copyWith(isPlaying: false);

      // Stop periodic position saving and save current position
      _stopPeriodicPositionSave();
      await _saveCurrentPosition();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }

  /// Seeks to a specific position in the audiobook.
  ///
  /// This method:
  /// 1. Seeks to the specified position using the audio service
  /// 2. Updates the playback state with the new position
  /// 3. Persists the playback session to the repository
  ///
  /// Throws: Exception if there's an error seeking or updating the session
  Future<void> seekTo(Duration position) async {
    try {
      await _audioService.seekTo(position);
      state = state.copyWith(currentPosition: position);

      // Update playback session in repository
      if (state.currentPosition.inMilliseconds > 0) {
        final currentAudiobook = ref.read(currentAudiobookProvider);
        if (currentAudiobook != null) {
          await _playbackRepo.updatePlaybackPosition(
            currentAudiobook.id,
            position,
          );
        }
      }
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }

  /// Sets the playback speed.
  ///
  /// This method:
  /// 1. Sets the playback speed using the audio service
  /// 2. Updates the playback state with the new speed
  /// 3. Persists the playback speed to the repository
  /// 4. Saves the preferred speed for this audiobook
  ///
  /// Throws: Exception if there's an error setting the speed or updating the session
  Future<void> setSpeed(double speed) async {
    try {
      await _audioService.setSpeed(speed);
      state = state.copyWith(playbackSpeed: speed);

      // Update playback session in repository
      final currentAudiobook = ref.read(currentAudiobookProvider);
      if (currentAudiobook != null) {
        await _playbackRepo.updatePlaybackSpeed(currentAudiobook.id, speed);
        // Save preferred speed for this audiobook
        try {
          await _libraryRepo.updatePreferredSpeed(currentAudiobook.id, speed);
          print(
            '[PlaybackNotifier] Saved preferred speed: $speed for audiobook: ${currentAudiobook.id}',
          );
        } catch (e) {
          print('[PlaybackNotifier] Could not save preferred speed: $e');
        }
      }
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }

  /// Sets a sleep timer that will pause playback after the specified duration.
  ///
  /// The [duration] parameter specifies how long until playback should pause.
  /// The [endOfChapter] parameter, when true, will pause playback at the end of the current chapter.
  ///
  /// Throws: Exception if there's an error setting the sleep timer
  void setSleepTimer(Duration duration, {bool endOfChapter = false}) {
    try {
      _audioService.setSleepTimer(duration, endOfChapter: endOfChapter);
      state = state.copyWith(
        sleepTimerActive: true,
        sleepTimerDuration: duration,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }

  /// Cancels the active sleep timer.
  ///
  /// Throws: Exception if there's an error canceling the sleep timer
  void cancelSleepTimer() {
    try {
      _audioService.cancelSleepTimer();
      state = state.copyWith(
        sleepTimerActive: false,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }

  /// Skips forward by the specified interval.
  ///
  /// This method:
  /// 1. Calculates the new position by adding the interval to the current position
  /// 2. Clamps the position to ensure it doesn't exceed the audiobook duration
  /// 3. Seeks to the new position
  ///
  /// Throws: Exception if there's an error seeking to the new position
  Future<void> skipForward(Duration interval) async {
    final newPosition = state.currentPosition + interval;
    final clampedPosition = newPosition.compareTo(state.duration) > 0
        ? state.duration
        : newPosition;

    await seekTo(clampedPosition);
  }

  /// Skips backward by the specified interval.
  ///
  /// This method:
  /// 1. Calculates the new position by subtracting the interval from the current position
  /// 2. Clamps the position to ensure it doesn't go below zero
  /// 3. Seeks to the new position
  ///
  /// Throws: Exception if there's an error seeking to the new position
  Future<void> skipBackward(Duration interval) async {
    final newPosition = state.currentPosition - interval;
    final clampedPosition = newPosition.isNegative ? Duration.zero : newPosition;

    await seekTo(clampedPosition);
  }

  /// Clears any error message from the playback state.
  void clearError() {
    state = state.copyWith();
  }

  /// Starts periodic position saving during playback
  void _startPeriodicPositionSave() {
    _positionSaveTimer?.cancel();
    _positionSaveTimer = Timer.periodic(_positionSaveInterval, (_) async {
      await _saveCurrentPosition();
    });
  }

  /// Stops periodic position saving
  void _stopPeriodicPositionSave() {
    _positionSaveTimer?.cancel();
    _positionSaveTimer = null;
  }

  /// Saves the current playback position to the repository
  Future<void> _saveCurrentPosition() async {
    try {
      final currentAudiobook = ref.read(currentAudiobookProvider);
      if (currentAudiobook != null && state.currentPosition.inMilliseconds > 0) {
        print(
          '[PlaybackNotifier] Saving position: ${state.currentPosition} for audiobook: ${currentAudiobook.id}',
        );
        await _playbackRepo.updatePlaybackPosition(
          currentAudiobook.id,
          state.currentPosition,
        );
      }
    } catch (e) {
      print('[PlaybackNotifier] Error saving position: $e');
      // Silently fail - don't disrupt playback
    }
  }

  /// Retry mechanism for failed operations
  /// This method can be called to retry operations that previously failed
  Future<bool> retryOperation(Future<bool> Function() operation) async {
    _retryCount = 0;

    while (_retryCount < _maxRetries) {
      try {
        final result = await operation();
        if (result) {
          _retryCount = 0; // Reset on success
          return true;
        }
      } catch (e) {
        _retryCount++;
        state = state.copyWith(
          errorMessage: ErrorHandler.handlePlaybackException(e),
        );

        if (_retryCount < _maxRetries) {
          // Wait before retrying
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
    }

    return false;
  }

  /// Reset retry counter
  void resetRetryCounter() {
    _retryCount = 0;
  }

  /// Gets the current playback session for the active audiobook.
  ///
  /// Returns: The current playback session, or null if no audiobook is active
  Future<PlaybackSession?> getCurrentPlaybackSession() async {
    final currentAudiobook = ref.read(currentAudiobookProvider);
    if (currentAudiobook == null) return null;

    return _playbackRepo.getPlaybackSession(currentAudiobook.id);
  }

  /// Updates the playback session with the current state.
  ///
  /// This method persists the current playback state to the repository.
  ///
  /// Throws: Exception if there's an error updating the playback session
  Future<void> updatePlaybackSession() async {
    final currentAudiobook = ref.read(currentAudiobookProvider);
    if (currentAudiobook == null) return;

    try {
      final playbackSession = PlaybackSession(
        audiobookId: currentAudiobook.id,
        currentPosition: state.currentPosition,
        playbackSpeed: state.playbackSpeed,
        isPlaying: state.isPlaying,
        lastPlayedAt: DateTime.now(),
        sleepTimerActive: state.sleepTimerActive,
        sleepTimerDuration: state.sleepTimerDuration,
      );

      await _playbackRepo.savePlaybackSession(playbackSession);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }

  /// Gets detailed playback feature availability status
  /// Returns a map with availability status and specific reasons if unavailable
  Map<String, dynamic> getPlaybackFeatureStatus() {
    try {
      return _playbackRepo.getPlaybackFeatureStatus();
    } catch (e) {
      return {
        'available': false,
        'message': 'Could not determine playback status',
        'reason': 'status_check_failed',
        'suggestion': 'Please close and reopen the app to fix this issue',
      };
    }
  }
}

/// Provider for all playback sessions (history).
///
/// This provider returns a list of all playback sessions stored in the repository,
/// which can be used to display playback history or resume previous sessions.
final playbackHistoryProvider = FutureProvider<List<PlaybackSession>>((
  ref,
) async {
  final repoAsync = ref.watch(playbackRepositoryProvider);
  return repoAsync.when(
    loading: () => [],
    error: (error, stackTrace) => [],
    data: (repo) => repo.getAllPlaybackSessions(),
  );
});

/// Providers for dependencies
final audioServiceProvider = Provider<AudioServiceHandler>((ref) {
  final playbackDatasourceAsync = ref.watch(playbackLocalDatasourceProvider);
  final playbackDatasource = playbackDatasourceAsync.when(
    loading: () => throw UninitializedDatasourceException('Playback datasource loading'),
    error: (error, stackTrace) =>
        throw UninitializedDatasourceException('Playback datasource error: $error'),
    data: (datasource) => datasource,
  );

  return AudioServiceHandler(
    playbackDatasource: playbackDatasource,
  );
});

final currentAudiobookProvider = Provider<Audiobook?>((ref) => null);
