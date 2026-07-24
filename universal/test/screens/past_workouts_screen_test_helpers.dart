import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:universal/models/exercise.dart';
import 'package:universal/models/workout.dart';
import 'package:universal/repositories/workout_repository.dart';
import 'package:universal/screens/past_workouts_screen.dart';

Future<WorkoutRepository> pumpPastWorkoutsScreen(
  WidgetTester tester, {
  required List<Workout> workouts,
  required List<Exercise> exercises,
}) async {
  final repository = WorkoutRepository(
    initialWorkouts: workouts,
    initialExercises: exercises,
  );
  await tester.pumpWidget(
    MaterialApp(
      home: ChangeNotifierProvider<WorkoutRepository>.value(
        value: repository,
        child: const PastWorkoutsScreen(),
      ),
    ),
  );
  return repository;
}
