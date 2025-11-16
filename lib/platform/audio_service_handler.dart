// lib/platform/audio_service_handler.dart
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:async';
import 'package:flutter/material.dart';

import '../domain/entities/audiobook.dart';
import '../domain/entities/playback_session.dart';

MediaControl playControl = const MediaControl(
  androidIcon: 'drawable/ic_action_play_arrow',
  label: 'Play',
  action: MediaAction.play,
);
MediaControl pauseControl = const MediaControl(
  androidIcon: 'drawable/ic_action_pause',
  label: 'Pause',
  action: MediaAction.pause,
);
MediaControl skipForwardControl = const MediaControl(
  androidIcon: 'drawable/ic_action_skip_next',
  label: 'Skip Forward',
  action: MediaAction.skipToNext,
);
MediaControl skipBackwardControl = const MediaControl(
  androidIcon: 'drawable/ic_action_skip_previous',
  label: 'Skip Backward',
  action: MediaAction.skipToPrevious,
);

class AudioServiceHandler {
  static const _skipInterval = Duration(seconds: 30);
  
  final AudioPlayer _player = AudioPlayer();
  final _playbackStateStream = StreamController<PlaybackState>();
  
  late final AudioHandler _handler;
  Stream<PlaybackState> get playbackStateStream => _playbackStateStream.stream;
  
  // Current audiobook being played
  Audiobook? _currentAudiobook;
  Duration _sleepTimerDuration = Duration.zero;
  Timer? _sleepTimer;
  bool _sleepTimerActive = false;
  
  AudioServiceHandler() {
    _setupPlayer();
    _handler = _createAudioHandler();
  }
  
  AudioHandler _createAudioHandler() {
    return AudioServiceBackground.run(
      onStart: _onStart,
      onPlay: _onPlay,
      onPause: _onPause,
      onClick: _onClick,
      onStop: _onStop,
      onSkipToNext: _onSkipToNext,
      onSkipToPrevious: _onSkipToPrevious,
      onSeekTo: _onSeekTo,
      onSetSpeed: _onSetSpeed,
    );
  }
  
  Future<void> _setupPlayer() async {
    // Set up player event listeners
    _player.playerStateStream.listen((playerState) {
      if (playerState.playing) {
        _updatePlaybackState(PlaybackState.playing);
      } else {
        _updatePlaybackState(PlaybackState.paused);
      }
    });
    
    _player.positionStream.listen((position) {
      _updatePosition(position);
    });
    
    _player.processingStateStream.listen((processingState) {
      if (processingState == ProcessingState.completed) {
        _updatePlaybackState(PlaybackState.completed);
        _onTrackComplete();
      }
    });
  }
  
  Future<void> _onStart() async {
    // Handler for when audio service starts
  }
  
  Future<void> _onPlay() async {
    await _player.play();
    _updatePlaybackState(PlaybackState.playing);
  }
  
  Future<void> _onPause() async {
    await _player.pause();
    _updatePlaybackState(PlaybackState.paused);
  }
  
  Future<void> _onStop() async {
    await _player.stop();
    _updatePlaybackState(PlaybackState.stopped);
  }
  
  Future<void> _onSkipToNext() async {
    await _player.seek(_player.position + _skipInterval);
  }
  
  Future<void> _onSkipToPrevious() async {
    Duration newPosition = _player.position - _skipInterval;
    if (newPosition.isNegative) {
      newPosition = Duration.zero;
    }
    await _player.seek(newPosition);
  }
  
  Future<void> _onSeekTo( Duration? to) async {
    if (to != null) {
      await _player.seek(to);
    }
  }
  
  Future<void> _onSetSpeed(double speed) async {
    await _player.setSpeed(speed);
  }
  
  void _onClick(MediaAction action) {
    switch (action) {
      case MediaAction.play:
        _onPlay();
        break;
      case MediaAction.pause:
        _onPause();
        break;
      default:
        break;
    }
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
      _updatePlaybackState(PlaybackState.error);
    }
  }
  
  Future<void> play() async {
    await _onPlay();
  }
  
  Future<void> pause() async {
    await _onPause();
  }
  
  Future<void> stop() async {
    await _onStop();
  }
  
  Future<void> seekTo(Duration position) async {
    await _player.seek(position);
  }
  
  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
  }
  
  void setSleepTimer(Duration duration) {
    _sleepTimerDuration = duration;
    _sleepTimerActive = true;
    
    // Cancel any existing timer
    _sleepTimer?.cancel();
    
    // Set up new timer
    _sleepTimer = Timer(duration, () {
      _sleepTimerActive = false;
      _onPause(); // Pause playback when timer ends
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
      currentPosition: _player.position,
      playbackSpeed: _player.speed,
      isPlaying: state == PlaybackState.playing,
      lastPlayedAt: DateTime.now(),
      sleepTimerActive: _sleepTimerActive,
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
    _updatePlaybackState(PlaybackState.completed);
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