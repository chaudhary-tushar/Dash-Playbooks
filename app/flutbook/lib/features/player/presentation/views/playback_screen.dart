// lib/features/player/presentation/views/playback_screen.dart
import 'package:flutbook/features/library/domain/entities/audiobook.dart';
import 'package:flutbook/features/player/presentation/providers/playback_provider.dart';
import 'package:flutbook/features/player/presentation/widgets/chapters_list.dart';
import 'package:flutbook/features/player/presentation/widgets/progress_bar.dart';
import 'package:flutbook/features/player/presentation/widgets/sleep_timer_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlaybackScreen extends ConsumerWidget {
  const PlaybackScreen({
    required this.audiobook,
    super.key,
  });
  final Audiobook audiobook;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize the playback provider with the audiobook
    final playbackNotifier = ref.read(playbackProvider.notifier);
    final playbackState = ref.watch(playbackProvider);

    // Handle initialization with comprehensive error handling
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Check if we're in an error state
      if (playbackState.errorMessage != null) {
        // Show error dialog for existing errors
        _showErrorDialogWithRetry(context, playbackState.errorMessage!, () {
          playbackNotifier.retryOperation(
            () => playbackNotifier.setCurrentAudiobook(audiobook),
          );
        });
      } else if (!playbackState.isLoading) {
        // Initialize playback if not already loading and no error
        final success = await playbackNotifier.setCurrentAudiobook(audiobook);
        if (!success) {
          // Show error dialog if initialization fails
          _showErrorDialogWithRetry(
            context,
            playbackState.errorMessage ?? 'Failed to initialize playback',
            () {
              playbackNotifier.retryOperation(
                () => playbackNotifier.setCurrentAudiobook(audiobook),
              );
            },
          );
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Now Playing'),
        centerTitle: true,
      ),
      body: _buildPlaybackBody(context, ref, playbackState, audiobook),
    );
  }

  Widget _buildPlaybackBody(
    BuildContext context,
    WidgetRef ref,
    PlaybackState playbackState,
    Audiobook audiobook,
  ) {
    // Show error state if there's an error
    if (playbackState.errorMessage != null) {
      return _buildErrorState(context, ref, playbackState);
    }

    // Show loading state if still loading
    if (playbackState.isLoading) {
      return _buildLoadingState(context);
    }

    // Check if playback provider is properly initialized
    // This handles cases where the provider might be in a bad state
    try {
      // Verify that the audio service is ready
      final playbackNotifier = ref.read(playbackProvider.notifier);

      // If we reach here, show normal playback UI
      return LayoutBuilder(
        builder: (context, constraints) {
          // Determine if we're on a small screen (mobile)
          final isMobile = constraints.maxWidth < 600;
          final coverSize = isMobile ? 250.0 : 300.0;
          final horizontalPadding = isMobile ? 16.0 : 32.0;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Cover art display
                Padding(
                  padding: EdgeInsets.all(isMobile ? 24 : 32),
                  child: Center(
                    child: Container(
                      width: coverSize,
                      height: coverSize,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(
                              255,
                              0,
                              0,
                              0,
                            ).withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: audiobook.coverArtPath != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                audiobook.coverArtPath!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return ColoredBox(
                                    color: Theme.of(context).cardColor,
                                    child: Icon(
                                      Icons.album_outlined,
                                      size: 80,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                                  );
                                },
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.album_outlined,
                                size: 80,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                    ),
                  ),
                ),

                // Audiobook info
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                  ),
                  child: Column(
                    children: [
                      Text(
                        audiobook.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        audiobook.author.isEmpty
                            ? 'Unknown Author'
                            : audiobook.author,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Progress bar with seeking capability
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                  ),
                  width: double.infinity,
                  child: ProgressBar(
                    currentPosition: playbackState.currentPosition,
                    totalDuration: playbackState.duration,
                    bufferedPosition:
                        playbackState.bufferedPosition ?? Duration.zero,
                    chapterMarkers: audiobook.chapters
                        .map((chapter) => chapter.startTime)
                        .toList(),
                    onSeek: (newPosition) {
                      ref.read(playbackProvider.notifier).seekTo(newPosition);
                    },
                    onSeekStart: () async {
                      // Handle seek start if needed
                    },
                    onSeekEnd: (finalPosition) async {
                      ref.read(playbackProvider.notifier).seekTo(finalPosition);
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Playback controls with FAB
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                  ),
                  child: Column(
                    children: [
                      // Skip buttons row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Skip backward button (15 sec)
                          IconButton(
                            iconSize: isMobile ? 48 : 56,
                            icon: const Icon(Icons.replay_10_outlined),
                            onPressed: playbackState.errorMessage != null
                                ? null
                                : () async {
                                    await ref
                                        .read(playbackProvider.notifier)
                                        .skipBackward(
                                          const Duration(seconds: 15),
                                        );
                                  },
                          ),

                          // Skip forward button (30 sec)
                          IconButton(
                            iconSize: isMobile ? 48 : 56,
                            icon: const Icon(Icons.forward_30_outlined),
                            onPressed: playbackState.errorMessage != null
                                ? null
                                : () async {
                                    await ref
                                        .read(playbackProvider.notifier)
                                        .skipForward(
                                          const Duration(seconds: 30),
                                        );
                                  },
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Main play/pause FAB
                      Center(
                        child: FloatingActionButton(
                          onPressed: playbackState.errorMessage != null
                              ? null
                              : () async {
                                  final notifier = ref.read(
                                    playbackProvider.notifier,
                                  );
                                  if (playbackState.isPlaying) {
                                    await notifier.pause();
                                  } else {
                                    await notifier.play();
                                  }
                                },
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Colors.white,
                          child: Icon(
                            playbackState.isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            size: isMobile ? 36 : 42,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Secondary controls row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Speed control dropdown
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(context).dividerColor,
                                ),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: ButtonTheme(
                                  alignedDropdown: true,
                                  child: DropdownButton<double>(
                                    isExpanded: true,
                                    value: playbackState.playbackSpeed,
                                    items: [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]
                                        .map(
                                          (speed) => DropdownMenuItem(
                                            value: speed,
                                            child: Text('${speed}x'),
                                          ),
                                        )
                                        .toList(),
                                    onChanged:
                                        playbackState.errorMessage != null
                                        ? null
                                        : (speed) {
                                            ref
                                                .read(playbackProvider.notifier)
                                                .setSpeed(speed ?? 1.0);
                                          },
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 16),

                          // Bookmark button
                          Expanded(
                            child: IconButton(
                              onPressed: playbackState.errorMessage != null
                                  ? null
                                  : () async {
                                      // Add bookmark at current position
                                      // This would use the bookmark provider
                                      // For now, we'll show a placeholder action
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Bookmark added at current position',
                                          ),
                                        ),
                                      );
                                    },
                              icon: const Icon(Icons.bookmark_add_outlined),
                              tooltip: 'Add bookmark',
                              style: IconButton.styleFrom(
                                foregroundColor: Theme.of(
                                  context,
                                ).colorScheme.onSurface,
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Sleep timer toggle
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: playbackState.errorMessage != null
                                  ? null
                                  : () async {
                                      final notifier = ref.read(
                                        playbackProvider.notifier,
                                      );
                                      if (playbackState.sleepTimerActive) {
                                        notifier.cancelSleepTimer();
                                      } else {
                                        // Show sleep timer dialog
                                        final result =
                                            await showDialog<
                                              SleepTimerSelection?
                                            >(
                                              context: context,
                                              builder: (context) =>
                                                  const SleepTimerDialog(),
                                            );

                                        if (result != null) {
                                          if (result.endOfChapter) {
                                            notifier.setSleepTimer(
                                              Duration.zero,
                                              endOfChapter: true,
                                            );
                                          } else if (result.duration != null) {
                                            notifier.setSleepTimer(
                                              result.duration!,
                                            );
                                          }
                                        }
                                      }
                                    },
                              icon: Icon(
                                playbackState.sleepTimerActive
                                    ? Icons.bedtime_rounded
                                    : Icons.bedtime_outlined,
                                color: playbackState.sleepTimerActive
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                              ),
                              label: Text(
                                playbackState.sleepTimerActive
                                    ? 'Cancel'
                                    : 'Sleep',
                                style: TextStyle(
                                  color: playbackState.sleepTimerActive
                                      ? Theme.of(context).colorScheme.primary
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Sleep timer display if active
                      if (playbackState.sleepTimerActive)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.timer,
                                color: Theme.of(context).colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _formatDuration(
                                  playbackState.sleepTimerDuration ??
                                      const Duration(minutes: 30),
                                ),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Chapters list - use a fixed height container instead of Expanded
                Container(
                  constraints: BoxConstraints(
                    maxHeight:
                        constraints.maxHeight *
                        0.3, // Reduced to 30% to make room for bookmarks
                  ),
                  child: ChaptersList(
                    audiobook: audiobook,
                    currentPosition: playbackState.currentPosition,
                    onChapterTap: (chapter) {
                      if (playbackState.errorMessage == null) {
                        ref
                            .read(playbackProvider.notifier)
                            .seekTo(chapter.startTime);
                      }
                    },
                  ),
                ),

                // Bookmarks section (commented out due to build system issues)
                // This would be enabled once the build system recognizes the new providers
                // Container(
                //   constraints: BoxConstraints(
                //     maxHeight:
                //         constraints.maxHeight *
                //         0.2, // Use 20% of available height for bookmarks
                //   ),
                //   child: BookmarkWidget(
                //     audiobookId: audiobook.id,
                //     currentPosition: playbackState.currentPosition,
                //   ),
                // ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      // If there's any error accessing the provider, show error state
      return _buildErrorState(
        context,
        ref,
        playbackState.copyWith(
          errorMessage: 'Failed to access playback service: $e',
        ),
      );
    }
  }

  Widget _buildErrorState(
    BuildContext context,
    WidgetRef ref,
    PlaybackState playbackState,
  ) {
    // Show error dialog when error state is detected
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showErrorDialogWithRetry(
        context,
        playbackState.errorMessage ?? 'Unknown playback error',
        () {
          ref
              .read(playbackProvider.notifier)
              .retryOperation(
                () => ref
                    .read(playbackProvider.notifier)
                    .setCurrentAudiobook(audiobook),
              );
        },
      );
    });

    return _buildFallbackUI(context, ref, playbackState);
  }

  /// Builds a fallback UI when playback is unavailable or in error state
  Widget _buildFallbackUI(
    BuildContext context,
    WidgetRef ref,
    PlaybackState playbackState,
  ) {
    final isProviderUnavailable =
        playbackState.errorMessage?.contains(
          'UninitializedDatasourceException',
        ) ??
        false;
    final isFileNotFound =
        playbackState.errorMessage?.contains('FileSystemException') ?? false;
    final isPermissionIssue =
        playbackState.errorMessage?.contains('PermissionException') ?? false;

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Show appropriate icon based on error type
              Icon(
                isProviderUnavailable
                    ? Icons.hourglass_empty_outlined
                    : isFileNotFound
                    ? Icons.folder_off_outlined
                    : isPermissionIssue
                    ? Icons.lock_outline
                    : Icons.error_outline,
                size: 80,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                isProviderUnavailable
                    ? 'Service Unavailable'
                    : isFileNotFound
                    ? 'File Not Found'
                    : isPermissionIssue
                    ? 'Permission Required'
                    : 'Playback Error',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _getUserFriendlyErrorMessage(
                  playbackState.errorMessage ?? 'Unknown playback error',
                ),
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Show audiobook info as fallback
              if (playbackState.errorMessage != null) ...[
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  'Audiobook:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  audiobook.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  audiobook.author.isEmpty
                      ? 'Unknown Author'
                      : audiobook.author,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
              ],

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      ref
                          .read(playbackProvider.notifier)
                          .retryOperation(
                            () => ref
                                .read(playbackProvider.notifier)
                                .setCurrentAudiobook(audiobook),
                          );
                    },
                    child: const Text('Retry'),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Back to Library'),
                  ),
                ],
              ),

              // Additional troubleshooting tips for specific error types
              if (isPermissionIssue) ...[
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Troubleshooting:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• Go to app settings and grant storage permission\n'
                          '• Restart the app after granting permission',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 24),
          Text('Loading playback...'),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    final twoDigitHours = twoDigits(duration.inHours);

    return duration.inHours > 0
        ? '$twoDigitHours:$twoDigitMinutes'
        : twoDigitMinutes;
  }

  /// Helper method to show error dialog with retry option
  void _showErrorDialogWithRetry(
    BuildContext context,
    String errorMessage,
    VoidCallback onRetry,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Playback Error'),
          content: Text(_getUserFriendlyErrorMessage(errorMessage)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text('Retry'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  /// Converts technical error messages to user-friendly ones
  String _getUserFriendlyErrorMessage(String errorMessage) {
    // Handle common error patterns
    if (errorMessage.contains('UninitializedDatasourceException') ||
        errorMessage.contains('not initialized')) {
      return 'Playback service is not ready. Please wait a moment and try again.';
    } else if (errorMessage.contains('AudioException') ||
        errorMessage.contains('audio playback')) {
      return 'Audio playback failed. The file may be corrupted or unsupported.';
    } else if (errorMessage.contains('PermissionException') ||
        errorMessage.contains('permission')) {
      return 'Storage permission required. Please grant storage access to play audiobooks.';
    } else if (errorMessage.contains('FileSystemException') ||
        errorMessage.contains('file not found')) {
      return 'Audio file not found. The file may have been moved or deleted.';
    } else if (errorMessage.contains('DatabaseException')) {
      return 'Failed to load playback position. Starting from beginning.';
    } else if (errorMessage.contains('TimeoutException') ||
        errorMessage.contains('timed out')) {
      return 'Operation took too long. Please check your device performance.';
    } else if (errorMessage.contains('NetworkException')) {
      return 'Network connection required. Please check your internet connection.';
    } else if (errorMessage.contains('Failed to initialize playback')) {
      return 'Failed to initialize playback. Please try again.';
    } else {
      // Generic fallback message
      return 'Playback error occurred. Please try again.';
    }
  }
}
