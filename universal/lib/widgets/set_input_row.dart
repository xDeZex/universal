import 'package:flutter/material.dart';

import '../models/workout.dart';
import '../prototype/input_control_variant.dart';
import '../prototype/input_control_variants.dart';

/// The weight-stepper / unit-toggle / reps-stepper row shared by the add-Set
/// bar and the edit-Set dialog, so both present the same input UI.
class SetInputRow extends StatelessWidget {
  final String weightStepperKey;
  final String unitKgKey;
  final String unitLbsKey;
  final String repsStepperKey;
  final num weight;
  final WeightUnit unit;
  final int reps;
  final ValueChanged<num> onWeightChanged;
  final ValueChanged<WeightUnit> onUnitChanged;
  final ValueChanged<int> onRepsChanged;

  const SetInputRow({
    super.key,
    required this.weightStepperKey,
    required this.unitKgKey,
    required this.unitLbsKey,
    required this.repsStepperKey,
    required this.weight,
    required this.unit,
    required this.reps,
    required this.onWeightChanged,
    required this.onUnitChanged,
    required this.onRepsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<InputControlVariant>(
      valueListenable: inputControlVariant,
      builder: (context, variant, _) {
        final children = [
          VariantWeightControls(
            variant: variant,
            weightStepperKey: weightStepperKey,
            unitKgKey: unitKgKey,
            unitLbsKey: unitLbsKey,
            weight: weight,
            unit: unit,
            onWeightChanged: onWeightChanged,
            onUnitChanged: onUnitChanged,
          ),
          VariantStepper(
            variant: variant,
            keyPrefix: repsStepperKey,
            value: reps,
            step: 1,
            onChanged: (value) => onRepsChanged(value.toInt()),
          ),
        ];

        // Same #209-workaround-retirement rule as PlannedExerciseRowEditor:
        // `current` keeps today's horizontal scroll, the new variants wrap.
        if (variant == InputControlVariant.current) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                children[0],
                const SizedBox(width: 8),
                children[1],
              ],
            ),
          );
        }
        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: children,
        );
      },
    );
  }
}
