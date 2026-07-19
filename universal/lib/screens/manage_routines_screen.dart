import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/routine.dart';
import '../repositories/workout_repository.dart';
import '../widgets/routine_name_dialog.dart';
import '../widgets/routine_tile.dart';
import 'navigation_helpers.dart';
import 'routine_screen.dart';

class ManageRoutinesScreen extends StatelessWidget {
  const ManageRoutinesScreen({super.key});

  List<Routine> _sorted(List<Routine> routines) {
    final sorted = [...routines];
    sorted.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return sorted;
  }

  void _openRoutine(BuildContext context, String routineId) {
    pushWithRepository(
      context,
      context.read<WorkoutRepository>(),
      (context) => RoutineScreen(routineId: routineId),
    );
  }

  RoutineTile _tile(BuildContext context, Routine routine) {
    return RoutineTile(
      key: ValueKey('routine-${routine.id}'),
      routine: routine,
      onTap: () => _openRoutine(context, routine.id),
    );
  }

  Future<void> _createRoutine(
    BuildContext context,
    List<Routine> routines,
  ) async {
    final repo = context.read<WorkoutRepository>();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => RoutineNameDialog(
        title: 'Create Routine',
        confirmLabel: 'Create',
        initialName: '',
        fieldKey: const ValueKey('create-routine-field'),
        cancelKey: const ValueKey('create-routine-cancel'),
        confirmKey: const ValueKey('create-routine-create'),
        validate: (name) => Routine.validateNewName(name, routines),
      ),
    );
    if (name == null) return;
    if (!context.mounted) return;

    final routine = repo.addRoutine(name);
    if (routine == null) return;
    if (!context.mounted) return;

    pushWithRepository(
      context,
      repo,
      (context) => RoutineScreen(routineId: routine.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final routines = context.watch<WorkoutRepository>().routines;
    final active = _sorted(routines.where((r) => !r.isLocked).toList());
    final archived = _sorted(routines.where((r) => r.isLocked).toList());

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Routines')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createRoutine(context, routines),
        child: const Icon(Icons.add),
      ),
      body: routines.isEmpty
          ? const Center(child: Text('No Routines yet'))
          : ListView(
              children: [
                ...active.map((routine) => _tile(context, routine)),
                if (archived.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Archived',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...archived.map((routine) => _tile(context, routine)),
                ],
              ],
            ),
    );
  }
}
