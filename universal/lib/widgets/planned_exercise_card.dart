import 'package:flutter/material.dart';

import '../models/routine.dart';

class PlannedExerciseCard extends StatelessWidget {
  final PlannedExercise plannedExercise;
  final String exerciseName;

  const PlannedExerciseCard({
    super.key,
    required this.plannedExercise,
    required this.exerciseName,
  });

  String _formatReps(RepsTarget reps) {
    return switch (reps) {
      FixedReps(reps: final r) => '$r reps',
      RangeReps(min: final min, max: final max) => '$min–$max reps',
    };
  }

  String _formatRow(PlannedExerciseRow row) {
    final repsText = _formatReps(row.reps);
    final weight = row.weight;
    if (weight == null) {
      return '$repsText · no weight';
    }
    return '$repsText @ ${weight.value} ${weight.unit.name}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
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
              ],
            ),
          ),
          for (final row in plannedExercise.rows)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(_formatRow(row)),
            ),
        ],
      ),
    );
  }
}
