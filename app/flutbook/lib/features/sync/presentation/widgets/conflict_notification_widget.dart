/// Compact widget that shows a conflict badge and opens the resolution view.
library;

import 'package:flutbook/features/sync/presentation/providers/conflict_resolver_provider.dart';
import 'package:flutbook/features/sync/presentation/views/conflict_resolution_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A chip or icon badge that shows how many conflicts need attention.
///
/// Tapping it navigates to [ConflictResolutionView].
/// Pass [compact: true] for a plain icon suitable for an AppBar.
class ConflictNotificationWidget extends ConsumerWidget {
  const ConflictNotificationWidget({super.key, this.compact = false});

  /// When true, renders as a small [IconButton] with a badge overlay.
  /// When false, renders as a filled chip with a count label.
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(conflictResolverProvider);
    final count = state.pendingCount;

    if (!state.hasConflicts) return const SizedBox.shrink();

    return compact ? _CompactBadge(count: count) : _FullChip(count: count);
  }
}

class _CompactBadge extends StatelessWidget {
  const _CompactBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Badge(
      label: Text('$count'),
      child: IconButton(
        icon: const Icon(Icons.warning_amber),
        color: Colors.orange,
        tooltip: '$count sync conflict(s) need attention',
        onPressed: () => _openView(context),
      ),
    );
  }
}

class _FullChip extends StatelessWidget {
  const _FullChip({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: const Icon(Icons.warning_amber, size: 18, color: Colors.orange),
      label: Text(
        '$count conflict${count == 1 ? '' : 's'} need attention',
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      backgroundColor: Colors.orange[50],
      side: BorderSide(color: Colors.orange[300]!),
      onPressed: () => _openView(context),
    );
  }
}

Future<void> _openView(BuildContext context) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => const ConflictResolutionView(),
    ),
  );
}
