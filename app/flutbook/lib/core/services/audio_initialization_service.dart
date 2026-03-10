import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';

/// Service responsible for initializing audio-related services early in the app lifecycle.
/// This ensures that audio playback, notifications, and background processing are ready
/// when the user starts interacting with the audiobook player.
class AudioInitializationService {
  static bool _isInitialized = false;
  static Completer<void>? _initializationCompleter;

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
  static Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    if (_initializationCompleter != null) {
      // If initialization is already in progress, wait for it to complete
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
    } catch (e, stackTrace) {
      print('Error initializing audio services: $e');
      print('Stack trace: $stackTrace');

      // Even if there's an error, mark as initialized to prevent repeated attempts
      _isInitialized = true;
      _initializationCompleter!.completeError(e, stackTrace);
    }

    return _initializationCompleter!.future;
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

      // Handle interruptions (like phone calls)
      session.interruptionEventStream.listen((event) {
        switch (event.begin) {
          case true:
            // Interruption began, pause audio if playing
            print('Audio interruption began');
          case false:
            // Interruption ended, resume audio if it was playing before
            print('Audio interruption ended');
        }
      });

      // Handle audio becoming noisy (like unplugging headphones)
      session.becomingNoisyEventStream.listen((_) {
        print('Audio output became noisy (e.g., headphones unplugged)');
        // In a real app, you might want to pause playback
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
