import 'package:flutter/material.dart';

import '../models/workout.dart';
import '../prototype/exercise_entry_tile_variants.dart';
import '../prototype/row_card_variant.dart';
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
    return ValueListenableBuilder<RowCardVariant>(
      valueListenable: rowCardVariant,
      builder: (context, variant, _) {
        final args = (
          entry: widget.entry,
          exerciseName: widget.exerciseName,
          locked: widget.locked,
          selected: widget.selected,
          onSelect: widget.onSelect,
          onDeleteEntry: _deleteEntry,
          onSetTap: _openEditDialog,
        );
        return switch (variant) {
          RowCardVariant.current => buildCurrentEntryTile(
            context,
            theme,
            entry: args.entry,
            exerciseName: args.exerciseName,
            locked: args.locked,
            selected: args.selected,
            onSelect: args.onSelect,
            onDeleteEntry: args.onDeleteEntry,
            onSetTap: args.onSetTap,
          ),
          RowCardVariant.gapList => buildGapListEntryTile(
            context,
            theme,
            entry: args.entry,
            exerciseName: args.exerciseName,
            locked: args.locked,
            selected: args.selected,
            onSelect: args.onSelect,
            onDeleteEntry: args.onDeleteEntry,
            onSetTap: args.onSetTap,
          ),
          RowCardVariant.accentBar => buildAccentBarEntryTile(
            context,
            theme,
            entry: args.entry,
            exerciseName: args.exerciseName,
            locked: args.locked,
            selected: args.selected,
            onSelect: args.onSelect,
            onDeleteEntry: args.onDeleteEntry,
            onSetTap: args.onSetTap,
          ),
          RowCardVariant.coplanarCards => buildCoplanarCardEntryTile(
            context,
            theme,
            entry: args.entry,
            exerciseName: args.exerciseName,
            locked: args.locked,
            selected: args.selected,
            onSelect: args.onSelect,
            onDeleteEntry: args.onDeleteEntry,
            onSetTap: args.onSetTap,
          ),
        };
      },
    );
  }
}
