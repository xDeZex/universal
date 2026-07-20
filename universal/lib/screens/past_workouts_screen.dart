import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/exercise.dart';
import '../models/workout.dart';
import '../prototype/row_card_variant.dart';
import '../repositories/workout_repository.dart';
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

  Widget _row(
    BuildContext context,
    RowCardVariant variant,
    Workout workout,
    List<Exercise> exercises,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final title = Text(
      MaterialLocalizations.of(context).formatShortDate(workout.endTime!),
    );
    final subtitle = Text(
      _exerciseSummary(workout, exercises),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    switch (variant) {
      case RowCardVariant.current:
      case RowCardVariant.accentBar:
        return ListTile(
          key: ValueKey('past-workout-${workout.id}'),
          title: title,
          subtitle: subtitle,
          onTap: onTap,
        );
      case RowCardVariant.gapList:
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
          child: Material(
            key: ValueKey('past-workout-${workout.id}'),
            color: theme.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: ListTile(title: title, subtitle: subtitle, onTap: onTap),
          ),
        );
      case RowCardVariant.coplanarCards:
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
          child: Card(
            key: ValueKey('past-workout-${workout.id}'),
            margin: EdgeInsets.zero,
            child: ListTile(title: title, subtitle: subtitle, onTap: onTap),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<WorkoutRepository>();
    final finished = _finishedWorkouts(repo.workouts);

    return Scaffold(
      appBar: AppBar(title: const Text('Past Workouts')),
      body: finished.isEmpty
          ? const Center(child: Text('No past workouts yet'))
          : ValueListenableBuilder<RowCardVariant>(
              valueListenable: rowCardVariant,
              builder: (context, variant, _) {
                final divide = variant == RowCardVariant.accentBar;
                return ListView(
                  children: [
                    for (var i = 0; i < finished.length; i++) ...[
                      _row(
                        context,
                        variant,
                        finished[i],
                        repo.exercises,
                        () => pushWithRepository(
                          context,
                          repo,
                          (context) =>
                              ActiveWorkoutScreen(workoutId: finished[i].id),
                        ),
                      ),
                      if (divide && i != finished.length - 1)
                        const Divider(height: 1, indent: 16, endIndent: 16),
                    ],
                  ],
                );
              },
            ),
    );
  }
}
