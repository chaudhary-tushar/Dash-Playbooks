// lib/presentation/widgets/chapter_list.dart
import 'package:flutter/material.dart';
import '../../domain/entities/chapter.dart';

class ChapterList extends StatefulWidget {
  final List<Chapter> chapters;
  final Chapter? currentChapter;
  final Function(Chapter)? onChapterSelected;
  final bool isExpanded;

  const ChapterList({
    Key? key,
    required this.chapters,
    this.currentChapter,
    this.onChapterSelected,
    this.isExpanded = true,
  }) : super(key: key);

  @override
  State<ChapterList> createState() => _ChapterListState();
}
}

class _ChapterListState extends State<ChapterList> {
  @override
  Widget build(BuildContext context) {
    if (widget.chapters.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedCrossFade(
      firstChild: ExpansionTile(
        title: const Text('Chapters'),
        children: _buildChapterList(),
        initiallyExpanded: false,
      ),
      secondChild: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Chapters',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ..._buildChapterList(),
        ],
      ),
      crossFadeState: widget.isExpanded
          ? CrossFadeState.showSecond
          : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 300),
    );
  }

  List<Widget> _buildChapterList() {
    return widget.chapters.asMap().entries.map((entry) {
      int index = entry.key;
      Chapter chapter = entry.value;
      bool isCurrent = widget.currentChapter?.id == chapter.id;

      return ListTile(
        title: Text(
          chapter.title,
          style: TextStyle(
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            color: isCurrent 
              ? Theme.of(context).colorScheme.primary 
              : Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          '${_formatDuration(chapter.startTime)} - ${_formatDuration(chapter.endTime)}',
          style: TextStyle(
            color: isCurrent 
              ? Theme.of(context).colorScheme.primary 
              : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Icon(
          Icons.play_arrow,
          color: isCurrent 
            ? Theme.of(context).colorScheme.primary 
            : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        selected: isCurrent,
        selectedColor: Theme.of(context).colorScheme.primary,
        onTap: () => widget.onChapterSelected?.call(chapter),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        tileColor: isCurrent
            ? Theme.of(context).colorScheme.primaryContainer
            : Colors.transparent,
      );
    }).toList();
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
}