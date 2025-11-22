// lib/presentation/widgets/audiobook_card.dart
import 'package:flutter/material.dart';

class AudiobookCard extends StatelessWidget {
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
  });
  final String title;
  final String author;
  final String? coverArtPath;
  final Duration duration;
  final bool isCompleted;
  final double? progress;
  final VoidCallback onTap;
  final bool showPlayButton;

  @override
  Widget build(BuildContext context) {
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
                    ? Image.network(
                        coverArtPath!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: isDark ? Colors.grey[800] : Colors.grey[300],
                            child: Icon(
                              Icons.album_outlined,
                              color: isDark
                                  ? Colors.grey[600]
                                  : Colors.grey[400],
                              size: 40,
                            ),
                          );
                        },
                      )
                    : Container(
                        color: isDark ? Colors.grey[800] : Colors.grey[300],
                        child: Icon(
                          Icons.album_outlined,
                          color: isDark ? Colors.grey[600] : Colors.grey[400],
                          size: 40,
                        ),
                      ),
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
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
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
                              backgroundColor: isDark
                                  ? Colors.grey[700]
                                  : Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  '${(progress! * 100).round()}%',
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                                const Spacer(),
                                Text(
                                  _formatDuration(duration),
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
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
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
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
                  onPressed: onTap,
                  tooltip: 'Play',
                ),
            ],
          ),
        ),
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
}
