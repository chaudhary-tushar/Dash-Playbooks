// test/features/player/presentation/providers/playback_provider_test.dart
import 'package:flutbook/features/library/domain/entities/audiobook.dart';
import 'package:flutbook/features/player/domain/entities/playback_session.dart';
import 'package:flutbook/features/player/presentation/providers/playback_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaybackState Tests', () {
    test('initial state should have correct default values', () {
      final state = PlaybackState.initial();

      expect(state.isPlaying, false);
      expect(state.currentPosition, Duration.zero);
      expect(state.duration, Duration.zero);
      expect(state.playbackSpeed, 1);
      expect(state.sleepTimerActive, false);
      expect(state.isLoading, false);
      expect(state.errorMessage, null);
      expect(state.sleepTimerDuration, null);
    });

    test('copyWith should create new state with updated values', () {
      final originalState = PlaybackState.initial();
      final newState = originalState.copyWith(
        isPlaying: true,
        currentPosition: const Duration(minutes: 30),
        playbackSpeed: 1.5,
      );

      expect(newState.isPlaying, true);
      expect(newState.currentPosition, const Duration(minutes: 30));
      expect(newState.playbackSpeed, 1.5);
      expect(newState.duration, Duration.zero); // Should remain unchanged
      expect(newState.sleepTimerActive, false); // Should remain unchanged
    });

    test('copyWith should preserve null values when not specified', () {
      final originalState = PlaybackState.initial();
      final newState = originalState.copyWith(
        isPlaying: true,
      );

      expect(newState.isPlaying, true);
      expect(
        newState.currentPosition,
        Duration.zero,
      ); // Should remain unchanged
      expect(newState.playbackSpeed, 1); // Should remain unchanged
      expect(newState.errorMessage, null); // Should remain unchanged
    });
  });

  group('PlaybackState Edge Cases', () {
    test('should handle negative duration correctly', () {
      const state = PlaybackState(
        isPlaying: false,
        currentPosition: Duration.zero,
        duration: Duration(seconds: -1), // Negative duration
        playbackSpeed: 1,
        sleepTimerActive: false,
        isLoading: false,
      );

      expect(state.duration, const Duration(seconds: -1));
    });

    test('should handle very large durations', () {
      const largeDuration = Duration(days: 365); // 1 year
      const state = PlaybackState(
        isPlaying: false,
        currentPosition: Duration.zero,
        duration: largeDuration,
        playbackSpeed: 1,
        sleepTimerActive: false,
        isLoading: false,
      );

      expect(state.duration, largeDuration);
    });

    test('should handle fractional playback speeds', () {
      const state = PlaybackState(
        isPlaying: false,
        currentPosition: Duration.zero,
        duration: Duration.zero,
        playbackSpeed: 0.5, // Slow speed
        sleepTimerActive: false,
        isLoading: false,
      );

      expect(state.playbackSpeed, 0.5);
    });
  });

  group('PlaybackState Equality', () {
    test('states with same values should be equal', () {
      const state1 = PlaybackState(
        isPlaying: true,
        currentPosition: Duration(minutes: 30),
        duration: Duration(hours: 1),
        playbackSpeed: 1.5,
        sleepTimerActive: true,
        sleepTimerDuration: Duration(minutes: 30),
        isLoading: false,
        errorMessage: 'test error',
      );

      const state2 = PlaybackState(
        isPlaying: true,
        currentPosition: Duration(minutes: 30),
        duration: Duration(hours: 1),
        playbackSpeed: 1.5,
        sleepTimerActive: true,
        sleepTimerDuration: Duration(minutes: 30),
        isLoading: false,
        errorMessage: 'test error',
      );

      expect(state1.isPlaying, state2.isPlaying);
      expect(state1.currentPosition, state2.currentPosition);
      expect(state1.duration, state2.duration);
      expect(state1.playbackSpeed, state2.playbackSpeed);
      expect(state1.sleepTimerActive, state2.sleepTimerActive);
      expect(state1.sleepTimerDuration, state2.sleepTimerDuration);
      expect(state1.isLoading, state2.isLoading);
      expect(state1.errorMessage, state2.errorMessage);
    });

    test('states with different values should not be equal', () {
      final state1 = PlaybackState.initial();
      final state2 = PlaybackState.initial().copyWith(isPlaying: true);

      expect(state1.isPlaying, isNot(state2.isPlaying));
    });
  });

  group('PlaybackSession Integration Tests', () {
    test('PlaybackSession should be compatible with PlaybackState', () {
      final testAudiobook = Audiobook(
        id: 'test-audiobook-1',
        title: 'Test Audiobook',
        author: 'Test Author',
        album: 'Test Album',
        duration: const Duration(hours: 1),
        filePath: '/path/to/audiobook.mp3',
        chapters: [],
        createdAt: DateTime.now(),
        completed: false,
        totalSize: 1000000,
      );

      final playbackSession = PlaybackSession(
        audiobookId: testAudiobook.id,
        currentPosition: const Duration(minutes: 30),
        playbackSpeed: 1.5,
        isPlaying: true,
        lastPlayedAt: DateTime.now(),
        sleepTimerActive: false,
      );

      // Verify that PlaybackSession values can be used to create PlaybackState
      final state = PlaybackState(
        isPlaying: playbackSession.isPlaying,
        currentPosition: playbackSession.currentPosition,
        duration: testAudiobook.duration,
        playbackSpeed: playbackSession.playbackSpeed,
        sleepTimerActive: playbackSession.sleepTimerActive,
        sleepTimerDuration: playbackSession.sleepTimerDuration,
        isLoading: false,
      );

      expect(state.isPlaying, playbackSession.isPlaying);
      expect(state.currentPosition, playbackSession.currentPosition);
      expect(state.playbackSpeed, playbackSession.playbackSpeed);
      expect(state.sleepTimerActive, playbackSession.sleepTimerActive);
    });

    test('PlaybackState should handle null sleep timer duration', () {
      const state = PlaybackState(
        isPlaying: false,
        currentPosition: Duration.zero,
        duration: Duration.zero,
        playbackSpeed: 1,
        sleepTimerActive: false,
        isLoading: false,
      );

      expect(state.sleepTimerDuration, null);
      expect(state.sleepTimerActive, false);
    });

    test('PlaybackState should handle null error message', () {
      const state = PlaybackState(
        isPlaying: false,
        currentPosition: Duration.zero,
        duration: Duration.zero,
        playbackSpeed: 1,
        sleepTimerActive: false,
        isLoading: false,
      );

      expect(state.errorMessage, null);
    });
  });

  group('PlaybackState Validation', () {
    test('should handle zero duration correctly', () {
      final state = PlaybackState.initial();
      expect(state.duration, Duration.zero);
    });

    test('should handle zero position correctly', () {
      final state = PlaybackState.initial();
      expect(state.currentPosition, Duration.zero);
    });

    test('should handle minimum playback speed', () {
      const state = PlaybackState(
        isPlaying: false,
        currentPosition: Duration.zero,
        duration: Duration.zero,
        playbackSpeed: 0.1, // Very slow
        sleepTimerActive: false,
        isLoading: false,
      );

      expect(state.playbackSpeed, 0.1);
    });

    test('should handle maximum playback speed', () {
      const state = PlaybackState(
        isPlaying: false,
        currentPosition: Duration.zero,
        duration: Duration.zero,
        playbackSpeed: 5, // Very fast
        sleepTimerActive: false,
        isLoading: false,
      );

      expect(state.playbackSpeed, 5.0);
    });
  });

  group('PlaybackState Serialization Compatibility', () {
    test('should be compatible with JSON serialization patterns', () {
      const state = PlaybackState(
        isPlaying: true,
        currentPosition: Duration(minutes: 30),
        duration: Duration(hours: 1),
        playbackSpeed: 1.5,
        sleepTimerActive: true,
        sleepTimerDuration: Duration(minutes: 30),
        isLoading: false,
        errorMessage: 'test error',
      );

      // Verify that all properties are accessible and can be used for serialization
      final map = {
        'isPlaying': state.isPlaying,
        'currentPosition': state.currentPosition.inMilliseconds,
        'duration': state.duration.inMilliseconds,
        'playbackSpeed': state.playbackSpeed,
        'sleepTimerActive': state.sleepTimerActive,
        'sleepTimerDuration': state.sleepTimerDuration?.inMilliseconds,
        'isLoading': state.isLoading,
        'errorMessage': state.errorMessage,
      };

      expect(map['isPlaying'], true);
      expect(map['currentPosition'], 1800000); // 30 minutes in milliseconds
      expect(map['duration'], 3600000); // 1 hour in milliseconds
      expect(map['playbackSpeed'], 1.5);
      expect(map['sleepTimerActive'], true);
      expect(map['sleepTimerDuration'], 1800000); // 30 minutes in milliseconds
      expect(map['isLoading'], false);
      expect(map['errorMessage'], 'test error');
    });
  });
}
