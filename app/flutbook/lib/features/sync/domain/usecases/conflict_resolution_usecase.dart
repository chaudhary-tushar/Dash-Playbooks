/// Use cases for detecting, querying, and resolving sync conflicts.
library;

import 'package:flutbook/features/sync/data/models/conflict_model.dart';
import 'package:flutbook/features/sync/domain/repositories/conflict_resolution_repository.dart';

/// Record a new conflict detected during a sync operation.
class RecordConflictUseCase {
  const RecordConflictUseCase(this._repo);

  final ConflictResolutionRepository _repo;

  Future<void> execute(SyncConflict conflict) => _repo.recordConflict(conflict);
}

/// Return all conflicts that still need user attention.
class GetPendingConflictsUseCase {
  const GetPendingConflictsUseCase(this._repo);

  final ConflictResolutionRepository _repo;

  Future<List<SyncConflict>> execute() => _repo.getPendingConflicts();
}

/// Return the full conflict history (pending + resolved).
class GetConflictHistoryUseCase {
  const GetConflictHistoryUseCase(this._repo);

  final ConflictResolutionRepository _repo;

  Future<List<SyncConflict>> execute() => _repo.getConflictHistory();
}

/// Resolve a single conflict using the given strategy.
class ResolveConflictUseCase {
  const ResolveConflictUseCase(this._repo);

  final ConflictResolutionRepository _repo;

  Future<SyncConflict> execute(
    String conflictId,
    ConflictResolutionStrategy strategy,
  ) =>
      _repo.resolveConflict(conflictId, strategy);
}

/// Automatically resolve all pending conflicts with last-write-wins.
class AutoResolveConflictsUseCase {
  const AutoResolveConflictsUseCase(this._repo);

  final ConflictResolutionRepository _repo;

  Future<int> execute() => _repo.autoResolveAll();
}

/// Remove all resolved conflict records to keep history clean.
class ClearResolvedConflictsUseCase {
  const ClearResolvedConflictsUseCase(this._repo);

  final ConflictResolutionRepository _repo;

  Future<void> execute() => _repo.clearResolvedConflicts();
}

/// Return aggregate statistics about conflicts.
class GetConflictStatsUseCase {
  const GetConflictStatsUseCase(this._repo);

  final ConflictResolutionRepository _repo;

  Future<ConflictStats> execute() => _repo.getStats();
}
