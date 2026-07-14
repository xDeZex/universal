import 'package:flutter/material.dart';

import '../models/workout.dart';
import 'set_input_row.dart';

class AddSetBar extends StatefulWidget {
  final WeightUnit initialUnit;
  final void Function(num weight, WeightUnit unit, int reps) onAddSet;
  final void Function(WeightUnit unit) onUnitChanged;

  const AddSetBar({
    super.key,
    required this.initialUnit,
    required this.onAddSet,
    required this.onUnitChanged,
  });

  @override
  State<AddSetBar> createState() => _AddSetBarState();
}

class _AddSetBarState extends State<AddSetBar> {
  late WeightUnit _unit;
  num _weight = 0;
  int _reps = 0;

  @override
  void initState() {
    super.initState();
    _unit = widget.initialUnit;
  }

  void _setUnit(WeightUnit unit) {
    setState(() => _unit = unit);
    widget.onUnitChanged(unit);
  }

  void _submit() {
    if (_reps <= 0) return;
    widget.onAddSet(_weight, _unit, _reps);
    setState(() {
      _weight = 0;
      _reps = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('add-set-bar'),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SetInputRow(
            weightStepperKey: 'weight-stepper',
            unitKgKey: 'unit-kg',
            unitLbsKey: 'unit-lbs',
            repsStepperKey: 'reps-stepper',
            weight: _weight,
            unit: _unit,
            reps: _reps,
            onWeightChanged: (value) => setState(() => _weight = value),
            onUnitChanged: _setUnit,
            onRepsChanged: (value) => setState(() => _reps = value),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              key: const ValueKey('add-set'),
              onPressed: _reps > 0 ? _submit : null,
              child: const Text('Add Set'),
            ),
          ),
        ],
      ),
    );
  }
}
