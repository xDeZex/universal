import 'package:flutter/material.dart';

import '../models/workout.dart';

// PROTOTYPE — throwaway. Shared header/set-row rendering for the
// ExerciseEntryTile row/card/divider/selection variants (see
// exercise_entry_tile_variants.dart). Answers wayfinder issue #212.
const setColumnWidth = 34.0;
const timeColumnWidth = 64.0;

Widget entryHeader(
  ThemeData theme, {
  required Key key,
  required String exerciseName,
  required bool locked,
  required VoidCallback? onSelect,
  required VoidCallback onDeleteEntry,
  required Key deleteKey,
  Color? tint,
}) {
  return InkWell(
    key: key,
    onTap: locked ? null : onSelect,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (tint != null) ...[
            Icon(Icons.check_circle, size: 18, color: tint),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              exerciseName,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: tint,
              ),
            ),
          ),
          IconButton(
            key: deleteKey,
            icon: const Icon(Icons.delete),
            onPressed: onDeleteEntry,
          ),
        ],
      ),
    ),
  );
}

Widget columnHeaderRow(ThemeData theme, {required bool locked}) {
  final style = theme.textTheme.labelSmall?.copyWith(
    color: theme.colorScheme.onSurfaceVariant,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.6,
  );
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
    child: Row(
      children: [
        SizedBox(width: setColumnWidth, child: Text('SET', style: style)),
        Expanded(child: Text('WEIGHT', style: style)),
        Expanded(child: Text('REPS', style: style)),
        SizedBox(
          width: timeColumnWidth,
          child: locked
              ? Text('TIME', style: style, textAlign: TextAlign.right)
              : null,
        ),
      ],
    ),
  );
}

Widget setRow(
  ThemeData theme,
  BuildContext context,
  int index,
  ExerciseSet set, {
  required bool locked,
  required void Function(ExerciseSet set) onTap,
  Color? bg,
}) {
  final mutedStyle = theme.textTheme.bodyMedium?.copyWith(
    color: theme.colorScheme.onSurfaceVariant,
  );
  return Container(
    color: bg,
    child: InkWell(
      key: ValueKey('set-${set.id}'),
      onTap: () => onTap(set),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: setColumnWidth,
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
              width: timeColumnWidth,
              child: locked
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
    ),
  );
}
