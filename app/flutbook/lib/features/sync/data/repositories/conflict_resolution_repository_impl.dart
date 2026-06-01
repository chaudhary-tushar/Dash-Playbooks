/// Implementation of the conflict resolution repository.
library;

import 'package:flutbook/features/sync/data/datasources/conflict_resolver_ds.dart';
import 'package:flutbook/features/sync/data/models/conflict_model.dart';
import 'package:flutbook/features/sync/domain/repositories/conflict_resolution_repository.dart';

/// Implements conflict detection, recording, and resolution logic.
///
/// Resolution strategies:
/// - [ConflictResolutionStrategy.lastWriteWins] — picks whichever version
///   has the newer timestamp (default automatic strategy).
/// - [ConflictResolutionStrategy.localWins] — always keep local data.
/// - [ConflictResolutionStrategy.remoteWins] — always keep remote data.
/// - [ConflictResolutionStrategy.manual] — preserves both versions in
///   [SyncConflict.resolvedData] so the caller can merge them.
class ConflictResolutionRepositoryImpl implements ConflictResolutionRepository {
  ConflictResolutionRepositoryImpl({required ConflictResolverDatasource datasource})
      : _ds = datasource;

  final ConflictResolverDatasource _ds;

  @override
  Future<void> recordConflict(SyncConflict conflict) => _ds.saveConflict(conflict);

  @override
  Future<List<SyncConflict>> getPendingConflicts() => _ds.getPendingConflicts();

  @override
  Future<List<SyncConflict>> getConflictHistory() => _ds.getAllConflicts();

  @override
  Future<SyncConflict> resolveConflict(
    String conflictId,
    ConflictResolutionStrategy strategy,
  ) async {
    final conflict = await _ds.getConflict(conflictId);
    if (conflict == null) {
      throw StateError('Conflict $conflictId not found');
    }

    final resolvedData = _pickResolution(conflict, strategy);
    final resolved = conflict.copyWith(
      status: _statusFor(strategy),
      resolutionStrategy: strategy,
      resolvedAt: DateTime.now(),
      resolvedData: resolvedData,
    );
    await _ds.saveConflict(resolved);
    return resolved;
  }

  @override
  Future<int> autoResolveAll() async {
    final pending = await _ds.getPendingConflicts();
    for (final conflict in pending) {
      await resolveConflict(conflict.id, ConflictResolutionStrategy.lastWriteWins);
    }
    return pending.length;
  }

  @override
  Future<void> deleteConflict(String conflictId) => _ds.deleteConflict(conflictId);

  @override
  Future<void> clearResolvedConflicts() => _ds.clearResolved();

  @override
  Future<ConflictStats> getStats() async {
    final pending = await _ds.getPendingCount();
    final all = await _ds.getAllConflicts();
    final autoResolved = all
        .where((c) => c.status == ConflictStatus.autoResolved)
        .length;
    final resolved = all.where((c) => c.isResolved).length - autoResolved;
    return ConflictStats(
      pendingCount: pending,
      resolvedCount: resolved,
      autoResolvedCount: autoResolved,
    );
  }

  // ── helpers ────────────────────────────────────────────────────────────────

  Map<String, dynamic> _pickResolution(
    SyncConflict conflict,
    ConflictResolutionStrategy strategy,
  ) {
    switch (strategy) {
      case ConflictResolutionStrategy.localWins:
        return conflict.localData;
      case ConflictResolutionStrategy.remoteWins:
        return conflict.remoteData;
      case ConflictResolutionStrategy.manual:
        // Return both so the UI can merge; caller is responsible for applying
        return {'local': conflict.localData, 'remote': conflict.remoteData};
      case ConflictResolutionStrategy.lastWriteWins:
        return conflict.isLocalNewer ? conflict.localData : conflict.remoteData;
    }
  }

  ConflictStatus _statusFor(ConflictResolutionStrategy strategy) {
    switch (strategy) {
      case ConflictResolutionStrategy.localWins:
        return ConflictStatus.resolvedLocal;
      case ConflictResolutionStrategy.remoteWins:
        return ConflictStatus.resolvedRemote;
      case ConflictResolutionStrategy.manual:
        return ConflictStatus.resolvedMerged;
      case ConflictResolutionStrategy.lastWriteWins:
        return ConflictStatus.autoResolved;
    }
  }
}
