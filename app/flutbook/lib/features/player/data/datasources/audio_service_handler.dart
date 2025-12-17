// lib/features/player/data/datasources/audio_service_handler.dart
import 'dart:async';

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

class AudioServiceHandler extends BaseAudioHandler {
  AudioServiceHandler() {
    _setupPlayer();
    _notifyAudioHandlerAboutPlaybackState();
  }
  
  static const _skipInterval = Duration(seconds: 30);

  final AudioPlayer _player = AudioPlayer();
  final _playbackStateStream = StreamController<CustomPlaybackState>();

  Stream<CustomPlaybackState> get playbackStateStream => _playbackStateStream.stream;

  // Current audiobook being played
  Audiobook? _currentAudiobook;
  Duration _sleepTimerDuration = Duration.zero;
  Timer? _sleepTimer;
  bool _sleepTimerActive = false;

  @override
  Future<void> play() async {
    await _player.play();
    _updatePlaybackState(
      CustomPlaybackState(
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
        playbackState.add(PlaybackState(
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
        ));
      } else {
        playbackState.add(PlaybackState(
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
          playing: false,
        ));
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

  void _updatePlaybackState(CustomPlaybackState state) {
    final newState = CustomPlaybackState(
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
    final currentState = CustomPlaybackState(
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
