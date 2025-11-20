// lib/domain/usecases/sync_library_usecase.dart
import 'package:flutbook/domain/repositories/audiobook_repository.dart';
import 'package:flutbook/domain/repositories/user_repository.dart';

abstract class SyncResult {
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

abstract class SyncConflict {
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

enum ConflictType { metadata_update, progress_update, audiobook_delete, settings_update }

enum ResolutionType { localWins, remoteWins }

abstract class ConflictResolutionResult {
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
  Future<ConflictResolutionResult> resolveConflicts(List<SyncConflict> conflicts);
}

class SyncLibraryUseCaseImpl implements SyncLibraryUseCase {
  SyncLibraryUseCaseImpl({
    required UserRepository userRepository,
    required AudiobookRepository audiobookRepository,
  }) : _userRepository = userRepository,
       _audiobookRepository = audiobookRepository;
  final UserRepository _userRepository;
  final AudiobookRepository _audiobookRepository;

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
      if (syncResult.hasConflicts) {
        final resolutionResult = await resolveConflicts(syncResult.conflicts);
        if (resolutionResult.hasUnresolvedConflicts) {
          return _createSyncResult(
            success: true, // Still successful but with warnings
            message:
                'Sync completed with unresolved conflicts. ${resolutionResult.resolvedItems.length} conflicts resolved, ${resolutionResult.unresolvedConflicts.length} remain.',
            itemsProcessed: syncResult.itemsProcessed,
            hasConflicts: true,
            conflicts: resolutionResult.unresolvedConflicts,
          );
        }
      }

      return syncResult;
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
  Future<ConflictResolutionResult> resolveConflicts(List<SyncConflict> conflicts) async {
    try {
      final resolvedItems = <String>[];
      final unresolvedConflicts = <SyncConflict>[];

      for (final conflict in conflicts) {
        try {
          final resolvedConflict = await _resolveSingleConflict(conflict);
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
        case ConflictType.metadata_update:
          // For metadata updates, use the most recent timestamp
          final localTimestamp = conflict.localData.lastModifiedAt;
          final remoteTimestamp = conflict.remoteData.lastModifiedAt;

          if (localTimestamp.isAfter(remoteTimestamp)) {
            // Local is newer, update remote with local data
            await _userRepository.updateRemoteData(conflict.itemId, conflict.localData);
            return _createResolvedConflict(
              itemId: conflict.itemId,
              resolution: ResolutionType.localWins,
              resolvedData: conflict.localData,
            );
          } else {
            // Remote is newer, update local with remote data
            await _userRepository.updateLocalData(conflict.itemId, conflict.remoteData);
            return _createResolvedConflict(
              itemId: conflict.itemId,
              resolution: ResolutionType.remoteWins,
              resolvedData: conflict.remoteData,
            );
          }

        case ConflictType.progress_update:
          // For progress updates, use the most recent timestamp as per specification
          final localTimestamp = conflict.localData.lastModifiedAt;
          final remoteTimestamp = conflict.remoteData.lastModifiedAt;

          if (localTimestamp.isAfter(remoteTimestamp)) {
            // Local is newer, update remote with local progress
            await _userRepository.updateRemoteProgress(
              conflict.itemId,
              conflict.localData.lastPosition,
            );
            return _createResolvedConflict(
              itemId: conflict.itemId,
              resolution: ResolutionType.localWins,
              resolvedData: conflict.localData,
            );
          } else {
            // Remote is newer, update local with remote progress
            await _userRepository.updateLocalProgress(
              conflict.itemId,
              conflict.remoteData.lastPosition,
            );
            return _createResolvedConflict(
              itemId: conflict.itemId,
              resolution: ResolutionType.remoteWins,
              resolvedData: conflict.remoteData,
            );
          }

        case ConflictType.audiobook_delete:
          // For deletions, the deletion timestamp is most important
          final deletionTimestamp = conflict.operationTimestamp;
          final remoteTimestamp = conflict.remoteData.lastModifiedAt;

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

        default:
          // For other conflict types, default to timestamp-based resolution
          final localTimestamp = conflict.localData.lastModifiedAt;
          final remoteTimestamp = conflict.remoteData.lastModifiedAt;

          final shouldUseLocal = localTimestamp.isAfter(remoteTimestamp);

          if (shouldUseLocal) {
            await _uploadLocalChanges(conflict.itemId, conflict.localData);
            return _createResolvedConflict(
              itemId: conflict.itemId,
              resolution: ResolutionType.localWins,
              resolvedData: conflict.localData,
            );
          } else {
            await _applyRemoteChanges(conflict.itemId, conflict.remoteData);
            return _createResolvedConflict(
              itemId: conflict.itemId,
              resolution: ResolutionType.remoteWins,
              resolvedData: conflict.remoteData,
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
    bool hasConflicts = false,
    List<SyncConflict> conflicts = const [],
    String? errorMessage,
  }) {
    return SyncResult(
      success: success,
      message: message,
      itemsProcessed: itemsProcessed,
      hasConflicts: hasConflicts,
      conflicts: conflicts,
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
    dynamic resolvedData,
  }) {
    // Placeholder for resolved conflict creation
    throw UnimplementedError('Resolved conflict creation requires actual implementation');
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
