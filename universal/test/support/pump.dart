import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:universal/models/exercise.dart';
import 'package:universal/models/routine.dart';
import 'package:universal/models/workout.dart';
import 'package:universal/repositories/workout_repository.dart';
import 'package:universal/screens/active_workout_screen.dart';
import 'package:universal/screens/manage_exercises_screen.dart';
import 'package:universal/screens/manage_routines_screen.dart';
import 'package:universal/screens/past_workouts_screen.dart';
import 'package:universal/screens/routine_screen.dart';
import 'package:universal/screens/workout_home_screen.dart';
import 'package:universal/services/update_service.dart';

/// Pumps [child] as the home route of a [MaterialApp], wired to [repository]
/// via provider, optionally under a [mediaQueryData] override.
Future<WorkoutRepository> _pumpChild(
  WidgetTester tester, {
  required Widget child,
  required WorkoutRepository repository,
  MediaQueryData? mediaQueryData,
}) async {
  final provided = ChangeNotifierProvider<WorkoutRepository>.value(
    value: repository,
    child: child,
  );
  await tester.pumpWidget(
    MaterialApp(
      home: mediaQueryData == null
          ? provided
          : MediaQuery(data: mediaQueryData, child: provided),
    ),
  );
  return repository;
}

/// Pumps [child] wired to a freshly seeded [WorkoutRepository].
Future<WorkoutRepository> _pumpWithRepository(
  WidgetTester tester, {
  required Widget child,
  List<Workout>? initialWorkouts,
  List<Exercise>? initialExercises,
  List<Routine>? initialRoutines,
  MediaQueryData? mediaQueryData,
}) {
  final repository = WorkoutRepository(
    initialWorkouts: initialWorkouts,
    initialExercises: initialExercises,
    initialRoutines: initialRoutines,
  );
  return _pumpChild(
    tester,
    child: child,
    repository: repository,
    mediaQueryData: mediaQueryData,
  );
}

Future<WorkoutRepository> pumpWorkoutHomeScreen(
  WidgetTester tester, {
  List<Workout>? initialWorkouts,
  List<Exercise>? initialExercises,
  List<Routine>? initialRoutines,
}) {
  return _pumpWithRepository(
    tester,
    child: ChangeNotifierProvider<UpdateService>.value(
      value: UpdateService(),
      child: const WorkoutHomeScreen(),
    ),
    initialWorkouts: initialWorkouts,
    initialExercises: initialExercises,
    initialRoutines: initialRoutines,
  );
}

Future<WorkoutRepository> pumpWorkoutHomeScreenFromStorage(
  WidgetTester tester,
) {
  final repository = WorkoutRepository()..load();
  return _pumpChild(
    tester,
    child: ChangeNotifierProvider<UpdateService>.value(
      value: UpdateService(),
      child: const WorkoutHomeScreen(),
    ),
    repository: repository,
  );
}

Future<WorkoutRepository> pumpPastWorkoutsScreen(
  WidgetTester tester, {
  required List<Workout> workouts,
  required List<Exercise> exercises,
}) {
  return _pumpWithRepository(
    tester,
    child: const PastWorkoutsScreen(),
    initialWorkouts: workouts,
    initialExercises: exercises,
  );
}

Future<WorkoutRepository> pumpRoutineScreen(
  WidgetTester tester, {
  required List<Routine> routines,
  required String routineId,
  List<Exercise> exercises = const [],
  List<Workout> workouts = const [],
}) {
  return _pumpWithRepository(
    tester,
    child: RoutineScreen(routineId: routineId),
    initialWorkouts: workouts,
    initialExercises: exercises,
    initialRoutines: routines,
  );
}

Future<WorkoutRepository> pumpActiveWorkoutScreen(
  WidgetTester tester, {
  required Workout workout,
  required List<Exercise> exercises,
  MediaQueryData? mediaQueryData,
}) {
  return _pumpWithRepository(
    tester,
    child: ActiveWorkoutScreen(workoutId: workout.id),
    initialWorkouts: [workout],
    initialExercises: exercises,
    mediaQueryData: mediaQueryData,
  );
}

Future<WorkoutRepository> pumpManageExercisesScreen(
  WidgetTester tester, {
  required List<Exercise> exercises,
}) {
  return _pumpWithRepository(
    tester,
    child: const ManageExercisesScreen(),
    initialWorkouts: const [],
    initialExercises: exercises,
  );
}

Future<WorkoutRepository> pumpManageRoutinesScreen(
  WidgetTester tester, {
  required List<Routine> routines,
}) {
  return _pumpWithRepository(
    tester,
    child: const ManageRoutinesScreen(),
    initialWorkouts: const [],
    initialExercises: const [],
    initialRoutines: routines,
  );
}
