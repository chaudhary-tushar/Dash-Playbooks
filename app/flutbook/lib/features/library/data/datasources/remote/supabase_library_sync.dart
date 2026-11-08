/// Supabase remote datasource for library synchronization.
///
/// This datasource replaces Firebase Firestore for audiobook metadata storage
/// and synchronization, providing real-time sync capabilities with Supabase.
library;

import 'package:flutbook/core/config/app_config.dart';
import 'package:flutbook/core/error/exceptions.dart';
import 'package:flutbook/features/library/data/models/audiobook_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// Supabase remote datasource for library operations.
///
/// Handles audiobook metadata synchronization with Supabase PostgreSQL database.
/// Provides real-time synchronization capabilities and offline-first approach.
class SupabaseLibraryDatasource {
  /// Create a new SupabaseLibraryDatasource.
  ///
  /// [supabase] - The Supabase client instance
  /// [configProvider] - Configuration provider for app settings
  SupabaseLibraryDatasource({
    required SupabaseClient supabase,
    required ConfigProvider configProvider,
  }) : _supabase = supabase,
       _configProvider = configProvider;
  final SupabaseClient _supabase;
  final ConfigProvider _configProvider;
  final _uuid = const Uuid();

  /// Get the current configuration
  AppConfig get _config => _configProvider.config;

  /// Uploads audiobook metadata to Supabase
  Future<void> uploadAudiobookMetadata(AudiobookModel audiobook) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException('User not authenticated');
      }

      final data = {
        'user_id': user.id,
        'title': audiobook.title,
        'author': audiobook.author,
        'album': audiobook.album,
        'cover_art_path': audiobook.coverArtPath,
        'duration_ms': audiobook.duration.inMilliseconds,
        'file_path': audiobook.filePath,
        'created_at': audiobook.createdAt,
        'last_played_at': audiobook.lastPlayedAt,
        'completed': audiobook.completed,
        'total_size': audiobook.totalSize,
        'updated_at': DateTime.now(),
      };

      // Match on (user_id, file_path) — the stable identity used throughout
      // sync — rather than the client internalId. A locally-scanned book's
      // internalId is a file path, which would never match the remote UUID
      // primary key, causing a spurious insert or a PK violation (m6).
      final updateResult = await _supabase
          .from('audiobooks')
          .update(data)
          .eq('user_id', user.id)
          .eq('file_path', audiobook.filePath);

      if (updateResult.length == 0) {
        // No existing row for this file - insert a new one. Use a valid UUID
        // id: reuse a stored internalId only when it is itself a UUID
        // (e.g. a book originally downloaded from remote), otherwise generate
        // a fresh one instead of violating the UUID primary key with a path.
        data['id'] = _remoteIdFor(audiobook.internalId);
        await _supabase.from('audiobooks').insert(data);
      }
    } catch (e) {
      throw DatabaseException('Failed to upload audiobook metadata: $e');
    }
  }

  /// Returns a valid UUID to use as the remote record id.
  ///
  /// Reuses [internalId] only if it is itself a valid UUID (the case for a
  /// book that was downloaded from remote); otherwise generates a fresh one.
  /// This prevents a file-path string from being used as the UUID primary key.
  static final _uuidPattern = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  String _remoteIdFor(String? internalId) {
    final id = internalId;
    if (id != null && _uuidPattern.hasMatch(id)) {
      return id;
    }
    return _uuid.v4();
  }

  /// Gets audiobook metadata from Supabase
  Future<List<AudiobookModel>> getAudiobookMetadata() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException('User not authenticated');
      }

      final result = await _supabase
          .from('audiobooks')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      final audiobooks = <AudiobookModel>[];
      for (final row in result) {
        final audiobook = AudiobookModel(
          internalId: row['id'] as String? ?? '',
          title: row['title'] as String? ?? '',
          author: row['author'] as String? ?? '',
          album: row['album'] as String? ?? '',
          coverArtPath: row['cover_art_path'] as String?,
          durationInMs: (row['duration_ms'] as num?)?.toInt() ?? 0,
          filePath: row['file_path'] as String? ?? '',
          chapters: [], // Chapters would be loaded separately if needed
          createdAt: (row['created_at'] as DateTime?) ?? DateTime.now(),
          lastPlayedAt: row['last_played_at'] as DateTime?,
          completed: row['completed'] as bool? ?? false,
          totalSize: (row['total_size'] as num?)?.toInt() ?? 0,
        );

        audiobooks.add(audiobook);
      }

      return audiobooks;
    } catch (e) {
      throw DatabaseException('Failed to retrieve audiobook metadata: $e');
    }
  }

  /// Deletes audiobook metadata from Supabase
  Future<void> deleteAudiobookMetadata(String audiobookId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException('User not authenticated');
      }

      await _supabase
          .from('audiobooks')
          .delete()
          .eq('id', audiobookId)
          .eq('user_id', user.id);
    } catch (e) {
      throw DatabaseException('Failed to delete audiobook metadata: $e');
    }
  }

  /// Gets audiobook by ID
  Future<AudiobookModel?> getAudiobookById(String audiobookId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException('User not authenticated');
      }

      final result = await _supabase
          .from('audiobooks')
          .select()
          .eq('id', audiobookId)
          .eq('user_id', user.id)
          .maybeSingle();

      if (result == null) {
        return null;
      }

      return AudiobookModel(
        internalId: result['id'] as String? ?? '',
        title: result['title'] as String? ?? '',
        author: result['author'] as String? ?? '',
        album: result['album'] as String? ?? '',
        coverArtPath: result['cover_art_path'] as String?,
        durationInMs: (result['duration_ms'] as num?)?.toInt() ?? 0,
        filePath: result['file_path'] as String? ?? '',
        chapters: [],
        createdAt: (result['created_at'] as DateTime?) ?? DateTime.now(),
        lastPlayedAt: result['last_played_at'] as DateTime?,
        completed: result['completed'] as bool? ?? false,
        totalSize: (result['total_size'] as num?)?.toInt() ?? 0,
      );
    } catch (e) {
      throw DatabaseException('Failed to retrieve audiobook: $e');
    }
  }

  /// Updates audiobook last played time
  Future<void> updateLastPlayedTime(String audiobookId, DateTime time) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException('User not authenticated');
      }

      await _supabase
          .from('audiobooks')
          .update({'last_played_at': time, 'updated_at': DateTime.now()})
          .eq('id', audiobookId)
          .eq('user_id', user.id);
    } catch (e) {
      throw DatabaseException('Failed to update last played time: $e');
    }
  }

  /// Marks audiobook as completed
  Future<void> markAsCompleted(String audiobookId, bool completed) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException('User not authenticated');
      }

      await _supabase
          .from('audiobooks')
          .update({'completed': completed, 'updated_at': DateTime.now()})
          .eq('id', audiobookId)
          .eq('user_id', user.id);
    } catch (e) {
      throw DatabaseException('Failed to mark audiobook as completed: $e');
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    try {
      final user = _supabase.auth.currentUser;
      return user != null;
    } catch (e) {
      return false;
    }
  }
}
