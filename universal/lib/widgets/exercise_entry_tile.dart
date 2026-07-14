import 'package:flutter/material.dart';

import '../models/workout.dart';
import 'confirm_delete_dialog.dart';
import 'edit_set_dialog.dart';

class ExerciseEntryTile extends StatefulWidget {
  final ExerciseEntry entry;
  final String exerciseName;
  final bool locked;
  final bool selected;
  final VoidCallback onSelect;
  final void Function(String setId, num weight, WeightUnit unit, int reps)
  onEditSet;
  final void Function(String setId) onDeleteSet;
  final VoidCallback onDeleteEntry;

  const ExerciseEntryTile({
    super.key,
    required this.entry,
    required this.exerciseName,
    required this.locked,
    required this.selected,
    required this.onSelect,
    required this.onEditSet,
    required this.onDeleteSet,
    required this.onDeleteEntry,
  });

  @override
  State<ExerciseEntryTile> createState() => _ExerciseEntryTileState();
}

class _ExerciseEntryTileState extends State<ExerciseEntryTile> {
  static const _setColumnWidth = 34.0;
  static const _timeColumnWidth = 64.0;

  Future<void> _openEditDialog(ExerciseSet set) async {
    final result = await showDialog<EditSetDialogResult>(
      context: context,
      builder: (context) => EditSetDialog(set: set),
    );
    switch (result) {
      case EditSetSubmitted(:final weight, :final unit, :final reps):
        widget.onEditSet(set.id, weight, unit, reps);
      case EditSetDeleted():
        widget.onDeleteSet(set.id);
      case null:
        break;
    }
  }

  Future<void> _deleteEntry() async {
    final count = widget.entry.sets.length;
    final message = count == 0
        ? 'Delete this Exercise Entry?'
        : 'Delete this Exercise Entry and all $count of its Sets?';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDeleteDialog(message: message),
    );
    if (confirmed != true) return;
    widget.onDeleteEntry();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tint = widget.selected ? theme.colorScheme.secondaryContainer : null;
    return Material(
      key: ValueKey('entry-${widget.entry.id}'),
      color: tint ?? Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            key: ValueKey('entry-header-${widget.entry.id}'),
            onTap: widget.locked ? null : widget.onSelect,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.exerciseName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    key: ValueKey('delete-entry-${widget.entry.id}'),
                    icon: const Icon(Icons.delete),
                    onPressed: _deleteEntry,
                  ),
                ],
              ),
            ),
          ),
          if (widget.entry.sets.isNotEmpty) _columnHeaderRow(theme),
          for (var i = 0; i < widget.entry.sets.length; i++) ...[
            const Divider(height: 1, indent: _setColumnWidth + 16),
            _setRow(theme, i, widget.entry.sets[i]),
          ],
        ],
      ),
    );
  }

  Widget _columnHeaderRow(ThemeData theme) {
    final style = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.6,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Row(
        children: [
          SizedBox(
            width: _setColumnWidth,
            child: Text('SET', style: style),
          ),
          Expanded(child: Text('WEIGHT', style: style)),
          Expanded(child: Text('REPS', style: style)),
          SizedBox(
            width: _timeColumnWidth,
            child: widget.locked
                ? Text('TIME', style: style, textAlign: TextAlign.right)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _setRow(ThemeData theme, int index, ExerciseSet set) {
    final mutedStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return InkWell(
      key: ValueKey('set-${set.id}'),
      onTap: () => _openEditDialog(set),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: _setColumnWidth,
              child: CircleAvatar(
                radius: 12,
                backgroundColor: theme.colorScheme.surfaceContainerHigh,
                child: Text(
                  '${index + 1}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Text(
                '${set.weight} ${set.unit.name}',
                key: ValueKey('set-weight-${set.id}'),
                style: theme.textTheme.bodyMedium,
              ),
            ),
            Expanded(
              child: Text(
                '${set.reps}',
                key: ValueKey('set-reps-${set.id}'),
                style: mutedStyle,
              ),
            ),
            SizedBox(
              width: _timeColumnWidth,
              child: widget.locked
                  ? Text(
                      TimeOfDay.fromDateTime(set.loggedAt).format(context),
                      key: ValueKey('set-time-${set.id}'),
                      textAlign: TextAlign.right,
                      style: mutedStyle?.copyWith(fontSize: 12),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
