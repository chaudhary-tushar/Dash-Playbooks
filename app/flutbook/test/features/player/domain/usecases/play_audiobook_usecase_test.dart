// test/features/player/domain/usecases/play_audiobook_usecase_test.dart
import 'package:flutbook/features/library/domain/entities/audiobook.dart';
import 'package:flutbook/features/player/domain/entities/playback_history.dart';
import 'package:flutbook/features/player/domain/entities/playback_session.dart';
import 'package:flutbook/features/player/domain/repositories/playback_repository.dart';
import 'package:flutbook/features/player/domain/usecases/play_audiobook_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

// Manual mock implementation of PlaybackRepository for testing
class MockPlaybackRepository implements PlaybackRepository {
  bool _shouldThrowError = false;
  final Map<String, PlaybackSession> _sessions = {};
  final Map<String, Duration> _lastPositions = {};
  final Map<String, Duration> _totalTimes = {};
  final Set<String> _completedAudiobooks = {};

  void setShouldThrowError(bool shouldThrow) {
    _shouldThrowError = shouldThrow;
  }

  void addTestSession(PlaybackSession session) {
    _sessions[session.audiobookId] = session;
  }

  void setLastPlayedPosition(String audiobookId, Duration position) {
    _lastPositions[audiobookId] = position;
  }

  void setTotalPlaybackTime(String audiobookId, Duration time) {
    _totalTimes[audiobookId] = time;
  }

  void markAsCompleted(String audiobookId) {
    _completedAudiobooks.add(audiobookId);
  }

  @override
  Future<PlaybackSession?> getPlaybackSession(String audiobookId) async {
    if (_shouldThrowError) {
      throw Exception('Database error');
    }
    return _sessions[audiobookId];
  }

  @override
  Future<void> updatePlaybackPosition(
    String audiobookId,
    Duration position,
  ) async {
    if (_shouldThrowError) {
      throw Exception('Update error');
    }
    // In a real implementation, this would update the session
  }

  @override
  Future<void> savePlaybackSession(PlaybackSession session) async {
    if (_shouldThrowError) {
      throw Exception('Save error');
    }
    _sessions[session.audiobookId] = session;
  }

  @override
  Future<List<PlaybackSession>> getAllPlaybackSessions() async {
    if (_shouldThrowError) {
      throw Exception('Database error');
    }
    return _sessions.values.toList();
  }

  @override
  Future<void> markAudiobookAsCompleted(String audiobookId) async {
    if (_shouldThrowError) {
      throw Exception('Update error');
    }
    _completedAudiobooks.add(audiobookId);
  }

  @override
  Future<void> updatePlaybackSpeed(String audiobookId, double speed) async {
    if (_shouldThrowError) {
      throw Exception('Update error');
    }
    // In a real implementation, this would update the session
    final session = _sessions[audiobookId];
    if (session != null) {
      _sessions[audiobookId] = session.copyWith(playbackSpeed: speed);
    }
  }

  @override
  Future<void> savePlaybackHistory(PlaybackHistory history) async {
    if (_shouldThrowError) {
      throw Exception('Save error');
    }
    // History saving logic would go here
  }

  @override
  Future<List<PlaybackHistory>> getPlaybackHistory(String audiobookId) async {
    if (_shouldThrowError) {
      throw Exception('Database error');
    }
    return []; // Simplified for testing
  }

  @override
  Future<List<PlaybackHistory>> getAllPlaybackHistory() async {
    if (_shouldThrowError) {
      throw Exception('Database error');
    }
    return []; // Simplified for testing
  }

  @override
  Future<void> clearPlaybackHistory() async {
    if (_shouldThrowError) {
      throw Exception('Clear error');
    }
    // Clear history logic would go here
  }

  @override
  Future<Duration?> getLastPlayedPosition(String audiobookId) async {
    if (_shouldThrowError) {
      throw Exception('Database error');
    }
    return _lastPositions[audiobookId];
  }

  @override
  Future<Duration> getTotalPlaybackTime(String audiobookId) async {
    if (_shouldThrowError) {
      throw Exception('Database error');
    }
    return _totalTimes[audiobookId] ?? Duration.zero;
  }
}

void main() {
  late PlayAudiobookUseCase useCase;
  late MockPlaybackRepository mockRepository;
  late Audiobook testAudiobook;

  setUp(() {
    mockRepository = MockPlaybackRepository();
    useCase = PlayAudiobookUseCaseImpl(mockRepository);

    // Create a test audiobook
    testAudiobook = Audiobook(
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
  });

  group('PlayAudiobookUseCase - Session Management', () {
    test(
      'createPlaybackSession should create a new session successfully',
      () async {
        // Act
        final result = await useCase.createPlaybackSession(testAudiobook);

        // Assert
        expect(result, true);
      },
    );

    test('createPlaybackSession should return false on error', () async {
      // Arrange
      mockRepository.setShouldThrowError(true);

      // Act
      final result = await useCase.createPlaybackSession(testAudiobook);

      // Assert
      expect(result, false);
    });

    test(
      'updatePlaybackPosition should update position successfully',
      () async {
        // Arrange
        const testPosition = Duration(minutes: 30);

        // Act
        final result = await useCase.updatePlaybackPosition(
          testAudiobook.id,
          testPosition,
        );

        // Assert
        expect(result, true);
      },
    );

    test('updatePlaybackPosition should return false on error', () async {
      // Arrange
      mockRepository.setShouldThrowError(true);
      const testPosition = Duration(minutes: 30);

      // Act
      final result = await useCase.updatePlaybackPosition(
        testAudiobook.id,
        testPosition,
      );

      // Assert
      expect(result, false);
    });

    test('updatePlaybackSpeed should update speed successfully', () async {
      // Arrange
      const testSpeed = 1.5;

      // Act
      final result = await useCase.updatePlaybackSpeed(
        testAudiobook.id,
        testSpeed,
      );

      // Assert
      expect(result, true);
    });

    test('updatePlaybackSpeed should return false on error', () async {
      // Arrange
      mockRepository.setShouldThrowError(true);
      const testSpeed = 1.5;

      // Act
      final result = await useCase.updatePlaybackSpeed(
        testAudiobook.id,
        testSpeed,
      );

      // Assert
      expect(result, false);
    });
  });

  group('PlayAudiobookUseCase - Session Retrieval', () {
    test('getPlaybackSession should return session when available', () async {
      // Arrange
      final testSession = PlaybackSession(
        audiobookId: testAudiobook.id,
        currentPosition: const Duration(minutes: 30),
        playbackSpeed: 1.5,
        isPlaying: true,
        lastPlayedAt: DateTime.now(),
        sleepTimerActive: false,
      );
      mockRepository.addTestSession(testSession);

      // Act
      final result = await useCase.getPlaybackSession(testAudiobook.id);

      // Assert
      expect(result, testSession);
      expect(result?.audiobookId, testAudiobook.id);
      expect(result?.currentPosition, const Duration(minutes: 30));
      expect(result?.playbackSpeed, 1.5);
    });

    test(
      'getPlaybackSession should return null when session not found',
      () async {
        // Act
        final result = await useCase.getPlaybackSession('non-existent-id');

        // Assert
        expect(result, null);
      },
    );

    test('getPlaybackSession should return null on error', () async {
      // Arrange
      mockRepository.setShouldThrowError(true);

      // Act
      final result = await useCase.getPlaybackSession(testAudiobook.id);

      // Assert
      expect(result, null);
    });

    test('getAllPlaybackSessions should return list of sessions', () async {
      // Arrange
      final testSessions = [
        PlaybackSession(
          audiobookId: 'audiobook-1',
          currentPosition: const Duration(minutes: 30),
          playbackSpeed: 1,
          isPlaying: false,
          lastPlayedAt: DateTime.now(),
          sleepTimerActive: false,
        ),
        PlaybackSession(
          audiobookId: 'audiobook-2',
          currentPosition: const Duration(minutes: 15),
          playbackSpeed: 1.5,
          isPlaying: true,
          lastPlayedAt: DateTime.now(),
          sleepTimerActive: true,
        ),
      ];

      for (final session in testSessions) {
        mockRepository.addTestSession(session);
      }

      // Act
      final result = await useCase.getAllPlaybackSessions();

      // Assert
      expect(result.length, 2);
      expect(result[0].audiobookId, 'audiobook-1');
      expect(result[1].audiobookId, 'audiobook-2');
    });

    test('getAllPlaybackSessions should return empty list on error', () async {
      // Arrange
      mockRepository.setShouldThrowError(true);

      // Act
      final result = await useCase.getAllPlaybackSessions();

      // Assert
      expect(result, []);
      expect(result.isEmpty, true);
    });
  });

  group('PlayAudiobookUseCase - Completion and History', () {
    test(
      'markAudiobookAsCompleted should mark audiobook as completed successfully',
      () async {
        // Act
        final result = await useCase.markAudiobookAsCompleted(testAudiobook.id);

        // Assert
        expect(result, true);
      },
    );

    test('markAudiobookAsCompleted should return false on error', () async {
      // Arrange
      mockRepository.setShouldThrowError(true);

      // Act
      final result = await useCase.markAudiobookAsCompleted(testAudiobook.id);

      // Assert
      expect(result, false);
    });

    test(
      'getLastPlayedPosition should return position when available',
      () async {
        // Arrange
        const testPosition = Duration(minutes: 45);
        mockRepository.setLastPlayedPosition(testAudiobook.id, testPosition);

        // Act
        final result = await useCase.getLastPlayedPosition(testAudiobook.id);

        // Assert
        expect(result, testPosition);
        expect(result, const Duration(minutes: 45));
      },
    );

    test(
      'getLastPlayedPosition should return null when position not found',
      () async {
        // Act
        final result = await useCase.getLastPlayedPosition('non-existent-id');

        // Assert
        expect(result, null);
      },
    );

    test('getLastPlayedPosition should return null on error', () async {
      // Arrange
      mockRepository.setShouldThrowError(true);

      // Act
      final result = await useCase.getLastPlayedPosition(testAudiobook.id);

      // Assert
      expect(result, null);
    });

    test(
      'getTotalPlaybackTime should return total time when available',
      () async {
        // Arrange
        const testTotalTime = Duration(hours: 2, minutes: 30);
        mockRepository.setTotalPlaybackTime(testAudiobook.id, testTotalTime);

        // Act
        final result = await useCase.getTotalPlaybackTime(testAudiobook.id);

        // Assert
        expect(result, testTotalTime);
        expect(result, const Duration(hours: 2, minutes: 30));
      },
    );

    test('getTotalPlaybackTime should return zero duration on error', () async {
      // Arrange
      mockRepository.setShouldThrowError(true);

      // Act
      final result = await useCase.getTotalPlaybackTime(testAudiobook.id);

      // Assert
      expect(result, Duration.zero);
    });
  });

  group('PlayAudiobookUseCase - Edge Cases', () {
    test('should handle empty audiobook ID', () async {
      // Act
      final result = await useCase.getPlaybackSession('');

      // Assert
      expect(result, null);
    });

    test('should handle zero duration position', () async {
      // Arrange
      const zeroPosition = Duration.zero;

      // Act
      final result = await useCase.updatePlaybackPosition(
        testAudiobook.id,
        zeroPosition,
      );

      // Assert
      expect(result, true);
    });

    test('should handle minimum playback speed', () async {
      // Arrange
      const minSpeed = 0.5;

      // Act
      final result = await useCase.updatePlaybackSpeed(
        testAudiobook.id,
        minSpeed,
      );

      // Assert
      expect(result, true);
    });

    test('should handle maximum playback speed', () async {
      // Arrange
      const maxSpeed = 3.0;

      // Act
      final result = await useCase.updatePlaybackSpeed(
        testAudiobook.id,
        maxSpeed,
      );

      // Assert
      expect(result, true);
    });
  });

  group('PlayAudiobookUseCase - Integration Scenarios', () {
    test('should handle complete playback session lifecycle', () async {
      // Arrange
      const testPosition = Duration(minutes: 45);
      const testSpeed = 1.25;

      // Act - Complete lifecycle
      final createResult = await useCase.createPlaybackSession(testAudiobook);
      final positionResult = await useCase.updatePlaybackPosition(
        testAudiobook.id,
        testPosition,
      );
      final speedResult = await useCase.updatePlaybackSpeed(
        testAudiobook.id,
        testSpeed,
      );
      final sessionResult = await useCase.getPlaybackSession(testAudiobook.id);

      // Assert
      expect(createResult, true);
      expect(positionResult, true);
      expect(speedResult, true);
      expect(sessionResult, isNotNull);
    });

    test('should handle error recovery scenarios', () async {
      // Arrange - First call fails, second succeeds
      const testPosition = Duration(minutes: 30);

      // First attempt should fail
      mockRepository.setShouldThrowError(true);
      final firstResult = await useCase.updatePlaybackPosition(
        testAudiobook.id,
        testPosition,
      );

      // Second attempt should succeed
      mockRepository.setShouldThrowError(false);
      final secondResult = await useCase.updatePlaybackPosition(
        testAudiobook.id,
        testPosition,
      );

      // Assert
      expect(firstResult, false);
      expect(secondResult, true);
    });
  });
}
