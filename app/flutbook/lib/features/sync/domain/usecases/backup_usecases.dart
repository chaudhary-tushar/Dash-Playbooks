/// Use cases for cloud backup operations.
///
/// Provides business logic for creating and restoring backups.
library;

import 'package:flutbook/features/sync/domain/repositories/backup_repository.dart';

/// Use case for creating a backup.
class CreateBackupUseCase {
  /// Create a new CreateBackupUseCase.
  const CreateBackupUseCase({
    required BackupRepository repository,
  }) : _repository = repository;

  final BackupRepository _repository;

  /// Execute the use case.
  ///
  /// Creates a full backup of user data.
  /// Returns [BackupResult] with backup statistics.
  Future<BackupResult> execute() async {
    final canBackup = await _repository.canBackup();
    if (!canBackup) {
      return const BackupResult(
        status: BackupStatus.unavailable,
        errorMessage: 'Cannot create backup: User not authenticated or offline',
      );
    }

    return _repository.createBackup();
  }

  /// Check if backup is available.
  Future<bool> canBackup() => _repository.canBackup();
}

/// Use case for restoring from a backup.
class RestoreBackupUseCase {
  /// Create a new RestoreBackupUseCase.
  const RestoreBackupUseCase({
    required BackupRepository repository,
  }) : _repository = repository;

  final BackupRepository _repository;

  /// Execute the use case.
  ///
  /// [backupId] - The ID of the backup to restore
  /// [overwrite] - If true, overwrite local data with backup data
  ///
  /// Returns [RestoreResult] with restore statistics.
  Future<RestoreResult> execute(String backupId, {bool overwrite = false}) async {
    final canBackup = await _repository.canBackup();
    if (!canBackup) {
      return const RestoreResult(
        status: BackupStatus.unavailable,
        errorMessage: 'Cannot restore backup: User not authenticated or offline',
      );
    }

    return _repository.restoreBackup(backupId, overwrite: overwrite);
  }
}

/// Use case for listing available backups.
class ListBackupsUseCase {
  /// Create a new ListBackupsUseCase.
  const ListBackupsUseCase({
    required BackupRepository repository,
  }) : _repository = repository;

  final BackupRepository _repository;

  /// Execute the use case.
  ///
  /// Returns a list of available backups.
  Future<List<BackupInfo>> execute() async {
    return _repository.listBackups();
  }
}

/// Use case for getting backup information.
class GetBackupInfoUseCase {
  /// Create a new GetBackupInfoUseCase.
  const GetBackupInfoUseCase({
    required BackupRepository repository,
  }) : _repository = repository;

  final BackupRepository _repository;

  /// Execute the use case.
  ///
  /// [backupId] - The ID of the backup
  ///
  /// Returns backup information.
  Future<BackupInfo?> execute(String backupId) async {
    return _repository.getBackupInfo(backupId);
  }
}

/// Use case for deleting a backup.
class DeleteBackupUseCase {
  /// Create a new DeleteBackupUseCase.
  const DeleteBackupUseCase({
    required BackupRepository repository,
  }) : _repository = repository;

  final BackupRepository _repository;

  /// Execute the use case.
  ///
  /// [backupId] - The ID of the backup to delete
  Future<void> execute(String backupId) async {
    await _repository.deleteBackup(backupId);
  }
}

/// Use case for getting last backup time.
class GetLastBackupTimeUseCase {
  /// Create a new GetLastBackupTimeUseCase.
  const GetLastBackupTimeUseCase({
    required BackupRepository repository,
  }) : _repository = repository;

  final BackupRepository _repository;

  /// Execute the use case.
  ///
  /// Returns the timestamp of the last backup.
  Future<DateTime?> execute() async {
    return _repository.getLastBackupTime();
  }
}

/// Use case for managing automatic backups.
class ManageAutomaticBackupsUseCase {
  /// Create a new ManageAutomaticBackupsUseCase.
  const ManageAutomaticBackupsUseCase({
    required BackupRepository repository,
  }) : _repository = repository;

  final BackupRepository _repository;

  /// Enable automatic backups.
  ///
  /// [frequency] - How often to create automatic backups (days)
  Future<void> enable({int frequency = 1}) async {
    await _repository.enableAutomaticBackups(frequency: frequency);
  }

  /// Disable automatic backups.
  Future<void> disable() async {
    await _repository.disableAutomaticBackups();
  }

  /// Check if automatic backups are enabled.
  Future<bool> isEnabled() async {
    return _repository.isAutomaticBackupEnabled();
  }
}
