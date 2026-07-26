import 'package:universal/models/routine.dart';
import 'package:universal/models/workout.dart';

/// Builds an [ExerciseSet] fixture, defaulting every field to a value that
/// works for the common "one Set logged" case so tests only override what
/// their scenario actually cares about.
ExerciseSet buildSet({
  String id = 'set-1',
  num weight = 60,
  WeightUnit unit = WeightUnit.kg,
  int reps = 8,
  DateTime? loggedAt,
}) {
  return ExerciseSet(
    id: id,
    weight: weight,
    unit: unit,
    reps: reps,
    loggedAt: loggedAt ?? DateTime(2026, 1, 1, 10),
  );
}

/// Builds an [ExerciseEntry] fixture, defaulting to an empty, target-less
/// Entry so tests only override what their scenario actually cares about.
ExerciseEntry buildEntry({
  String id = 'entry-1',
  String exerciseId = 'exercise-1',
  List<ExerciseSet> sets = const [],
  List<PlannedExerciseRow>? targets,
}) {
  return ExerciseEntry(
    id: id,
    exerciseId: exerciseId,
    sets: sets,
    targets: targets,
  );
}

/// Builds a [Workout] fixture, defaulting to a fresh, empty, in-progress
/// Workout so tests only override what their scenario actually cares about.
class WorkoutBuilder {
  WorkoutBuilder({
    this.id = 'workout-1',
    DateTime? startTime,
    this.endTime,
    this.routineId,
    this.entries = const [],
  }) : startTime = startTime ?? DateTime(2026, 1, 1);

  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final String? routineId;
  final List<ExerciseEntry> entries;

  Workout build() {
    return Workout(
      id: id,
      startTime: startTime,
      endTime: endTime,
      routineId: routineId,
      exerciseEntries: entries,
    );
  }
}
