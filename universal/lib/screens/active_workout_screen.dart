import 'package:flutter/material.dart';

import '../models/exercise.dart';
import '../models/workout.dart';
import '../widgets/confirm_delete_dialog.dart';

({num weight, int reps})? _parseSetInput(String weightText, String repsText) {
  final weight = num.tryParse(weightText);
  final reps = int.tryParse(repsText);
  if (weight == null || reps == null || reps <= 0) return null;
  return (weight: weight, reps: reps);
}

class ActiveWorkoutScreen extends StatefulWidget {
  final Workout workout;
  final List<Exercise> exercises;
  final void Function(Workout) onWorkoutChanged;
  final void Function(List<Exercise>) onExercisesChanged;
  final void Function(String workoutId) onWorkoutDiscarded;

  const ActiveWorkoutScreen({
    super.key,
    required this.workout,
    required this.exercises,
    required this.onWorkoutChanged,
    required this.onExercisesChanged,
    required this.onWorkoutDiscarded,
  });

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  late Workout _workout;
  late List<Exercise> _exercises;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _workout = widget.workout;
    _exercises = widget.exercises;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _addExerciseEntry() {
    final name = _nameController.text.trim();
    final exercise = Exercise.resolve(name, _exercises);
    if (exercise == null) return;

    final isNewExercise = !_exercises.any((e) => e.id == exercise.id);

    final entry = ExerciseEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      exerciseId: exercise.id,
    );

    setState(() {
      _workout = _workout.copyWith(
        exerciseEntries: [..._workout.exerciseEntries, entry],
      );
      if (isNewExercise) {
        _exercises = [..._exercises, exercise];
      }
    });

    widget.onWorkoutChanged(_workout);
    if (isNewExercise) {
      widget.onExercisesChanged(_exercises);
    }
    _nameController.clear();
  }

  void _addSet(String entryId, num weight, WeightUnit unit, int reps) {
    setState(() {
      _workout = _workout.addSet(
        entryId: entryId,
        weight: weight,
        unit: unit,
        reps: reps,
      );
    });
    widget.onWorkoutChanged(_workout);
  }

  void _editSet(
    String entryId,
    String setId,
    num weight,
    WeightUnit unit,
    int reps,
  ) {
    setState(() {
      _workout = _workout.editSet(
        entryId: entryId,
        setId: setId,
        weight: weight,
        unit: unit,
        reps: reps,
      );
    });
    widget.onWorkoutChanged(_workout);
  }

  void _deleteSet(String entryId, String setId) {
    setState(() {
      _workout = _workout.deleteSet(entryId: entryId, setId: setId);
    });
    widget.onWorkoutChanged(_workout);
  }

  void _deleteExerciseEntry(String entryId) {
    setState(() {
      _workout = _workout.deleteExerciseEntry(entryId: entryId);
    });
    widget.onWorkoutChanged(_workout);
  }

  bool get _hasLoggedSets =>
      _workout.exerciseEntries.any((entry) => entry.sets.isNotEmpty);

  bool get _canAddNew => _workout.isInProgress;

  String _appBarTitle(BuildContext context) {
    if (_canAddNew) return 'Active Workout';
    return MaterialLocalizations.of(context).formatShortDate(_workout.endTime!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_appBarTitle(context))),
      body: SafeArea(
        child: Column(
          children: [
            if (_canAddNew)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: 'Exercise name',
                        ),
                        onSubmitted: (_) => _addExerciseEntry(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _addExerciseEntry,
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ListView(
                children: _workout.exerciseEntries.map((entry) {
                  return _ExerciseEntryTile(
                    key: ValueKey(entry.id),
                    entry: entry,
                    exerciseName: Exercise.nameFor(
                      entry.exerciseId,
                      _exercises,
                    ),
                    locked: !_canAddNew,
                    onAddSet: (weight, unit, reps) =>
                        _addSet(entry.id, weight, unit, reps),
                    onEditSet: (setId, weight, unit, reps) =>
                        _editSet(entry.id, setId, weight, unit, reps),
                    onDeleteSet: (setId) => _deleteSet(entry.id, setId),
                    onDeleteEntry: () => _deleteExerciseEntry(entry.id),
                  );
                }).toList(),
              ),
            ),
            if (_canAddNew)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        key: const ValueKey('discard-workout'),
                        onPressed: _discard,
                        child: const Text('Discard'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        key: const ValueKey('finish-workout'),
                        onPressed: _hasLoggedSets ? _finish : null,
                        child: const Text('Finish'),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _finish() {
    final finished = _workout.finish();
    if (finished == null) return;

    setState(() {
      _workout = finished;
    });
    widget.onWorkoutChanged(finished);
    Navigator.pop(context);
  }

  void _discard() {
    widget.onWorkoutDiscarded(_workout.id);
    Navigator.pop(context);
  }
}

class _ExerciseEntryTile extends StatefulWidget {
  final ExerciseEntry entry;
  final String exerciseName;
  final bool locked;
  final void Function(num weight, WeightUnit unit, int reps) onAddSet;
  final void Function(String setId, num weight, WeightUnit unit, int reps)
  onEditSet;
  final void Function(String setId) onDeleteSet;
  final VoidCallback onDeleteEntry;

  const _ExerciseEntryTile({
    super.key,
    required this.entry,
    required this.exerciseName,
    required this.locked,
    required this.onAddSet,
    required this.onEditSet,
    required this.onDeleteSet,
    required this.onDeleteEntry,
  });

  @override
  State<_ExerciseEntryTile> createState() => _ExerciseEntryTileState();
}

class _ExerciseEntryTileState extends State<_ExerciseEntryTile> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();
  WeightUnit _selectedUnit = WeightUnit.kg;

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  void _submit() {
    final parsed = _parseSetInput(_weightController.text, _repsController.text);
    if (parsed == null) return;

    widget.onAddSet(parsed.weight, _selectedUnit, parsed.reps);
    _weightController.clear();
    _repsController.clear();
  }

  String _setLabel(ExerciseSet set) {
    final base = '${set.reps} reps at ${set.weight} ${set.unit.name}';
    if (!widget.locked) return base;
    return '$base — ${TimeOfDay.fromDateTime(set.loggedAt).format(context)}';
  }

  Future<void> _openEditDialog(ExerciseSet set) async {
    final result = await showDialog<_EditSetDialogResult>(
      context: context,
      builder: (context) => _EditSetDialog(set: set),
    );
    switch (result) {
      case _EditSetSubmitted(:final weight, :final unit, :final reps):
        widget.onEditSet(set.id, weight, unit, reps);
      case _EditSetDeleted():
        widget.onDeleteSet(set.id);
      case null:
        break;
    }
  }

  Future<void> _deleteEntry() async {
    final count = widget.entry.sets.length;
    final message = count == 0
        ? 'Delete this Exercise Entry?'
        : 'Delete this Exercise Entry and all $count of its Sets?';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDeleteDialog(message: message),
    );
    if (confirmed != true) return;
    widget.onDeleteEntry();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.exerciseName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                key: ValueKey('delete-entry-${widget.entry.id}'),
                icon: const Icon(Icons.delete),
                onPressed: _deleteEntry,
              ),
            ],
          ),
        ),
        for (final set in widget.entry.sets)
          ListTile(
            key: ValueKey('set-${set.id}'),
            title: Text(_setLabel(set)),
            onTap: () => _openEditDialog(set),
          ),
        if (!widget.locked)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    key: ValueKey('weight-${widget.entry.id}'),
                    controller: _weightController,
                    decoration: const InputDecoration(hintText: 'Weight'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  key: ValueKey('unit-kg-${widget.entry.id}'),
                  label: const Text('kg'),
                  selected: _selectedUnit == WeightUnit.kg,
                  onSelected: (_) =>
                      setState(() => _selectedUnit = WeightUnit.kg),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  key: ValueKey('unit-lbs-${widget.entry.id}'),
                  label: const Text('lbs'),
                  selected: _selectedUnit == WeightUnit.lbs,
                  onSelected: (_) =>
                      setState(() => _selectedUnit = WeightUnit.lbs),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    key: ValueKey('reps-${widget.entry.id}'),
                    controller: _repsController,
                    decoration: const InputDecoration(hintText: 'Reps'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                IconButton(
                  key: ValueKey('add-set-${widget.entry.id}'),
                  icon: const Icon(Icons.add),
                  onPressed: _submit,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

sealed class _EditSetDialogResult {}

class _EditSetSubmitted extends _EditSetDialogResult {
  final num weight;
  final WeightUnit unit;
  final int reps;

  _EditSetSubmitted({
    required this.weight,
    required this.unit,
    required this.reps,
  });
}

class _EditSetDeleted extends _EditSetDialogResult {}

class _EditSetDialog extends StatefulWidget {
  final ExerciseSet set;

  const _EditSetDialog({required this.set});

  @override
  State<_EditSetDialog> createState() => _EditSetDialogState();
}

class _EditSetDialogState extends State<_EditSetDialog> {
  late final TextEditingController _weightController;
  late final TextEditingController _repsController;
  late WeightUnit _selectedUnit;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: widget.set.weight.toString(),
    );
    _repsController = TextEditingController(text: widget.set.reps.toString());
    _selectedUnit = widget.set.unit;
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  void _submit() {
    final parsed = _parseSetInput(_weightController.text, _repsController.text);
    if (parsed == null) return;

    Navigator.pop(
      context,
      _EditSetSubmitted(
        weight: parsed.weight,
        unit: _selectedUnit,
        reps: parsed.reps,
      ),
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
    Navigator.pop(context, _EditSetDeleted());
  }

  @override
  Widget build(BuildContext context) {
    final setId = widget.set.id;
    return AlertDialog(
      title: const Text('Edit Set'),
      content: Row(
        children: [
          Expanded(
            child: TextField(
              key: ValueKey('edit-weight-$setId'),
              controller: _weightController,
              decoration: const InputDecoration(hintText: 'Weight'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            key: ValueKey('edit-unit-kg-$setId'),
            label: const Text('kg'),
            selected: _selectedUnit == WeightUnit.kg,
            onSelected: (_) => setState(() => _selectedUnit = WeightUnit.kg),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            key: ValueKey('edit-unit-lbs-$setId'),
            label: const Text('lbs'),
            selected: _selectedUnit == WeightUnit.lbs,
            onSelected: (_) => setState(() => _selectedUnit = WeightUnit.lbs),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              key: ValueKey('edit-reps-$setId'),
              controller: _repsController,
              decoration: const InputDecoration(hintText: 'Reps'),
              keyboardType: TextInputType.number,
            ),
          ),
        ],
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
          onPressed: _submit,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
