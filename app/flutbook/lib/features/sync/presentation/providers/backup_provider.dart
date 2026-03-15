/// Backup provider for state management.
///
/// Provides state management for backup operations including:
/// - Create backup
/// - Restore from backup
/// - List backups
/// - Delete backup
/// - Automatic backup settings
library;

import 'package:flutbook/core/provider/providers.dart';
import 'package:flutbook/features/sync/domain/repositories/backup_repository.dart';
import 'package:flutbook/features/sync/domain/usecases/backup_usecases.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Backup state.
class BackupState {
  const BackupState({
    this.status = BackupStatus.neverBackedUp,
    this.lastBackupTime,
    this.availableBackups = const [],
    this.isBackingUp = false,
    this.isRestoring = false,
    this.errorMessage,
    this.lastBackupSize = 0,
    this.lastBackupItemCount = 0,
  });

  final BackupStatus status;
  final DateTime? lastBackupTime;
  final List<BackupInfo> availableBackups;
  final bool isBackingUp;
  final bool isRestoring;
  final String? errorMessage;
  final int lastBackupSize;
  final int lastBackupItemCount;

  bool get hasBackups => availableBackups.isNotEmpty;
  BackupInfo? get latestBackup => availableBackups.isNotEmpty ? availableBackups.first : null;
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  BackupState copyWith({
    BackupStatus? status,
    DateTime? lastBackupTime,
    List<BackupInfo>? availableBackups,
    bool? isBackingUp,
    bool? isRestoring,
    String? errorMessage,
    int? lastBackupSize,
    int? lastBackupItemCount,
  }) {
    return BackupState(
      status: status ?? this.status,
      lastBackupTime: lastBackupTime ?? this.lastBackupTime,
      availableBackups: availableBackups ?? this.availableBackups,
      isBackingUp: isBackingUp ?? this.isBackingUp,
      isRestoring: isRestoring ?? this.isRestoring,
      errorMessage: errorMessage ?? this.errorMessage,
      lastBackupSize: lastBackupSize ?? this.lastBackupSize,
      lastBackupItemCount: lastBackupItemCount ?? this.lastBackupItemCount,
    );
  }
}

/// Notifier for managing backup state.
class BackupNotifier extends Notifier<BackupState> {
  /// Create a new BackupNotifier.
  BackupNotifier();

  @override
  BackupState build() {
    return const BackupState();
  }

  /// Get the create backup use case.
  CreateBackupUseCase get _createBackupUseCase {
    return ref.read(createBackupUseCaseProvider);
  }

  /// Get the restore backup use case.
  RestoreBackupUseCase get _restoreBackupUseCase {
    return ref.read(restoreBackupUseCaseProvider);
  }

  /// Get the list backups use case.
  ListBackupsUseCase get _listBackupsUseCase {
    return ref.read(listBackupsUseCaseProvider);
  }

  /// Get the delete backup use case.
  DeleteBackupUseCase get _deleteBackupUseCase {
    return ref.read(deleteBackupUseCaseProvider);
  }

  /// Get the last backup time use case.
  GetLastBackupTimeUseCase get _getLastBackupTimeUseCase {
    return ref.read(getLastBackupTimeUseCaseProvider);
  }

  /// Get the manage automatic backups use case.
  ManageAutomaticBackupsUseCase get _manageAutomaticBackupsUseCase {
    return ref.read(manageAutomaticBackupsUseCaseProvider);
  }

  /// Load available backups.
  Future<void> loadBackups() async {
    try {
      final backups = await _listBackupsUseCase.execute();
      final lastBackupTime = await _getLastBackupTimeUseCase.execute();

      state = state.copyWith(
        availableBackups: backups,
        lastBackupTime: lastBackupTime,
        status: lastBackupTime != null ? BackupStatus.success : BackupStatus.neverBackedUp,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to load backups: $e',
        status: BackupStatus.failed,
      );
    }
  }

  /// Create a new backup.
  Future<BackupResult> createBackup() async {
    state = state.copyWith(
      isBackingUp: true,
    );

    try {
      final result = await _createBackupUseCase.execute();

      if (result.isSuccess) {
        await loadBackups();
        state = state.copyWith(
          isBackingUp: false,
          status: BackupStatus.success,
          lastBackupTime: result.timestamp,
          lastBackupSize: result.backupSize,
          lastBackupItemCount: result.itemCount,
        );
      } else {
        state = state.copyWith(
          isBackingUp: false,
          status: BackupStatus.failed,
          errorMessage: result.errorMessage,
        );
      }

      return result;
    } catch (e) {
      state = state.copyWith(
        isBackingUp: false,
        status: BackupStatus.failed,
        errorMessage: 'Failed to create backup: $e',
      );

      return BackupResult(
        status: BackupStatus.failed,
        errorMessage: 'Failed to create backup: $e',
        timestamp: DateTime.now(),
      );
    }
  }

  /// Restore from a backup.
  Future<RestoreResult> restoreBackup(String backupId, {bool overwrite = false}) async {
    state = state.copyWith(
      isRestoring: true,
    );

    try {
      final result = await _restoreBackupUseCase.execute(backupId, overwrite: overwrite);

      if (result.isSuccess) {
        await loadBackups();
        state = state.copyWith(
          isRestoring: false,
          status: BackupStatus.success,
        );
      } else {
        state = state.copyWith(
          isRestoring: false,
          status: BackupStatus.failed,
          errorMessage: result.errorMessage,
        );
      }

      return result;
    } catch (e) {
      state = state.copyWith(
        isRestoring: false,
        status: BackupStatus.failed,
        errorMessage: 'Failed to restore backup: $e',
      );

      return RestoreResult(
        status: BackupStatus.failed,
        errorMessage: 'Failed to restore backup: $e',
        timestamp: DateTime.now(),
      );
    }
  }

  /// Delete a backup.
  Future<void> deleteBackup(String backupId) async {
    try {
      await _deleteBackupUseCase.execute(backupId);
      await loadBackups();
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to delete backup: $e',
      );
    }
  }

  /// Enable automatic backups.
  Future<void> enableAutomaticBackups({int frequency = 1}) async {
    try {
      await _manageAutomaticBackupsUseCase.enable(frequency: frequency);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to enable automatic backups: $e',
      );
    }
  }

  /// Disable automatic backups.
  Future<void> disableAutomaticBackups() async {
    try {
      await _manageAutomaticBackupsUseCase.disable();
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to disable automatic backups: $e',
      );
    }
  }

  /// Clear error state.
  void clearError() {
    state = state.copyWith();
  }
}

/// Provider for backup state management.
final backupProvider = NotifierProvider<BackupNotifier, BackupState>(
  BackupNotifier.new,
);

// =============================================================================
// USE CASE PROVIDERS
// =============================================================================

/// Provides CreateBackupUseCase.
final createBackupUseCaseProvider = Provider<CreateBackupUseCase>((ref) {
  final repoAsync = ref.read(backupRepositoryProvider);
  final repo = repoAsync.value;
  if (repo == null) {
    throw Exception('Backup repository not initialized');
  }
  return CreateBackupUseCase(repository: repo);
});

/// Provides RestoreBackupUseCase.
final restoreBackupUseCaseProvider = Provider<RestoreBackupUseCase>((ref) {
  final repoAsync = ref.read(backupRepositoryProvider);
  final repo = repoAsync.value;
  if (repo == null) {
    throw Exception('Backup repository not initialized');
  }
  return RestoreBackupUseCase(repository: repo);
});

/// Provides ListBackupsUseCase.
final listBackupsUseCaseProvider = Provider<ListBackupsUseCase>((ref) {
  final repoAsync = ref.read(backupRepositoryProvider);
  final repo = repoAsync.value;
  if (repo == null) {
    throw Exception('Backup repository not initialized');
  }
  return ListBackupsUseCase(repository: repo);
});

/// Provides DeleteBackupUseCase.
final deleteBackupUseCaseProvider = Provider<DeleteBackupUseCase>((ref) {
  final repoAsync = ref.read(backupRepositoryProvider);
  final repo = repoAsync.value;
  if (repo == null) {
    throw Exception('Backup repository not initialized');
  }
  return DeleteBackupUseCase(repository: repo);
});

/// Provides GetLastBackupTimeUseCase.
final getLastBackupTimeUseCaseProvider = Provider<GetLastBackupTimeUseCase>((ref) {
  final repoAsync = ref.read(backupRepositoryProvider);
  final repo = repoAsync.value;
  if (repo == null) {
    throw Exception('Backup repository not initialized');
  }
  return GetLastBackupTimeUseCase(repository: repo);
});

/// Provides ManageAutomaticBackupsUseCase.
final manageAutomaticBackupsUseCaseProvider = Provider<ManageAutomaticBackupsUseCase>((ref) {
  final repoAsync = ref.read(backupRepositoryProvider);
  final repo = repoAsync.value;
  if (repo == null) {
    throw Exception('Backup repository not initialized');
  }
  return ManageAutomaticBackupsUseCase(repository: repo);
});
