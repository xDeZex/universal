import 'package:flutter/material.dart';

import '../models/workout.dart';
import 'number_stepper.dart';
import 'weight_input_controls.dart';

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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          WeightInputControls(
            weightStepperKey: weightStepperKey,
            unitKgKey: unitKgKey,
            unitLbsKey: unitLbsKey,
            weight: weight,
            unit: unit,
            onWeightChanged: onWeightChanged,
            onUnitChanged: onUnitChanged,
          ),
          const SizedBox(width: 8),
          NumberStepper(
            keyPrefix: repsStepperKey,
            value: reps,
            step: 1,
            onChanged: (value) => onRepsChanged(value.toInt()),
          ),
        ],
      ),
    );
  }
}
