import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/exercise.dart';
import '../models/routine.dart';
import '../repositories/workout_repository.dart';
import '../widgets/planned_exercise_add_field.dart';
import '../widgets/planned_exercise_card.dart';
import '../widgets/routine_name_dialog.dart';

class RoutineScreen extends StatefulWidget {
  final String routineId;

  const RoutineScreen({super.key, required this.routineId});

  @override
  State<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen> {
  ({String plannedExerciseId, int rowIndex})? _openRow;

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
      setState(() => _openRow = null);
    }
  }

  void _addRow(
    WorkoutRepository repo,
    Routine routine,
    PlannedExercise plannedExercise,
  ) {
    final newIndex = plannedExercise.rows.length;
    repo.addPlannedExerciseRow(routine.id, plannedExercise.id);
    setState(
      () => _openRow = (
        plannedExerciseId: plannedExercise.id,
        rowIndex: newIndex,
      ),
    );
  }

  void _toggleRow(String plannedExerciseId, int rowIndex) {
    setState(() {
      final current = _openRow;
      if (current != null &&
          current.plannedExerciseId == plannedExerciseId &&
          current.rowIndex == rowIndex) {
        _openRow = null;
      } else {
        _openRow = (plannedExerciseId: plannedExerciseId, rowIndex: rowIndex);
      }
    });
  }

  void _deleteRow(
    WorkoutRepository repo,
    Routine routine,
    String plannedExerciseId,
    int rowIndex,
  ) {
    repo.removePlannedExerciseRow(routine.id, plannedExerciseId, rowIndex);
    if (_openRow?.plannedExerciseId == plannedExerciseId) {
      setState(() => _openRow = null);
    }
  }

  PlannedExerciseCard _buildCard(
    WorkoutRepository repo,
    Routine routine,
    List<Exercise> exercises,
    int index,
  ) {
    final plannedExercise = routine.plannedExercises[index];
    final openRow = _openRow;
    final isLocked = routine.isLocked;
    return PlannedExerciseCard(
      key: ValueKey(plannedExercise.id),
      plannedExercise: plannedExercise,
      exerciseName: Exercise.nameFor(plannedExercise.exerciseId, exercises),
      onDelete: isLocked
          ? null
          : () => repo.removePlannedExercise(routine.id, plannedExercise.id),
      onAddRow: isLocked ? null : () => _addRow(repo, routine, plannedExercise),
      openRowIndex:
          !isLocked && openRow?.plannedExerciseId == plannedExercise.id
          ? openRow!.rowIndex
          : null,
      onRowTap: isLocked
          ? null
          : (rowIndex) => _toggleRow(plannedExercise.id, rowIndex),
      onDeleteRow: isLocked
          ? null
          : (rowIndex) =>
                _deleteRow(repo, routine, plannedExercise.id, rowIndex),
      onRowChanged: isLocked
          ? null
          : (rowIndex, updated) => repo.updatePlannedExerciseRow(
              routine.id,
              plannedExercise.id,
              rowIndex,
              updated,
            ),
    );
  }

  Widget _buildList(
    WorkoutRepository repo,
    Routine routine,
    List<Exercise> exercises,
  ) {
    if (routine.isLocked) {
      return ListView.builder(
        itemCount: routine.plannedExercises.length,
        itemBuilder: (context, index) =>
            _buildCard(repo, routine, exercises, index),
      );
    }
    return ReorderableListView.builder(
      itemCount: routine.plannedExercises.length,
      onReorderItem: (oldIndex, newIndex) =>
          repo.reorderPlannedExercises(routine.id, oldIndex, newIndex),
      itemBuilder: (context, index) =>
          _buildCard(repo, routine, exercises, index),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<WorkoutRepository>();
    final routine = repo.routines.firstWhere((r) => r.id == widget.routineId);
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
          if (!routine.isLocked)
            PlannedExerciseAddField(
              exercises: exercises,
              onAdd: (name) => repo.addPlannedExercise(routine.id, name),
            ),
          Expanded(
            child: routine.plannedExercises.isEmpty
                ? const Center(
                    key: ValueKey('routine-empty-state'),
                    child: Text('No Planned Exercises yet'),
                  )
                : _buildList(repo, routine, exercises),
          ),
        ],
      ),
    );
  }
}
