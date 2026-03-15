// lib/features/player/data/datasources/audio_service_handler.dart
import 'dart:async';
import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:flutbook/features/library/domain/entities/audiobook.dart';
import 'package:flutbook/features/player/data/datasources/playback_local_ds.dart';
import 'package:flutbook/features/player/domain/entities/playback_session.dart';
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
  AudioServiceHandler({
    required PlaybackLocalDatasource playbackDatasource,
  }) {
    print('[AudioServiceHandler] Constructor called');
    _playbackDatasource = playbackDatasource;
    _initializePlayer();
    _setupPlayer();
    _setupAudioFocus();
    _notifyAudioHandlerAboutPlaybackState();
  }

  static const _skipInterval = Duration(seconds: 30);
  static const _autoSaveInterval = Duration(seconds: 5);

  late final AudioPlayer _player;
  late final PlaybackLocalDatasource _playbackDatasource;
  final _playbackStateStream = StreamController<CustomPlaybackState>();

  Stream<CustomPlaybackState> get playbackStateStream => _playbackStateStream.stream;

  // Current audiobook being played
  Audiobook? _currentAudiobook;
  Timer? _autoSaveTimer;
  Duration _sleepTimerDuration = Duration.zero;
  Timer? _sleepTimer;
  Timer? _sleepTimerCountdown;
  bool _sleepTimerActive = false;

  // Audio focus management
  bool _hasAudioFocus = false;

  // Initialize the appropriate audio player based on platform
  void _initializePlayer() {
    // Create the AudioPlayer with appropriate settings
    _player = AudioPlayer();
    // Ensure volume is at maximum
    _player.setVolume(1);
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

    // Check if audio source is loaded
    if (_player.processingState == ProcessingState.idle) {
      print('[AudioServiceHandler] play() aborted: audio source not loaded (state=idle)');
      throw StateError(
        'Cannot play: audio source not loaded. Please ensure the audiobook file exists at: ${_currentAudiobook!.filePath}',
      );
    }

    // Request audio focus before playing
    await _requestAudioFocus();
    print('[AudioServiceHandler] Audio focus: $_hasAudioFocus');

    if (_hasAudioFocus) {
      // Log player state before play
      print(
        '[AudioServiceHandler] Player state before play: processingState=${_player.processingState}, playing=${_player.playing}, duration=${_player.duration}',
      );
      try {
        print('[AudioServiceHandler] Calling _player.play()');
        await _player.play();
        print('[AudioServiceHandler] _player.play() completed successfully');
        // Log player state after play
        await Future<void>.delayed(const Duration(milliseconds: 100));
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

        // Start auto-save timer when playback starts
        _startAutoSaveTimer();
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
    // Stop auto-save timer when pausing
    _stopAutoSaveTimer();

    await _player.pause();

    // Save current playback position immediately when paused
    await _savePlaybackSession();

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

      // Verify the audio source was loaded successfully
      if (_player.processingState == ProcessingState.idle) {
        print('[AudioServiceHandler] ERROR: Audio source failed to load, state is still idle');
        throw StateError('Failed to load audio source. The file may not exist or is inaccessible.');
      }

      print(
        '[AudioServiceHandler] Audio source loaded successfully. Duration: ${_player.duration}, State: ${_player.processingState}',
      );
    } catch (e) {
      print('[AudioServiceHandler] setCurrentAudiobook() failed: $e');
      rethrow;
    }
  }

  Future<void> _loadAudioSource(String filePath) async {
    print('[AudioServiceHandler] _loadAudioSource() starting. filePath: $filePath');

    // Validate file path
    if (filePath.isEmpty) {
      throw ArgumentError('File path cannot be empty');
    }

    // Check if file exists (for local files)
    // Note: On web, this check is not available, so we skip it
    try {
      final file = File(filePath);
      final exists = await file.exists();
      print('[AudioServiceHandler] File exists: $exists, path: $filePath');

      if (!exists) {
        throw FileSystemException('Audio file does not exist', filePath);
      }

      // Check file size to ensure it's not empty
      final size = await file.length();
      print('[AudioServiceHandler] File size: $size bytes');

      if (size == 0) {
        throw FileSystemException('Audio file is empty', filePath);
      }
    } catch (e) {
      // File check may not be available on all platforms (e.g., web)
      // Continue with loading and let setAudioSource handle errors
      print('[AudioServiceHandler] File validation skipped or failed: $e');
    }

    try {
      // Clear any previous state
      await _player.stop();

      // Create audio source from file
      final audioSource = AudioSource.uri(Uri.file(filePath));
      print('[AudioServiceHandler] Created audio source, loading...');

      // Load audio source with a timeout to prevent indefinite hanging
      await _player
          .setAudioSource(audioSource)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              print('[AudioServiceHandler] setAudioSource timed out after 30 seconds');
              throw TimeoutException('Failed to load audio source within 30 seconds');
            },
          );

      print('[AudioServiceHandler] _loadAudioSource() completed successfully');

      // Wait for the player to be ready
      await _player.processingStateStream.firstWhere(
        (state) => state != ProcessingState.loading,
        orElse: () => _player.processingState,
      );

      // Log duration and position after loading
      final duration = _player.duration;
      final position = _player.position;
      final processingState = _player.processingState;
      print(
        '[AudioServiceHandler] Audio source loaded. Duration: $duration, Position: $position, State: $processingState',
      );

      // Verify the audio was loaded correctly
      if (processingState == ProcessingState.idle) {
        throw StateError(
          'Audio source loaded but state is idle - file may be corrupted or unsupported format',
        );
      }

      if (duration == null || duration == Duration.zero) {
        print(
          '[AudioServiceHandler] WARNING: Duration is null or zero, file may not be fully loaded',
        );
      }
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
    _stopAutoSaveTimer();

    // Save final position when track completes
    _savePlaybackSession()
        .then((_) {
          print('[AudioServiceHandler] Saved final playback session on track complete');
        })
        .catchError((e) {
          print('[AudioServiceHandler] Error saving on track complete: $e');
        });

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

  /// Starts a timer to auto-save playback position every 5 seconds
  void _startAutoSaveTimer() {
    // Cancel any existing timer
    _autoSaveTimer?.cancel();

    // Create new timer that saves position periodically
    _autoSaveTimer = Timer.periodic(_autoSaveInterval, (_) {
      _savePlaybackSession().catchError((e) {
        print('[AudioServiceHandler] Error in auto-save: $e');
      });
    });

    print(
      '[AudioServiceHandler] Auto-save timer started (interval: ${_autoSaveInterval.inSeconds}s)',
    );
  }

  /// Stops the auto-save timer
  void _stopAutoSaveTimer() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;
    print('[AudioServiceHandler] Auto-save timer stopped');
  }

  /// Saves the current playback session to the datasource
  Future<void> _savePlaybackSession() async {
    if (_currentAudiobook == null) {
      print('[AudioServiceHandler] Cannot save session: no audiobook set');
      return;
    }

    try {
      final session = PlaybackSession(
        audiobookId: _currentAudiobook!.id,
        currentPosition: _player.position,
        playbackSpeed: _player.speed,
        isPlaying: _player.playing,
        lastPlayedAt: DateTime.now(),
        sleepTimerActive: _sleepTimerActive,
        sleepTimerDuration: _sleepTimerDuration,
      );

      await _playbackDatasource.savePlaybackSession(session);
      print(
        '[AudioServiceHandler] Saved playback session: ${_currentAudiobook!.id} at position ${_player.position.inSeconds}s',
      );
    } catch (e) {
      print('[AudioServiceHandler] Error saving playback session: $e');
      // Don't rethrow - we want auto-save to be silent on failure
    }
  }

  /// Standard dispose that includes canceling auto-save timer
  @override
  Future<void> dispose() async {
    print('[AudioServiceHandler] dispose() called');
    _stopAutoSaveTimer();
    // Save final position before disposing
    await _savePlaybackSession();
    _sleepTimer?.cancel();
    _sleepTimerCountdown?.cancel();
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
