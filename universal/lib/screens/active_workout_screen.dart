import 'package:flutter/material.dart';

import '../models/exercise.dart';
import '../models/workout.dart';

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

  bool get _hasLoggedSets =>
      _workout.exerciseEntries.any((entry) => entry.sets.isNotEmpty);

  bool get _isReadOnly => !_workout.isInProgress;

  String _appBarTitle(BuildContext context) {
    if (!_isReadOnly) return 'Active Workout';
    return MaterialLocalizations.of(context).formatShortDate(_workout.endTime!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_appBarTitle(context))),
      body: SafeArea(
        child: Column(
          children: [
            if (!_isReadOnly)
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
                    readOnly: _isReadOnly,
                    onAddSet: (weight, unit, reps) =>
                        _addSet(entry.id, weight, unit, reps),
                  );
                }).toList(),
              ),
            ),
            if (!_isReadOnly)
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
  final bool readOnly;
  final void Function(num weight, WeightUnit unit, int reps) onAddSet;

  const _ExerciseEntryTile({
    super.key,
    required this.entry,
    required this.exerciseName,
    required this.readOnly,
    required this.onAddSet,
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
    final weight = num.tryParse(_weightController.text);
    final reps = int.tryParse(_repsController.text);

    if (weight == null || reps == null || reps <= 0) return;

    widget.onAddSet(weight, _selectedUnit, reps);
    _weightController.clear();
    _repsController.clear();
  }

  String _setLabel(ExerciseSet set) {
    final base = '${set.reps} reps at ${set.weight} ${set.unit.name}';
    if (!widget.readOnly) return base;
    return '$base — ${TimeOfDay.fromDateTime(set.loggedAt).format(context)}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            widget.exerciseName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        for (final set in widget.entry.sets)
          ListTile(title: Text(_setLabel(set))),
        if (!widget.readOnly)
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
