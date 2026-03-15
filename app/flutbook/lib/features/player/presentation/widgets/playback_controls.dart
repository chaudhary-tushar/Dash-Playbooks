// lib/presentation/widgets/playback_controls.dart
import 'package:flutter/material.dart';

class PlaybackControls extends StatefulWidget {
  const PlaybackControls({
    required this.isPlaying,
    required this.playbackSpeed,
    required this.sleepTimerActive,
    required this.sleepTimerDuration,
    required this.onPlayPause,
    required this.onSpeedChanged,
    required this.onSleepTimerToggle,
    required this.onSkipForward,
    required this.onSkipBackward,
    this.perBookSpeedEnabled = false,
    this.onPerBookSpeedToggle,
    super.key,
  });
  final bool isPlaying;
  final double playbackSpeed;
  final bool sleepTimerActive;
  final Duration sleepTimerDuration;
  final void Function() onPlayPause;
  final void Function(double) onSpeedChanged;
  final void Function({required bool value}) onSleepTimerToggle;
  final void Function(Duration) onSkipForward;
  final void Function(Duration) onSkipBackward;
  final bool perBookSpeedEnabled;
  final void Function(bool)? onPerBookSpeedToggle;

  @override
  PlaybackControlsState createState() => PlaybackControlsState();
}

class PlaybackControlsState extends State<PlaybackControls> {
  late double _currentSpeed;

  @override
  void initState() {
    super.initState();
    _currentSpeed = widget.playbackSpeed;
  }

  @override
  void didUpdateWidget(PlaybackControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.playbackSpeed != widget.playbackSpeed) {
      _currentSpeed = widget.playbackSpeed;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Main playback controls row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Skip backward button
                IconButton(
                  iconSize: 48,
                  icon: const Icon(Icons.replay_10_outlined),
                  onPressed: () {
                    widget.onSkipBackward(const Duration(seconds: 10));
                  },
                ),

                // Previous button (for multiple chapters)
                IconButton(
                  iconSize: 36,
                  icon: const Icon(Icons.skip_previous_outlined),
                  onPressed: () {
                    // Implement previous chapter functionality
                  },
                ),

                // Play/Pause button (main control)
                IconButton(
                  iconSize: 72,
                  icon: Icon(
                    widget.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: widget.onPlayPause,
                ),

                // Next button (for multiple chapters)
                IconButton(
                  iconSize: 36,
                  icon: const Icon(Icons.skip_next_outlined),
                  onPressed: () {
                    // Implement next chapter functionality
                  },
                ),

                // Skip forward button
                IconButton(
                  iconSize: 48,
                  icon: const Icon(Icons.forward_30_outlined),
                  onPressed: () {
                    widget.onSkipForward(const Duration(seconds: 30));
                  },
                ),
              ],
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
                    padding: const EdgeInsets.symmetric(horizontal: 8),
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
                          value: _currentSpeed,
                          items: [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]
                              .map(
                                (speed) => DropdownMenuItem(
                                  value: speed,
                                  child: Text('${speed}x'),
                                ),
                              )
                              .toList(),
                          onChanged: (speed) {
                            setState(() {
                              _currentSpeed = speed ?? 1.0;
                            });
                            widget.onSpeedChanged(_currentSpeed);
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Per-book speed toggle
                if (widget.onPerBookSpeedToggle != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        widget.onPerBookSpeedToggle!(!widget.perBookSpeedEnabled);
                      },
                      icon: Icon(
                        widget.perBookSpeedEnabled ? Icons.bookmark : Icons.bookmark_border,
                        color: widget.perBookSpeedEnabled
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      label: Text(
                        'Per Book',
                        style: TextStyle(
                          color: widget.perBookSpeedEnabled
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(width: 16),

                // Sleep timer toggle
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      widget.onSleepTimerToggle(value: !widget.sleepTimerActive);
                    },
                    icon: Icon(
                      widget.sleepTimerActive ? Icons.bedtime_rounded : Icons.bedtime_outlined,
                      color: widget.sleepTimerActive ? Theme.of(context).colorScheme.primary : null,
                    ),
                    label: Text(
                      'Sleep',
                      style: TextStyle(
                        color: widget.sleepTimerActive
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Sleep timer display if active
            if (widget.sleepTimerActive)
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(
                    (Theme.of(context).colorScheme.primary.red * 255.0).round().clamp(0, 255),
                    (Theme.of(context).colorScheme.primary.green * 255.0).round().clamp(0, 255),
                    (Theme.of(context).colorScheme.primary.blue * 255.0).round().clamp(0, 255),
                    0.1,
                  ),
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
                      _formatDuration(widget.sleepTimerDuration),
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
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    final twoDigitHours = twoDigits(duration.inHours);

    return duration.inHours > 0 ? '$twoDigitHours:$twoDigitMinutes' : twoDigitMinutes;
  }
}
