// lib/features/player/presentation/widgets/queue_manager_widget.dart
import 'package:flutbook/features/library/domain/entities/audiobook.dart';
import 'package:flutbook/features/player/domain/entities/queue.dart';
import 'package:flutbook/features/player/presentation/providers/queue_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QueueManagerWidget extends ConsumerWidget {
  const QueueManagerWidget({
    required this.currentAudiobook,
    super.key,
  });

  final Audiobook? currentAudiobook;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueState = ref.watch(queueProvider);
    final queueNotifier = ref.read(queueProvider.notifier);

    return Column(
      children: [
        // Queue header with create button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Queues (${queueState.queues.length})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 24),
                onPressed: () => _showCreateQueueDialog(context, ref),
                tooltip: 'Create new queue',
              ),
            ],
          ),
        ),

        // Current queue indicator
        if (queueState.currentQueue != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            child: Row(
              children: [
                Icon(
                  Icons.queue_music,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Now playing from: ${queueState.currentQueue!.name}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${queueState.currentQueue!.audiobookIds.length} items',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),

        // Queue list
        if (queueState.isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: CircularProgressIndicator(),
          )
        else if (queueState.queues.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('No queues yet. Create one using the + button above.'),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: queueState.queues.length,
            itemBuilder: (context, index) {
              final queue = queueState.queues[index];
              final isCurrentQueue = queueState.currentQueue?.id == queue.id;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                color: isCurrentQueue
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                    : null,
                child: ListTile(
                  leading: Icon(
                    isCurrentQueue ? Icons.play_circle : Icons.queue_music,
                    color: isCurrentQueue ? Theme.of(context).colorScheme.primary : null,
                  ),
                  title: Text(
                    queue.name,
                    style: TextStyle(
                      fontWeight: isCurrentQueue ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    '${queue.audiobookIds.length} audiobooks${queue.isDefault ? ' • Default' : ''}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isCurrentQueue)
                        IconButton(
                          icon: const Icon(Icons.play_arrow, size: 20),
                          onPressed: () => queueNotifier.setCurrentQueue(queue.id),
                          tooltip: 'Play this queue',
                        ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        onPressed: () => _confirmDeleteQueue(context, ref, queue),
                        tooltip: 'Delete queue',
                      ),
                    ],
                  ),
                  onTap: () => _showQueueDetails(context, ref, queue),
                ),
              );
            },
          ),

        // Error message if any
        if (queueState.errorMessage != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              queueState.errorMessage!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }

  void _showCreateQueueDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create New Queue'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Queue Name',
              hintText: 'e.g., Workout Mix, Commute',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  ref.read(queueProvider.notifier).createQueue(name: name);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteQueue(BuildContext context, WidgetRef ref, Queue queue) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Queue'),
          content: Text('Are you sure you want to delete "${queue.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                ref.read(queueProvider.notifier).deleteQueue(queue.id);
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showQueueDetails(BuildContext context, WidgetRef ref, Queue queue) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                queue.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                '${queue.audiobookIds.length} audiobooks in queue',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              if (queue.audiobookIds.isNotEmpty)
                ...queue.audiobookIds.map(
                  (id) => ListTile(
                    leading: const Icon(Icons.headphones),
                    title: Text('Audiobook ID: $id'),
                  ),
                )
              else
                const Text('No audiobooks in this queue'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      ref.read(queueProvider.notifier).setCurrentQueue(queue.id);
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Play Queue'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    label: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
