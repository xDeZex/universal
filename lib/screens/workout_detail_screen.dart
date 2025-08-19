import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shopping_app_state.dart';
import '../models/workout_list.dart';
import '../models/exercise.dart';
import '../models/set_entry.dart';
import '../constants/spacing.dart';

class WorkoutDetailScreen extends StatelessWidget {
  
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
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.screenPadding),
            ),
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
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding, vertical: AppSpacing.dividerPadding),
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddExerciseDialog(workoutId: workoutList.id);
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
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: _iconSize,
          ),
          const SizedBox(width: AppSpacing.md),
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
    final rows = <Widget>[];
    
    // Check if we have today's logged entry with detailed sets
    final todaysWeight = exercise.todaysWeight;
    if (todaysWeight != null && todaysWeight.hasDetailedSets) {
      // Show actual logged sets with reps
      final setsDisplay = todaysWeight.setsRepsDisplay;
      rows.add(
        Text(
          '${todaysWeight.totalSets} sets: $setsDisplay reps',
          style: TextStyle(
            color: exercise.isCompleted
                ? Theme.of(context).colorScheme.onSurfaceVariant
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
      
      // Show weight from today's entry
      rows.add(
        Text(
          todaysWeight.weight,
          style: TextStyle(
            color: exercise.isCompleted
                ? Theme.of(context).colorScheme.onSurfaceVariant
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    } else if (todaysWeight != null) {
      // Show weight from today's entry (simple logging mode with no sets)
      // Note: Simple mode entries now create SetEntry objects internally
    } else {
      // Only show planned sets/reps when no logging has occurred
      if (exercise.sets != null || exercise.reps != null) {
        final setsReps = [
          if (exercise.sets != null) '${exercise.sets} sets',
          if (exercise.reps != null) '${exercise.reps} reps',
        ].join(' × ');
        
        rows.add(
          Text(
            'Target: $setsReps',
            style: TextStyle(
              color: exercise.isCompleted
                  ? Theme.of(context).colorScheme.onSurfaceVariant
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        );
      }
    }
    
    // Show weight from logging or planned weight
    final weightToShow = todaysWeight?.weight ?? exercise.weight;
    if (weightToShow != null) {
      final isPlanned = todaysWeight?.weight == null && exercise.weight != null;
      rows.add(
        Text(
          isPlanned ? 'Target: $weightToShow' : weightToShow,
          style: TextStyle(
            color: exercise.isCompleted
                ? Theme.of(context).colorScheme.onSurfaceVariant
                : Theme.of(context).colorScheme.onSurfaceVariant,
            fontStyle: isPlanned ? FontStyle.italic : null,
          ),
        ),
      );
    }
    
    if (rows.isEmpty) return null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows,
    );
  }

  Widget _buildTrailing(BuildContext context) {
    final buttons = [
      _buildAddWeightEntryButton(context),
      _buildEditButton(context),
      if (showDragHandle)
        ReorderableDragStartListener(
          index: index,
          child: const Icon(Icons.drag_handle),
        ),
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: buttons,
    );
  }

  Widget _buildAddWeightEntryButton(BuildContext context) {
    final todaysWeight = exercise.todaysWeight;
    final hasToday = todaysWeight != null;
    final hasCurrentData = exercise.weight != null && exercise.weight!.isNotEmpty;
    
    return IconButton(
      icon: Icon(
        hasToday ? Icons.check_circle : Icons.add_circle_outline,
        color: hasToday 
            ? Theme.of(context).colorScheme.primary 
            : Colors.grey[600],
        size: 20,
      ),
      onPressed: () {
        if (hasToday) {
          _unsaveWeightForToday(context);
        } else if (hasCurrentData) {
          _saveWeightForToday(context);
        } else {
          _showAddWeightEntryDialog(context);
        }
      },
      onLongPress: () => _showAddWeightEntryDialog(context),
      tooltip: hasToday 
          ? 'Remove today\'s weight entry (long press for custom date)'
          : hasCurrentData 
              ? 'Save current data for today (long press for custom date)'
              : 'Add weight entry (long press for custom date)',
    );
  }


  Widget _buildEditButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.edit),
      onPressed: () => _showEditExerciseDialog(context),
    );
  }


  void _saveWeightForToday(BuildContext context) {
    if (exercise.weight != null && exercise.weight!.isNotEmpty) {
      context.read<ShoppingAppState>().saveWeightForExercise(
        workoutId, 
        exercise.id, 
        exercise.weight!,
        sets: exercise.sets != null ? int.tryParse(exercise.sets!) : null,
        reps: exercise.reps != null ? int.tryParse(exercise.reps!) : null,
      );
    }
  }

  void _unsaveWeightForToday(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Remove Weight Entry'),
        content: Text('Are you sure you want to remove today\'s weight entry for "${exercise.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ShoppingAppState>().deleteTodaysWeightForExercise(
                workoutId,
                exercise.id,
              );
              Navigator.of(context).pop();
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showAddWeightEntryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => DetailedWeightEntryDialog(
        exercise: exercise,
        workoutId: workoutId,
      ),
    );
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
                const SizedBox(height: AppSpacing.screenPadding),
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
                    const SizedBox(width: AppSpacing.screenPadding),
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
                const SizedBox(height: AppSpacing.screenPadding),
                TextField(
                  controller: weightController,
                  decoration: const InputDecoration(
                    labelText: 'Weight',
                    hintText: '80kg or bodyweight',
                  ),
                ),
                const SizedBox(height: AppSpacing.screenPadding),
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
              onPressed: () => _showDeleteConfirmation(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
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

class AddExerciseDialog extends StatefulWidget {
  final String workoutId;

  const AddExerciseDialog({
    super.key,
    required this.workoutId,
  });

  @override
  State<AddExerciseDialog> createState() => _AddExerciseDialogState();
}

class _AddExerciseDialogState extends State<AddExerciseDialog> {
  final nameController = TextEditingController();
  final setsController = TextEditingController();
  final repsController = TextEditingController();
  final weightController = TextEditingController();
  final notesController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    setsController.dispose();
    repsController.dispose();
    weightController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ShoppingAppState>(
      builder: (context, appState, child) {
        final recommendations = appState.getExerciseNamesWithLogsNotInWorkout(widget.workoutId);
        
        return AlertDialog(
          title: const Text('Add Exercise'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (recommendations.isNotEmpty) ...[
                  Text(
                    'Suggestions (with previous logs):',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.sm,
                    children: recommendations.take(6).map((exerciseName) {
                      return ActionChip(
                        label: Text(exerciseName),
                        onPressed: () {
                          nameController.text = exerciseName;
                          final history = appState.getExerciseHistory(exerciseName);
                          if (history != null && history.weightHistory.isNotEmpty) {
                            final lastEntry = history.weightHistory.last;
                            if (lastEntry.hasDetailedSets) {
                              setsController.text = lastEntry.totalSets.toString();
                              if (lastEntry.setEntries.isNotEmpty) {
                                repsController.text = lastEntry.setEntries.first.reps.toString();
                              }
                            }
                            weightController.text = lastEntry.weight;
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.screenPadding),
                ],
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Exercise name',
                    hintText: 'e.g. Push ups, Bench press',
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: AppSpacing.screenPadding),
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
                    const SizedBox(width: AppSpacing.screenPadding),
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
                const SizedBox(height: AppSpacing.screenPadding),
                TextField(
                  controller: weightController,
                  decoration: const InputDecoration(
                    labelText: 'Weight',
                    hintText: '80kg or bodyweight',
                  ),
                ),
                const SizedBox(height: AppSpacing.screenPadding),
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
                  appState.addExerciseToWorkout(
                    widget.workoutId,
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

class DetailedWeightEntryDialog extends StatefulWidget {
  final Exercise exercise;
  final String workoutId;

  const DetailedWeightEntryDialog({
    super.key,
    required this.exercise,
    required this.workoutId,
  });

  @override
  State<DetailedWeightEntryDialog> createState() => _DetailedWeightEntryDialogState();
}

class _DetailedWeightEntryDialogState extends State<DetailedWeightEntryDialog> {
  final _baseWeightController = TextEditingController();
  final List<_SetEntryController> _setControllers = [];
  DateTime _selectedDate = DateTime.now();
  bool _useDetailedSets = false;
  
  // Legacy mode controllers
  final _legacySetsController = TextEditingController();
  final _legacyRepsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _baseWeightController.text = widget.exercise.weight ?? '';
    
    // Initialize with exercise's default sets/reps if available
    if (widget.exercise.sets != null) {
      _legacySetsController.text = widget.exercise.sets!;
    }
    if (widget.exercise.reps != null) {
      _legacyRepsController.text = widget.exercise.reps!;
    }
    
    // Add initial sets based on planned sets, or default to 1
    final plannedSets = widget.exercise.sets != null ? int.tryParse(widget.exercise.sets!) ?? 1 : 1;
    for (int i = 0; i < plannedSets; i++) {
      _addSet();
    }
  }

  @override
  void dispose() {
    _baseWeightController.dispose();
    _legacySetsController.dispose();
    _legacyRepsController.dispose();
    for (final controller in _setControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addSet() {
    setState(() {
      _setControllers.add(_SetEntryController(
        reps: widget.exercise.reps != null ? int.tryParse(widget.exercise.reps!) ?? 10 : 10,
        weight: _baseWeightController.text,
      ));
    });
  }

  void _removeSet(int index) {
    if (_setControllers.length > 1) {
      setState(() {
        _setControllers[index].dispose();
        _setControllers.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      title: Text('Weight Entry for ${widget.exercise.name}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date selection
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Date'),
                subtitle: Text(_formatDialogDate(_selectedDate)),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: AppSpacing.screenPadding),
            
            // Base weight input
            TextField(
              controller: _baseWeightController,
              decoration: const InputDecoration(
                labelText: 'Base Weight',
                hintText: 'e.g., 80kg, bodyweight',
              ),
              textCapitalization: TextCapitalization.none,
            ),
            const SizedBox(height: AppSpacing.screenPadding),
            
            // Toggle between modes
            Row(
              children: [
                Text('Logging mode:', style: theme.textTheme.titleSmall),
                const SizedBox(width: 8),
                Expanded(
                  child: SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: false, label: Text('Simple')),
                      ButtonSegment(value: true, label: Text('Detailed Sets')),
                    ],
                    selected: {_useDetailedSets},
                    onSelectionChanged: (Set<bool> selection) {
                      setState(() {
                        _useDetailedSets = selection.first;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.screenPadding),
            
            if (_useDetailedSets) ...[
              // Detailed sets mode
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Sets', style: theme.textTheme.titleSmall),
                  TextButton.icon(
                    onPressed: _addSet,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Set'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // List of sets
              ..._setControllers.asMap().entries.map((entry) {
                final index = entry.key;
                final controller = entry.value;
                return _buildSetRow(index, controller);
              }),
            ] else ...[
              // Simple mode - legacy sets and reps
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _legacySetsController,
                      decoration: const InputDecoration(
                        labelText: 'Sets',
                        hintText: '3',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.screenPadding),
                  Expanded(
                    child: TextField(
                      controller: _legacyRepsController,
                      decoration: const InputDecoration(
                        labelText: 'Reps',
                        hintText: '10',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _saveEntry,
          child: Text(_isToday(_selectedDate) ? 'Save' : 'Save for ${_formatDialogDate(_selectedDate)}'),
        ),
      ],
    );
  }

  Widget _buildSetRow(int index, _SetEntryController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Text('Set ${index + 1}:', style: const TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: controller._repsController,
                  decoration: const InputDecoration(
                    labelText: 'Reps',
                    hintText: '10',
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: TextField(
                  controller: controller._weightController,
                  decoration: const InputDecoration(
                    labelText: 'Weight',
                    hintText: '80kg',
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (_setControllers.length > 1)
                IconButton(
                  onPressed: () => _removeSet(index),
                  icon: const Icon(Icons.remove_circle_outline, size: 20),
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  padding: EdgeInsets.zero,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveEntry() {
    if (_baseWeightController.text.trim().isEmpty) {
      return;
    }

    final appState = context.read<ShoppingAppState>();
    
    if (_useDetailedSets) {
      // Save with detailed sets
      final setEntries = _setControllers
          .where((controller) => controller.isValid)
          .map((controller) => controller.toSetEntry())
          .toList();
      
      if (setEntries.isNotEmpty) {
        appState.saveDetailedWeightForExercise(
          widget.workoutId,
          widget.exercise.id,
          _baseWeightController.text.trim(),
          setEntries,
          date: _selectedDate,
        );
      }
    } else {
      // Save with legacy format
      final sets = _legacySetsController.text.trim().isNotEmpty 
          ? int.tryParse(_legacySetsController.text.trim())
          : null;
      final reps = _legacyRepsController.text.trim().isNotEmpty 
          ? int.tryParse(_legacyRepsController.text.trim())
          : null;
      
      appState.saveWeightForExercise(
        widget.workoutId,
        widget.exercise.id,
        _baseWeightController.text.trim(),
        sets: sets,
        reps: reps,
        date: _selectedDate,
      );
    }
    
    Navigator.of(context).pop();
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  String _formatDialogDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(date.year, date.month, date.day);
    final difference = today.difference(selectedDay).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _SetEntryController {
  final TextEditingController _repsController;
  final TextEditingController _weightController;
  final TextEditingController _notesController;

  _SetEntryController({
    int reps = 10,
    String weight = '',
    String notes = '',
  }) : _repsController = TextEditingController(text: reps.toString()),
       _weightController = TextEditingController(text: weight),
       _notesController = TextEditingController(text: notes);

  void dispose() {
    _repsController.dispose();
    _weightController.dispose();
    _notesController.dispose();
  }

  bool get isValid {
    final reps = int.tryParse(_repsController.text.trim());
    return reps != null && reps > 0;
  }

  SetEntry toSetEntry() {
    final reps = int.tryParse(_repsController.text.trim()) ?? 0;
    final weight = _weightController.text.trim().isNotEmpty 
        ? _weightController.text.trim() 
        : null;
    final notes = _notesController.text.trim().isNotEmpty 
        ? _notesController.text.trim() 
        : null;
    
    return SetEntry(
      reps: reps,
      weight: weight,
      notes: notes,
    );
  }
}