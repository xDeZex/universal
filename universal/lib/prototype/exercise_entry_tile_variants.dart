import 'package:flutter/material.dart';

import '../models/workout.dart';
import 'exercise_entry_tile_shared.dart';

// PROTOTYPE — throwaway. Row/card/divider/selection variants for
// ExerciseEntryTile, split out of widgets/exercise_entry_tile.dart to stay
// under the repo's 300-line file limit. Answers wayfinder issue #212.

Widget buildCurrentEntryTile(
  BuildContext context,
  ThemeData theme, {
  required ExerciseEntry entry,
  required String exerciseName,
  required bool locked,
  required bool selected,
  required VoidCallback onSelect,
  required VoidCallback onDeleteEntry,
  required void Function(ExerciseSet set) onSetTap,
}) {
  final tint = selected ? theme.colorScheme.secondaryContainer : null;
  return Material(
    key: ValueKey('entry-${entry.id}'),
    color: tint ?? Colors.transparent,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        entryHeader(
          theme,
          key: ValueKey('entry-header-${entry.id}'),
          exerciseName: exerciseName,
          locked: locked,
          onSelect: onSelect,
          onDeleteEntry: onDeleteEntry,
          deleteKey: ValueKey('delete-entry-${entry.id}'),
        ),
        if (entry.sets.isNotEmpty) columnHeaderRow(theme, locked: locked),
        for (var i = 0; i < entry.sets.length; i++) ...[
          const Divider(height: 1, indent: setColumnWidth + 16),
          setRow(theme, context, i, entry.sets[i], locked: locked, onTap: onSetTap),
        ],
      ],
    ),
  );
}

Widget buildGapListEntryTile(
  BuildContext context,
  ThemeData theme, {
  required ExerciseEntry entry,
  required String exerciseName,
  required bool locked,
  required bool selected,
  required VoidCallback onSelect,
  required VoidCallback onDeleteEntry,
  required void Function(ExerciseSet set) onSetTap,
}) {
  // Selection = solid container-color swap on the entry's own rounded
  // container; set rows are gap/zebra-separated instead of divided.
  return Material(
    key: ValueKey('entry-${entry.id}'),
    color: selected
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.surfaceContainerHigh,
    borderRadius: BorderRadius.circular(16),
    clipBehavior: Clip.antiAlias,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        entryHeader(
          theme,
          key: ValueKey('entry-header-${entry.id}'),
          exerciseName: exerciseName,
          locked: locked,
          onSelect: onSelect,
          onDeleteEntry: onDeleteEntry,
          deleteKey: ValueKey('delete-entry-${entry.id}'),
          tint: selected ? theme.colorScheme.onPrimaryContainer : null,
        ),
        if (entry.sets.isNotEmpty) columnHeaderRow(theme, locked: locked),
        for (var i = 0; i < entry.sets.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: setRow(
              theme,
              context,
              i,
              entry.sets[i],
              locked: locked,
              onTap: onSetTap,
              bg: i.isOdd ? theme.colorScheme.surface.withValues(alpha: 0.3) : null,
            ),
          ),
        const SizedBox(height: 4),
      ],
    ),
  );
}

Widget buildAccentBarEntryTile(
  BuildContext context,
  ThemeData theme, {
  required ExerciseEntry entry,
  required String exerciseName,
  required bool locked,
  required bool selected,
  required VoidCallback onSelect,
  required VoidCallback onDeleteEntry,
  required void Function(ExerciseSet set) onSetTap,
}) {
  // Selection = a left accent bar, so it never competes with the
  // full-width dividers this variant keeps between set rows.
  return Container(
    key: ValueKey('entry-${entry.id}'),
    decoration: selected
        ? BoxDecoration(
            border: Border(
              left: BorderSide(color: theme.colorScheme.primary, width: 4),
            ),
            color: theme.colorScheme.surfaceContainerLow,
          )
        : null,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        entryHeader(
          theme,
          key: ValueKey('entry-header-${entry.id}'),
          exerciseName: exerciseName,
          locked: locked,
          onSelect: onSelect,
          onDeleteEntry: onDeleteEntry,
          deleteKey: ValueKey('delete-entry-${entry.id}'),
        ),
        if (entry.sets.isNotEmpty) columnHeaderRow(theme, locked: locked),
        for (var i = 0; i < entry.sets.length; i++) ...[
          const Divider(height: 1, indent: setColumnWidth + 16),
          setRow(theme, context, i, entry.sets[i], locked: locked, onTap: onSetTap),
        ],
      ],
    ),
  );
}

Widget buildCoplanarCardEntryTile(
  BuildContext context,
  ThemeData theme, {
  required ExerciseEntry entry,
  required String exerciseName,
  required bool locked,
  required bool selected,
  required VoidCallback onSelect,
  required VoidCallback onDeleteEntry,
  required void Function(ExerciseSet set) onSetTap,
}) {
  // Coplanar card; header tint + check icon signal selection, and set
  // rows are separated by an inset divider (inside one card) rather
  // than a full-width one.
  return Card(
    key: ValueKey('entry-${entry.id}'),
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    color: selected ? theme.colorScheme.primaryContainer : null,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        entryHeader(
          theme,
          key: ValueKey('entry-header-${entry.id}'),
          exerciseName: exerciseName,
          locked: locked,
          onSelect: onSelect,
          onDeleteEntry: onDeleteEntry,
          deleteKey: ValueKey('delete-entry-${entry.id}'),
          tint: selected ? theme.colorScheme.onPrimaryContainer : null,
        ),
        if (entry.sets.isNotEmpty) columnHeaderRow(theme, locked: locked),
        for (var i = 0; i < entry.sets.length; i++) ...[
          Divider(
            height: 1,
            indent: setColumnWidth + 16,
            endIndent: 16,
            color: selected
                ? theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.3)
                : null,
          ),
          setRow(theme, context, i, entry.sets[i], locked: locked, onTap: onSetTap),
        ],
      ],
    ),
  );
}
