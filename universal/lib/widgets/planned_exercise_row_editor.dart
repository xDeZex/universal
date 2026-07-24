import 'package:flutter/material.dart';

import '../models/routine.dart';
import 'number_stepper.dart';
import 'weight_input_controls.dart';

/// In-place editor for a single Planned Exercise row's reps target and
/// weight, opened beneath the row in [PlannedExerciseCard].
class PlannedExerciseRowEditor extends StatelessWidget {
  final String keyPrefix;
  final PlannedExerciseRow row;
  final ValueChanged<PlannedExerciseRow> onChanged;

  const PlannedExerciseRowEditor({
    super.key,
    required this.keyPrefix,
    required this.row,
    required this.onChanged,
  });

  void _toggleRange() {
    final reps = row.reps;
    final newReps = switch (reps) {
      FixedReps(reps: final r) => RangeReps(min: r, max: r + 1),
      RangeReps(min: final min) => FixedReps(min),
    };
    onChanged(row.copyWith(reps: newReps));
  }

  Widget _buildFixedReps(FixedReps reps) {
    return NumberStepper(
      keyPrefix: '$keyPrefix-reps',
      value: reps.reps,
      step: 1,
      min: 1,
      onChanged: (value) =>
          onChanged(row.copyWith(reps: FixedReps(value.toInt()))),
    );
  }

  Widget _buildRangeReps(RangeReps reps) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        NumberStepper(
          keyPrefix: '$keyPrefix-reps-min',
          value: reps.min,
          step: 1,
          min: 1,
          max: reps.max - 1,
          onChanged: (value) => onChanged(
            row.copyWith(
              reps: RangeReps(min: value.toInt(), max: reps.max),
            ),
          ),
        ),
        const SizedBox(width: 4),
        const Text('–'),
        const SizedBox(width: 4),
        NumberStepper(
          keyPrefix: '$keyPrefix-reps-max',
          value: reps.max,
          step: 1,
          min: reps.min + 1,
          onChanged: (value) => onChanged(
            row.copyWith(
              reps: RangeReps(min: reps.min, max: value.toInt()),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final reps = row.reps;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            switch (reps) {
              FixedReps() => _buildFixedReps(reps),
              RangeReps() => _buildRangeReps(reps),
            },
            const Spacer(),
            IconButton(
              key: ValueKey('$keyPrefix-range-toggle'),
              icon: Icon(reps is RangeReps ? Icons.height : Icons.swap_vert),
              tooltip: reps is RangeReps
                  ? 'Use a fixed rep count'
                  : 'Use a rep range',
              onPressed: _toggleRange,
            ),
          ],
        ),
        const SizedBox(height: 8),
        WeightInputControls(
          weightStepperKey: '$keyPrefix-weight-stepper',
          unitKgKey: '$keyPrefix-unit-kg',
          unitLbsKey: '$keyPrefix-unit-lbs',
          weight: row.weight.value,
          unit: row.weight.unit,
          onWeightChanged: (value) => onChanged(
            row.copyWith(
              weight: PlannedWeight(value: value, unit: row.weight.unit),
            ),
          ),
          onUnitChanged: (unit) => onChanged(
            row.copyWith(
              weight: PlannedWeight(value: row.weight.value, unit: unit),
            ),
          ),
        ),
      ],
    );
  }
}
