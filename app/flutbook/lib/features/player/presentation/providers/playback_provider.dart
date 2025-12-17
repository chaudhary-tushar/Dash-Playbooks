// lib/presentation/providers/playback_provider.dart
import 'dart:async';

import 'package:flutbook/features/library/domain/entities/audiobook.dart';
import 'package:flutbook/features/player/data/datasources/audio_service_handler.dart';
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
  late final StreamSubscription<dynamic> _playbackStreamSubscription;

  @override
  PlaybackState build() {
    _audioService = ref.read(audioServiceProvider);
    _playbackRepo = ref.read(playbackRepositoryProvider);

    // Listen to playback state changes from audio service
    _playbackStreamSubscription = _audioService.getPlaybackStateStream().listen(
      (playbackState) {
        state = state.copyWith(
          isPlaying: playbackState.isPlaying,
          currentPosition: playbackState.currentPosition,
          playbackSpeed: playbackState.playbackSpeed,
          sleepTimerActive: playbackState.sleepTimerActive,
          bufferedPosition: playbackState.bufferedPosition,
        );
      },
      onError: (Object error) {
        state = state.copyWith(errorMessage: error.toString());
      },
    );

    ref.onDispose(() {
      _playbackStreamSubscription.cancel();
      _audioService.dispose();
    });

    return PlaybackState.initial();
  }

  /// Sets the current audiobook to play and loads any saved playback position.
  ///
  /// This method:
  /// 1. Sets the audiobook in the audio service
  /// 2. Loads any saved playback session from the repository
  /// 3. Restores the playback position and settings if available
  /// 4. Updates the playback state accordingly
  ///
  /// Throws: Exception if there's an error setting the audiobook or loading the session
  Future<void> setCurrentAudiobook(Audiobook audiobook) async {
    state = state.copyWith(isLoading: true);
    try {
      _audioService.setCurrentAudiobook(audiobook);

      // Load saved playback position if available
      final savedSession = await _playbackRepo.getPlaybackSession(audiobook.id);
      if (savedSession != null) {
        await _audioService.seekTo(savedSession.currentPosition);
        state = state.copyWith(
          currentPosition: savedSession.currentPosition,
          duration: audiobook.duration,
          playbackSpeed: savedSession.playbackSpeed,
          sleepTimerActive: savedSession.sleepTimerActive,
          sleepTimerDuration: savedSession.sleepTimerDuration,
        );

        // If sleep timer was active, restart it
        if (savedSession.sleepTimerActive &&
            savedSession.sleepTimerDuration != null) {
          _audioService.setSleepTimer(savedSession.sleepTimerDuration!);
        }
      } else {
        state = state.copyWith(duration: audiobook.duration);
      }
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      rethrow; // Re-throw to allow UI to handle the error
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Starts or resumes playback.
  ///
  /// Throws: Exception if there's an error starting playback
  Future<void> play() async {
    try {
      await _audioService.play();
      state = state.copyWith(isPlaying: true);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }

  /// Pauses playback.
  ///
  /// Throws: Exception if there's an error pausing playback
  Future<void> pause() async {
    try {
      await _audioService.pause();
      state = state.copyWith(isPlaying: false);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }

  /// Stops playback completely.
  ///
  /// Throws: Exception if there's an error stopping playback
  Future<void> stop() async {
    try {
      await _audioService.stop();
      state = state.copyWith(isPlaying: false);
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
          final playbackSession = PlaybackSession(
            audiobookId: currentAudiobook.id,
            currentPosition: position,
            playbackSpeed: state.playbackSpeed,
            isPlaying: state.isPlaying,
            lastPlayedAt: DateTime.now(),
            sleepTimerActive: state.sleepTimerActive,
            sleepTimerDuration: state.sleepTimerDuration,
          );

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
    final clampedPosition = newPosition.isNegative
        ? Duration.zero
        : newPosition;

    await seekTo(clampedPosition);
  }

  /// Clears any error message from the playback state.
  void clearError() {
    state = state.copyWith();
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
}

/// Provider for all playback sessions (history).
///
/// This provider returns a list of all playback sessions stored in the repository,
/// which can be used to display playback history or resume previous sessions.
final playbackHistoryProvider = FutureProvider<List<PlaybackSession>>((
  ref,
) async {
  final repo = ref.read(playbackRepositoryProvider);
  return repo.getAllPlaybackSessions();
});

/// Providers for dependencies
final audioServiceProvider = Provider<AudioServiceHandler>((ref) {
  return AudioServiceHandler();
});

final playbackRepositoryProvider = Provider<PlaybackRepositoryImpl>((ref) {
  // This would need to be properly constructed with dependencies in main app
  throw UnimplementedError(
    'This would be constructed with actual dependencies in real implementation',
  );
});

final currentAudiobookProvider = Provider<Audiobook?>((ref) => null);
