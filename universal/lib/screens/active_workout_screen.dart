import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/exercise.dart';
import '../models/workout.dart';
import '../repositories/workout_repository.dart';
import '../widgets/add_set_bar.dart';
import '../widgets/exercise_entry_tile.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  final String workoutId;

  const ActiveWorkoutScreen({super.key, required this.workoutId});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  final TextEditingController _nameController = TextEditingController();
  String? _selectedEntryId;
  final Map<String, WeightUnit> _entryUnits = {};
  bool _isLeaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  WorkoutRepository get _repo => context.read<WorkoutRepository>();

  Workout? _findWorkout(WorkoutRepository repo) {
    for (final workout in repo.workouts) {
      if (workout.id == widget.workoutId) return workout;
    }
    return null;
  }

  void _addExerciseEntry() {
    final name = _nameController.text.trim();
    final entry = _repo.addExerciseEntry(widget.workoutId, name);

    if (entry != null) {
      setState(() {
        _selectedEntryId = entry.id;
      });
      _nameController.clear();
    }
  }

  void _addSet(String entryId, num weight, WeightUnit unit, int reps) {
    _repo.addSet(
      workoutId: widget.workoutId,
      entryId: entryId,
      weight: weight,
      unit: unit,
      reps: reps,
    );
    setState(() {
      _entryUnits[entryId] = unit;
    });
  }

  WeightUnit _unitFor(String entryId) => _entryUnits[entryId] ?? WeightUnit.kg;

  void _setEntryUnit(String entryId, WeightUnit unit) {
    setState(() {
      _entryUnits[entryId] = unit;
    });
  }

  void _editSet(
    String entryId,
    String setId,
    num weight,
    WeightUnit unit,
    int reps,
  ) {
    _repo.editSet(
      workoutId: widget.workoutId,
      entryId: entryId,
      setId: setId,
      weight: weight,
      unit: unit,
      reps: reps,
    );
    setState(() {
      _entryUnits[entryId] = unit;
    });
  }

  void _deleteSet(String entryId, String setId) {
    _repo.deleteSet(
      workoutId: widget.workoutId,
      entryId: entryId,
      setId: setId,
    );
  }

  void _deleteExerciseEntry(String entryId) {
    _repo.deleteExerciseEntry(workoutId: widget.workoutId, entryId: entryId);
    if (_selectedEntryId == entryId) {
      setState(() {
        _selectedEntryId = null;
      });
    }
  }

  void _selectEntry(String entryId) {
    setState(() {
      _selectedEntryId = entryId;
    });
  }

  List<Widget> _buildEntryRows(Workout workout, List<Exercise> exercises) {
    final entries = workout.exerciseEntries;
    final rows = <Widget>[];
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      rows.add(
        ExerciseEntryTile(
          key: ValueKey(entry.id),
          entry: entry,
          exerciseName: Exercise.nameFor(entry.exerciseId, exercises),
          locked: !_canAddNew(workout),
          selected: _canAddNew(workout) && entry.id == _selectedEntryId,
          onSelect: () => _selectEntry(entry.id),
          onEditSet: (setId, weight, unit, reps) =>
              _editSet(entry.id, setId, weight, unit, reps),
          onDeleteSet: (setId) => _deleteSet(entry.id, setId),
          onDeleteEntry: () => _deleteExerciseEntry(entry.id),
        ),
      );
      if (i != entries.length - 1) {
        rows.add(const Divider(height: 1));
      }
    }
    return rows;
  }

  bool _hasLoggedSets(Workout workout) =>
      workout.exerciseEntries.any((entry) => entry.sets.isNotEmpty);

  bool _canAddNew(Workout workout) => workout.isInProgress;

  String _appBarTitle(BuildContext context, Workout workout) {
    if (_canAddNew(workout)) return 'Active Workout';
    return MaterialLocalizations.of(context).formatShortDate(workout.endTime!);
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<WorkoutRepository>();
    final workout = _findWorkout(repo);
    if (workout == null) {
      if (!_isLeaving) {
        _isLeaving = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) Navigator.pop(context);
        });
      }
      return const SizedBox.shrink();
    }
    final exercises = repo.exercises;
    final canAddNew = _canAddNew(workout);

    return Scaffold(
      appBar: AppBar(title: Text(_appBarTitle(context, workout))),
      body: SafeArea(
        child: Column(
          children: [
            if (canAddNew)
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
              child: ListView(children: _buildEntryRows(workout, exercises)),
            ),
            if (canAddNew && _selectedEntryId != null) ...[
              AddSetBar(
                key: ValueKey(_selectedEntryId),
                initialUnit: _unitFor(_selectedEntryId!),
                onAddSet: (weight, unit, reps) =>
                    _addSet(_selectedEntryId!, weight, unit, reps),
                onUnitChanged: (unit) => _setEntryUnit(_selectedEntryId!, unit),
              ),
              const Divider(height: 1),
            ],
            if (canAddNew)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        key: const ValueKey('discard-workout'),
                        onPressed: () => _discard(workout),
                        child: const Text('Discard'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        key: const ValueKey('finish-workout'),
                        onPressed: _hasLoggedSets(workout)
                            ? () => _finish(workout)
                            : null,
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

  void _finish(Workout workout) {
    if (!_hasLoggedSets(workout)) return;
    _isLeaving = true;
    _repo.finishWorkout(widget.workoutId);
    Navigator.pop(context);
  }

  void _discard(Workout workout) {
    _isLeaving = true;
    _repo.discardWorkout(workout.id);
    Navigator.pop(context);
  }
}
