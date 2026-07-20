import 'package:flutter/material.dart';

import '../models/routine.dart';
import '../prototype/input_control_variant.dart';
import '../prototype/input_control_variants.dart';

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

  Widget _buildFixedReps(InputControlVariant variant, FixedReps reps) {
    return VariantStepper(
      variant: variant,
      keyPrefix: '$keyPrefix-reps',
      value: reps.reps,
      step: 1,
      min: 1,
      onChanged: (value) =>
          onChanged(row.copyWith(reps: FixedReps(value.toInt()))),
    );
  }

  Widget _buildRangeReps(InputControlVariant variant, RangeReps reps) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        VariantStepper(
          variant: variant,
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
        VariantStepper(
          variant: variant,
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

  Widget _rangeToggle(RepsTarget reps) {
    return IconButton(
      key: ValueKey('$keyPrefix-range-toggle'),
      icon: Icon(reps is RangeReps ? Icons.height : Icons.swap_vert),
      tooltip: reps is RangeReps ? 'Use a fixed rep count' : 'Use a rep range',
      onPressed: _toggleRange,
    );
  }

  Widget _weightControls(InputControlVariant variant) {
    return VariantWeightControls(
      variant: variant,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final reps = row.reps;
    return ValueListenableBuilder<InputControlVariant>(
      valueListenable: inputControlVariant,
      builder: (context, variant, _) {
        // `current` reproduces today's app exactly, including the #209
        // horizontal-scroll workaround — that's the bug this ticket exists
        // to retire.
        if (variant == InputControlVariant.current) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                switch (reps) {
                  FixedReps() => _buildFixedReps(variant, reps),
                  RangeReps() => _buildRangeReps(variant, reps),
                },
                const SizedBox(width: 8),
                _rangeToggle(reps),
                const SizedBox(width: 8),
                _weightControls(variant),
              ],
            ),
          );
        }

        // Fixed two-line layout, not a Wrap: the range-toggle icon is
        // pinned to the row's right edge (via Spacer) regardless of how
        // wide the reps stepper(s) are, and weight controls always sit on
        // their own second line. Toggling fixed/range reps only changes
        // how much space the reps steppers themselves take — it no longer
        // shifts anything else, which is what "everything moves" was about.
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                switch (reps) {
                  FixedReps() => _buildFixedReps(variant, reps),
                  RangeReps() => _buildRangeReps(variant, reps),
                },
                const Spacer(),
                _rangeToggle(reps),
              ],
            ),
            const SizedBox(height: 4),
            _weightControls(variant),
          ],
        );
      },
    );
  }
}
