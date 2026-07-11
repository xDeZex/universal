import 'package:flutter/material.dart';

import '../models/exercise.dart';
import '../models/workout.dart';
import 'active_workout_screen.dart';

class PastWorkoutsScreen extends StatelessWidget {
  final List<Workout> workouts;
  final List<Exercise> exercises;

  const PastWorkoutsScreen({
    super.key,
    required this.workouts,
    required this.exercises,
  });

  List<Workout> get _finishedWorkouts {
    final finished = workouts.where((w) => !w.isInProgress).toList();
    finished.sort((a, b) => b.endTime!.compareTo(a.endTime!));
    return finished;
  }

  String _exerciseSummary(Workout workout) {
    return workout.exerciseEntries
        .map((entry) => Exercise.nameFor(entry.exerciseId, exercises))
        .join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final finished = _finishedWorkouts;

    return Scaffold(
      appBar: AppBar(title: const Text('Past Workouts')),
      body: finished.isEmpty
          ? const Center(child: Text('No past workouts yet'))
          : ListView(
              children: finished.map((workout) {
                return ListTile(
                  key: ValueKey('past-workout-${workout.id}'),
                  title: Text(
                    MaterialLocalizations.of(
                      context,
                    ).formatShortDate(workout.endTime!),
                  ),
                  subtitle: Text(
                    _exerciseSummary(workout),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => Navigator.push<void>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ActiveWorkoutScreen(
                        workout: workout,
                        exercises: exercises,
                        onWorkoutChanged: (_) {},
                        onExercisesChanged: (_) {},
                        onWorkoutDiscarded: (_) {},
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }
}
