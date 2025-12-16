// lib/domain/usecases/sync_library_usecase.dart
import 'package:flutbook/features/auth/domain/repositories/user_repository.dart';

class SyncResult {
  const SyncResult({
    required this.success,
    required this.message,
    required this.itemsProcessed,
    this.hasConflicts = false,
    this.conflicts = const [],
    this.errorMessage,
  });
  final bool success;
  final String message;
  final int itemsProcessed;
  final bool hasConflicts;
  final List<SyncConflict> conflicts;
  final String? errorMessage;
}

class SyncConflict {
  const SyncConflict({
    required this.itemId,
    required this.type,
    required this.localData,
    required this.remoteData,
    required this.operationTimestamp,
  });
  final String itemId;
  final ConflictType type;
  final dynamic localData;
  final dynamic remoteData;
  final DateTime operationTimestamp;
}

enum ConflictType {
  metadataUpdate,
  progressUpdate,
  audiobookDelete,
  settingsUpdate,
}

enum ResolutionType { localWins, remoteWins }

class ConflictResolutionResult {
  const ConflictResolutionResult({
    required this.resolvedItems,
    required this.unresolvedConflicts,
    required this.strategyUsed,
    this.errorMessage,
  });
  final List<String> resolvedItems;
  final List<SyncConflict> unresolvedConflicts;
  final String strategyUsed;
  final String? errorMessage;

  bool get hasUnresolvedConflicts => unresolvedConflicts.isNotEmpty;
}

abstract class SyncLibraryUseCase {
  /// Syncs local library with remote storage
  Future<SyncResult> execute();

  /// Handles conflicts when local and remote data differ
  Future<ConflictResolutionResult> resolveConflicts(
    List<SyncConflict> conflicts,
  );
}

class SyncLibraryUseCaseImpl implements SyncLibraryUseCase {
  SyncLibraryUseCaseImpl({
    required UserRepository userRepository,
  }) : _userRepository = userRepository;
  final UserRepository _userRepository;

  @override
  Future<SyncResult> execute() async {
    try {
      // Get current sync status
      final syncStatus = await _userRepository.getSyncStatus();
      if (!syncStatus.syncEnabled) {
        return _createSyncResult(
          success: true,
          message: 'Sync is disabled for this user',
          itemsProcessed: 0,
        );
      }

      // Perform the actual sync
      final syncResult = await _userRepository.syncWithRemote();

      // Handle conflicts if they occurred
      if (syncResult.success && syncResult.itemsSynced > 0) {
        // For now, we'll assume no conflicts if sync was successful
        // In a real implementation, you'd need to check for conflicts
        return _createSyncResult(
          success: true,
          message: 'Sync completed successfully',
          itemsProcessed: syncResult.itemsSynced,
        );
      }

      return _createSyncResult(
        success: syncResult.success,
        message: syncResult.errorMessage ?? 'Sync completed',
        itemsProcessed: syncResult.itemsSynced,
        errorMessage: syncResult.errorMessage,
      );
    } catch (e) {
      return _createSyncResult(
        success: false,
        message: 'Sync failed: $e',
        itemsProcessed: 0,
        errorMessage: e.toString(),
      );
    }
  }

  @override
  Future<ConflictResolutionResult> resolveConflicts(
    List<SyncConflict> conflicts,
  ) async {
    try {
      final resolvedItems = <String>[];
      final unresolvedConflicts = <SyncConflict>[];

      for (final conflict in conflicts) {
        try {
          await _resolveSingleConflict(conflict);
          resolvedItems.add(conflict.itemId);
        } on ConflictResolutionFailedException {
          unresolvedConflicts.add(conflict);
        }
      }

      return _createConflictResolutionResult(
        resolvedItems: resolvedItems,
        unresolvedConflicts: unresolvedConflicts,
        strategyUsed: 'timestamp_based', // Always use timestamp-based resolution as per spec
      );
    } catch (e) {
      return _createConflictResolutionResult(
        resolvedItems: [],
        unresolvedConflicts: conflicts,
        strategyUsed: 'none',
        errorMessage: 'Conflict resolution failed: $e',
      );
    }
  }

  /// Resolves a single sync conflict using timestamp-based strategy (favors newer timestamp)
  Future<SyncConflict> _resolveSingleConflict(SyncConflict conflict) async {
    try {
      switch (conflict.type) {
        case ConflictType.metadataUpdate:
          // For metadata updates, use the most recent timestamp
          final localTimestamp =
              (conflict.localData as Map<String, dynamic>)['lastModifiedAt'] as DateTime;
          final remoteTimestamp =
              (conflict.remoteData as Map<String, dynamic>)['lastModifiedAt'] as DateTime;

          if (localTimestamp.isAfter(remoteTimestamp)) {
            // Local is newer, update remote with local data
            await _userRepository.updateRemoteData(
              conflict.itemId,
              conflict.localData,
            );
            return _createResolvedConflict(
              itemId: conflict.itemId,
              resolution: ResolutionType.localWins,
            );
          } else {
            // Remote is newer, update local with remote data
            await _userRepository.updateLocalData(
              conflict.itemId,
              conflict.remoteData,
            );
            return _createResolvedConflict(
              itemId: conflict.itemId,
              resolution: ResolutionType.remoteWins,
            );
          }

        case ConflictType.progressUpdate:
          // For progress updates, use the most recent timestamp as per specification
          final localTimestamp =
              (conflict.localData as Map<String, dynamic>)['lastModifiedAt'] as DateTime;
          final remoteTimestamp =
              (conflict.remoteData as Map<String, dynamic>)['lastModifiedAt'] as DateTime;

          if (localTimestamp.isAfter(remoteTimestamp)) {
            // Local is newer, update remote with local progress
            await _userRepository.updateRemoteProgress(
              conflict.itemId,
              (conflict.localData as Map<String, dynamic>)['lastPosition'] as int,
            );
            return _createResolvedConflict(
              itemId: conflict.itemId,
              resolution: ResolutionType.localWins,
            );
          } else {
            // Remote is newer, update local with remote progress
            await _userRepository.updateLocalProgress(
              conflict.itemId,
              (conflict.remoteData as Map<String, dynamic>)['lastPosition'] as int,
            );
            return _createResolvedConflict(
              itemId: conflict.itemId,
              resolution: ResolutionType.remoteWins,
            );
          }

        case ConflictType.audiobookDelete:
          // For deletions, the deletion timestamp is most important
          final deletionTimestamp = conflict.operationTimestamp;
          final remoteTimestamp =
              (conflict.remoteData as Map<String, dynamic>)['lastModifiedAt'] as DateTime;

          if (deletionTimestamp.isAfter(remoteTimestamp)) {
            // Local deletion is more recent, ensure remote deletion
            await _userRepository.deleteRemoteAudiobook(conflict.itemId);
            return _createResolvedConflict(
              itemId: conflict.itemId,
              resolution: ResolutionType.localWins,
            );
          } else {
            // Remote deletion is more recent, sync to local
            await _userRepository.deleteLocalAudiobook(conflict.itemId);
            return _createResolvedConflict(
              itemId: conflict.itemId,
              resolution: ResolutionType.remoteWins,
            );
          }

        case ConflictType.settingsUpdate:
          // For settings updates, default to timestamp-based resolution
          final localTimestamp =
              (conflict.localData as Map<String, dynamic>)['lastModifiedAt'] as DateTime;
          final remoteTimestamp =
              (conflict.remoteData as Map<String, dynamic>)['lastModifiedAt'] as DateTime;

          final shouldUseLocal = localTimestamp.isAfter(remoteTimestamp);

          if (shouldUseLocal) {
            await _uploadLocalChanges(conflict.itemId, conflict.localData);
            return _createResolvedConflict(
              itemId: conflict.itemId,
              resolution: ResolutionType.localWins,
            );
          } else {
            await _applyRemoteChanges(conflict.itemId, conflict.remoteData);
            return _createResolvedConflict(
              itemId: conflict.itemId,
              resolution: ResolutionType.remoteWins,
            );
          }
      }
    } catch (e) {
      throw ConflictResolutionFailedException(
        conflictId: conflict.itemId,
        reason: e.toString(),
      );
    }
  }

  /// Uploads local changes to remote storage
  Future<void> _uploadLocalChanges(String itemId, dynamic localData) async {
    // Implementation depends on the type of data
    // This would call the appropriate repository method to update remote
    await _userRepository.updateRemoteData(itemId, localData);
  }

  /// Applies remote changes to local storage
  Future<void> _applyRemoteChanges(String itemId, dynamic remoteData) async {
    // Implementation depends on the type of data
    // This would call the appropriate repository method to update local
    await _userRepository.updateLocalData(itemId, remoteData);
  }

  SyncResult _createSyncResult({
    required bool success,
    required String message,
    required int itemsProcessed,
    String? errorMessage,
  }) {
    return SyncResult(
      success: success,
      message: message,
      itemsProcessed: itemsProcessed,
      errorMessage: errorMessage,
    );
  }

  ConflictResolutionResult _createConflictResolutionResult({
    required List<String> resolvedItems,
    required List<SyncConflict> unresolvedConflicts,
    required String strategyUsed,
    String? errorMessage,
  }) {
    return ConflictResolutionResult(
      resolvedItems: resolvedItems,
      unresolvedConflicts: unresolvedConflicts,
      strategyUsed: strategyUsed,
      errorMessage: errorMessage,
    );
  }

  SyncConflict _createResolvedConflict({
    required String itemId,
    required ResolutionType resolution,
  }) {
    // Placeholder for resolved conflict creation
    throw UnimplementedError(
      'Resolved conflict creation requires actual implementation',
    );
  }
}

/// Exception thrown when conflict resolution fails
class ConflictResolutionFailedException implements Exception {
  const ConflictResolutionFailedException({
    required this.conflictId,
    required this.reason,
  });
  final String conflictId;
  final String reason;

  @override
  String toString() =>
      'ConflictResolutionFailedException: Conflict $conflictId failed because: $reason';
}
