/// Domain interface for conflict resolution operations.
library;

import 'package:flutbook/features/sync/data/models/conflict_model.dart';

/// Statistics about the current conflict state.
class ConflictStats {
  const ConflictStats({
    this.pendingCount = 0,
    this.resolvedCount = 0,
    this.autoResolvedCount = 0,
  });

  final int pendingCount;
  final int resolvedCount;
  final int autoResolvedCount;

  int get totalCount => pendingCount + resolvedCount + autoResolvedCount;
  bool get hasPending => pendingCount > 0;
}

/// Contract for conflict detection and resolution operations.
abstract class ConflictResolutionRepository {
  /// Record a detected conflict for later resolution.
  Future<void> recordConflict(SyncConflict conflict);

  /// Get all unresolved (pending) conflicts.
  Future<List<SyncConflict>> getPendingConflicts();

  /// Get the full conflict history including resolved conflicts.
  Future<List<SyncConflict>> getConflictHistory();

  /// Resolve a conflict using the given strategy.
  ///
  /// Returns the resolved [SyncConflict] with updated status.
  Future<SyncConflict> resolveConflict(
    String conflictId,
    ConflictResolutionStrategy strategy,
  );

  /// Auto-resolve all pending conflicts using last-write-wins.
  ///
  /// Returns the number of conflicts resolved.
  Future<int> autoResolveAll();

  /// Delete a specific conflict record by id.
  Future<void> deleteConflict(String conflictId);

  /// Remove all resolved conflicts from history.
  Future<void> clearResolvedConflicts();

  /// Get summary statistics about conflicts.
  Future<ConflictStats> getStats();
}
