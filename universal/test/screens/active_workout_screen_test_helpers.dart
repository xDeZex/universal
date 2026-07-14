import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:universal/models/exercise.dart';
import 'package:universal/models/workout.dart';
import 'package:universal/repositories/workout_repository.dart';
import 'package:universal/screens/active_workout_screen.dart';

Future<WorkoutRepository> pumpActiveWorkoutScreen(
  WidgetTester tester, {
  required Workout workout,
  required List<Exercise> exercises,
}) async {
  final repository = WorkoutRepository(
    initialWorkouts: [workout],
    initialExercises: exercises,
  );
  await tester.pumpWidget(
    MaterialApp(
      home: ChangeNotifierProvider<WorkoutRepository>.value(
        value: repository,
        child: ActiveWorkoutScreen(workoutId: workout.id),
      ),
    ),
  );
  return repository;
}

Future<void> tapAndSettle(WidgetTester tester, String key) async {
  await tester.tap(find.byKey(ValueKey(key)));
  await tester.pumpAndSettle();
}

String weightStepperValue(WidgetTester tester) => tester
    .widget<Text>(find.byKey(const ValueKey('weight-stepper-value')))
    .data!;

String repsStepperValue(WidgetTester tester) => tester
    .widget<Text>(find.byKey(const ValueKey('reps-stepper-value')))
    .data!;
