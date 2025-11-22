// lib/presentation/screens/playback_screen.dart
import 'package:flutbook/features/library/domain/entities/audiobook.dart';
import 'package:flutbook/features/library/data/models/audiobook_model.dart';
import 'package:flutbook/features/playback/presentation/widgets/playback_controls.dart';
import 'package:flutbook/features/playback/presentation/widgets/progress_bar.dart';
import 'package:flutter/material.dart';

class PlaybackScreen extends StatefulWidget {
  const PlaybackScreen({
    required this.audiobook,
    super.key,
  });
  final AudiobookModel audiobook;

  @override
  PlaybackScreenState createState() => PlaybackScreenState();
}

class PlaybackScreenState extends State<PlaybackScreen> {
  late Audiobook audiobook;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get the audiobook from the route arguments
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is Audiobook) {
      audiobook = args;
    } else {
      // Default audiobook in case arguments are not passed correctly
      audiobook = Audiobook(
        id: 'default',
        title: 'Default Title',
        author: 'Default Author',
        album: 'Default Album',
        duration: Duration.zero,
        filePath: '',
        chapters: [],
        createdAt: DateTime.now(),
        completed: false,
        totalSize: 0,
      );
    }
  }

  // These would connect to actual playback state providers in a complete implementation
  bool _isPlaying = false;
  double _playbackSpeed = 1;
  bool _sleepTimerActive = false;
  final Duration _sleepTimerDuration = const Duration(minutes: 30);
  Duration _currentPosition = Duration.zero;
  Duration _scrubPosition = Duration.zero;
  bool _isScrubbing = false;

  @override
  Widget build(BuildContext context) {
    final _ = Theme.of(context);

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
                      color: const Color.fromARGB(255, 0, 0, 0).withValues(),
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
                  audiobook.author.isEmpty ? 'Unknown Author' : audiobook.author,
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
              currentPosition: _isScrubbing ? _scrubPosition : _currentPosition,
              totalDuration: audiobook.duration,
              chapterMarkers: audiobook.chapters.map((chapter) => chapter.startTime).toList(),
              onSeek: (newPosition) {
                setState(() {
                  _scrubPosition = newPosition;
                });
              },
              onSeekStart: () {
                setState(() {
                  _isScrubbing = true;
                });
              },
              onSeekEnd: (finalPosition) {
                setState(() {
                  _currentPosition = finalPosition;
                  _isScrubbing = false;
                  // In a real implementation, this would update the playback position
                  print('Seek to: ${_formatDuration(finalPosition)}');
                });
              },
            ),
          ),

          const SizedBox(height: 24),

          // Playback controls
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: PlaybackControls(
                isPlaying: _isPlaying,
                playbackSpeed: _playbackSpeed,
                sleepTimerActive: _sleepTimerActive,
                sleepTimerDuration: _sleepTimerDuration,
                onPlayPause: () {
                  setState(() {
                    _isPlaying = !_isPlaying;
                  });
                  // In a real implementation, this would trigger playback/pause
                },
                onSpeedChanged: (newSpeed) {
                  setState(() {
                    _playbackSpeed = newSpeed;
                  });
                  // In a real implementation, this would update the playback speed
                },
                onSleepTimerToggle: (active) {
                  setState(() {
                    _sleepTimerActive = active;
                  });
                  // In a real implementation, this would activate/deactivate the sleep timer
                },
                onSkipForward: (duration) {
                  setState(() {
                    final newPosition = _currentPosition + duration;
                    _currentPosition = newPosition.compareTo(audiobook.duration) > 0
                        ? audiobook.duration
                        : newPosition;
                  });
                  // In a real implementation, this would skip forward in playback
                },
                onSkipBackward: (duration) {
                  setState(() {
                    final newPosition = _currentPosition - duration;
                    _currentPosition = newPosition.isNegative ? Duration.zero : newPosition;
                  });
                  // In a real implementation, this would skip backward in playback
                },
              ),
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
}
