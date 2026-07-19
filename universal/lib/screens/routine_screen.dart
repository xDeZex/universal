import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/routine.dart';
import '../repositories/workout_repository.dart';
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

  @override
  Widget build(BuildContext context) {
    final routine = context
        .watch<WorkoutRepository>()
        .routines
        .firstWhere((r) => r.id == routineId);

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
          const Expanded(
            child: Center(
              key: ValueKey('routine-empty-state'),
              child: Text('No Planned Exercises yet'),
            ),
          ),
        ],
      ),
    );
  }
}
