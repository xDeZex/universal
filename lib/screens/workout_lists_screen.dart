import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shopping_app_state.dart';
import '../models/workout_list.dart';
import '../constants/spacing.dart';
import 'workout_detail_screen.dart';

class WorkoutListsScreen extends StatelessWidget {
  final bool showAppBar;
  
  const WorkoutListsScreen({super.key, this.showAppBar = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Consumer<ShoppingAppState>(
        builder: (context, appState, child) => _buildBody(context, appState),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  PreferredSizeWidget? _buildAppBar() {
    if (!showAppBar) return null;
    
    return AppBar(
      title: const Text('Workouts'),
    );
  }

  Widget _buildBody(BuildContext context, ShoppingAppState appState) {
    if (appState.workoutLists.isEmpty) {
      return _buildEmptyState(context);
    }

    return _buildWorkoutList(context, appState);
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Text(
        'No workouts yet.\nTap the + button to create your first workout!',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
      ),
    );
  }

  Widget _buildWorkoutList(BuildContext context, ShoppingAppState appState) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.only(top: AppSpacing.screenPadding),
      itemCount: appState.workoutLists.length,
      onReorder: (oldIndex, newIndex) => appState.reorderWorkoutLists(oldIndex, newIndex),
      itemBuilder: (context, index) => _buildWorkoutCard(context, appState, appState.workoutLists[index], index),
    );
  }

  Widget _buildWorkoutCard(BuildContext context, ShoppingAppState appState, WorkoutList workoutList, int index) {
    return Card(
      key: ValueKey(workoutList.id),
      child: ListTile(
        title: _buildWorkoutTitle(workoutList),
        subtitle: _buildWorkoutSubtitle(workoutList),
        trailing: _buildWorkoutActions(context, appState, workoutList, index),
        onTap: () => _navigateToWorkoutDetail(context, workoutList),
      ),
    );
  }

  Widget _buildWorkoutTitle(WorkoutList workoutList) {
    return Text(workoutList.name);
  }

  Widget _buildWorkoutSubtitle(WorkoutList workoutList) {
    return Text(
      '${workoutList.completedExercises}/${workoutList.totalExercises} exercises completed',
    );
  }

  Widget _buildWorkoutActions(BuildContext context, ShoppingAppState appState, WorkoutList workoutList, int index) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (workoutList.isCompleted) _buildCompletionIcon(),
        _buildDeleteButton(context, appState, workoutList),
        _buildDragHandle(index),
      ],
    );
  }

  Widget _buildCompletionIcon() {
    return const Icon(Icons.check_circle, color: Colors.green);
  }

  Widget _buildDeleteButton(BuildContext context, ShoppingAppState appState, WorkoutList workoutList) {
    return IconButton(
      icon: const Icon(Icons.delete),
      onPressed: () => _showDeleteConfirmation(context, appState, workoutList),
    );
  }

  Widget _buildDragHandle(int index) {
    return ReorderableDragStartListener(
      index: index,
      child: const Icon(Icons.drag_handle),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showAddWorkoutDialog(context),
      child: const Icon(Icons.add),
    );
  }

  // ============================================================================
  // Helper Methods - Navigation
  // ============================================================================

  void _navigateToWorkoutDetail(BuildContext context, WorkoutList workoutList) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WorkoutDetailScreen(
          workoutList: workoutList,
        ),
      ),
    );
  }

  // ============================================================================
  // Helper Methods - Dialog Management
  // ============================================================================

  void _showDeleteConfirmation(BuildContext context, ShoppingAppState appState, WorkoutList workoutList) {
    showDialog(
      context: context,
      builder: (BuildContext context) => _buildDeleteConfirmationDialog(context, appState, workoutList),
    );
  }

  Widget _buildDeleteConfirmationDialog(BuildContext context, ShoppingAppState appState, WorkoutList workoutList) {
    return AlertDialog(
      title: const Text('Delete Workout'),
      content: Text('Are you sure you want to delete "${workoutList.name}"?'),
      actions: [
        _buildDialogCancelButton(context),
        _buildDialogDeleteButton(context, appState, workoutList),
      ],
    );
  }

  Widget _buildDialogCancelButton(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.of(context).pop(),
      child: const Text('Cancel'),
    );
  }

  Widget _buildDialogDeleteButton(BuildContext context, ShoppingAppState appState, WorkoutList workoutList) {
    return TextButton(
      onPressed: () {
        appState.deleteWorkoutList(workoutList.id);
        Navigator.of(context).pop();
      },
      child: const Text('Delete'),
    );
  }

  void _showAddWorkoutDialog(BuildContext context) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) => _buildAddWorkoutDialog(context, controller),
    );
  }

  Widget _buildAddWorkoutDialog(BuildContext context, TextEditingController controller) {
    return AlertDialog(
      title: const Text('New Workout'),
      content: _buildWorkoutNameField(controller),
      actions: [
        _buildDialogCancelButton(context),
        _buildDialogCreateButton(context, controller),
      ],
    );
  }

  Widget _buildWorkoutNameField(TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Workout name',
        hintText: 'e.g. Push, Pull, Legs, Upper Body',
      ),
      autofocus: true,
    );
  }

  Widget _buildDialogCreateButton(BuildContext context, TextEditingController controller) {
    return TextButton(
      onPressed: () {
        if (controller.text.trim().isNotEmpty) {
          context.read<ShoppingAppState>().addWorkoutList(controller.text.trim());
          Navigator.of(context).pop();
        }
      },
      child: const Text('Create'),
    );
  }
}