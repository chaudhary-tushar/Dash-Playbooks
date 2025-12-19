// lib/presentation/screens/audiobook_detail_screen.dart
import 'package:flutbook/core/error/exceptions.dart';
import 'package:flutbook/features/library/domain/entities/audiobook.dart';
import 'package:flutbook/features/player/presentation/providers/playback_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AudiobookDetailScreen extends ConsumerWidget {
  const AudiobookDetailScreen({
    required this.audiobook,
    super.key,
  });
  final Audiobook audiobook;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playbackState = ref.watch(playbackProvider);
    final hasPlaybackError = playbackState.errorMessage != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audiobook Details'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover art
              Center(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Theme.of(context).cardColor,
                  ),
                  child: audiobook.coverArtPath != null
                      ? Image.network(
                          audiobook.coverArtPath!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.album_outlined,
                              size: 80,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            );
                          },
                        )
                      : Icon(
                          Icons.album_outlined,
                          size: 80,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Title and author
              Text(
                audiobook.title,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                audiobook.author.isEmpty ? 'Unknown Author' : audiobook.author,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Basic metadata
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMetadataRow(
                        context,
                        'Duration',
                        _formatDuration(audiobook.duration),
                      ),
                      _buildMetadataRow(
                        context,
                        'File Size',
                        _formatFileSize(audiobook.totalSize),
                      ),
                      _buildMetadataRow(
                        context,
                        'File Path',
                        audiobook.filePath.split('/').last,
                      ),
                      _buildMetadataRow(
                        context,
                        'Added',
                        audiobook.createdAt
                            .toLocal()
                            .toString()
                            .split('.')
                            .first,
                      ),
                      if (audiobook.lastPlayedAt != null)
                        _buildMetadataRow(
                          context,
                          'Last Played',
                          audiobook.lastPlayedAt!
                              .toLocal()
                              .toString()
                              .split('.')
                              .first,
                        ),
                      _buildMetadataRow(
                        context,
                        'Status',
                        audiobook.completed ? 'Completed' : 'In Progress',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Progress section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progress',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),

                      const SizedBox(height: 8),

                      // Simplified progress bar - actual progress would come from playback repository
                      Container(
                        width: double.infinity,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Theme.of(context).dividerColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Container(
                          width:
                              0.6 *
                              MediaQuery.of(
                                    context,
                                  )
                                  .size
                                  .width, // Placeholder: actual progress would be dynamic
                          height: 4,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '60%', // Placeholder: actual progress percentage
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            _formatDuration(audiobook.duration),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Chapter navigation (if chapters exist)
              if (audiobook.chapters.isNotEmpty) ...[
                Text(
                  'Chapters',
                  style: Theme.of(context).textTheme.titleMedium,
                ),

                const SizedBox(height: 8),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        for (int i = 0; i < audiobook.chapters.length; i++)
                          ListTile(
                            title: Text(audiobook.chapters[i].title),
                            subtitle: Text(
                              '${_formatDuration(audiobook.chapters[i].startTime)} - ${_formatDuration(audiobook.chapters[i].endTime)}',
                            ),
                            trailing: const Icon(Icons.play_arrow),
                            onTap: () {
                              // Handle chapter selection
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Play'),
                      onPressed: hasPlaybackError
                          ? () {
                              ErrorHandler.showPlaybackUnavailableNotification(
                                context,
                                'Playback is currently unavailable. Please try again later.',
                              );
                            }
                          : () {
                              // Handle the returned Future properly
                              Navigator.pushNamed(
                                context,
                                '/playback',
                                arguments: audiobook,
                              );
                            },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.share_outlined),
                      label: const Text('Share'),
                      onPressed: () {
                        // Share audiobook
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetadataRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label: ',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    final twoDigitHours = twoDigits(duration.inHours);
    final twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

    return duration.inHours > 0
        ? '$twoDigitHours:$twoDigitMinutes:$twoDigitSeconds'
        : '$twoDigitMinutes:$twoDigitSeconds';
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
