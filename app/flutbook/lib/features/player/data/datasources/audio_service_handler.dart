// lib/features/player/data/datasources/audio_service_handler.dart
import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutbook/features/library/domain/entities/audiobook.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

// Define a simple PlaybackState class for internal use that matches the expected structure
class CustomPlaybackState {
  CustomPlaybackState({
    required this.isPlaying,
    required this.currentPosition,
    required this.playbackSpeed,
    required this.sleepTimerActive,
    required this.audiobookId,
    required this.lastPlayedAt,
    this.sleepTimerDuration,
    this.duration,
    this.bufferedPosition,
  });

  final bool isPlaying;
  final Duration currentPosition;
  final double playbackSpeed;
  final bool sleepTimerActive;
  final String audiobookId;
  final DateTime lastPlayedAt;
  final Duration? sleepTimerDuration;
  final Duration? duration;
  final Duration? bufferedPosition;
}

class AudioServiceHandler extends BaseAudioHandler {
  AudioServiceHandler() {
    _setupPlayer();
    _setupAudioFocus();
    _notifyAudioHandlerAboutPlaybackState();
  }

  static const _skipInterval = Duration(seconds: 30);

  final AudioPlayer _player = AudioPlayer();
  final _playbackStateStream = StreamController<CustomPlaybackState>();

  Stream<CustomPlaybackState> get playbackStateStream =>
      _playbackStateStream.stream;

  // Current audiobook being played
  Audiobook? _currentAudiobook;
  Duration _sleepTimerDuration = Duration.zero;
  Timer? _sleepTimer;
  Timer? _sleepTimerCountdown;
  bool _sleepTimerActive = false;

  // Audio focus management
  bool _hasAudioFocus = false;
  final bool _isPlayPauseActionInProgress = false;

  @override
  Future<void> play() async {
    // Handle rapid taps - debounce play/pause actions
    if (_isPlayPauseActionInProgress) {
      return; // Ignore rapid taps
    }

    // Use debounce for play action
    await Future(() async {
      // Request audio focus before playing
      await _requestAudioFocus();

      if (_hasAudioFocus) {
        await _player.play();
        _updatePlaybackState(
          CustomPlaybackState(
            isPlaying: true,
            currentPosition: _player.position,
            playbackSpeed: _player.speed,
            sleepTimerActive: _sleepTimerActive,
            audiobookId: _currentAudiobook?.id ?? '',
            lastPlayedAt: DateTime.now(),
            bufferedPosition: _player.bufferedPosition,
          ),
        );
      } else {
        // Handle audio focus conflict
        _handleAudioFocusConflict();
      }
    });
  }

  @override
  Future<void> pause() async {
    // Handle rapid taps - debounce play/pause actions
    if (_isPlayPauseActionInProgress) {
      return; // Ignore rapid taps
    }

    // Use debounce for pause action
    await Future(() async {
      await _player.pause();
      _updatePlaybackState(
        CustomPlaybackState(
          isPlaying: false,
          currentPosition: _player.position,
          playbackSpeed: _player.speed,
          sleepTimerActive: _sleepTimerActive,
          audiobookId: _currentAudiobook?.id ?? '',
          lastPlayedAt: DateTime.now(),
          bufferedPosition: _player.bufferedPosition,
        ),
      );

      // Abandon audio focus when paused
      await _abandonAudioFocus();
    });
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    _updatePlaybackState(
      CustomPlaybackState(
        isPlaying: false,
        currentPosition: _player.position,
        playbackSpeed: _player.speed,
        sleepTimerActive: _sleepTimerActive,
        audiobookId: _currentAudiobook?.id ?? '',
        lastPlayedAt: DateTime.now(),
        bufferedPosition: _player.bufferedPosition,
      ),
    );
  }

  @override
  Future<void> skipToNext() async {
    await _player.seek(_player.position + _skipInterval);
  }

  @override
  Future<void> skipToPrevious() async {
    final newPosition = _player.position - _skipInterval;
    if (newPosition.isNegative) {
      await _player.seek(Duration.zero);
    } else {
      await _player.seek(newPosition);
    }
  }

  @override
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  @override
  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
  }

  // Helper to notify audio handler about playback state changes
  void _notifyAudioHandlerAboutPlaybackState() {
    _player.playingStream.listen((playing) {
      if (playing) {
        playbackState.add(
          PlaybackState(
            controls: const [
              MediaControl.rewind,
              MediaControl.pause,
              MediaControl.fastForward,
            ],
            systemActions: const {
              MediaAction.seek,
              MediaAction.setRating,
            },
            androidCompactActionIndices: const [0, 1, 2],
            processingState: AudioProcessingState.ready,
            playing: true,
          ),
        );
      } else {
        playbackState.add(
          PlaybackState(
            controls: const [
              MediaControl.rewind,
              MediaControl.play,
              MediaControl.fastForward,
            ],
            systemActions: const {
              MediaAction.seek,
              MediaAction.setRating,
            },
            androidCompactActionIndices: const [0, 1, 2],
            processingState: AudioProcessingState.ready,
          ),
        );
      }
    });
  }

  Future<void> _setupPlayer() async {
    // Set up player event listeners
    _player.playerStateStream.listen((playerState) {
      if (playerState.playing) {
        _updatePlaybackState(
          CustomPlaybackState(
            isPlaying: true,
            currentPosition: _player.position,
            playbackSpeed: _player.speed,
            sleepTimerActive: _sleepTimerActive,
            audiobookId: _currentAudiobook?.id ?? '',
            lastPlayedAt: DateTime.now(),
            bufferedPosition: _player.bufferedPosition,
          ),
        );
      } else {
        _updatePlaybackState(
          CustomPlaybackState(
            isPlaying: false,
            currentPosition: _player.position,
            playbackSpeed: _player.speed,
            sleepTimerActive: _sleepTimerActive,
            audiobookId: _currentAudiobook?.id ?? '',
            lastPlayedAt: DateTime.now(),
            bufferedPosition: _player.bufferedPosition,
          ),
        );
      }
    });

    _player.positionStream.listen(_updatePosition);

    _player.processingStateStream.listen((processingState) {
      if (processingState == ProcessingState.completed) {
        _updatePlaybackState(
          CustomPlaybackState(
            isPlaying: false,
            currentPosition: _player.position,
            playbackSpeed: _player.speed,
            sleepTimerActive: _sleepTimerActive,
            audiobookId: _currentAudiobook?.id ?? '',
            lastPlayedAt: DateTime.now(),
            bufferedPosition: _player.bufferedPosition,
          ),
        );
        _onTrackComplete();
      }
    });
  }

  Future<void> _setupAudioFocus() async {
    // Audio focus handling - this is a simplified implementation
    // In a real app, you would use the audio_session package for proper audio focus management
    _hasAudioFocus = true; // Assume we have focus initially

    // Listen for audio focus changes (simplified)
    // This would be more sophisticated in a production app
    // For background audio continuation, we would configure the audio service properly
  }

  Future<void> _requestAudioFocus() async {
    // Simplified audio focus request
    // In production, use audio_session package for proper focus handling
    if (!_hasAudioFocus) {
      _hasAudioFocus = true;
      // In real implementation, this would request audio focus from the system
      // and handle focus loss/gain events
    }
  }

  Future<void> _abandonAudioFocus() async {
    // Simplified audio focus abandonment
    // In production, use audio_session package for proper focus handling
    if (_hasAudioFocus) {
      _hasAudioFocus = false;
      // In real implementation, this would abandon audio focus
    }
  }

  void _handleAudioFocusConflict() {
    // Handle audio focus conflicts
    if (!_hasAudioFocus && _player.playing) {
      // Pause playback if we lose audio focus
      _player.pause();
      _updatePlaybackState(
        CustomPlaybackState(
          isPlaying: false,
          currentPosition: _player.position,
          playbackSpeed: _player.speed,
          sleepTimerActive: _sleepTimerActive,
          audiobookId: _currentAudiobook?.id ?? '',
          lastPlayedAt: DateTime.now(),
        ),
      );
    }
  }

  void setCurrentAudiobook(Audiobook audiobook) {
    _currentAudiobook = audiobook;
    _loadAudioSource(audiobook.filePath);
  }

  Future<void> _loadAudioSource(String filePath) async {
    try {
      // Add platform-specific initialization check
      if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
        await _player.setAudioSource(AudioSource.uri(Uri.file(filePath)));
      } else {
        // For desktop platforms, use a different approach or show unsupported message
        print(
          'Warning: Audio playback not fully supported on desktop platforms',
        );
        throw UnsupportedError(
          'Audio playback is not fully supported on this platform',
        );
      }
    } catch (e) {
      print('Error loading audio source: $e');

      // Handle MissingPluginException specifically
      if (e.toString().contains('MissingPluginException')) {
        print(
          'MissingPluginException: just_audio plugin not properly initialized',
        );
        print('Please ensure you have run: flutter pub add just_audio');
        print(
          'And for Android, ensure proper native setup with: flutter pub add just_audio --platforms android',
        );
      }

      _updatePlaybackState(
        CustomPlaybackState(
          isPlaying: false,
          currentPosition: _player.position,
          playbackSpeed: _player.speed,
          sleepTimerActive: _sleepTimerActive,
          audiobookId: _currentAudiobook?.id ?? '',
          lastPlayedAt: DateTime.now(),
          bufferedPosition: _player.bufferedPosition,
        ),
      );

      // Re-throw the error to be handled by the calling code
      rethrow;
    }
  }

  Future<void> seekTo(Duration position) async {
    await _player.seek(position);
  }

  void setSleepTimer(Duration duration, {bool endOfChapter = false}) {
    _sleepTimerDuration = duration;
    _sleepTimerActive = true;

    // Cancel any existing timers
    _sleepTimer?.cancel();
    _sleepTimerCountdown?.cancel();

    if (endOfChapter) {
      // For end of chapter, we'll monitor position changes
      // and stop at the end of the current chapter
      _setupChapterEndMonitoring();
    } else {
      // Set up countdown timer for notification
      _setupCountdownNotifications(duration);

      // Set up main sleep timer
      _sleepTimer = Timer(duration, () {
        _sleepTimerActive = false;
        _sleepTimerDuration = Duration.zero;
        unawaited(_showSleepTimerNotification());
        unawaited(pause()); // Pause playback when timer ends
      });

      // Set up periodic updates for countdown display
      _setupCountdownUpdates(duration);
    }
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimerCountdown?.cancel();
    _sleepTimerActive = false;
    _sleepTimerDuration = Duration.zero;

    // Update playback state to trigger UI refresh
    _updatePlaybackState(
      CustomPlaybackState(
        audiobookId: _currentAudiobook?.id ?? '',
        currentPosition: _player.position,
        playbackSpeed: _player.speed,
        isPlaying: _player.playing,
        lastPlayedAt: DateTime.now(),
        sleepTimerActive: false,
        sleepTimerDuration: Duration.zero,
        bufferedPosition: _player.bufferedPosition,
      ),
    );
  }

  void _setupCountdownNotifications(Duration duration) {
    // Set up notifications at 1 minute intervals
    final notificationIntervals = [
      duration - const Duration(minutes: 1),
      duration - const Duration(minutes: 2),
      duration - const Duration(minutes: 5),
    ].where((d) => d > Duration.zero).toList();

    for (final notifyAt in notificationIntervals) {
      Timer(notifyAt, () {
        final remaining = duration - notifyAt;
        _showSleepTimerNotification(remaining: remaining);
      });
    }
  }

  void _setupChapterEndMonitoring() {
    // For end of chapter monitoring, we need to check position changes
    // This would require access to chapter information which isn't available here
    // In a real implementation, this would monitor position and stop at chapter end
    _sleepTimerActive = true;
  }

  void _setupCountdownUpdates(Duration duration) {
    // Update remaining time every second for smooth countdown display
    final startTime = DateTime.now();
    final endTime = startTime.add(duration);

    _sleepTimerCountdown = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final remaining = endTime.difference(now);

      if (remaining <= Duration.zero) {
        timer.cancel();
        _sleepTimerDuration = Duration.zero;
      } else {
        _sleepTimerDuration = remaining;

        // Update playback state to trigger UI refresh
        _updatePlaybackState(
          CustomPlaybackState(
            audiobookId: _currentAudiobook?.id ?? '',
            currentPosition: _player.position,
            playbackSpeed: _player.speed,
            isPlaying: _player.playing,
            lastPlayedAt: DateTime.now(),
            sleepTimerActive: _sleepTimerActive,
            sleepTimerDuration: _sleepTimerDuration,
            bufferedPosition: _player.bufferedPosition,
          ),
        );
      }
    });
  }

  Future<void> _showSleepTimerNotification({Duration? remaining}) async {
    // In a real app, this would show a system notification
    // For now, we'll just print to console
    if (remaining != null) {
      print(
        'Sleep timer will pause playback in ${remaining.inMinutes} minutes',
      );
    } else {
      print('Sleep timer has paused playback');
    }

    // Update the playback state to trigger UI updates
    _updatePlaybackState(
      CustomPlaybackState(
        audiobookId: _currentAudiobook?.id ?? '',
        currentPosition: _player.position,
        playbackSpeed: _player.speed,
        isPlaying: _player.playing,
        lastPlayedAt: DateTime.now(),
        sleepTimerActive: _sleepTimerActive,
        sleepTimerDuration: remaining ?? _sleepTimerDuration,
        bufferedPosition: _player.bufferedPosition,
      ),
    );
  }

  void _updatePlaybackState(CustomPlaybackState state) {
    final newState = CustomPlaybackState(
      audiobookId: _currentAudiobook?.id ?? '',
      currentPosition: state.currentPosition,
      playbackSpeed: state.playbackSpeed,
      isPlaying: state.isPlaying,
      lastPlayedAt: DateTime.now(),
      sleepTimerActive: state.sleepTimerActive,
      sleepTimerDuration: _sleepTimerDuration,
      bufferedPosition: _player.bufferedPosition,
    );

    _playbackStateStream.add(newState);
  }

  void _updatePosition(Duration position) {
    // Update position without changing state
    final currentState = CustomPlaybackState(
      audiobookId: _currentAudiobook?.id ?? '',
      currentPosition: position,
      playbackSpeed: _player.speed,
      isPlaying: _player.playing,
      lastPlayedAt: DateTime.now(),
      sleepTimerActive: _sleepTimerActive,
      sleepTimerDuration: _sleepTimerDuration,
      bufferedPosition: _player.bufferedPosition,
    );

    _playbackStateStream.add(currentState);
  }

  void _onTrackComplete() {
    // Handle track completion
    _updatePlaybackState(
      CustomPlaybackState(
        isPlaying: false,
        currentPosition: _player.position,
        playbackSpeed: _player.speed,
        sleepTimerActive: _sleepTimerActive,
        audiobookId: _currentAudiobook?.id ?? '',
        lastPlayedAt: DateTime.now(),
        bufferedPosition: _player.bufferedPosition,
      ),
    );
  }

  Stream<CustomPlaybackState> getPlaybackStateStream() {
    return _playbackStateStream.stream;
  }

  Future<void> dispose() async {
    _sleepTimer?.cancel();
    await _player.dispose();
    await _playbackStateStream.close();
  }

  // Get current playback position
  Duration get currentPosition => _player.position;

  // Get current playback speed
  double get playbackSpeed => _player.speed;

  // Check if currently playing
  bool get isPlaying => _player.playing;

  // Check if sleep timer is active
  bool get isSleepTimerActive => _sleepTimerActive;

  // Get remaining sleep timer duration
  Duration get sleepTimerRemaining => _sleepTimerDuration;
}
