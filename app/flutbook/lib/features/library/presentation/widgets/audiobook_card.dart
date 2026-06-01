// lib/presentation/widgets/audiobook_card.dart
import 'dart:io';

import 'package:flutbook/core/error/exceptions.dart';
import 'package:flutbook/core/provider/providers.dart' show playbackRepositoryProvider;
import 'package:flutbook/features/library/domain/entities/audiobook.dart';
import 'package:flutbook/features/player/presentation/providers/playback_provider.dart';
import 'package:flutbook/features/player/presentation/providers/queue_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AudiobookCard extends ConsumerWidget {
  const AudiobookCard({
    required this.title,
    required this.author,
    required this.duration,
    required this.onTap,
    super.key,
    this.coverArtPath,
    this.isCompleted = false,
    this.progress,
    this.showPlayButton = true,
    this.audiobook, // Add audiobook parameter for validation
  });
  final String title;
  final String author;
  final String? coverArtPath;
  final Duration duration;
  final bool isCompleted;
  final double? progress;
  final VoidCallback onTap;
  final bool showPlayButton;
  final Audiobook? audiobook; // Optional audiobook for validation

  // Validate if playback is available for this audiobook
  Future<bool> _canPlayAudiobook(
    BuildContext context,
    WidgetRef ref,
    Audiobook? audiobook,
  ) async {
    try {
      // Check playback feature availability first
      final playbackNotifier = ref.read(playbackProvider.notifier);
      final featureStatus = playbackNotifier.getPlaybackFeatureStatus();

      final featuresAvailable = await ErrorHandler.checkPlaybackFeaturesAndNotify(
        context,
        featureStatus,
      );

      if (!featuresAvailable) {
        return false;
      }

      // If no audiobook is provided, can't play
      if (audiobook == null) {
        return false;
      }

      // Check if playback provider is initialized and ready
      final playbackState = ref.watch(playbackProvider);

      // If there's an existing playback error, don't allow playback
      if (playbackState.errorMessage != null) {
        return false;
      }

      // Check if the audiobook has a valid file path
      if (audiobook.filePath.isEmpty || !await File(audiobook.filePath).exists()) {
        return false;
      }

      // Check if playback repository is available
      final playbackRepoAsync = ref.watch(playbackRepositoryProvider);
      final playbackRepo = playbackRepoAsync.whenOrNull(
        data: (repo) => repo,
        loading: () => null,
        error: (error, stack) => null,
      );

      if (playbackRepo == null) {
        return false;
      }

      return true;
    } catch (e) {
      // Log the error but don't show to user
      ErrorHandler.logError(e, StackTrace.current);
      return false;
    }
  }

  // Handle play button tap with proper validation
  Future<void> _handlePlayButtonTap(
    BuildContext context,
    WidgetRef ref,
    Audiobook? audiobook,
    VoidCallback onTap,
  ) async {
    try {
      final canPlay = await _canPlayAudiobook(context, ref, audiobook);

      if (canPlay) {
        onTap(); // Proceed with navigation
      } else {
        // Show appropriate error message with retry option
        ErrorHandler.showPlaybackErrorWithRetry(
          context,
          'Playback unavailable. Please check your audio files and try again.',
          () => _retryPlayback(context, ref, audiobook),
        );
      }
    } catch (e) {
      // Handle any unexpected errors gracefully
      ErrorHandler.showFeatureUnavailableNotification(
        context,
        'Playback',
        'Failed to start playback. Please try again later.',
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playbackState = ref.watch(playbackProvider);
    final hasPlaybackError = playbackState.errorMessage != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 100,
          child: Row(
            children: [
              // Cover art or placeholder
              SizedBox(
                width: 80,
                height: 100,
                child: coverArtPath != null
                    ? _buildCoverImage(coverArtPath!, isDark)
                    : _placeholderCover(isDark),
              ),

              // Main content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Title
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Author
                      Text(
                        author.isEmpty ? 'Unknown author' : author,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Progress bar if progress is provided
                      if (progress != null)
                        Column(
                          children: [
                            LinearProgressIndicator(
                              value: progress,
                              minHeight: 4,
                              backgroundColor: isDark ? Colors.grey[700] : Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  '${(progress! * 100).round()}%',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  _formatDuration(duration),
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                      // Completed indicator
                      if (isCompleted)
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Completed',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),

              // Play button if needed
              if (showPlayButton)
                IconButton(
                  icon: const Icon(Icons.play_arrow_rounded),
                  onPressed: () => _handlePlayButtonTap(
                    context,
                    ref,
                    audiobook,
                    onTap,
                  ),
                  tooltip: hasPlaybackError ? 'Playback unavailable' : 'Play',
                ),

              // Queue options menu
              if (showPlayButton && audiobook != null)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20),
                  onSelected: (value) {
                    if (value == 'add_to_queue') {
                      _handleAddToQueue(context, ref, audiobook!);
                    } else if (value == 'play_next') {
                      _handlePlayNext(context, ref, audiobook!);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'add_to_queue',
                      child: Row(
                        children: [
                          Icon(Icons.queue_music, size: 18),
                          SizedBox(width: 8),
                          Text('Add to Queue'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'play_next',
                      child: Row(
                        children: [
                          Icon(Icons.playlist_play, size: 18),
                          SizedBox(width: 8),
                          Text('Play Next'),
                        ],
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

  /// Renders cover art, choosing Image.file for local paths and Image.network
  /// for http/https URLs, so local extracted artwork displays correctly.
  Widget _buildCoverImage(String artPath, bool isDark) {
    final isRemote = artPath.startsWith('http://') || artPath.startsWith('https://');
    if (isRemote) {
      return Image.network(
        artPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => _placeholderCover(isDark),
      );
    }
    return Image.file(
      File(artPath),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stack) => _placeholderCover(isDark),
    );
  }

  Widget _placeholderCover(bool isDark) {
    return Container(
      color: isDark ? Colors.grey[800] : Colors.grey[300],
      child: Icon(
        Icons.album_outlined,
        color: isDark ? Colors.grey[600] : Colors.grey[400],
        size: 40,
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  /// Retry playback after a failure
  Future<void> _retryPlayback(
    BuildContext context,
    WidgetRef ref,
    Audiobook? audiobook,
  ) async {
    try {
      if (audiobook == null) {
        ErrorHandler.showPlaybackUnavailableNotification(
          context,
          'No audiobook selected for playback.',
        );
        return;
      }

      // Show retry attempt notification
      ErrorHandler.showRetryAttemptNotification(context, 1);

      // Wait a moment before retrying
      await Future.delayed(const Duration(milliseconds: 500));

      // Check if playback is now available
      final canPlay = await _canPlayAudiobook(context, ref, audiobook);

      if (canPlay) {
        onTap(); // Proceed with navigation
      } else {
        ErrorHandler.showPlaybackUnavailableNotification(
          context,
          'Playback still unavailable. Please try again later.',
        );
      }
    } catch (e) {
      ErrorHandler.showPlaybackUnavailableNotification(
        context,
        'Retry failed. Please try again later.',
      );
    }
  }

  /// Handle adding audiobook to queue
  Future<void> _handleAddToQueue(
    BuildContext context,
    WidgetRef ref,
    Audiobook audiobook,
  ) async {
    try {
      final queueNotifier = ref.read(queueProvider.notifier);
      final queueState = ref.read(queueProvider);

      // Get or create a default queue
      int queueId;
      if (queueState.currentQueue != null) {
        queueId = queueState.currentQueue!.id;
      } else if (queueState.queues.isNotEmpty) {
        queueId = queueState.queues.first.id;
      } else {
        // Create a default queue
        await queueNotifier.createQueue(name: 'My Queue');
        final updatedState = ref.read(queueProvider);
        if (updatedState.currentQueue != null) {
          queueId = updatedState.currentQueue!.id;
        } else {
          throw Exception('Failed to create queue');
        }
      }

      await queueNotifier.addAudiobookToQueue(
        queueId: queueId,
        audiobookId: audiobook.id,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added "${audiobook.title}" to queue'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add to queue: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  /// Handle playing audiobook next in queue
  Future<void> _handlePlayNext(
    BuildContext context,
    WidgetRef ref,
    Audiobook audiobook,
  ) async {
    try {
      final queueNotifier = ref.read(queueProvider.notifier);
      final queueState = ref.read(queueProvider);

      // Get or create a default queue
      int queueId;
      if (queueState.currentQueue != null) {
        queueId = queueState.currentQueue!.id;
      } else if (queueState.queues.isNotEmpty) {
        queueId = queueState.queues.first.id;
      } else {
        // Create a default queue
        await queueNotifier.createQueue(name: 'My Queue');
        final updatedState = ref.read(queueProvider);
        if (updatedState.currentQueue != null) {
          queueId = updatedState.currentQueue!.id;
        } else {
          throw Exception('Failed to create queue');
        }
      }

      await queueNotifier.addAudiobookToQueue(
        queueId: queueId,
        audiobookId: audiobook.id,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added "${audiobook.title}" to play next'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add to queue: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
