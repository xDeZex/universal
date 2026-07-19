import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:universal/models/exercise.dart';
import 'package:universal/models/routine.dart';
import 'package:universal/models/workout.dart';
import 'package:universal/repositories/workout_repository.dart';
import 'package:universal/screens/workout_home_screen.dart';

Future<WorkoutRepository> pumpWorkoutHomeScreen(
  WidgetTester tester, {
  List<Workout>? initialWorkouts,
  List<Exercise>? initialExercises,
  List<Routine>? initialRoutines,
}) async {
  final repository = WorkoutRepository(
    initialWorkouts: initialWorkouts,
    initialExercises: initialExercises,
    initialRoutines: initialRoutines,
  );
  await tester.pumpWidget(
    MaterialApp(
      home: ChangeNotifierProvider<WorkoutRepository>.value(
        value: repository,
        child: const WorkoutHomeScreen(),
      ),
    ),
  );
  return repository;
}

Future<WorkoutRepository> pumpWorkoutHomeScreenFromStorage(
  WidgetTester tester,
) async {
  final repository = WorkoutRepository()..load();
  await tester.pumpWidget(
    MaterialApp(
      home: ChangeNotifierProvider<WorkoutRepository>.value(
        value: repository,
        child: const WorkoutHomeScreen(),
      ),
    ),
  );
  return repository;
}
