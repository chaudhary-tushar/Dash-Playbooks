/// In-memory datasource for conflict records.
///
/// Stores conflict records during the app's lifetime.
/// Future enhancement: persist to Isar for cross-session history.
library;

import 'package:flutbook/features/sync/data/models/conflict_model.dart';
import 'package:uuid/uuid.dart';

/// Local datasource that holds conflict records in memory.
class ConflictResolverDatasource {
  ConflictResolverDatasource();

  final _conflicts = <String, SyncConflict>{};
  final _uuid = const Uuid();

  /// Generate a new unique conflict ID.
  String generateId() => _uuid.v4();

  /// Save a conflict record (insert or update).
  Future<void> saveConflict(SyncConflict conflict) async {
    _conflicts[conflict.id] = conflict;
  }

  /// Retrieve a single conflict by ID. Returns null if not found.
  Future<SyncConflict?> getConflict(String id) async {
    return _conflicts[id];
  }

  /// Return all stored conflicts ordered by localTimestamp descending.
  Future<List<SyncConflict>> getAllConflicts() async {
    final list = _conflicts.values.toList()
      ..sort((a, b) => b.localTimestamp.compareTo(a.localTimestamp));
    return list;
  }

  /// Return only conflicts with [ConflictStatus.pending].
  Future<List<SyncConflict>> getPendingConflicts() async {
    final all = await getAllConflicts();
    return all.where((c) => c.isPending).toList();
  }

  /// Delete a conflict record by ID.
  Future<void> deleteConflict(String id) async {
    _conflicts.remove(id);
  }

  /// Remove all resolved conflict records, keeping only pending ones.
  Future<void> clearResolved() async {
    _conflicts.removeWhere((_, c) => c.isResolved);
  }

  /// Remove all conflict records.
  Future<void> clearAll() async {
    _conflicts.clear();
  }

  /// Number of currently pending conflicts.
  Future<int> getPendingCount() async {
    return _conflicts.values.where((c) => c.isPending).length;
  }

  /// Number of resolved conflict records.
  Future<int> getResolvedCount() async {
    return _conflicts.values.where((c) => c.isResolved).length;
  }
}
