// lib/features/player/presentation/views/playback_screen.dart
import 'package:flutbook/features/library/domain/entities/audiobook.dart';
import 'package:flutbook/features/player/presentation/providers/playback_provider.dart';
import 'package:flutbook/features/player/presentation/widgets/chapters_list.dart';
import 'package:flutbook/features/player/presentation/widgets/playback_controls.dart';
import 'package:flutbook/features/player/presentation/widgets/progress_bar.dart';
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
      body: Column(
        children: [
          // Cover art display
          Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Container(
                width: 250,
                height: 250,
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
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
              ),
            ),
          ),

          // Audiobook info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Progress bar with seeking capability
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            width: double.infinity,
            child: ProgressBar(
              currentPosition: playbackState.currentPosition,
              totalDuration: playbackState.duration,
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

          // Playback controls
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: PlaybackControls(
              isPlaying: playbackState.isPlaying,
              playbackSpeed: playbackState.playbackSpeed,
              sleepTimerActive: playbackState.sleepTimerActive,
              sleepTimerDuration: playbackState.sleepTimerDuration ?? const Duration(minutes: 30),
              onPlayPause: () {
                final notifier = ref.read(playbackProvider.notifier);
                if (playbackState.isPlaying) {
                  notifier.pause();
                } else {
                  notifier.play();
                }
              },
              onSpeedChanged: (newSpeed) {
                ref.read(playbackProvider.notifier).setSpeed(newSpeed);
              },
              onSleepTimerToggle: (active) {
                final notifier = ref.read(playbackProvider.notifier);
                if (active) {
                  notifier.setSleepTimer(const Duration(minutes: 30)); // Default 30 minutes
                } else {
                  notifier.cancelSleepTimer();
                }
              },
              onSkipForward: (duration) {
                ref.read(playbackProvider.notifier).skipForward(duration);
              },
              onSkipBackward: (duration) {
                ref.read(playbackProvider.notifier).skipBackward(duration);
              },
            ),
          ),

          const SizedBox(height: 16),

          // Chapters list
          Expanded(
            flex: 2,
            child: ChaptersList(
              audiobook: audiobook,
              currentPosition: playbackState.currentPosition,
              onChapterTap: (chapter) {
                ref.read(playbackProvider.notifier).seekTo(chapter.startTime);
              },
            ),
          ),
        ],
      ),
    );
  }
}
