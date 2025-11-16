// lib/presentation/screens/audiobook_detail_screen.dart
import 'package:flutter/material.dart';
import '../widgets/progress_bar.dart';
import '../../domain/entities/audiobook.dart';

class AudiobookDetailScreen extends StatefulWidget {
  final Audiobook audiobook;

  const AudiobookDetailScreen({
    Key? key,
    required this.audiobook,
  }) : super(key: key);

  @override
  _AudiobookDetailScreenState createState() => _AudiobookDetailScreenState();
}

class _AudiobookDetailScreenState extends State<AudiobookDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Audiobook Details'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
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
                  child: widget.audiobook.coverArtPath != null
                      ? Image.network(
                          widget.audiobook.coverArtPath!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.album_outlined,
                              size: 80,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
              
              SizedBox(height: 16),
              
              // Title and author
              Text(
                widget.audiobook.title,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 8),
              
              Text(
                widget.audiobook.author.isEmpty ? 'Unknown Author' : widget.audiobook.author,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 16),
              
              // Basic metadata
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMetadataRow('Duration', _formatDuration(widget.audiobook.duration)),
                      _buildMetadataRow('File Size', _formatFileSize(widget.audiobook.totalSize)),
                      _buildMetadataRow('File Path', widget.audiobook.filePath.split('/').last),
                      _buildMetadataRow('Added', 
                          widget.audiobook.createdAt.toLocal().toString().split('.').first),
                      if (widget.audiobook.lastPlayedAt != null)
                        _buildMetadataRow('Last Played', 
                            widget.audiobook.lastPlayedAt!.toLocal().toString().split('.').first),
                      _buildMetadataRow('Status', 
                          widget.audiobook.completed ? 'Completed' : 'In Progress'),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 16),
              
              // Progress section
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progress',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      
                      SizedBox(height: 8),
                      
                      // Simplified progress bar - actual progress would come from playback repository
                      Container(
                        width: double.infinity,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Theme.of(context).dividerColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Container(
                          width: 0.6 * MediaQuery.of(context).size.width, // Placeholder: actual progress would be dynamic
                          height: 4,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 8),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '60%', // Placeholder: actual progress percentage
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            _formatDuration(widget.audiobook.duration),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 16),
              
              // Chapter navigation (if chapters exist)
              if (widget.audiobook.chapters.isNotEmpty) ...[
                Text(
                  'Chapters',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                
                SizedBox(height: 8),
                
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        for (int i = 0; i < widget.audiobook.chapters.length; i++)
                          ListTile(
                            title: Text(widget.audiobook.chapters[i].title),
                            subtitle: Text(
                              '${_formatDuration(widget.audiobook.chapters[i].startTime)} - ${_formatDuration(widget.audiobook.chapters[i].endTime)}',
                            ),
                            trailing: Icon(Icons.play_arrow),
                            onTap: () {
                              // Handle chapter selection
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ],
              
              SizedBox(height: 16),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.play_arrow),
                      label: Text('Play'),
                      onPressed: () {
                        // Navigate to playback screen with this audiobook
                        Navigator.pushNamed(
                          context,
                          '/playback',
                          arguments: {'audiobook': widget.audiobook},
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: Icon(Icons.share_outlined),
                      label: Text('Share'),
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

  Widget _buildMetadataRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
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
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitHours = twoDigits(duration.inHours);
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

    return duration.inHours > 0
        ? "$twoDigitHours:$twoDigitMinutes:$twoDigitSeconds"
        : "$twoDigitMinutes:$twoDigitSeconds";
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return "$bytes B";
    if (bytes < 1024 * 1024) return "${(bytes / 1024).toStringAsFixed(1)} KB";
    if (bytes < 1024 * 1024 * 1024) return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB";
    return "${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB";
  }
}