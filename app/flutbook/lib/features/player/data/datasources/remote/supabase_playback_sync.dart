/// Supabase remote datasource for playback synchronization.
///
/// This datasource replaces Firebase Firestore for playback session storage
/// and synchronization, providing real-time sync capabilities with Supabase.
library;

import 'package:flutbook/core/config/app_config.dart';
import 'package:flutbook/core/error/exceptions.dart';
import 'package:flutbook/features/player/domain/entities/playback_session.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase remote datasource for playback operations.
///
/// Handles playback session synchronization with Supabase PostgreSQL database.
/// Provides real-time synchronization capabilities for playback progress.
class SupabasePlaybackDatasource {
  /// Create a new SupabasePlaybackDatasource.
  ///
  /// [supabase] - The Supabase client instance
  /// [configProvider] - Configuration provider for app settings
  SupabasePlaybackDatasource({
    required SupabaseClient supabase,
    required ConfigProvider configProvider,
  }) : _supabase = supabase,
       _configProvider = configProvider;
  final SupabaseClient _supabase;
  final ConfigProvider _configProvider;

  /// Get the current configuration
  AppConfig get _config => _configProvider.config;

  /// Uploads playback session to Supabase
  Future<void> uploadPlaybackSession(PlaybackSession session) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException('User not authenticated');
      }

      final data = {
        'user_id': user.id,
        'audiobook_id': session.audiobookId,
        'current_position_ms': session.currentPosition.inMilliseconds,
        'playback_speed': session.playbackSpeed,
        'is_playing': session.isPlaying,
        'last_played_at': session.lastPlayedAt,
        'sleep_timer_active': session.sleepTimerActive,
        'sleep_timer_duration_ms': session.sleepTimerDuration?.inMilliseconds,
        'updated_at': DateTime.now(),
      };

      // Try to update existing record first
      final updateResult = await _supabase
          .from('playback_sessions')
          .update(data)
          .eq('audiobook_id', session.audiobookId)
          .eq('user_id', user.id);

      if (updateResult.length == 0) {
        // If no records were updated, insert a new record
        await _supabase.from('playback_sessions').insert(data);
      }
    } catch (e) {
      throw DatabaseException('Failed to upload playback session: $e');
    }
  }

  /// Gets playback sessions from Supabase
  Future<List<PlaybackSession>> getPlaybackSessions() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException('User not authenticated');
      }

      final result = await _supabase
          .from('playback_sessions')
          .select()
          .eq('user_id', user.id)
          .order('last_played_at', ascending: false);

      final sessions = <PlaybackSession>[];
      for (final row in result) {
        final session = PlaybackSession(
          audiobookId: row['audiobook_id'] as String? ?? '',
          currentPosition: Duration(
            milliseconds: (row['current_position_ms'] as num?)?.toInt() ?? 0,
          ),
          playbackSpeed: (row['playback_speed'] as num?)?.toDouble() ?? 1.0,
          isPlaying: row['is_playing'] as bool? ?? false,
          lastPlayedAt: (row['last_played_at'] as DateTime?) ?? DateTime.now(),
          sleepTimerActive: row['sleep_timer_active'] as bool? ?? false,
          sleepTimerDuration: row['sleep_timer_duration_ms'] != null
              ? Duration(milliseconds: row['sleep_timer_duration_ms'] as int)
              : null,
        );

        sessions.add(session);
      }

      return sessions;
    } catch (e) {
      throw DatabaseException('Failed to retrieve playback sessions: $e');
    }
  }

  /// Gets playback session for a specific audiobook
  Future<PlaybackSession?> getPlaybackSession(String audiobookId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException('User not authenticated');
      }

      final result = await _supabase
          .from('playback_sessions')
          .select()
          .eq('audiobook_id', audiobookId)
          .eq('user_id', user.id)
          .single();

      return PlaybackSession(
        audiobookId: result['audiobook_id'] as String? ?? '',
        currentPosition: Duration(
          milliseconds: (result['current_position_ms'] as num?)?.toInt() ?? 0,
        ),
        playbackSpeed: (result['playback_speed'] as num?)?.toDouble() ?? 1.0,
        isPlaying: result['is_playing'] as bool? ?? false,
        lastPlayedAt: (result['last_played_at'] as DateTime?) ?? DateTime.now(),
        sleepTimerActive: result['sleep_timer_active'] as bool? ?? false,
        sleepTimerDuration: result['sleep_timer_duration_ms'] != null
            ? Duration(milliseconds: result['sleep_timer_duration_ms'] as int)
            : null,
      );
    } catch (e) {
      throw DatabaseException('Failed to retrieve playback session: $e');
    }
  }

  /// Deletes playback session for a specific audiobook
  Future<void> deletePlaybackSession(String audiobookId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException('User not authenticated');
      }

      await _supabase
          .from('playback_sessions')
          .delete()
          .eq('audiobook_id', audiobookId)
          .eq('user_id', user.id);
    } catch (e) {
      throw DatabaseException('Failed to delete playback session: $e');
    }
  }

  /// Updates playback position
  Future<void> updatePlaybackPosition(
    String audiobookId,
    Duration position,
  ) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException('User not authenticated');
      }

      await _supabase
          .from('playback_sessions')
          .update({
            'current_position_ms': position.inMilliseconds,
            'last_played_at': DateTime.now(),
            'updated_at': DateTime.now(),
          })
          .eq('audiobook_id', audiobookId)
          .eq('user_id', user.id);
    } catch (e) {
      throw DatabaseException('Failed to update playback position: $e');
    }
  }

  /// Updates playback state (playing/paused)
  Future<void> updatePlaybackState(
    String audiobookId,
    bool isPlaying,
  ) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException('User not authenticated');
      }

      await _supabase
          .from('playback_sessions')
          .update({
            'is_playing': isPlaying,
            'updated_at': DateTime.now(),
          })
          .eq('audiobook_id', audiobookId)
          .eq('user_id', user.id);
    } catch (e) {
      throw DatabaseException('Failed to update playback state: $e');
    }
  }

  /// Updates playback speed
  Future<void> updatePlaybackSpeed(
    String audiobookId,
    double speed,
  ) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException('User not authenticated');
      }

      await _supabase
          .from('playback_sessions')
          .update({
            'playback_speed': speed,
            'updated_at': DateTime.now(),
          })
          .eq('audiobook_id', audiobookId)
          .eq('user_id', user.id);
    } catch (e) {
      throw DatabaseException('Failed to update playback speed: $e');
    }
  }

  /// Updates sleep timer settings
  Future<void> updateSleepTimer(
    String audiobookId,
    bool active,
    Duration? duration,
  ) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException('User not authenticated');
      }

      final data = {
        'sleep_timer_active': active,
        'sleep_timer_duration_ms': duration?.inMilliseconds,
        'updated_at': DateTime.now(),
      };

      await _supabase
          .from('playback_sessions')
          .update(data)
          .eq('audiobook_id', audiobookId)
          .eq('user_id', user.id);
    } catch (e) {
      throw DatabaseException('Failed to update sleep timer: $e');
    }
  }
}
