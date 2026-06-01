/// Full-screen view for reviewing and resolving sync conflicts.
library;

import 'package:flutbook/features/sync/data/models/conflict_model.dart';
import 'package:flutbook/features/sync/presentation/providers/conflict_resolver_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Screen that lists pending conflicts and lets the user resolve each one.
class ConflictResolutionView extends ConsumerStatefulWidget {
  const ConflictResolutionView({super.key});

  @override
  ConsumerState<ConflictResolutionView> createState() =>
      _ConflictResolutionViewState();
}

class _ConflictResolutionViewState extends ConsumerState<ConflictResolutionView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(conflictResolverProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(conflictResolverProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync Conflicts'),
        actions: [
          if (state.pendingCount > 0)
            TextButton.icon(
              onPressed: state.isResolving ? null : _autoResolveAll,
              icon: const Icon(Icons.auto_fix_high),
              label: const Text('Auto-resolve all'),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: 'Pending (${state.pendingCount})',
              icon: const Icon(Icons.pending_actions),
            ),
            Tab(
              text: 'History (${state.resolvedCount + state.autoResolvedCount})',
              icon: const Icon(Icons.history),
            ),
          ],
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (state.hasError) _ErrorBanner(message: state.errorMessage!),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _ConflictList(
                        conflicts: state.pendingConflicts,
                        isPending: true,
                        isResolving: state.isResolving,
                        onResolve: _resolveConflict,
                      ),
                      _ConflictList(
                        conflicts: state.conflictHistory
                            .where((c) => c.isResolved)
                            .toList(),
                        isPending: false,
                        isResolving: false,
                        onClearHistory: state.resolvedCount > 0
                            ? _clearHistory
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _resolveConflict(
    String conflictId,
    ConflictResolutionStrategy strategy,
  ) async {
    await ref
        .read(conflictResolverProvider.notifier)
        .resolveConflict(conflictId, strategy);
  }

  Future<void> _autoResolveAll() async {
    final count =
        await ref.read(conflictResolverProvider.notifier).autoResolveAll();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Auto-resolved $count conflict(s)')),
      );
    }
  }

  Future<void> _clearHistory() async {
    await ref.read(conflictResolverProvider.notifier).clearResolved();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conflict history cleared')),
      );
    }
  }
}

// ── Conflict list ─────────────────────────────────────────────────────────────

class _ConflictList extends StatelessWidget {
  const _ConflictList({
    required this.conflicts,
    required this.isPending,
    required this.isResolving,
    this.onResolve,
    this.onClearHistory,
  });

  final List<SyncConflict> conflicts;
  final bool isPending;
  final bool isResolving;
  final Future<void> Function(String id, ConflictResolutionStrategy)? onResolve;
  final VoidCallback? onClearHistory;

  @override
  Widget build(BuildContext context) {
    if (conflicts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPending ? Icons.check_circle_outline : Icons.history,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              isPending ? 'No pending conflicts' : 'No conflict history',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: conflicts.length + (onClearHistory != null ? 1 : 0),
      itemBuilder: (context, index) {
        if (onClearHistory != null && index == conflicts.length) {
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: OutlinedButton.icon(
              onPressed: onClearHistory,
              icon: const Icon(Icons.delete_sweep),
              label: const Text('Clear history'),
            ),
          );
        }
        final conflict = conflicts[index];
        return isPending
            ? _PendingConflictCard(
                conflict: conflict,
                isResolving: isResolving,
                onResolve: onResolve,
              )
            : _ResolvedConflictCard(conflict: conflict);
      },
    );
  }
}

// ── Pending conflict card ─────────────────────────────────────────────────────

class _PendingConflictCard extends StatelessWidget {
  const _PendingConflictCard({
    required this.conflict,
    required this.isResolving,
    this.onResolve,
  });

  final SyncConflict conflict;
  final bool isResolving;
  final Future<void> Function(String id, ConflictResolutionStrategy)? onResolve;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                _entityIcon(conflict.entityType),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conflict.entityTitle,
                        style: theme.textTheme.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _entityTypeLabel(conflict.entityType),
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                _timestampChip(context, conflict),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Side-by-side summary
            Row(
              children: [
                Expanded(
                  child: _VersionSummary(
                    label: 'Local',
                    timestamp: conflict.localTimestamp,
                    isNewer: conflict.isLocalNewer,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.compare_arrows, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: _VersionSummary(
                    label: 'Remote',
                    timestamp: conflict.remoteTimestamp,
                    isNewer: conflict.isRemoteNewer,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Resolution actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isResolving
                        ? null
                        : () => onResolve?.call(
                              conflict.id,
                              ConflictResolutionStrategy.localWins,
                            ),
                    child: const Text('Keep Local'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: isResolving
                        ? null
                        : () => onResolve?.call(
                              conflict.id,
                              ConflictResolutionStrategy.remoteWins,
                            ),
                    child: const Text('Keep Remote'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: isResolving
                        ? null
                        : () => onResolve?.call(
                              conflict.id,
                              ConflictResolutionStrategy.lastWriteWins,
                            ),
                    child: const Text('Keep Newer'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _entityIcon(ConflictEntityType type) {
    IconData icon;
    Color color;
    switch (type) {
      case ConflictEntityType.library:
        icon = Icons.library_books;
        color = Colors.orange;
      case ConflictEntityType.playback:
        icon = Icons.play_circle;
        color = Colors.green;
      case ConflictEntityType.readingList:
        icon = Icons.list_alt;
        color = Colors.blue;
    }
    return CircleAvatar(
      radius: 18,
      backgroundColor: color.withValues(alpha: 0.15),
      child: Icon(icon, color: color, size: 18),
    );
  }

  String _entityTypeLabel(ConflictEntityType type) {
    switch (type) {
      case ConflictEntityType.library:
        return 'Library';
      case ConflictEntityType.playback:
        return 'Playback position';
      case ConflictEntityType.readingList:
        return 'Reading list';
    }
  }

  Widget _timestampChip(BuildContext context, SyncConflict conflict) {
    return Chip(
      label: const Text('Conflict'),
      avatar: const Icon(Icons.warning_amber, size: 16),
      backgroundColor: Colors.orange[50],
      side: BorderSide(color: Colors.orange[200]!),
      padding: EdgeInsets.zero,
      labelStyle: const TextStyle(fontSize: 11),
    );
  }
}

// ── Resolved conflict card ────────────────────────────────────────────────────

class _ResolvedConflictCard extends StatelessWidget {
  const _ResolvedConflictCard({required this.conflict});

  final SyncConflict conflict;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedAt = conflict.resolvedAt;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(_statusIcon(conflict.status), color: Colors.green),
        title: Text(
          conflict.entityTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${_statusLabel(conflict.status)} · ${_formatDate(resolvedAt)}',
          style: theme.textTheme.bodySmall,
        ),
        trailing: Chip(
          label: Text(_strategyLabel(conflict.resolutionStrategy)),
          padding: EdgeInsets.zero,
          labelStyle: const TextStyle(fontSize: 10),
        ),
      ),
    );
  }

  IconData _statusIcon(ConflictStatus status) {
    switch (status) {
      case ConflictStatus.resolvedLocal:
        return Icons.phone_android;
      case ConflictStatus.resolvedRemote:
        return Icons.cloud;
      case ConflictStatus.resolvedMerged:
        return Icons.merge;
      case ConflictStatus.autoResolved:
        return Icons.auto_fix_high;
      case ConflictStatus.pending:
        return Icons.pending;
    }
  }

  String _statusLabel(ConflictStatus status) {
    switch (status) {
      case ConflictStatus.resolvedLocal:
        return 'Kept local';
      case ConflictStatus.resolvedRemote:
        return 'Kept remote';
      case ConflictStatus.resolvedMerged:
        return 'Merged';
      case ConflictStatus.autoResolved:
        return 'Auto-resolved';
      case ConflictStatus.pending:
        return 'Pending';
    }
  }

  String _strategyLabel(ConflictResolutionStrategy strategy) {
    switch (strategy) {
      case ConflictResolutionStrategy.lastWriteWins:
        return 'Newest wins';
      case ConflictResolutionStrategy.localWins:
        return 'Local';
      case ConflictResolutionStrategy.remoteWins:
        return 'Remote';
      case ConflictResolutionStrategy.manual:
        return 'Manual';
    }
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '—';
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-'
        '${dt.day.toString().padLeft(2, '0')}';
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

class _VersionSummary extends StatelessWidget {
  const _VersionSummary({
    required this.label,
    required this.timestamp,
    required this.isNewer,
    required this.color,
  });

  final String label;
  final DateTime timestamp;
  final bool isNewer;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isNewer ? color : Colors.grey[300]!,
          width: isNewer ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: color,
                  fontSize: 12,
                ),
              ),
              if (isNewer) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'NEWER',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _formatTimestamp(timestamp),
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-'
        '${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.red[50],
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700], size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.red[700], fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
