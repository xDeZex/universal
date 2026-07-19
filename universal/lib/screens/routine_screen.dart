import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/exercise.dart';
import '../models/routine.dart';
import '../repositories/workout_repository.dart';
import '../widgets/planned_exercise_add_field.dart';
import '../widgets/planned_exercise_card.dart';
import '../widgets/routine_name_dialog.dart';

class RoutineScreen extends StatelessWidget {
  final String routineId;

  const RoutineScreen({super.key, required this.routineId});

  Future<void> _rename(BuildContext context, Routine routine) async {
    final repo = context.read<WorkoutRepository>();
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => RoutineNameDialog(
        title: 'Rename Routine',
        confirmLabel: 'Save',
        initialName: routine.name,
        fieldKey: const ValueKey('rename-routine-field'),
        cancelKey: const ValueKey('rename-routine-cancel'),
        confirmKey: const ValueKey('rename-routine-save'),
        validate: (name) => routine.validateRename(name, repo.routines),
      ),
    );
    if (newName == null) return;
    if (!context.mounted) return;

    repo.renameRoutine(routine.id, newName);
  }

  void _toggleArchive(BuildContext context, Routine routine) {
    final repo = context.read<WorkoutRepository>();
    if (routine.isLocked) {
      repo.unarchiveRoutine(routine.id);
    } else {
      repo.archiveRoutine(routine.id);
    }
  }

  Widget _buildList(List<PlannedExercise> plannedExercises, List<Exercise> exercises) {
    return ListView.builder(
      itemCount: plannedExercises.length,
      itemBuilder: (context, index) {
        final plannedExercise = plannedExercises[index];
        return PlannedExerciseCard(
          key: ValueKey(plannedExercise.id),
          plannedExercise: plannedExercise,
          exerciseName: Exercise.nameFor(plannedExercise.exerciseId, exercises),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<WorkoutRepository>();
    final routine = repo.routines.firstWhere((r) => r.id == routineId);
    final exercises = repo.exercises;

    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: () => _rename(context, routine),
          child: Text(routine.name),
        ),
        actions: [
          IconButton(
            key: const ValueKey('routine-archive-toggle'),
            icon: Icon(routine.isLocked ? Icons.unarchive : Icons.archive),
            onPressed: () => _toggleArchive(context, routine),
          ),
        ],
      ),
      body: Column(
        children: [
          if (routine.isLocked)
            Container(
              key: const ValueKey('routine-locked-banner'),
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Text(
                'Archived — unarchive to edit Planned Exercises',
              ),
            ),
          PlannedExerciseAddField(
            onAdd: (name) => repo.addPlannedExercise(routine.id, name),
          ),
          Expanded(
            child: routine.plannedExercises.isEmpty
                ? const Center(
                    key: ValueKey('routine-empty-state'),
                    child: Text('No Planned Exercises yet'),
                  )
                : _buildList(routine.plannedExercises, exercises),
          ),
        ],
      ),
    );
  }
}
