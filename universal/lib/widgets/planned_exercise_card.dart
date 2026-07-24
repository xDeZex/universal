import 'package:flutter/material.dart';

import '../models/routine.dart';
import 'coplanar_card.dart';
import 'planned_exercise_row_editor.dart';
import 'selection_accent_border.dart';
import 'zebra_row.dart';

class PlannedExerciseCard extends StatelessWidget {
  final PlannedExercise plannedExercise;
  final String exerciseName;
  final VoidCallback? onDelete;
  final VoidCallback? onAddRow;
  final int? openRowIndex;
  final void Function(int rowIndex)? onRowTap;
  final void Function(int rowIndex)? onDeleteRow;
  final void Function(int rowIndex, PlannedExerciseRow updated)? onRowChanged;

  const PlannedExerciseCard({
    super.key,
    required this.plannedExercise,
    required this.exerciseName,
    required this.onDelete,
    this.onAddRow,
    this.openRowIndex,
    this.onRowTap,
    this.onDeleteRow,
    this.onRowChanged,
  });

  String _formatReps(RepsTarget reps) {
    return switch (reps) {
      FixedReps(reps: final r) => '$r reps',
      RangeReps(min: final min, max: final max) => '$min–$max reps',
    };
  }

  String _formatRow(PlannedExerciseRow row) {
    final repsText = _formatReps(row.reps);
    return '$repsText @ ${row.weight.value} ${row.weight.unit.name}';
  }

  Widget _buildRow(int index, PlannedExerciseRow row) {
    final rowKey = 'planned-exercise-row-${plannedExercise.id}-$index';
    final rowContent = Row(
      children: [
        Expanded(child: Text(_formatRow(row))),
        if (onDeleteRow != null)
          IconButton(
            key: ValueKey('delete-$rowKey'),
            icon: const Icon(Icons.close),
            onPressed: () => onDeleteRow!(index),
          ),
      ],
    );

    final tappableRow = onRowTap != null
        ? InkWell(
            key: ValueKey(rowKey),
            onTap: () => onRowTap!(index),
            child: rowContent,
          )
        : KeyedSubtree(key: ValueKey(rowKey), child: rowContent);

    if (openRowIndex != index) {
      return ZebraRow(
        index: index,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: tappableRow,
        ),
      );
    }

    // Left inset drops from 16 to 12 here because SelectionAccentBorder's
    // 4dp border auto-adds the remaining 4dp of padding — keeping the row
    // flush with the closed state's 16dp inset instead of shifting it.
    return SelectionAccentBorder(
      selected: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 16, 8),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: tappableRow,
            ),
            PlannedExerciseRowEditor(
              keyPrefix: 'row-${plannedExercise.id}-$index',
              row: row,
              onChanged: (updated) => onRowChanged?.call(index, updated),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CoplanarCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.drag_handle),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    exerciseName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (onDelete != null)
                  IconButton(
                    key: ValueKey(
                      'delete-planned-exercise-${plannedExercise.id}',
                    ),
                    icon: const Icon(Icons.delete),
                    onPressed: onDelete,
                  ),
              ],
            ),
          ),
          for (final entry in plannedExercise.rows.asMap().entries)
            _buildRow(entry.key, entry.value),
          if (onAddRow != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextButton(
                key: ValueKey('add-planned-exercise-row-${plannedExercise.id}'),
                onPressed: onAddRow,
                child: const Text('+ Add row'),
              ),
            ),
        ],
      ),
    );
  }
}
