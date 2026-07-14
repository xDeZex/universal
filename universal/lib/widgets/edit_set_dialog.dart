import 'package:flutter/material.dart';

import '../models/workout.dart';
import 'confirm_delete_dialog.dart';
import 'set_input_row.dart';

sealed class EditSetDialogResult {}

class EditSetSubmitted extends EditSetDialogResult {
  final num weight;
  final WeightUnit unit;
  final int reps;

  EditSetSubmitted({
    required this.weight,
    required this.unit,
    required this.reps,
  });
}

class EditSetDeleted extends EditSetDialogResult {}

class EditSetDialog extends StatefulWidget {
  final ExerciseSet set;

  const EditSetDialog({super.key, required this.set});

  @override
  State<EditSetDialog> createState() => _EditSetDialogState();
}

class _EditSetDialogState extends State<EditSetDialog> {
  late num _weight;
  late WeightUnit _unit;
  late int _reps;

  @override
  void initState() {
    super.initState();
    _weight = widget.set.weight;
    _unit = widget.set.unit;
    _reps = widget.set.reps;
  }

  void _submit() {
    if (_reps <= 0) return;
    Navigator.pop(
      context,
      EditSetSubmitted(weight: _weight, unit: _unit, reps: _reps),
    );
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) =>
          const ConfirmDeleteDialog(message: 'Delete this Set?'),
    );
    if (confirmed != true) return;
    if (!mounted) return;
    Navigator.pop(context, EditSetDeleted());
  }

  @override
  Widget build(BuildContext context) {
    final setId = widget.set.id;
    return AlertDialog(
      title: const Text('Edit Set'),
      content: SetInputRow(
        weightStepperKey: 'edit-weight-stepper-$setId',
        unitKgKey: 'edit-unit-kg-$setId',
        unitLbsKey: 'edit-unit-lbs-$setId',
        repsStepperKey: 'edit-reps-stepper-$setId',
        weight: _weight,
        unit: _unit,
        reps: _reps,
        onWeightChanged: (value) => setState(() => _weight = value),
        onUnitChanged: (unit) => setState(() => _unit = unit),
        onRepsChanged: (value) => setState(() => _reps = value),
      ),
      actions: [
        TextButton(
          key: ValueKey('edit-delete-$setId'),
          onPressed: _delete,
          child: const Text('Delete'),
        ),
        TextButton(
          key: ValueKey('edit-cancel-$setId'),
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          key: ValueKey('edit-submit-$setId'),
          onPressed: _reps > 0 ? _submit : null,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
