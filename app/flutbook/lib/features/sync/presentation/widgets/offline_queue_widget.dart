/// Offline queue widget for displaying queue status.
///
/// Shows pending sync operations with visual indicators:
/// - Pending item count
/// - Failed item count
/// - Process queue button
/// - Clear queue options
library;

import 'package:flutbook/features/sync/presentation/providers/queue_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Widget for displaying offline queue status.
class OfflineQueueWidget extends ConsumerWidget {
  /// Create a new OfflineQueueWidget.
  const OfflineQueueWidget({
    super.key,
    this.compact = false,
  });

  /// Whether to use compact mode.
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueState = ref.watch(queueProvider);

    if (compact) {
      return _buildCompactStatus(context, ref, queueState);
    }

    return _buildFullStatus(context, ref, queueState);
  }

  Widget _buildCompactStatus(BuildContext context, WidgetRef ref, QueueState state) {
    if (!state.hasPendingItems) {
      return const SizedBox.shrink();
    }

    return Badge(
      label: Text('${state.pendingItems.length}'),
      child: IconButton(
        icon: const Icon(Icons.sync_problem),
        onPressed: () => _showQueueDialog(context, ref, state),
        tooltip: '${state.pendingItems.length} pending sync operations',
      ),
    );
  }

  Widget _buildFullStatus(BuildContext context, WidgetRef ref, QueueState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (state.isProcessing)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Icon(
                    state.hasPendingItems ? Icons.sync_problem : Icons.sync,
                    color: state.hasPendingItems ? Colors.orange : Colors.green,
                    size: 24,
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.hasPendingItems
                            ? 'Offline Queue'
                            : 'Queue Empty',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '${state.pendingItems.length} pending, ${state.failedCount} failed',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (state.hasPendingItems && !state.isProcessing)
                  ElevatedButton.icon(
                    onPressed: () => ref.read(queueProvider.notifier).processQueue(),
                    icon: const Icon(Icons.sync),
                    label: const Text('Sync Now'),
                  ),
              ],
            ),
            if (state.hasPendingItems) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  if (state.failedCount > 0)
                    ActionChip(
                      avatar: const Icon(Icons.refresh, size: 16),
                      label: const Text('Retry Failed'),
                      onPressed: () => ref.read(queueProvider.notifier).retryFailed(),
                    ),
                  ActionChip(
                    avatar: const Icon(Icons.clear_all, size: 16),
                    label: const Text('Clear Synced'),
                    onPressed: () => ref.read(queueProvider.notifier).clearSynced(),
                  ),
                  if (state.failedCount > 0)
                    ActionChip(
                      avatar: const Icon(Icons.delete_sweep, size: 16),
                      label: const Text('Clear Failed'),
                      onPressed: () => ref.read(queueProvider.notifier).clearFailed(),
                    ),
                ],
              ),
            ],
            if (state.hasError) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.errorMessage ?? 'Unknown error',
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                    TextButton(
                      onPressed: () => ref.read(queueProvider.notifier).clearError(),
                      child: const Text('Dismiss'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showQueueDialog(BuildContext context, WidgetRef ref, QueueState state) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Offline Queue',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              '${state.pendingItems.length} operations pending sync',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            if (state.hasPendingItems)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: state.isProcessing
                      ? null
                      : () {
                          Navigator.pop(context);
                          ref.read(queueProvider.notifier).processQueue();
                        },
                  icon: state.isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.sync),
                  label: Text(state.isProcessing ? 'Syncing...' : 'Sync All'),
                ),
              ),
            if (state.failedCount > 0) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ref.read(queueProvider.notifier).retryFailed();
                  },
                  icon: const Icon(Icons.refresh),
                  label: Text('Retry ${state.failedCount} Failed'),
                ),
              ),
            ],
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ref.read(queueProvider.notifier).clearSynced();
                },
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear Synced Items'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
