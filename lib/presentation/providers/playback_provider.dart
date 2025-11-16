// lib/presentation/providers/playback_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../domain/entities/audiobook.dart';
import '../../domain/entities/playback_session.dart';
import '../../data/repositories/playback_repository_impl.dart';
import '../services/audio_service_handler.dart';

// State classes for playback
class PlaybackState {
  final bool isPlaying;
  final Duration currentPosition;
  final Duration duration;
  final double playbackSpeed;
  final bool sleepTimerActive;
  final Duration? sleepTimerDuration;
  final String? errorMessage;
  final bool isLoading;

  const PlaybackState({
    required this.isPlaying,
    required this.currentPosition,
    required this.duration,
    required this.playbackSpeed,
    required this.sleepTimerActive,
    this.sleepTimerDuration,
    this.errorMessage,
    required this.isLoading,
  });

  PlaybackState copyWith({
    bool? isPlaying,
    Duration? currentPosition,
    Duration? duration,
    double? playbackSpeed,
    bool? sleepTimerActive,
    Duration? sleepTimerDuration,
    String? errorMessage,
    bool? isLoading,
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
    );
  }

  factory PlaybackState.initial() {
    return const PlaybackState(
      isPlaying: false,
      currentPosition: Duration.zero,
      duration: Duration.zero,
      playbackSpeed: 1.0,
      sleepTimerActive: false,
      sleepTimerDuration: null,
      errorMessage: null,
      isLoading: false,
    );
  }
}

// Main playback provider
final playbackProvider = StateNotifierProvider<PlaybackNotifier, PlaybackState>(
  (ref) => PlaybackNotifier(ref),
);

class PlaybackNotifier extends StateNotifier<PlaybackState> {
  final Ref ref;
  final AudioServiceHandler _audioService;
  final PlaybackRepositoryImpl _playbackRepo;
  final _playbackStreamSubscription = StreamSubscription.none;

  PlaybackNotifier(this.ref) : super(PlaybackState.initial()) {
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
        );
      },
      onError: (error) {
        state = state.copyWith(errorMessage: error.toString());
      },
    );
  }

  // Set the current audiobook to play
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
      } else {
        state = state.copyWith(duration: audiobook.duration);
      }
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // Start or resume playback
  Future<void> play() async {
    try {
      await _audioService.play();
      state = state.copyWith(isPlaying: true);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  // Pause playback
  Future<void> pause() async {
    try {
      await _audioService.pause();
      state = state.copyWith(isPlaying: false);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  // Stop playback
  Future<void> stop() async {
    try {
      await _audioService.stop();
      state = state.copyWith(isPlaying: false);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  // Seek to a specific position
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
          
          await _playbackRepo.updatePlaybackPosition(currentAudiobook.id, position);
        }
      }
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  // Set playback speed
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
    }
  }

  // Set sleep timer
  void setSleepTimer(Duration duration) {
    try {
      _audioService.setSleepTimer(duration);
      state = state.copyWith(
        sleepTimerActive: true,
        sleepTimerDuration: duration,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  // Cancel sleep timer
  void cancelSleepTimer() {
    try {
      _audioService.cancelSleepTimer();
      state = state.copyWith(
        sleepTimerActive: false,
        sleepTimerDuration: null,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  // Skip forward
  Future<void> skipForward(Duration interval) async {
    final newPosition = state.currentPosition + interval;
    final clampedPosition = newPosition.compareTo(state.duration) > 0
        ? state.duration
        : newPosition;
    
    await seekTo(clampedPosition);
  }

  // Skip backward
  Future<void> skipBackward(Duration interval) async {
    final newPosition = state.currentPosition - interval;
    final clampedPosition = newPosition.isNegative
        ? Duration.zero
        : newPosition;
    
    await seekTo(clampedPosition);
  }

  @override
  void dispose() {
    _playbackStreamSubscription.cancel();
    _audioService.dispose();
    super.dispose();
  }
}

// Providers for dependencies
final audioServiceProvider = Provider<AudioServiceHandler>((ref) {
  return AudioServiceHandler();
});

final playbackRepositoryProvider = Provider<PlaybackRepositoryImpl>((ref) {
  // This would need to be properly constructed with dependencies in main app
  throw UnimplementedError("This would be constructed with actual dependencies in real implementation");
});

final currentAudiobookProvider = StateProvider<Audiobook?>((ref) => null);