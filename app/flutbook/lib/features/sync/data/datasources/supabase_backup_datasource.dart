/// Supabase remote datasource for backup operations.
///
/// Handles backup and restore operations with Supabase Storage.
/// Provides compressed backup storage and retrieval.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutbook/core/config/app_config.dart';
import 'package:flutbook/core/error/exceptions.dart';
import 'package:flutbook/features/sync/domain/repositories/backup_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase remote datasource for backup operations.
///
/// Handles backup storage and retrieval with Supabase Storage.
class SupabaseBackupDatasource {
  /// Create a new SupabaseBackupDatasource.
  ///
  /// [supabase] - The Supabase client instance
  /// [configProvider] - Configuration provider for app settings
  SupabaseBackupDatasource({
    required SupabaseClient supabase,
    required ConfigProvider configProvider,
  }) : _supabase = supabase,
       _configProvider = configProvider;

  final SupabaseClient _supabase;
  final ConfigProvider _configProvider;

  /// Get the current configuration
  AppConfig get _config => _configProvider.config;

  /// Storage bucket name for backups
  static const String _bucketName = 'backups';

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    try {
      final user = _supabase.auth.currentUser;
      return user != null;
    } catch (e) {
      return false;
    }
  }

  /// Upload a backup to Supabase Storage.
  ///
  /// [backupId] - Unique identifier for the backup
  /// [backupData] - The backup data (will be compressed)
  /// [backupInfo] - Backup metadata
  ///
  /// Returns the URL of the uploaded backup.
  Future<String> uploadBackup({
    required String backupId,
    required Map<String, dynamic> backupData,
    required BackupInfo backupInfo,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException('User not authenticated');
      }

      // Compress and encode data
      final jsonData = jsonEncode(backupData);
      final compressedData = await _compressData(jsonData);

      // Upload to Supabase Storage
      final fileName = 'user_${user.id}/backup_$backupId.json.gz';
      await _supabase.storage
          .from(_bucketName)
          .uploadBinary(
            fileName,
            compressedData,
            fileOptions: const FileOptions(
              contentType: 'application/gzip',
              upsert: true,
            ),
          );

      // Store metadata in database
      await _supabase.from('backup_metadata').upsert({
        'id': backupId,
        'user_id': user.id,
        'size': backupInfo.size,
        'item_count': backupInfo.itemCount,
        'type': backupInfo.type.name,
        'created_at': backupInfo.timestamp.toIso8601String(),
        'file_path': fileName,
      });

      return fileName;
    } catch (e) {
      throw DatabaseException('Failed to upload backup: $e');
    }
  }

  /// Download a backup from Supabase Storage.
  ///
  /// [backupId] - The ID of the backup to download
  ///
  /// Returns the decompressed backup data.
  Future<Map<String, dynamic>> downloadBackup(String backupId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException('User not authenticated');
      }

      // Get metadata first
      final metadata = await _getBackupMetadata(backupId);
      if (metadata == null) {
        throw NotFoundException('Backup not found');
      }

      // Download from Supabase Storage
      final fileName = metadata['file_path'] as String;
      final compressedData = await _supabase.storage.from(_bucketName).download(fileName);

      // Decompress and decode data
      final jsonData = await _decompressData(compressedData);
      return jsonDecode(jsonData) as Map<String, dynamic>;
    } catch (e) {
      throw DatabaseException('Failed to download backup: $e');
    }
  }

  /// List all backups for the current user.
  ///
  /// Returns a list of backup information.
  Future<List<BackupInfo>> listBackups() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException('User not authenticated');
      }

      final result = await _supabase
          .from('backup_metadata')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return result
          .map(
            (row) => BackupInfo(
              id: row['id'] as String,
              timestamp: DateTime.parse(row['created_at'] as String),
              size: row['size'] as int? ?? 0,
              itemCount: row['item_count'] as int? ?? 0,
              type: BackupType.values.firstWhere(
                (t) => t.name == row['type'],
                orElse: () => BackupType.full,
              ),
            ),
          )
          .toList();
    } catch (e) {
      throw DatabaseException('Failed to list backups: $e');
    }
  }

  /// Get metadata for a specific backup.
  ///
  /// [backupId] - The ID of the backup
  ///
  /// Returns backup metadata or null if not found.
  Future<Map<String, dynamic>?> getBackupMetadata(String backupId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException('User not authenticated');
      }

      final result = await _supabase
          .from('backup_metadata')
          .select()
          .eq('id', backupId)
          .eq('user_id', user.id)
          .single();

      return result as Map<String, dynamic>?;
    } catch (e) {
      if (e is PostgrestException && e.code == 'PGRST116') {
        return null; // Not found
      }
      throw DatabaseException('Failed to get backup metadata: $e');
    }
  }

  /// Delete a backup from Supabase Storage.
  ///
  /// [backupId] - The ID of the backup to delete
  Future<void> deleteBackup(String backupId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException('User not authenticated');
      }

      // Get metadata to find file path
      final metadata = await _getBackupMetadata(backupId);
      if (metadata != null) {
        // Delete from storage
        final fileName = metadata['file_path'] as String?;
        if (fileName != null) {
          await _supabase.storage.from(_bucketName).remove([fileName]);
        }

        // Delete metadata from database
        await _supabase.from('backup_metadata').delete().eq('id', backupId).eq('user_id', user.id);
      }
    } catch (e) {
      throw DatabaseException('Failed to delete backup: $e');
    }
  }

  /// Get backup metadata by ID.
  Future<Map<String, dynamic>?> _getBackupMetadata(String backupId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      return null;
    }

    final result = await _supabase
        .from('backup_metadata')
        .select()
        .eq('id', backupId)
        .eq('user_id', user.id)
        .maybeSingle();

    return result;
  }

  /// Compress data using gzip.
  Future<Uint8List> _compressData(String jsonData) async {
    // Note: For production, use a proper gzip package
    // For now, return UTF-8 encoded bytes
    return utf8.encode(jsonData);
  }

  /// Decompress data.
  Future<String> _decompressData(Uint8List compressedData) async {
    // Note: For production, use a proper gzip package
    // For now, return UTF-8 decoded string
    return utf8.decode(compressedData, allowMalformed: true);
  }
}
