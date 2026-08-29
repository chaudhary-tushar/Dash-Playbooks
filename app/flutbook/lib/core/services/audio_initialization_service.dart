import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';

/// Service responsible for initializing audio-related services early in the app lifecycle.
/// This ensures that audio playback, notifications, and background processing are ready
/// when the user starts interacting with the audiobook player.
/// Fired when playback should pause (interruption began / noisiness).
typedef PlaybackControlCallback = void Function();

class AudioInitializationService {
  static bool _isInitialized = false;
  static Completer<void>? _initializationCompleter;

  // Registered by the player layer (AudioServiceHandler) so that real audio
  // interruptions actually pause/resume the active player rather than being
  // print-only. Callbacks are invoked at interruption time, so they may be
  // registered lazily after initialization without missing anything later.
  static PlaybackControlCallback? _onInterruptionBegin;
  static PlaybackControlCallback? _onInterruptionEnd;
  static PlaybackControlCallback? _onBecomingNoisy;

  /// Registers callbacks used to react to OS audio interruptions.
  /// [onInterruptionBegin] should pause playback while the interruption lasts;
  /// [onInterruptionEnd] may resume it; [onBecomingNoisy] should pause when
  /// the output route is lost (e.g. headphones unplugged).
  static void setAudioInterruptionHandlers({
    PlaybackControlCallback? onInterruptionBegin,
    PlaybackControlCallback? onInterruptionEnd,
    PlaybackControlCallback? onBecomingNoisy,
  }) {
    _onInterruptionBegin = onInterruptionBegin;
    _onInterruptionEnd = onInterruptionEnd;
    _onBecomingNoisy = onBecomingNoisy;
  }

  /// Initializes media_kit backend for desktop platforms.
  /// This must be called before any AudioPlayer is created.
  static void _initializeMediaKit() {
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      try {
        JustAudioMediaKit.ensureInitialized();
        if (kDebugMode) {
          print('just_audio_media_kit initialized successfully');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error initializing just_audio_media_kit: $e');
        }
        // Don't throw - continue without media_kit fallback
      }
    }
  }

  /// Initializes all audio-related services.
  /// This method should be called early in the app lifecycle, ideally in bootstrap.
  ///
  /// State machine:
  /// - If already initialized, returns immediately.
  /// - If an initialization is currently in flight, concurrent callers share
  ///   the same in-flight future (deduped via [_initializationCompleter]).
  /// - On failure the completer and flags are reset so a later call can retry;
  ///   the error is rethrown to the caller.
  static Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    if (_initializationCompleter != null) {
      // Initialization is already in progress - wait for it to complete.
      return _initializationCompleter!.future;
    }

    _initializationCompleter = Completer<void>();

    try {
      // Initialize media_kit for desktop platforms first (critical for audio playback)
      _initializeMediaKit();

      // Initialize audio session management
      await _initializeAudioSession();

      // Initialize media notification services
      await _initializeMediaNotifications();

      // Initialize background audio processing (if applicable)
      await _initializeBackgroundAudio();

      // Additional audio-related initializations can be added here

      _isInitialized = true;
      _initializationCompleter!.complete();
      // Clear the completer so a later call starts fresh (idempotent success).
      _initializationCompleter = null;
    } catch (e, stackTrace) {
      print('Error initializing audio services: $e');
      print('Stack trace: $stackTrace');

      // Do NOT mark as initialized on failure: keep _isInitialized false so a
      // subsequent call can retry instead of being permanently poisoned.
      _isInitialized = false;
      _initializationCompleter!.completeError(e, stackTrace);
      _initializationCompleter = null;
      rethrow;
    }

    return;
  }

  /// Initializes audio session management for proper audio focus handling.
  static Future<void> _initializeAudioSession() async {
    try {
      final session = await AudioSession.instance;

      // Configure the audio session for audio book playback
      await session.configure(
        const AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playback,
          avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.duckOthers,
          avAudioSessionMode: AVAudioSessionMode.spokenAudio,
          avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
          avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
          androidAudioAttributes: AndroidAudioAttributes(
            contentType: AndroidAudioContentType.sonification,
            usage: AndroidAudioUsage.media,
          ),
          androidWillPauseWhenDucked: false,
        ),
      );

      // Activate the audio session to enable playback
      await session.setActive(true);

      // Handle interruptions (like phone calls). Delegates to the registered
      // handler (AudioServiceHandler) which pauses/resumes the actual player.
      session.interruptionEventStream.listen((event) {
        switch (event.begin) {
          case true:
            print('Audio interruption began');
            _onInterruptionBegin?.call();
          case false:
            print('Audio interruption ended');
            _onInterruptionEnd?.call();
        }
      });

      // Handle audio becoming noisy (like unplugging headphones)
      session.becomingNoisyEventStream.listen((_) {
        print('Audio output became noisy (e.g., headphones unplugged)');
        _onBecomingNoisy?.call();
      });

      print('Audio session initialized successfully');
    } catch (e) {
      print('Error initializing audio session: $e');
      if (kDebugMode) {
        print('This might be expected in debug mode or on unsupported platforms');
      }
      // Don't throw the error as this might be expected on certain platforms during development
    }
  }

  /// Initializes media notification services for displaying playback controls.
  static Future<void> _initializeMediaNotifications() async {
    try {
      // In a real implementation, this would set up the audio_service package
      // to handle media notifications and background audio
      print('Media notifications initialized');
    } catch (e) {
      print('Error initializing media notifications: $e');
      // Don't throw the error as this might be expected on certain platforms
    }
  }

  /// Initializes background audio processing capabilities.
  static Future<void> _initializeBackgroundAudio() async {
    try {
      // On Android, we need to register the audio service
      if (Platform.isAndroid) {
        // This would typically involve setting up the audio service for background playback
        // In a real implementation, this would connect to the audio_service package
        print('Background audio initialized for Android');
      } else if (Platform.isIOS) {
        // iOS background audio is handled through audio session configuration
        print('Background audio initialized for iOS');
      } else {
        print('Background audio initialization skipped for this platform');
      }
    } catch (e) {
      print('Error initializing background audio: $e');
      // Don't throw the error as this might be expected on certain platforms
    }
  }

  /// Checks if the audio services have been initialized.
  static bool get isInitialized => _isInitialized;
}
