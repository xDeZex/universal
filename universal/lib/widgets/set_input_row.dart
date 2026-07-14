import 'package:flutter/material.dart';

import '../models/workout.dart';

num normalizeStepValue(num value) {
  if (value is int) return value;
  final rounded = value.roundToDouble();
  return value == rounded ? value.toInt() : value;
}

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

  num get _weightStep => unit == WeightUnit.kg ? 2.5 : 5;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
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

class NumberStepper extends StatelessWidget {
  final String keyPrefix;
  final num value;
  final num step;
  final bool allowNegative;
  final ValueChanged<num> onChanged;

  const NumberStepper({
    super.key,
    required this.keyPrefix,
    required this.value,
    required this.step,
    this.allowNegative = false,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          key: ValueKey('$keyPrefix-decrement'),
          icon: const Icon(Icons.remove),
          onPressed: (allowNegative || value > 0)
              ? () => onChanged(normalizeStepValue(value - step))
              : null,
        ),
        SizedBox(
          width: 40,
          child: Text(
            '${normalizeStepValue(value)}',
            key: ValueKey('$keyPrefix-value'),
            textAlign: TextAlign.center,
          ),
        ),
        IconButton(
          key: ValueKey('$keyPrefix-increment'),
          icon: const Icon(Icons.add),
          onPressed: () => onChanged(normalizeStepValue(value + step)),
        ),
      ],
    );
  }
}
