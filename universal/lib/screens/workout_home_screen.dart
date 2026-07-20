import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../prototype/workout_home_variant.dart';
import '../prototype/workout_home_variants.dart';
import '../repositories/workout_repository.dart';
import 'active_workout_screen.dart';
import 'manage_exercises_screen.dart';
import 'manage_routines_screen.dart';
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

  void _openManageRoutines(BuildContext context) {
    pushWithRepository(
      context,
      context.read<WorkoutRepository>(),
      (context) => const ManageRoutinesScreen(),
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ValueListenableBuilder<WorkoutHomeVariant>(
                  valueListenable: workoutHomeVariant,
                  builder: (context, variant, _) => WorkoutHomeActions(
                    variant: variant,
                    primaryLabel: hasInProgress
                        ? 'Continue Workout'
                        : 'Start Workout',
                    onPrimaryPressed: hasInProgress
                        ? () => _continueWorkout(context)
                        : () => _startWorkout(context),
                    secondaryActions: [
                      WorkoutHomeAction(
                        label: 'Past Workouts',
                        icon: Icons.history,
                        onPressed: () => _openPastWorkouts(context),
                      ),
                      WorkoutHomeAction(
                        label: 'Manage Exercises',
                        icon: Icons.fitness_center,
                        onPressed: () => _openManageExercises(context),
                      ),
                      WorkoutHomeAction(
                        label: 'Manage Routines',
                        icon: Icons.list_alt,
                        onPressed: () => _openManageRoutines(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
