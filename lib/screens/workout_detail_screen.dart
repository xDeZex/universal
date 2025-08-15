import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/workout_list.dart';
import '../models/exercise.dart';

class WorkoutDetailScreen extends StatelessWidget {
  static const double _sectionPadding = 16.0;
  static const double _dividerPadding = 8.0;
  
  final WorkoutList workoutList;

  const WorkoutDetailScreen({
    super.key,
    required this.workoutList,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFAB(context),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(workoutList.name),
    );
  }

  Widget _buildBody() {
    return Consumer<ShoppingAppState>(
      builder: (context, appState, child) {
        final currentList = _getCurrentList(appState);

        if (currentList.exercises.isEmpty) {
          return _buildEmptyState(context);
        }

        final exerciseGroups = _separateExercises(currentList);
        
        return CustomScrollView(
          slivers: [
            if (exerciseGroups.incompleteExercises.isNotEmpty)
              IncompleteExercisesSection(
                exercises: exerciseGroups.incompleteExercises,
                workoutId: currentList.id,
                onReorder: (oldIndex, newIndex) => 
                  _handleIncompleteExerciseReorder(appState, currentList.id, oldIndex, newIndex),
              ),

            if (_shouldShowDivider(exerciseGroups))
              _buildSectionDivider(context),

            if (exerciseGroups.completedExercises.isNotEmpty)
              CompletedExercisesSection(
                exercises: exerciseGroups.completedExercises,
                workoutId: currentList.id,
              ),
          ],
        );
      },
    );
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showAddExerciseDialog(context),
      child: const Icon(Icons.add),
    );
  }

  WorkoutList _getCurrentList(ShoppingAppState appState) {
    return appState.workoutLists.firstWhere((list) => list.id == workoutList.id);
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Text(
        'No exercises in this workout yet.\nTap the + button to add exercises!',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
      ),
    );
  }

  ExerciseGroups _separateExercises(WorkoutList list) {
    final incompleteExercises = list.exercises.where((exercise) => !exercise.isCompleted).toList();
    final completedExercises = list.exercises.where((exercise) => exercise.isCompleted).toList();
    return ExerciseGroups(incompleteExercises: incompleteExercises, completedExercises: completedExercises);
  }

  bool _shouldShowDivider(ExerciseGroups exerciseGroups) {
    return exerciseGroups.incompleteExercises.isNotEmpty && exerciseGroups.completedExercises.isNotEmpty;
  }

  Widget _buildSectionDivider(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: _sectionPadding, vertical: _dividerPadding),
        child: Divider(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
          thickness: 1,
        ),
      ),
    );
  }

  void _handleIncompleteExerciseReorder(ShoppingAppState appState, String workoutId, int oldIndex, int newIndex) {
    appState.reorderExercises(workoutId, oldIndex, newIndex);
  }

  void _showAddExerciseDialog(BuildContext context) {
    final nameController = TextEditingController();
    final setsController = TextEditingController();
    final repsController = TextEditingController();
    final weightController = TextEditingController();
    final notesController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Exercise'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Exercise name',
                    hintText: 'e.g. Push ups, Bench press',
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: setsController,
                        decoration: const InputDecoration(
                          labelText: 'Sets',
                          hintText: '3',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: repsController,
                        decoration: const InputDecoration(
                          labelText: 'Reps',
                          hintText: '10',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: weightController,
                  decoration: const InputDecoration(
                    labelText: 'Weight',
                    hintText: '80kg or bodyweight',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    hintText: 'Optional notes',
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  context.read<ShoppingAppState>().addExerciseToWorkout(
                    workoutList.id,
                    nameController.text.trim(),
                    sets: setsController.text.trim().isNotEmpty ? setsController.text.trim() : null,
                    reps: repsController.text.trim().isNotEmpty ? repsController.text.trim() : null,
                    weight: weightController.text.trim().isNotEmpty ? weightController.text.trim() : null,
                    notes: notesController.text.trim().isNotEmpty ? notesController.text.trim() : null,
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

// Helper classes
class ExerciseGroups {
  final List<Exercise> incompleteExercises;
  final List<Exercise> completedExercises;

  const ExerciseGroups({
    required this.incompleteExercises,
    required this.completedExercises,
  });
}

// Widget classes
class IncompleteExercisesSection extends StatelessWidget {
  final List<Exercise> exercises;
  final String workoutId;
  final void Function(int, int) onReorder;

  const IncompleteExercisesSection({
    super.key,
    required this.exercises,
    required this.workoutId,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: SectionHeader(
            icon: Icons.fitness_center,
            title: 'Exercises (${exercises.length})',
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        SliverReorderableList(
          itemCount: exercises.length,
          onReorder: onReorder,
          itemBuilder: (context, index) {
            final exercise = exercises[index];
            return ExerciseCard(
              key: ValueKey(exercise.id),
              exercise: exercise,
              workoutId: workoutId,
              index: index,
              showDragHandle: true,
            );
          },
        ),
      ],
    );
  }
}

class CompletedExercisesSection extends StatelessWidget {
  final List<Exercise> exercises;
  final String workoutId;

  const CompletedExercisesSection({
    super.key,
    required this.exercises,
    required this.workoutId,
  });

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: SectionHeader(
            icon: Icons.check_circle_outline,
            title: 'Completed (${exercises.length})',
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final exercise = exercises[index];
              return ExerciseCard(
                key: ValueKey(exercise.id),
                exercise: exercise,
                workoutId: workoutId,
                index: index,
                showDragHandle: false,
              );
            },
            childCount: exercises.length,
          ),
        ),
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  static const double _sectionPadding = 16.0;
  static const double _iconSize = 20.0;
  
  final IconData icon;
  final String title;
  final Color color;

  const SectionHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(_sectionPadding),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: _iconSize,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final String workoutId;
  final int index;
  final bool showDragHandle;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.workoutId,
    required this.index,
    required this.showDragHandle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: _buildCheckbox(context),
        title: _buildTitle(context),
        subtitle: _buildSubtitle(context),
        trailing: _buildTrailing(context),
      ),
    );
  }

  Widget _buildCheckbox(BuildContext context) {
    return Checkbox(
      value: exercise.isCompleted,
      onChanged: (bool? value) {
        context.read<ShoppingAppState>().toggleExerciseCompletion(workoutId, exercise.id);
      },
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      exercise.name,
      style: TextStyle(
        decoration: exercise.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
        color: exercise.isCompleted
            ? Theme.of(context).colorScheme.onSurfaceVariant
            : Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget? _buildSubtitle(BuildContext context) {
    final details = <String>[];
    
    if (exercise.sets != null || exercise.reps != null) {
      final setsReps = [
        if (exercise.sets != null) '${exercise.sets}s',
        if (exercise.reps != null) '${exercise.reps}r',
      ].join(' × ');
      details.add(setsReps);
    }
    
    if (exercise.weight != null) {
      details.add(exercise.weight!);
    }
    
    if (exercise.notes != null) {
      details.add(exercise.notes!);
    }
    
    if (details.isEmpty) return null;
    
    return Text(
      details.join(' • '),
      style: TextStyle(
        color: exercise.isCompleted
            ? Theme.of(context).colorScheme.onSurfaceVariant
            : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildTrailing(BuildContext context) {
    if (showDragHandle) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (exercise.weight != null && exercise.weight!.isNotEmpty)
            _buildSaveWeightButton(context),
          _buildEditButton(context),
          _buildDeleteButton(context),
          ReorderableDragStartListener(
            index: index,
            child: const Icon(Icons.drag_handle),
          ),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (exercise.weight != null && exercise.weight!.isNotEmpty)
          _buildSaveWeightButton(context),
        _buildEditButton(context),
        _buildDeleteButton(context),
      ],
    );
  }

  Widget _buildSaveWeightButton(BuildContext context) {
    final todaysWeight = exercise.todaysWeight;
    final hasToday = todaysWeight != null;
    
    return IconButton(
      icon: Icon(
        hasToday ? Icons.check_circle : Icons.save,
        color: hasToday ? Theme.of(context).colorScheme.primary : null,
      ),
      tooltip: hasToday 
          ? 'Weight saved for today: ${todaysWeight.weight}'
          : 'Save current weight for today',
      onPressed: hasToday ? null : () => _saveWeightForToday(context),
    );
  }


  Widget _buildEditButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.edit),
      onPressed: () => _showEditExerciseDialog(context),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.delete),
      onPressed: () => _showDeleteConfirmation(context),
    );
  }

  void _saveWeightForToday(BuildContext context) {
    if (exercise.weight != null && exercise.weight!.isNotEmpty) {
      context.read<ShoppingAppState>().saveWeightForExercise(
        workoutId, 
        exercise.id, 
        exercise.weight!,
      );
    }
  }

  void _showEditExerciseDialog(BuildContext context) {
    final nameController = TextEditingController(text: exercise.name);
    final setsController = TextEditingController(text: exercise.sets ?? '');
    final repsController = TextEditingController(text: exercise.reps ?? '');
    final weightController = TextEditingController(text: exercise.weight ?? '');
    final notesController = TextEditingController(text: exercise.notes ?? '');
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Exercise'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Exercise name',
                    hintText: 'e.g. Push ups, Bench press',
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: setsController,
                        decoration: const InputDecoration(
                          labelText: 'Sets',
                          hintText: '3',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: repsController,
                        decoration: const InputDecoration(
                          labelText: 'Reps',
                          hintText: '10',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: weightController,
                  decoration: const InputDecoration(
                    labelText: 'Weight',
                    hintText: '80kg or bodyweight',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    hintText: 'Optional notes',
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  final updatedExercise = exercise.copyWith(
                    name: nameController.text.trim(),
                    sets: setsController.text.trim().isNotEmpty ? setsController.text.trim() : null,
                    reps: repsController.text.trim().isNotEmpty ? repsController.text.trim() : null,
                    weight: weightController.text.trim().isNotEmpty ? weightController.text.trim() : null,
                    notes: notesController.text.trim().isNotEmpty ? notesController.text.trim() : null,
                  );
                  context.read<ShoppingAppState>().updateExercise(workoutId, exercise.id, updatedExercise);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }


  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete Exercise'),
        content: Text('Are you sure you want to delete "${exercise.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ShoppingAppState>().deleteExerciseFromWorkout(workoutId, exercise.id);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}