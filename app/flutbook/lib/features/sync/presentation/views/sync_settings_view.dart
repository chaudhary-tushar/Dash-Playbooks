/// Sync settings view for configuring synchronization options.
///
/// Provides user controls for:
/// - Enable/disable sync
/// - Auto-sync toggle
/// - Manual sync trigger
/// - Sync status display
/// - Clear sync data
library;

import 'package:flutbook/features/sync/presentation/providers/conflict_resolver_provider.dart';
import 'package:flutbook/features/sync/presentation/providers/sync_provider.dart';
import 'package:flutbook/features/sync/presentation/views/conflict_resolution_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Settings view for sync configuration.
class SyncSettingsView extends ConsumerStatefulWidget {
  /// Create a new SyncSettingsView.
  const SyncSettingsView({super.key});

  @override
  ConsumerState<SyncSettingsView> createState() => _SyncSettingsViewState();
}

class _SyncSettingsViewState extends ConsumerState<SyncSettingsView> {
  bool _syncEnabled = true;
  bool _autoSyncEnabled = true;
  bool _playbackSyncEnabled = true;

  @override
  Widget build(BuildContext context) {
    final syncState = ref.watch(syncProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Sync Status Card
        _buildStatusCard(syncState),

        const SizedBox(height: 24),

        // Sync Settings
        _buildSettingsSection(),

        const SizedBox(height: 24),

        // Playback Sync Settings
        _buildPlaybackSyncSection(syncState),

        const SizedBox(height: 24),

        // Manual Sync Button
        _buildManualSyncButton(syncState),

        const SizedBox(height: 24),

        // Conflict Resolution
        _buildConflictSection(),

        const SizedBox(height: 24),

        // Danger Zone
        _buildDangerZone(),
      ],
    );
  }

  Widget _buildStatusCard(SyncState syncState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildStatusIcon(syncState),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getStatusTitle(syncState),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (syncState.lastSyncTime != null)
                        Text(
                          'Last synced: ${_formatLastSyncTime(syncState.lastSyncTime!)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (syncState.hasError) ...[
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
                        syncState.errorMessage ?? 'Unknown error',
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (syncState.pendingSyncCount > 0) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.pending_actions, size: 20, color: Colors.orange[700]),
                  const SizedBox(width: 8),
                  Text(
                    '${syncState.pendingSyncCount} pending sync operations',
                    style: TextStyle(color: Colors.orange[700]),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Library Sync Settings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Enable Library Sync'),
            subtitle: const Text('Sync library with cloud'),
            value: _syncEnabled,
            onChanged: (value) {
              setState(() {
                _syncEnabled = value;
              });
            },
            secondary: const Icon(Icons.cloud_sync),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Auto Sync Library'),
            subtitle: const Text('Automatically sync when online'),
            value: _autoSyncEnabled,
            onChanged: _syncEnabled
                ? (value) {
                    setState(() {
                      _autoSyncEnabled = value;
                    });
                  }
                : null,
            secondary: const Icon(Icons.autorenew),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaybackSyncSection(SyncState syncState) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Playback Position Sync',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Enable Playback Sync'),
            subtitle: const Text('Sync playback position across devices'),
            value: _playbackSyncEnabled,
            onChanged: (value) {
              setState(() {
                _playbackSyncEnabled = value;
              });
              ref.read(syncProvider.notifier).togglePlaybackSync(value);
            },
            secondary: Icon(
              syncState.lastPlaybackSyncTime != null
                  ? Icons.check_circle
                  : Icons.sync,
              color: syncState.lastPlaybackSyncTime != null
                  ? Colors.green
                  : null,
            ),
          ),
          if (syncState.lastPlaybackSyncTime != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Last position sync: ${_formatLastSyncTime(syncState.lastPlaybackSyncTime!)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.green[700],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildManualSyncButton(SyncState syncState) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: syncState.isSyncing || !_syncEnabled
            ? null
            : () => ref.read(syncProvider.notifier).performSync(),
        icon: syncState.isSyncing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.sync),
        label: Text(syncState.isSyncing ? 'Syncing...' : 'Sync Now'),
      ),
    );
  }

  Widget _buildConflictSection() {
    final conflictState = ref.watch(conflictResolverProvider);
    final pendingCount = conflictState.pendingCount;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Conflict Resolution',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              pendingCount > 0 ? Icons.warning_amber : Icons.check_circle,
              color: pendingCount > 0 ? Colors.orange : Colors.green,
            ),
            title: Text(
              pendingCount > 0
                  ? '$pendingCount conflict${pendingCount == 1 ? '' : 's'} need attention'
                  : 'No pending conflicts',
            ),
            subtitle: Text(
              'Resolved: ${conflictState.resolvedCount + conflictState.autoResolvedCount}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: pendingCount > 0
                ? FilledButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const ConflictResolutionView(),
                      ),
                    ),
                    child: const Text('Review'),
                  )
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone() {
    return Card(
      color: Colors.red[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Danger Zone',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.red[700],
              ),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.delete_outline, color: Colors.red[700]),
            title: const Text('Clear Sync Data'),
            subtitle: const Text('Remove all synced data from cloud'),
            onTap: _showClearDataDialog,
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Sync Data?'),
        content: const Text(
          'This will remove all your synced data from the cloud. '
          'Your local library will remain unchanged.\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement clear sync data
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Clear sync data not yet implemented')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Clear Data'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(SyncState syncState) {
    if (syncState.isSyncing) {
      return const SizedBox(
        width: 32,
        height: 32,
        child: CircularProgressIndicator(strokeWidth: 3),
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
      default:
        icon = Icons.cloud_sync;
        color = Theme.of(context).colorScheme.primary;
    }

    return Icon(icon, color: color, size: 32);
  }

  String _getStatusTitle(SyncState syncState) {
    if (syncState.isSyncing) {
      return 'Syncing...';
    } else if (syncState.hasError) {
      return 'Sync Failed';
    } else if (syncState.isSuccess) {
      return 'Synced';
    } else if (syncState.isOffline) {
      return 'Offline';
    } else {
      return 'Ready to Sync';
    }
  }

  String _formatLastSyncTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}
