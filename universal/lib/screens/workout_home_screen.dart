import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../repositories/workout_repository.dart';
import 'active_workout_screen.dart';
import 'manage_exercises_screen.dart';
import 'navigation_helpers.dart';
import 'past_workouts_screen.dart';

class WorkoutHomeScreen extends StatelessWidget {
  const WorkoutHomeScreen({super.key});

  void _startWorkout(BuildContext context) {
    final repo = context.read<WorkoutRepository>();
    if (repo.workouts.any((w) => w.isInProgress)) return;

    repo.startWorkout();
    final workout = repo.workouts.firstWhere((w) => w.isInProgress);
    _openActiveWorkout(context, workout.id);
  }

  void _continueWorkout(BuildContext context) {
    final workout = context
        .read<WorkoutRepository>()
        .workouts
        .firstWhere((w) => w.isInProgress);
    _openActiveWorkout(context, workout.id);
  }

  void _openPastWorkouts(BuildContext context) {
    pushWithRepository(
      context,
      context.read<WorkoutRepository>(),
      (context) => const PastWorkoutsScreen(),
    );
  }

  void _openManageExercises(BuildContext context) {
    pushWithRepository(
      context,
      context.read<WorkoutRepository>(),
      (context) => const ManageExercisesScreen(),
    );
  }

  void _openActiveWorkout(BuildContext context, String workoutId) {
    pushWithRepository(
      context,
      context.read<WorkoutRepository>(),
      (context) => ActiveWorkoutScreen(workoutId: workoutId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<WorkoutRepository>();
    final hasInProgress = repo.workouts.any((w) => w.isInProgress);

    return Scaffold(
      appBar: AppBar(title: const Text('Workout')),
      body: !repo.isLoaded
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: hasInProgress
                        ? () => _continueWorkout(context)
                        : () => _startWorkout(context),
                    child: Text(
                      hasInProgress ? 'Continue Workout' : 'Start Workout',
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () => _openPastWorkouts(context),
                        child: const Text('Past Workouts'),
                      ),
                      TextButton(
                        onPressed: () => _openManageExercises(context),
                        child: const Text('Manage Exercises'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
