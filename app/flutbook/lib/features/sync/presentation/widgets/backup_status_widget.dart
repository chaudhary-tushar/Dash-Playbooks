/// Backup status widget for displaying backup state.
///
/// Shows current backup status with visual indicators:
/// - Last backup time
/// - Backup size
/// - Item count
/// - Create backup button
library;

import 'package:flutbook/features/sync/presentation/providers/backup_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Widget for displaying backup status.
class BackupStatusWidget extends ConsumerWidget {
  /// Create a new BackupStatusWidget.
  const BackupStatusWidget({
    super.key,
    this.compact = false,
    this.onCreateBackup,
  });

  /// Whether to use compact mode.
  final bool compact;

  /// Callback when backup is created.
  final VoidCallback? onCreateBackup;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backupState = ref.watch(backupProvider);

    if (compact) {
      return _buildCompactStatus(context, ref, backupState);
    }

    return _buildFullStatus(context, ref, backupState);
  }

  Widget _buildCompactStatus(BuildContext context, WidgetRef ref, BackupState state) {
    IconData icon;
    Color color;

    if (state.isBackingUp) {
      icon = Icons.cloud_upload;
      color = Colors.blue;
    } else if (state.isRestoring) {
      icon = Icons.cloud_download;
      color = Colors.orange;
    } else if (state.hasBackups) {
      icon = Icons.cloud_done;
      color = Colors.green;
    } else {
      icon = Icons.cloud_off;
      color = Colors.grey;
    }

    return IconButton(
      icon: Icon(icon, color: color),
      onPressed: state.isBackingUp || state.isRestoring
          ? null
          : () => _showBackupDialog(context, ref, state),
      tooltip: _getTooltip(state),
    );
  }

  Widget _buildFullStatus(BuildContext context, WidgetRef ref, BackupState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildStatusIcon(state),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getStatusTitle(state),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (state.lastBackupTime != null)
                        Text(
                          'Last backup: ${_formatLastBackupTime(state.lastBackupTime!)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                if (!state.isBackingUp && !state.isRestoring)
                  ElevatedButton.icon(
                    onPressed: () => ref.read(backupProvider.notifier).createBackup(),
                    icon: const Icon(Icons.cloud_upload),
                    label: const Text('Backup Now'),
                  ),
              ],
            ),
            if (state.lastBackupSize > 0) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.storage, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    _formatSize(state.lastBackupSize),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.folder, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    '${state.lastBackupItemCount} items',
                    style: Theme.of(context).textTheme.bodySmall,
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
                      onPressed: () => ref.read(backupProvider.notifier).clearError(),
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

  Widget _buildStatusIcon(BackupState state) {
    if (state.isBackingUp) {
      return const SizedBox(
        width: 32,
        height: 32,
        child: CircularProgressIndicator(strokeWidth: 3),
      );
    } else if (state.isRestoring) {
      return const SizedBox(
        width: 32,
        height: 32,
        child: CircularProgressIndicator(strokeWidth: 3),
      );
    }

    IconData icon;
    Color color;

    if (state.hasBackups) {
      icon = Icons.cloud_done;
      color = Colors.green;
    } else {
      icon = Icons.cloud_off;
      color = Colors.grey;
    }

    return Icon(icon, color: color, size: 32);
  }

  String _getStatusTitle(BackupState state) {
    if (state.isBackingUp) {
      return 'Creating Backup...';
    } else if (state.isRestoring) {
      return 'Restoring Backup...';
    } else if (state.hasBackups) {
      return 'Backed Up';
    } else {
      return 'No Backups';
    }
  }

  String _formatLastBackupTime(DateTime time) {
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

  String _formatSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  String _getTooltip(BackupState state) {
    if (state.isBackingUp) {
      return 'Creating backup...';
    } else if (state.isRestoring) {
      return 'Restoring backup...';
    } else if (state.hasBackups) {
      return 'View backups';
    } else {
      return 'No backups available';
    }
  }

  void _showBackupDialog(BuildContext context, WidgetRef ref, BackupState state) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Backup Options',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.cloud_upload),
              title: const Text('Create Backup'),
              subtitle: const Text('Backup all your data to the cloud'),
              onTap: () {
                Navigator.pop(context);
                ref.read(backupProvider.notifier).createBackup();
              },
            ),
            if (state.hasBackups)
              ListTile(
                leading: const Icon(Icons.cloud_download),
                title: const Text('Restore Backup'),
                subtitle: const Text('Restore from a previous backup'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to restore view
                },
              ),
            if (state.hasBackups)
              ListTile(
                leading: const Icon(Icons.list),
                title: const Text('View Backups'),
                subtitle: Text('${state.availableBackups.length} backups available'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to backup list view
                },
              ),
          ],
        ),
      ),
    );
  }
}
