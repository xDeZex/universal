import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/workout_list.dart';
import 'workout_detail_screen.dart';

class WorkoutListsScreen extends StatelessWidget {
  final bool showAppBar;
  
  const WorkoutListsScreen({super.key, this.showAppBar = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar ? AppBar(
        title: const Text('Workouts'),
      ) : null,
      body: Consumer<ShoppingAppState>(
        builder: (context, appState, child) {
          if (appState.workoutLists.isEmpty) {
            return Center(
              child: Text(
                'No workouts yet.\nTap the + button to create your first workout!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
              ),
            );
          }

          return ReorderableListView.builder(
            itemCount: appState.workoutLists.length,
            onReorder: (oldIndex, newIndex) {
              appState.reorderWorkoutLists(oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              final workoutList = appState.workoutLists[index];
              return Card(
                key: ValueKey(workoutList.id),
                child: ListTile(
                  title: Text(workoutList.name),
                  subtitle: Text(
                    '${workoutList.completedExercises}/${workoutList.totalExercises} exercises completed',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (workoutList.isCompleted)
                        const Icon(Icons.check_circle, color: Colors.green),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _showDeleteConfirmation(context, appState, workoutList),
                      ),
                      ReorderableDragStartListener(
                        index: index,
                        child: const Icon(Icons.drag_handle),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => WorkoutDetailScreen(
                          workoutList: workoutList,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddWorkoutDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, ShoppingAppState appState, WorkoutList workoutList) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Workout'),
          content: Text('Are you sure you want to delete "${workoutList.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                appState.deleteWorkoutList(workoutList.id);
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showAddWorkoutDialog(BuildContext context) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('New Workout'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Workout name',
              hintText: 'e.g. Push, Pull, Legs, Upper Body',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  context.read<ShoppingAppState>().addWorkoutList(controller.text.trim());
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}