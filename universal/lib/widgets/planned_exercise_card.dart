import 'package:flutter/material.dart';

import '../models/routine.dart';
import '../prototype/planned_exercise_row_variants.dart';
import '../prototype/row_card_variant.dart';
import 'planned_exercise_row_editor.dart';

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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.drag_handle),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              exerciseName,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          if (onDelete != null)
            IconButton(
              key: ValueKey('delete-planned-exercise-${plannedExercise.id}'),
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }

  Widget _rowContent(int index, PlannedExerciseRow row) {
    final rowKey = 'planned-exercise-row-${plannedExercise.id}-$index';
    return Row(
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
  }

  Widget _editor(int index, PlannedExerciseRow row) {
    return PlannedExerciseRowEditor(
      keyPrefix: 'row-${plannedExercise.id}-$index',
      row: row,
      onChanged: (updated) => onRowChanged?.call(index, updated),
    );
  }

  /// Row rendering shared by every variant, except how the *open* (being
  /// edited) row is set apart — that's the selection-language question
  /// this prototype exists to answer, so it's the one thing that varies.
  Widget _buildRow(
    BuildContext context,
    RowCardVariant variant,
    int index,
    PlannedExerciseRow row,
  ) {
    final rowKey = 'planned-exercise-row-${plannedExercise.id}-$index';
    final theme = Theme.of(context);
    final isOpen = openRowIndex == index;

    final rowLine = onRowTap != null
        ? InkWell(
            key: ValueKey(rowKey),
            onTap: () => onRowTap!(index),
            child: _rowContent(index, row),
          )
        : KeyedSubtree(key: ValueKey(rowKey), child: _rowContent(index, row));

    if (!isOpen) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: rowLine,
      );
    }

    return buildOpenPlannedExerciseRow(
      context,
      variant,
      theme,
      rowLine: rowLine,
      editor: _editor(index, row),
    );
  }

  Widget _addRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: TextButton(
        key: ValueKey('add-planned-exercise-row-${plannedExercise.id}'),
        onPressed: onAddRow,
        child: const Text('+ Add row'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<RowCardVariant>(
      valueListenable: rowCardVariant,
      builder: (context, variant, _) {
        final theme = Theme.of(context);
        final header = _buildHeader(context);
        final rows = [
          for (final entry in plannedExercise.rows.asMap().entries)
            _buildRow(context, variant, entry.key, entry.value),
        ];

        switch (variant) {
          case RowCardVariant.current:
            return Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  header,
                  ...rows,
                  if (onAddRow != null) _addRow(),
                ],
              ),
            );
          case RowCardVariant.gapList:
            // Expressive list: rounded, gap-separated container — no
            // divider between this card and its neighbours.
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  header,
                  ...rows,
                  if (onAddRow != null) _addRow(),
                ],
              ),
            );
          case RowCardVariant.accentBar:
            // Baseline/uncontained list: square corners, full-width
            // divider under the header instead of card containment.
            return Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  header,
                  if (rows.isNotEmpty)
                    Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ...rows,
                  if (onAddRow != null) _addRow(),
                ],
              ),
            );
          case RowCardVariant.coplanarCards:
            // Coplanar card with an inset divider between the always-
            // visible header and the expandable row list (M3: "use inset
            // dividers to separate related content" within one card).
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  header,
                  if (rows.isNotEmpty)
                    Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ...rows,
                  if (onAddRow != null) _addRow(),
                ],
              ),
            );
        }
      },
    );
  }
}
