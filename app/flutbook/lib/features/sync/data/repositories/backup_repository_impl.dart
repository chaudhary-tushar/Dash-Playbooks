/// Implementation of backup repository for cloud backup operations.
///
/// Handles backup and restore operations with data aggregation
/// from various sources (library, playback, lists, etc.).
library;

import 'dart:convert';

import 'package:flutbook/features/library/domain/entities/audiobook.dart';
import 'package:flutbook/features/player/domain/entities/playback_session.dart';
import 'package:flutbook/features/sync/data/datasources/supabase_backup_datasource.dart';
import 'package:flutbook/features/sync/domain/entities/reading_list.dart';
import 'package:flutbook/features/sync/domain/repositories/backup_repository.dart';
import 'package:uuid/uuid.dart';

/// Implementation of [BackupRepository].
///
/// Provides backup and restore functionality with Supabase Storage.
class BackupRepositoryImpl implements BackupRepository {
  /// Create a new BackupRepositoryImpl.
  ///
  /// [backupDatasource] - Remote backup datasource
  /// [audiobooks] - List of audiobooks to backup
  /// [playbackSessions] - Playback sessions to backup
  /// [readingLists] - Reading lists to backup
  BackupRepositoryImpl({
    required SupabaseBackupDatasource backupDatasource,
    required List<Audiobook> audiobooks,
    required List<PlaybackSession> playbackSessions,
    required List<ReadingList> readingLists,
  })  : _backupDatasource = backupDatasource,
        _audiobooks = audiobooks,
        _playbackSessions = playbackSessions,
        _readingLists = readingLists;

  final SupabaseBackupDatasource _backupDatasource;
  final List<Audiobook> _audiobooks;
  final List<PlaybackSession> _playbackSessions;
  final List<ReadingList> _readingLists;

  DateTime? _lastBackupTime;

  @override
  Future<BackupResult> createBackup() async {
    try {
      final backupId = const Uuid().v4();
      final timestamp = DateTime.now();

      // Aggregate all user data
      final backupData = {
        'version': '1.0',
        'timestamp': timestamp.toIso8601String(),
        'audiobooks': _audiobooks.map(_audiobookToJson).toList(),
        'playback_sessions': _playbackSessions
            .map(_sessionToJson)
            .toList(),
        'reading_lists': _readingLists.map(_listToJson).toList(),
      };

      final itemCount = _audiobooks.length +
          _playbackSessions.length +
          _readingLists.length;

      final backupInfo = BackupInfo(
        id: backupId,
        timestamp: timestamp,
        size: jsonEncode(backupData).length,
        itemCount: itemCount,
      );

      // Upload to Supabase
      await _backupDatasource.uploadBackup(
        backupId: backupId,
        backupData: backupData,
        backupInfo: backupInfo,
      );

      _lastBackupTime = timestamp;

      return BackupResult(
        status: BackupStatus.success,
        backupSize: backupInfo.size,
        itemCount: itemCount,
        timestamp: timestamp,
      );
    } catch (e) {
      return BackupResult(
        status: BackupStatus.failed,
        errorMessage: 'Failed to create backup: $e',
        timestamp: DateTime.now(),
      );
    }
  }

  @override
  Future<RestoreResult> restoreBackup(String backupId, {bool overwrite = false}) async {
    try {
      // Download backup data
      final backupData = await _backupDatasource.downloadBackup(backupId);

      // Parse and restore data
      int restoredCount = 0;

      // Restore audiobooks
      final audiobooksJson = backupData['audiobooks'] as List? ?? [];
      for (final audiobookJson in audiobooksJson) {
        await _restoreAudiobook(audiobookJson as Map<String, dynamic>);
        restoredCount++;
      }

      // Restore playback sessions
      final sessionsJson = backupData['playback_sessions'] as List? ?? [];
      for (final sessionJson in sessionsJson) {
        await _restorePlaybackSession(sessionJson as Map<String, dynamic>);
        restoredCount++;
      }

      // Restore reading lists
      final listsJson = backupData['reading_lists'] as List? ?? [];
      for (final listJson in listsJson) {
        await _restoreReadingList(listJson as Map<String, dynamic>);
        restoredCount++;
      }

      return RestoreResult(
        status: BackupStatus.success,
        restoredCount: restoredCount,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      return RestoreResult(
        status: BackupStatus.failed,
        errorMessage: 'Failed to restore backup: $e',
        timestamp: DateTime.now(),
      );
    }
  }

  @override
  Future<List<BackupInfo>> listBackups() async {
    return _backupDatasource.listBackups();
  }

  @override
  Future<BackupInfo?> getBackupInfo(String backupId) async {
    final backups = await listBackups();
    try {
      return backups.firstWhere((b) => b.id == backupId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> deleteBackup(String backupId) async {
    await _backupDatasource.deleteBackup(backupId);
  }

  @override
  Future<DateTime?> getLastBackupTime() async {
    if (_lastBackupTime != null) {
      return _lastBackupTime;
    }

    final backups = await listBackups();
    if (backups.isNotEmpty) {
      return backups.first.timestamp;
    }
    return null;
  }

  @override
  Future<bool> canBackup() async {
    return _backupDatasource.isAuthenticated();
  }

  @override
  Future<void> enableAutomaticBackups({int frequency = 1}) async {
    // TODO: Implement scheduled backups using WorkManager or similar
  }

  @override
  Future<void> disableAutomaticBackups() async {
    // TODO: Cancel scheduled backups
  }

  @override
  Future<bool> isAutomaticBackupEnabled() async {
    // TODO: Check if scheduled backups are enabled
    return false;
  }

  // Serialization helpers
  Map<String, dynamic> _audiobookToJson(Audiobook audiobook) {
    return {
      'id': audiobook.id,
      'title': audiobook.title,
      'author': audiobook.author,
      'duration_ms': audiobook.duration.inMilliseconds,
      'file_path': audiobook.filePath,
    };
  }

  Map<String, dynamic> _sessionToJson(PlaybackSession session) {
    return {
      'audiobook_id': session.audiobookId,
      'current_position_ms': session.currentPosition.inMilliseconds,
      'playback_speed': session.playbackSpeed,
      'last_played_at': session.lastPlayedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _listToJson(ReadingList list) {
    return {
      'id': list.id,
      'name': list.name,
      'description': list.description,
      'audiobook_ids': list.audiobookIds,
      'created_at': list.createdAt.toIso8601String(),
    };
  }

  // Deserialization helpers
  Future<void> _restoreAudiobook(Map<String, dynamic> json) async {
    // TODO: Implement audiobook restore logic
  }

  Future<void> _restorePlaybackSession(Map<String, dynamic> json) async {
    // TODO: Implement playback session restore logic
  }

  Future<void> _restoreReadingList(Map<String, dynamic> json) async {
    // TODO: Implement reading list restore logic
  }
}
