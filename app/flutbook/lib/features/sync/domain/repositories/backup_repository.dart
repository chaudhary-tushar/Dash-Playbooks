/// Backup repository interface for cloud backup operations.
///
/// Defines the contract for backing up and restoring user data
/// to/from cloud storage.
library;

/// Backup status enumeration.
enum BackupStatus {
  /// No backup has been performed yet
  neverBackedUp,

  /// Backup is currently in progress
  backingUp,

  /// Restore is currently in progress
  restoring,

  /// Last backup was successful
  success,

  /// Last backup/restore failed
  failed,

  /// Backup is not available (offline or not authenticated)
  unavailable,
}

/// Backup result.
class BackupResult {
  const BackupResult({
    required this.status,
    this.backupSize = 0,
    this.itemCount = 0,
    this.errorMessage,
    this.timestamp,
  });

  final BackupStatus status;
  final int backupSize;
  final int itemCount;
  final String? errorMessage;
  final DateTime? timestamp;

  bool get isSuccess => status == BackupStatus.success;
  bool get hasError => status == BackupStatus.failed;

  BackupResult copyWith({
    BackupStatus? status,
    int? backupSize,
    int? itemCount,
    String? errorMessage,
    DateTime? timestamp,
  }) {
    return BackupResult(
      status: status ?? this.status,
      backupSize: backupSize ?? this.backupSize,
      itemCount: itemCount ?? this.itemCount,
      errorMessage: errorMessage ?? this.errorMessage,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

/// Restore result.
class RestoreResult {
  const RestoreResult({
    required this.status,
    this.restoredCount = 0,
    this.errorMessage,
    this.timestamp,
  });

  final BackupStatus status;
  final int restoredCount;
  final String? errorMessage;
  final DateTime? timestamp;

  bool get isSuccess => status == BackupStatus.success;
  bool get hasError => status == BackupStatus.failed;

  RestoreResult copyWith({
    BackupStatus? status,
    int? restoredCount,
    String? errorMessage,
    DateTime? timestamp,
  }) {
    return RestoreResult(
      status: status ?? this.status,
      restoredCount: restoredCount ?? this.restoredCount,
      errorMessage: errorMessage ?? this.errorMessage,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

/// Repository interface for cloud backup operations.
///
/// This interface defines the contract for backing up and restoring
/// user data to/from cloud storage.
abstract class BackupRepository {
  /// Create a full backup of user data.
  ///
  /// Backs up:
  /// - Library (audiobooks)
  /// - Playback positions
  /// - Reading lists
  /// - Bookmarks
  /// - User preferences
  ///
  /// Returns [BackupResult] with backup statistics.
  Future<BackupResult> createBackup();

  /// Restore user data from a backup.
  ///
  /// [backupId] - The ID of the backup to restore
  /// [overwrite] - If true, overwrite local data with backup data
  ///
  /// Returns [RestoreResult] with restore statistics.
  Future<RestoreResult> restoreBackup(String backupId, {bool overwrite = false});

  /// List available backups.
  ///
  /// Returns a list of backup IDs with timestamps.
  Future<List<BackupInfo>> listBackups();

  /// Get information about a specific backup.
  ///
  /// [backupId] - The ID of the backup
  Future<BackupInfo?> getBackupInfo(String backupId);

  /// Delete a backup.
  ///
  /// [backupId] - The ID of the backup to delete
  Future<void> deleteBackup(String backupId);

  /// Get the last backup timestamp.
  ///
  /// Returns null if no backup has been created.
  Future<DateTime?> getLastBackupTime();

  /// Check if backup is available (user authenticated and online).
  ///
  /// Returns true if backup operations can be performed.
  Future<bool> canBackup();

  /// Enable automatic backups.
  ///
  /// [frequency] - How often to create automatic backups (days)
  Future<void> enableAutomaticBackups({int frequency = 1});

  /// Disable automatic backups.
  Future<void> disableAutomaticBackups();

  /// Check if automatic backups are enabled.
  Future<bool> isAutomaticBackupEnabled();
}

/// Information about a backup.
class BackupInfo {
  const BackupInfo({
    required this.id,
    required this.timestamp,
    this.size = 0,
    this.itemCount = 0,
    this.type = BackupType.full,
  });

  final String id;
  final DateTime timestamp;
  final int size;
  final int itemCount;
  final BackupType type;

  String get formattedSize {
    if (size < 1024) {
      return '$size B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(1)} KB';
    } else if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  BackupInfo copyWith({
    String? id,
    DateTime? timestamp,
    int? size,
    int? itemCount,
    BackupType? type,
  }) {
    return BackupInfo(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      size: size ?? this.size,
      itemCount: itemCount ?? this.itemCount,
      type: type ?? this.type,
    );
  }
}

/// Type of backup.
enum BackupType {
  /// Full backup (all data)
  full,

  /// Incremental backup (changes since last backup)
  incremental,

  /// Differential backup (changes since last full backup)
  differential,
}
