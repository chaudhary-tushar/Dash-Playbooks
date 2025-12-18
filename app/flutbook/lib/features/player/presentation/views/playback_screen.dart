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
    ref.read(playbackProvider.notifier).setCurrentAudiobook(audiobook);

    final playbackState = ref.watch(playbackProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Now Playing'),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Determine if we're on a small screen (mobile)
          final isMobile = constraints.maxWidth < 600;
          final coverSize = isMobile ? 250.0 : 300.0;
          final horizontalPadding = isMobile ? 16.0 : 32.0;

          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
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
                                ).withValues(alpha: 0.2),
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
                          ref
                              .read(playbackProvider.notifier)
                              .seekTo(newPosition);
                        },
                        onSeekStart: () async {
                          // Handle seek start if needed
                        },
                        onSeekEnd: (finalPosition) async {
                          ref
                              .read(playbackProvider.notifier)
                              .seekTo(finalPosition);
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
                                onPressed: () async {
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
                                onPressed: () async {
                                  await ref
                                      .read(playbackProvider.notifier)
                                      .skipForward(const Duration(seconds: 30));
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Main play/pause FAB
                          Center(
                            child: FloatingActionButton(
                              onPressed: () async {
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
                                        items:
                                            [
                                                  0.5,
                                                  0.75,
                                                  1.0,
                                                  1.25,
                                                  1.5,
                                                  2.0,
                                                ]
                                                .map(
                                                  (speed) => DropdownMenuItem(
                                                    value: speed,
                                                    child: Text('${speed}x'),
                                                  ),
                                                )
                                                .toList(),
                                        onChanged: (speed) {
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

                              // Sleep timer toggle
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () async {
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
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.primary
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
                                ).colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.timer,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
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
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Chapters list
                    Expanded(
                      flex: 2,
                      child: ChaptersList(
                        audiobook: audiobook,
                        currentPosition: playbackState.currentPosition,
                        onChapterTap: (chapter) async {
                          await ref
                              .read(playbackProvider.notifier)
                              .seekTo(chapter.startTime);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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
}
