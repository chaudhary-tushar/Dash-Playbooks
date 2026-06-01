/// Riverpod state management for conflict resolution.
library;

import 'package:flutbook/features/sync/data/datasources/conflict_resolver_ds.dart';
import 'package:flutbook/features/sync/data/models/conflict_model.dart';
import 'package:flutbook/features/sync/data/repositories/conflict_resolution_repository_impl.dart';
import 'package:flutbook/features/sync/domain/repositories/conflict_resolution_repository.dart';
import 'package:flutbook/features/sync/domain/usecases/conflict_resolution_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Infrastructure providers ────────────────────────────────────────────────

final conflictResolverDatasourceProvider = Provider<ConflictResolverDatasource>(
  (_) => ConflictResolverDatasource(),
);

final conflictResolutionRepositoryProvider =
    Provider<ConflictResolutionRepository>((ref) {
  return ConflictResolutionRepositoryImpl(
    datasource: ref.watch(conflictResolverDatasourceProvider),
  );
});

// ── Use-case providers ───────────────────────────────────────────────────────

final recordConflictUseCaseProvider = Provider<RecordConflictUseCase>(
  (ref) => RecordConflictUseCase(ref.watch(conflictResolutionRepositoryProvider)),
);

final getPendingConflictsUseCaseProvider = Provider<GetPendingConflictsUseCase>(
  (ref) => GetPendingConflictsUseCase(
    ref.watch(conflictResolutionRepositoryProvider),
  ),
);

final getConflictHistoryUseCaseProvider = Provider<GetConflictHistoryUseCase>(
  (ref) => GetConflictHistoryUseCase(
    ref.watch(conflictResolutionRepositoryProvider),
  ),
);

final resolveConflictUseCaseProvider = Provider<ResolveConflictUseCase>(
  (ref) => ResolveConflictUseCase(ref.watch(conflictResolutionRepositoryProvider)),
);

final autoResolveConflictsUseCaseProvider = Provider<AutoResolveConflictsUseCase>(
  (ref) => AutoResolveConflictsUseCase(
    ref.watch(conflictResolutionRepositoryProvider),
  ),
);

final clearResolvedConflictsUseCaseProvider =
    Provider<ClearResolvedConflictsUseCase>(
  (ref) => ClearResolvedConflictsUseCase(
    ref.watch(conflictResolutionRepositoryProvider),
  ),
);

final getConflictStatsUseCaseProvider = Provider<GetConflictStatsUseCase>(
  (ref) => GetConflictStatsUseCase(ref.watch(conflictResolutionRepositoryProvider)),
);

// ── State ────────────────────────────────────────────────────────────────────

/// Immutable state for the conflict resolver.
class ConflictResolverState {
  const ConflictResolverState({
    this.pendingConflicts = const [],
    this.conflictHistory = const [],
    this.isLoading = false,
    this.isResolving = false,
    this.errorMessage,
    this.pendingCount = 0,
    this.resolvedCount = 0,
    this.autoResolvedCount = 0,
  });

  final List<SyncConflict> pendingConflicts;
  final List<SyncConflict> conflictHistory;
  final bool isLoading;
  final bool isResolving;
  final String? errorMessage;
  final int pendingCount;
  final int resolvedCount;
  final int autoResolvedCount;

  bool get hasConflicts => pendingCount > 0;
  bool get hasError => errorMessage != null;

  ConflictResolverState copyWith({
    List<SyncConflict>? pendingConflicts,
    List<SyncConflict>? conflictHistory,
    bool? isLoading,
    bool? isResolving,
    String? errorMessage,
    bool clearError = false,
    int? pendingCount,
    int? resolvedCount,
    int? autoResolvedCount,
  }) {
    return ConflictResolverState(
      pendingConflicts: pendingConflicts ?? this.pendingConflicts,
      conflictHistory: conflictHistory ?? this.conflictHistory,
      isLoading: isLoading ?? this.isLoading,
      isResolving: isResolving ?? this.isResolving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      pendingCount: pendingCount ?? this.pendingCount,
      resolvedCount: resolvedCount ?? this.resolvedCount,
      autoResolvedCount: autoResolvedCount ?? this.autoResolvedCount,
    );
  }
}

/// Notifier that manages conflict detection and resolution state.
class ConflictResolverNotifier extends Notifier<ConflictResolverState> {
  @override
  ConflictResolverState build() => const ConflictResolverState();

  GetPendingConflictsUseCase get _getPending =>
      ref.read(getPendingConflictsUseCaseProvider);
  GetConflictHistoryUseCase get _getHistory =>
      ref.read(getConflictHistoryUseCaseProvider);
  ResolveConflictUseCase get _resolve =>
      ref.read(resolveConflictUseCaseProvider);
  AutoResolveConflictsUseCase get _autoResolve =>
      ref.read(autoResolveConflictsUseCaseProvider);
  ClearResolvedConflictsUseCase get _clearResolved =>
      ref.read(clearResolvedConflictsUseCaseProvider);
  GetConflictStatsUseCase get _getStats =>
      ref.read(getConflictStatsUseCaseProvider);

  /// Load pending conflicts and refresh statistics.
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final pending = await _getPending.execute();
      final history = await _getHistory.execute();
      final stats = await _getStats.execute();
      state = state.copyWith(
        isLoading: false,
        pendingConflicts: pending,
        conflictHistory: history,
        pendingCount: stats.pendingCount,
        resolvedCount: stats.resolvedCount,
        autoResolvedCount: stats.autoResolvedCount,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load conflicts: $e',
      );
    }
  }

  /// Resolve a single conflict with the chosen strategy.
  Future<void> resolveConflict(
    String conflictId,
    ConflictResolutionStrategy strategy,
  ) async {
    state = state.copyWith(isResolving: true, clearError: true);
    try {
      await _resolve.execute(conflictId, strategy);
      await refresh();
    } catch (e) {
      state = state.copyWith(
        isResolving: false,
        errorMessage: 'Failed to resolve conflict: $e',
      );
    } finally {
      if (state.isResolving) {
        state = state.copyWith(isResolving: false);
      }
    }
  }

  /// Resolve all pending conflicts using last-write-wins.
  Future<int> autoResolveAll() async {
    state = state.copyWith(isResolving: true, clearError: true);
    try {
      final count = await _autoResolve.execute();
      await refresh();
      return count;
    } catch (e) {
      state = state.copyWith(
        isResolving: false,
        errorMessage: 'Failed to auto-resolve conflicts: $e',
      );
      return 0;
    } finally {
      if (state.isResolving) {
        state = state.copyWith(isResolving: false);
      }
    }
  }

  /// Remove resolved records from history.
  Future<void> clearResolved() async {
    try {
      await _clearResolved.execute();
      await refresh();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to clear history: $e');
    }
  }

  /// Dismiss any current error message.
  void clearError() => state = state.copyWith(clearError: true);
}

/// Provider for [ConflictResolverNotifier].
final conflictResolverProvider =
    NotifierProvider<ConflictResolverNotifier, ConflictResolverState>(
  ConflictResolverNotifier.new,
);
