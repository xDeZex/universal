import 'package:flutter/material.dart';

import '../models/workout.dart';
import 'number_stepper.dart';

/// The weight-stepper / kg-lbs-unit-toggle controls shared by [SetInputRow]
/// and `PlannedExerciseRowEditor`, so both present the same weight input UI.
class WeightInputControls extends StatelessWidget {
  final String weightStepperKey;
  final String unitKgKey;
  final String unitLbsKey;
  final num weight;
  final WeightUnit unit;
  final ValueChanged<num> onWeightChanged;
  final ValueChanged<WeightUnit> onUnitChanged;

  const WeightInputControls({
    super.key,
    required this.weightStepperKey,
    required this.unitKgKey,
    required this.unitLbsKey,
    required this.weight,
    required this.unit,
    required this.onWeightChanged,
    required this.onUnitChanged,
  });

  num get _weightStep => unit == WeightUnit.kg ? 2.5 : 5;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        NumberStepper(
          keyPrefix: weightStepperKey,
          value: weight,
          step: _weightStep,
          allowNegative: true,
          onChanged: onWeightChanged,
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          key: ValueKey(unitKgKey),
          label: const Text('kg'),
          showCheckmark: false,
          selected: unit == WeightUnit.kg,
          onSelected: (_) => onUnitChanged(WeightUnit.kg),
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          key: ValueKey(unitLbsKey),
          label: const Text('lbs'),
          showCheckmark: false,
          selected: unit == WeightUnit.lbs,
          onSelected: (_) => onUnitChanged(WeightUnit.lbs),
        ),
      ],
    );
  }
}
