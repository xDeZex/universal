import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/exercise.dart';
import '../repositories/workout_repository.dart';
import '../widgets/exercise_tile.dart';

class ManageExercisesScreen extends StatelessWidget {
  const ManageExercisesScreen({super.key});

  List<Exercise> _sortedExercises(List<Exercise> exercises) {
    final sorted = [...exercises];
    sorted.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return sorted;
  }

  Future<void> _renameExercise(
    BuildContext context,
    Exercise exercise,
    List<Exercise> exercises,
  ) async {
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => _RenameExerciseDialog(
        exercise: exercise,
        existingExercises: exercises,
      ),
    );
    if (newName == null) return;
    if (!context.mounted) return;

    context.read<WorkoutRepository>().renameExercise(exercise.id, newName);
  }

  @override
  Widget build(BuildContext context) {
    final exercises = context.watch<WorkoutRepository>().exercises;
    final sorted = _sortedExercises(exercises);
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Exercises')),
      body: sorted.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('No Exercises yet'),
                  Text('Log a Workout to add one'),
                ],
              ),
            )
          : ListView(
              children: sorted.map((exercise) {
                return ExerciseTile(
                  key: ValueKey('exercise-${exercise.id}'),
                  exercise: exercise,
                  onTap: () => _renameExercise(context, exercise, exercises),
                );
              }).toList(),
            ),
    );
  }
}

class _RenameExerciseDialog extends StatefulWidget {
  final Exercise exercise;
  final List<Exercise> existingExercises;

  const _RenameExerciseDialog({
    required this.exercise,
    required this.existingExercises,
  });

  @override
  State<_RenameExerciseDialog> createState() => _RenameExerciseDialogState();
}

class _RenameExerciseDialogState extends State<_RenameExerciseDialog> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.exercise.name);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text;
    final error = widget.exercise.validateRename(
      name,
      widget.existingExercises,
    );
    if (error != null) {
      setState(() {
        _errorText = switch (error) {
          ExerciseRenameError.blank => 'Name cannot be empty',
          ExerciseRenameError.duplicate =>
            'An Exercise with this name already exists',
        };
      });
      return;
    }

    Navigator.pop(context, name.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rename Exercise'),
      content: TextField(
        key: const ValueKey('rename-exercise-field'),
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(errorText: _errorText),
      ),
      actions: [
        TextButton(
          key: const ValueKey('rename-exercise-cancel'),
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          key: const ValueKey('rename-exercise-save'),
          onPressed: _submit,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
