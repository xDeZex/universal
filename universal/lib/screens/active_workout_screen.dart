import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/exercise.dart';
import '../models/workout.dart';
import '../repositories/workout_repository.dart';
import '../widgets/add_set_bar.dart';
import '../widgets/exercise_entry_tile.dart';
import 'active_workout_controller.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  final String workoutId;

  const ActiveWorkoutScreen({super.key, required this.workoutId});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  final TextEditingController _nameController = TextEditingController();
  late final ActiveWorkoutController _controller;
  bool _isLeaving = false;

  @override
  void initState() {
    super.initState();
    _controller = ActiveWorkoutController(
      repository: context.read<WorkoutRepository>(),
      workoutId: widget.workoutId,
    )..addListener(_onControllerChanged);
  }

  void _onControllerChanged() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _addExerciseEntry() {
    final entry = _controller.addExerciseEntry(_nameController.text.trim());
    if (entry != null) {
      _nameController.clear();
    }
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
          locked: !_controller.canAddNew(workout),
          selected:
              _controller.canAddNew(workout) &&
              entry.id == _controller.selectedEntryId,
          onSelect: () => _controller.selectEntry(entry.id),
          onEditSet: (setId, weight, unit, reps) => _controller.editSet(
            entryId: entry.id,
            setId: setId,
            weight: weight,
            unit: unit,
            reps: reps,
          ),
          onDeleteSet: (setId) =>
              _controller.deleteSet(entryId: entry.id, setId: setId),
          onDeleteEntry: () => _controller.deleteExerciseEntry(entry.id),
        ),
      );
      if (i != entries.length - 1) {
        rows.add(const Divider(height: 1));
      }
    }
    return rows;
  }

  String _appBarTitle(BuildContext context, Workout workout) {
    if (_controller.canAddNew(workout)) return 'Active Workout';
    return MaterialLocalizations.of(context).formatShortDate(workout.endTime!);
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<WorkoutRepository>();
    final workout = _controller.workout;
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
    final canAddNew = _controller.canAddNew(workout);

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
            if (canAddNew && _controller.selectedEntryId != null) ...[
              AddSetBar(
                key: ValueKey(_controller.selectedEntryId),
                initialUnit: _controller.unitFor(_controller.selectedEntryId!),
                onAddSet: (weight, unit, reps) => _controller.addSet(
                  entryId: _controller.selectedEntryId!,
                  weight: weight,
                  unit: unit,
                  reps: reps,
                ),
                onUnitChanged: (unit) => _controller.setEntryUnit(
                  _controller.selectedEntryId!,
                  unit,
                ),
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
                        onPressed: _discard,
                        child: const Text('Discard'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        key: const ValueKey('finish-workout'),
                        onPressed: _controller.hasLoggedSets(workout)
                            ? _finish
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

  void _finish() {
    _isLeaving = true;
    _controller.finish();
    Navigator.pop(context);
  }

  void _discard() {
    _isLeaving = true;
    _controller.discard();
    Navigator.pop(context);
  }
}
