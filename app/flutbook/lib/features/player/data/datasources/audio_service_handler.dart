// lib/platform/audio_service_handler.dart
import 'dart:async';

import 'package:audio_service/audio_service.dart' as audio_service;
import 'package:flutbook/features/library/domain/entities/audiobook.dart';
import 'package:just_audio/just_audio.dart';

// Define a simple PlaybackState class for internal use that matches the expected structure
class PlaybackState {
  PlaybackState({
    required this.isPlaying,
    required this.currentPosition,
    required this.playbackSpeed,
    required this.sleepTimerActive,
    required this.audiobookId,
    required this.lastPlayedAt,
    this.sleepTimerDuration,
    this.duration,
  });

  final bool isPlaying;
  final Duration currentPosition;
  final double playbackSpeed;
  final bool sleepTimerActive;
  final String audiobookId;
  final DateTime lastPlayedAt;
  final Duration? sleepTimerDuration;
  final Duration? duration;
}

audio_service.MediaControl playControl = const audio_service.MediaControl(
  androidIcon: 'drawable/ic_action_play_arrow',
  label: 'Play',
  action: audio_service.MediaAction.play,
);
audio_service.MediaControl pauseControl = const audio_service.MediaControl(
  androidIcon: 'drawable/ic_action_pause',
  label: 'Pause',
  action: audio_service.MediaAction.pause,
);
audio_service.MediaControl skipForwardControl = const audio_service.MediaControl(
  androidIcon: 'drawable/ic_action_skip_next',
  label: 'Skip Forward',
  action: audio_service.MediaAction.skipToNext,
);
audio_service.MediaControl skipBackwardControl = const audio_service.MediaControl(
  androidIcon: 'drawable/ic_action_skip_previous',
  label: 'Skip Backward',
  action: audio_service.MediaAction.skipToPrevious,
);

class AudioServiceHandler extends audio_service.BaseAudioHandler {
  AudioServiceHandler() {
    _setupPlayer();
  }
  static const _skipInterval = Duration(seconds: 30);

  final AudioPlayer _player = AudioPlayer();
  final _playbackStateStream = StreamController<PlaybackState>();

  Stream<PlaybackState> get playbackStateStream => _playbackStateStream.stream;

  // Current audiobook being played
  Audiobook? _currentAudiobook;
  Duration _sleepTimerDuration = Duration.zero;
  Timer? _sleepTimer;
  bool _sleepTimerActive = false;

  @override
  Future<void> play() async {
    await _player.play();
    _updatePlaybackState(
      PlaybackState(
        isPlaying: true,
        currentPosition: _player.position,
        playbackSpeed: _player.speed,
        sleepTimerActive: _sleepTimerActive,
        audiobookId: _currentAudiobook?.id ?? '',
        lastPlayedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> pause() async {
    await _player.pause();
    _updatePlaybackState(
      PlaybackState(
        isPlaying: false,
        currentPosition: _player.position,
        playbackSpeed: _player.speed,
        sleepTimerActive: _sleepTimerActive,
        audiobookId: _currentAudiobook?.id ?? '',
        lastPlayedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    _updatePlaybackState(
      PlaybackState(
        isPlaying: false,
        currentPosition: _player.position,
        playbackSpeed: _player.speed,
        sleepTimerActive: _sleepTimerActive,
        audiobookId: _currentAudiobook?.id ?? '',
        lastPlayedAt: DateTime.now(),
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

  Future<void> onMediaButton(audio_service.MediaButton button) async {
    // Simplified media button handling
    if (button == audio_service.MediaButton.media) {
      if (_player.playing) {
        await pause();
      } else {
        await play();
      }
    }
  }

  Future<void> _setupPlayer() async {
    // Set up player event listeners
    _player.playerStateStream.listen((playerState) {
      if (playerState.playing) {
        _updatePlaybackState(
          PlaybackState(
            isPlaying: true,
            currentPosition: _player.position,
            playbackSpeed: _player.speed,
            sleepTimerActive: _sleepTimerActive,
            audiobookId: _currentAudiobook?.id ?? '',
            lastPlayedAt: DateTime.now(),
          ),
        );
      } else {
        _updatePlaybackState(
          PlaybackState(
            isPlaying: false,
            currentPosition: _player.position,
            playbackSpeed: _player.speed,
            sleepTimerActive: _sleepTimerActive,
            audiobookId: _currentAudiobook?.id ?? '',
            lastPlayedAt: DateTime.now(),
          ),
        );
      }
    });

    _player.positionStream.listen(_updatePosition);

    _player.processingStateStream.listen((processingState) {
      if (processingState == ProcessingState.completed) {
        _updatePlaybackState(
          PlaybackState(
            isPlaying: false,
            currentPosition: _player.position,
            playbackSpeed: _player.speed,
            sleepTimerActive: _sleepTimerActive,
            audiobookId: _currentAudiobook?.id ?? '',
            lastPlayedAt: DateTime.now(),
          ),
        );
        _onTrackComplete();
      }
    });
  }

  void setCurrentAudiobook(Audiobook audiobook) {
    _currentAudiobook = audiobook;
    _loadAudioSource(audiobook.filePath);
  }

  Future<void> _loadAudioSource(String filePath) async {
    try {
      await _player.setAudioSource(AudioSource.uri(Uri.file(filePath)));
    } catch (e) {
      print('Error loading audio source: $e');
      _updatePlaybackState(
        PlaybackState(
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

  Future<void> seekTo(Duration position) async {
    await _player.seek(position);
  }

  void setSleepTimer(Duration duration) {
    _sleepTimerDuration = duration;
    _sleepTimerActive = true;

    // Cancel any existing timer
    _sleepTimer?.cancel();

    // Set up new timer
    _sleepTimer = Timer(duration, () {
      _sleepTimerActive = false;
      unawaited(pause()); // Pause playback when timer ends
    });
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimerActive = false;
    _sleepTimerDuration = Duration.zero;
  }

  void _updatePlaybackState(PlaybackState state) {
    final newState = PlaybackState(
      audiobookId: _currentAudiobook?.id ?? '',
      currentPosition: state.currentPosition,
      playbackSpeed: state.playbackSpeed,
      isPlaying: state.isPlaying,
      lastPlayedAt: DateTime.now(),
      sleepTimerActive: state.sleepTimerActive,
      sleepTimerDuration: _sleepTimerDuration,
    );

    _playbackStateStream.add(newState);
  }

  void _updatePosition(Duration position) {
    // Update position without changing state
    final currentState = PlaybackState(
      audiobookId: _currentAudiobook?.id ?? '',
      currentPosition: position,
      playbackSpeed: _player.speed,
      isPlaying: _player.playing,
      lastPlayedAt: DateTime.now(),
      sleepTimerActive: _sleepTimerActive,
      sleepTimerDuration: _sleepTimerDuration,
    );

    _playbackStateStream.add(currentState);
  }

  void _onTrackComplete() {
    // Handle track completion
    _updatePlaybackState(
      PlaybackState(
        isPlaying: false,
        currentPosition: _player.position,
        playbackSpeed: _player.speed,
        sleepTimerActive: _sleepTimerActive,
        audiobookId: _currentAudiobook?.id ?? '',
        lastPlayedAt: DateTime.now(),
      ),
    );
  }

  Stream<PlaybackState> getPlaybackStateStream() {
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
