// lib/features/player/data/datasources/audio_service_handler.dart
import 'dart:async';
import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:flutbook/features/library/domain/entities/audiobook.dart';
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
    print('[AudioServiceHandler] Constructor called');
    _initializePlayer();
    _setupPlayer();
    _setupAudioFocus();
    _notifyAudioHandlerAboutPlaybackState();
  }

  static const _skipInterval = Duration(seconds: 30);

  late final AudioPlayer _player;
  final _playbackStateStream = StreamController<CustomPlaybackState>();

  Stream<CustomPlaybackState> get playbackStateStream => _playbackStateStream.stream;

  // Current audiobook being played
  Audiobook? _currentAudiobook;
  Duration _sleepTimerDuration = Duration.zero;
  Timer? _sleepTimer;
  Timer? _sleepTimerCountdown;
  bool _sleepTimerActive = false;

  // Audio focus management
  bool _hasAudioFocus = false;

  // Initialize the appropriate audio player based on platform
  void _initializePlayer() {
    // Create the AudioPlayer with appropriate settings
    _player = AudioPlayer(
      handleInterruptions: true,
    );
    // Ensure volume is at maximum
    _player.setVolume(1.0);
  }

  @override
  Future<void> play() async {
    print(
      '[AudioServiceHandler] play() called. Current audiobook: ${_currentAudiobook?.id}, player.playing: ${_player.playing}',
    );

    if (_currentAudiobook == null) {
      print('[AudioServiceHandler] play() aborted: no audiobook set');
      throw StateError('Cannot play: no audiobook has been set');
    }

    // Request audio focus before playing
    await _requestAudioFocus();
    print('[AudioServiceHandler] Audio focus: $_hasAudioFocus');

    if (_hasAudioFocus) {
      // Log player state before play
      print(
        '[AudioServiceHandler] Player state before play: processingState=${_player.processingState}, playing=${_player.playing}',
      );
      try {
        print('[AudioServiceHandler] Calling _player.play()');
        await _player.play();
        print('[AudioServiceHandler] _player.play() completed successfully');
        // Log player state after play
        print(
          '[AudioServiceHandler] Player state after play: processingState=${_player.processingState}, playing=${_player.playing}',
        );
        _updatePlaybackState(
          CustomPlaybackState(
            isPlaying: true,
            currentPosition: _player.position,
            playbackSpeed: _player.speed,
            sleepTimerActive: _sleepTimerActive,
            audiobookId: _currentAudiobook!.id,
            lastPlayedAt: DateTime.now(),
            bufferedPosition: _player.bufferedPosition,
          ),
        );
      } catch (e) {
        print('[AudioServiceHandler] Error during play: $e');
        rethrow;
      }
    } else {
      print('[AudioServiceHandler] Audio focus conflict, handling...');
      // Handle audio focus conflict
      _handleAudioFocusConflict();
    }
  }

  @override
  Future<void> pause() async {
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

  void _setupPlayer() {
    print('[AudioServiceHandler] _setupPlayer() setting up listeners');
    // Set up player event listeners
    _player.playerStateStream.listen((playerState) {
      print(
        '[AudioServiceHandler] playerStateStream: playing=${playerState.playing}, processingState=${playerState.processingState}',
      );
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

    _player.positionStream.listen((position) {
      // Throttle logging for position updates to avoid spam
      if (position.inMilliseconds % 1000 == 0) {
        print('[AudioServiceHandler] positionStream: ${position.inSeconds}s');
      }
      _updatePosition(position);
    });

    _player.processingStateStream.listen((processingState) {
      print('[AudioServiceHandler] processingStateStream: $processingState');
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

  Future<void> setCurrentAudiobook(Audiobook audiobook) async {
    print(
      '[AudioServiceHandler] setCurrentAudiobook() called. Audiobook ID: ${audiobook.id}, title: ${audiobook.title}, filePath: ${audiobook.filePath}',
    );
    _currentAudiobook = audiobook;
    try {
      await _loadAudioSource(audiobook.filePath);
      print('[AudioServiceHandler] setCurrentAudiobook() completed');
    } catch (e) {
      print('[AudioServiceHandler] setCurrentAudiobook() failed: $e');
      rethrow;
    }
  }

  Future<void> _loadAudioSource(String filePath) async {
    print('[AudioServiceHandler] _loadAudioSource() starting. filePath: $filePath');
    try {
      // Load audio source with a timeout to prevent indefinite hanging
      await _player
          .setAudioSource(AudioSource.uri(Uri.file(filePath)))
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              print('[AudioServiceHandler] setAudioSource timed out after 30 seconds');
              throw TimeoutException('Failed to load audio source within 30 seconds');
            },
          );
      print('[AudioServiceHandler] _loadAudioSource() completed successfully');
      // Log duration and position after loading
      final duration = _player.duration;
      final position = _player.position;
      print('[AudioServiceHandler] Audio source loaded. Duration: $duration, Position: $position');
    } catch (e) {
      print('[AudioServiceHandler] Error loading audio source: $e');
      // Handle MissingPluginException specifically
      if (e.toString().contains('MissingPluginException')) {
        print(
          'MissingPluginException: just_audio plugin not properly initialized',
        );
        print('Please ensure you have run: flutter pub add just_audio');
        print(
          'And for desktop, ensure proper native setup with: flutter pub add just_audio_media_kit media_kit_libs_linux',
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
    print('[AudioServiceHandler] dispose() called');
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
