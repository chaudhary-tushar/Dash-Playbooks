/// Sync status widget for displaying sync state.
///
/// Shows current sync status with visual indicators:
/// - Sync button (manual trigger)
/// - Status icon (idle, syncing, success, error, offline)
/// - Last sync time
/// - Pending sync count
library;

import 'package:flutbook/features/sync/presentation/providers/sync_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Widget for displaying and triggering sync operations.
class SyncStatusWidget extends ConsumerWidget {
  /// Create a new SyncStatusWidget.
  const SyncStatusWidget({
    super.key,
    this.showLastSyncTime = true,
    this.showPendingCount = true,
    this.compact = false,
  });

  /// Whether to show the last sync timestamp.
  final bool showLastSyncTime;

  /// Whether to show the pending sync count.
  final bool showPendingCount;

  /// Whether to use compact mode (icon only).
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncProvider);

    if (compact) {
      return _buildCompactStatus(context, ref, syncState);
    }

    return _buildFullStatus(context, ref, syncState);
  }

  Widget _buildFullStatus(BuildContext context, WidgetRef ref, SyncState syncState) {
    return InkWell(
      onTap: syncState.isSyncing ? null : () => ref.read(syncProvider.notifier).performSync(),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusIcon(context, syncState),
            if (!compact) ...[
              const SizedBox(width: 8),
              _buildStatusText(syncState),
            ],
            if (showLastSyncTime && syncState.lastSyncTime != null) ...[
              const SizedBox(width: 8),
              _buildLastSyncTime(syncState.lastSyncTime!),
            ],
            if (showPendingCount && syncState.pendingSyncCount > 0) ...[
              const SizedBox(width: 8),
              _buildPendingBadge(syncState.pendingSyncCount),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompactStatus(BuildContext context, WidgetRef ref, SyncState syncState) {
    return IconButton(
      icon: _buildStatusIcon(context, syncState),
      onPressed: syncState.isSyncing ? null : () => ref.read(syncProvider.notifier).performSync(),
      tooltip: _getTooltip(syncState),
    );
  }

  Widget _buildStatusIcon(BuildContext context, SyncState syncState) {
    if (syncState.isSyncing) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    IconData icon;
    Color color;

    switch (syncState.status) {
      case SyncStateStatus.success:
        icon = Icons.check_circle;
        color = Colors.green;
      case SyncStateStatus.error:
        icon = Icons.error;
        color = Colors.red;
      case SyncStateStatus.offline:
        icon = Icons.cloud_off;
        color = Colors.grey;
      case SyncStateStatus.idle:
        icon = Icons.cloud_sync;
        color = Theme.of(context).colorScheme.primary;
      case SyncStateStatus.syncing:
        icon = Icons.cloud_sync;
        color = Colors.blue;
    }

    return Icon(icon, color: color, size: 24);
  }

  Widget _buildStatusText(SyncState syncState) {
    String text;
    Color? color;

    if (syncState.isSyncing) {
      text = 'Syncing...';
    } else if (syncState.hasError) {
      text = 'Sync failed';
      color = Colors.red;
    } else if (syncState.isSuccess) {
      text = 'Synced';
      color = Colors.green;
    } else if (syncState.isOffline) {
      text = 'Offline';
      color = Colors.grey;
    } else {
      text = 'Sync';
    }

    return Text(
      text,
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildLastSyncTime(DateTime lastSyncTime) {
    final now = DateTime.now();
    final difference = now.difference(lastSyncTime);

    String text;
    if (difference.inMinutes < 1) {
      text = 'Just now';
    } else if (difference.inHours < 1) {
      text = '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      text = '${difference.inHours}h ago';
    } else {
      text = '${difference.inDays}d ago';
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey[600],
      ),
    );
  }

  Widget _buildPendingBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getTooltip(SyncState syncState) {
    if (syncState.isSyncing) {
      return 'Syncing...';
    } else if (syncState.hasError) {
      return 'Sync failed: ${syncState.errorMessage ?? "Unknown error"}';
    } else if (syncState.isOffline) {
      return 'Offline - Cannot sync';
    } else {
      return 'Sync now';
    }
  }
}
