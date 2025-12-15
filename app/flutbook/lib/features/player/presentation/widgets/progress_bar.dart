// lib/presentation/widgets/progress_bar.dart
import 'package:flutter/material.dart';
import 'dart:async';

class ProgressBar extends StatefulWidget {
  const ProgressBar({
    required this.currentPosition,
    required this.totalDuration,
    required this.onSeek,
    super.key,
    this.chapterMarkers = const [],
    this.onSeekStart,
    this.onSeekEnd,
    this.isLoading = false,
  });
  final Duration currentPosition;
  final Duration totalDuration;
  final List<Duration> chapterMarkers; // Positions of chapters if available
  final Function(Duration) onSeek;
  final Future<void> Function()? onSeekStart;
  final Future<void> Function(Duration)? onSeekEnd;
  final bool isLoading;

  @override
  ProgressBarState createState() => ProgressBarState();
}

class ProgressBarState extends State<ProgressBar> {
  double get _currentSliderPosition {
    if (widget.totalDuration.inMilliseconds == 0) return 0;
    return widget.currentPosition.inMilliseconds /
        widget.totalDuration.inMilliseconds;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final inactiveColor = isDark ? Colors.grey[700] : Colors.grey[300];

    return Column(
      children: [
        // Main progress bar
        GestureDetector(
          onPanDown: (details) {
            _handleSeekStart(details.localPosition.dx);
          },
          onPanUpdate: (details) {
            _handleSeek(details.localPosition.dx);
          },
          onPanEnd: (details) {
            _handleSeekEnd(details.localPosition.dx);
          },
          child: SizedBox(
            height: 40,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background progress track
                Container(
                  width: double.infinity,
                  height: 4,
                  decoration: BoxDecoration(
                    color: inactiveColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Chapter markers
                if (widget.chapterMarkers.isNotEmpty)
                  for (int i = 0; i < widget.chapterMarkers.length; i++)
                    Positioned(
                      left:
                          (widget.chapterMarkers[i].inMilliseconds /
                              widget.totalDuration.inMilliseconds) *
                          MediaQuery.of(context).size.width,
                      child: Container(
                        width: 2,
                        height: 8,
                        color: Color.fromRGBO(primaryColor.red, primaryColor.green, primaryColor.blue, 0.7),
                      ),
                    ),

                // Buffered progress (simulated)
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromRGBO(primaryColor.red, primaryColor.green, primaryColor.blue, 0.5),
                        Color.fromRGBO(primaryColor.red, primaryColor.green, primaryColor.blue, 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Completed progress
                Container(
                  width:
                      _currentSliderPosition *
                      MediaQuery.of(context).size.width,
                  height: 4,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(2),
                      bottomLeft: const Radius.circular(2),
                      topRight: _currentSliderPosition == 1.0
                          ? const Radius.circular(2)
                          : Radius.zero,
                      bottomRight: _currentSliderPosition == 1.0
                          ? const Radius.circular(2)
                          : Radius.zero,
                    ),
                  ),
                ),

                // Seek handle
                Positioned(
                  left:
                      _currentSliderPosition *
                      MediaQuery.of(context).size.width,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(Colors.black.red, Colors.black.green, Colors.black.blue, 0.3),
                          blurRadius: 2,
                          offset: const Offset(1, 1),
                        ),
                      ],
                    ),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Time labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDuration(widget.currentPosition),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            if (widget.isLoading)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              )
            else
              Text(
                _formatDuration(widget.totalDuration),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ],
    );
  }

  void _handleSeek(double dx) {
    final renderBox = context.findRenderObject()! as RenderBox;
    final width = renderBox.size.width;
    final percent = (dx / width).clamp(0.0, 1.0);
    final newDuration = Duration(
      milliseconds: (percent * widget.totalDuration.inMilliseconds).round(),
    );

    if (mounted) {
      widget.onSeek(newDuration);
    }
  }

  void _handleSeekStart(double dx) {
    unawaited(widget.onSeekStart?.call());
    _handleSeek(dx);
  }

  void _handleSeekEnd(double dx) {
    final renderBox = context.findRenderObject()! as RenderBox;
    final width = renderBox.size.width;
    final percent = (dx / width).clamp(0.0, 1.0);
    final newDuration = Duration(
      milliseconds: (percent * widget.totalDuration.inMilliseconds).round(),
    );

    unawaited(widget.onSeekEnd?.call(newDuration));
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
