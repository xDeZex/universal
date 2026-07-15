import 'package:universal/models/exercise.dart';
import 'package:universal/models/workout.dart';
import 'package:universal/repositories/workout_repository.dart';
import 'package:universal/screens/active_workout_controller.dart';

ActiveWorkoutController makeController({
  required Workout workout,
  List<Exercise> exercises = const [],
}) {
  final repository = WorkoutRepository(
    initialWorkouts: [workout],
    initialExercises: exercises,
  );
  return ActiveWorkoutController(repository: repository, workoutId: workout.id);
}
