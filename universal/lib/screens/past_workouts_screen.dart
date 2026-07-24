import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/exercise.dart';
import '../models/workout.dart';
import '../repositories/workout_repository.dart';
import '../widgets/coplanar_card.dart';
import 'active_workout_screen.dart';
import 'navigation_helpers.dart';

class PastWorkoutsScreen extends StatelessWidget {
  const PastWorkoutsScreen({super.key});

  List<Workout> _finishedWorkouts(List<Workout> workouts) {
    final finished = workouts.where((w) => !w.isInProgress).toList();
    finished.sort((a, b) => b.endTime!.compareTo(a.endTime!));
    return finished;
  }

  String _exerciseSummary(Workout workout, List<Exercise> exercises) {
    return workout.exerciseEntries
        .map((entry) => Exercise.nameFor(entry.exerciseId, exercises))
        .join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<WorkoutRepository>();
    final finished = _finishedWorkouts(repo.workouts);

    return Scaffold(
      appBar: AppBar(title: const Text('Past Workouts')),
      body: finished.isEmpty
          ? const Center(child: Text('No past workouts yet'))
          : ListView(
              children: finished.map((workout) {
                return CoplanarCard(
                  key: ValueKey('past-workout-${workout.id}'),
                  child: ListTile(
                    title: Text(
                      MaterialLocalizations.of(
                        context,
                      ).formatShortDate(workout.endTime!),
                    ),
                    subtitle: Text(
                      _exerciseSummary(workout, repo.exercises),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => pushWithRepository(
                      context,
                      repo,
                      (context) => ActiveWorkoutScreen(workoutId: workout.id),
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }
}
