import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal/models/exercise.dart';
import 'package:universal/models/workout.dart';
import 'package:universal/screens/active_workout_screen.dart';

Future<void> _pumpActiveWorkoutScreen(
  WidgetTester tester, {
  required Workout workout,
  required List<Exercise> exercises,
  void Function(Workout)? onWorkoutChanged,
  void Function(List<Exercise>)? onExercisesChanged,
  void Function(String)? onWorkoutDiscarded,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: ActiveWorkoutScreen(
        workout: workout,
        exercises: exercises,
        onWorkoutChanged: onWorkoutChanged ?? (_) {},
        onExercisesChanged: onExercisesChanged ?? (_) {},
        onWorkoutDiscarded: onWorkoutDiscarded ?? (_) {},
      ),
    ),
  );
}

void main() {
  group('ActiveWorkoutScreen', () {
    testWidgets(
      'submitting a new Exercise Entry name adds an entry and persists both '
      'the Workout and the Exercise list',
      (tester) async {
        Workout? savedWorkout;
        List<Exercise>? savedExercises;

        await _pumpActiveWorkoutScreen(
          tester,
          workout: Workout(id: 'workout-1', startTime: DateTime(2026, 1, 1)),
          exercises: const [],
          onWorkoutChanged: (w) => savedWorkout = w,
          onExercisesChanged: (e) => savedExercises = e,
        );

        await tester.enterText(find.byType(TextField).first, 'Bench Press');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        expect(savedWorkout, isNotNull);
        expect(savedWorkout!.exerciseEntries.length, 1);
        expect(savedExercises, isNotNull);
        expect(savedExercises!.length, 1);
        expect(savedExercises![0].name, 'Bench Press');
        expect(
          savedWorkout!.exerciseEntries[0].exerciseId,
          savedExercises![0].id,
        );
      },
    );

    testWidgets(
      'submitting an Exercise Entry name matching an existing Exercise '
      'reuses it and does not persist a new Exercise list',
      (tester) async {
        Workout? savedWorkout;
        var exercisesSaveCount = 0;
        final existing = Exercise(id: 'exercise-1', name: 'Bench Press');

        await _pumpActiveWorkoutScreen(
          tester,
          workout: Workout(id: 'workout-1', startTime: DateTime(2026, 1, 1)),
          exercises: [existing],
          onWorkoutChanged: (w) => savedWorkout = w,
          onExercisesChanged: (_) => exercisesSaveCount++,
        );

        await tester.enterText(find.byType(TextField).first, 'bench press');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        expect(savedWorkout, isNotNull);
        expect(savedWorkout!.exerciseEntries.length, 1);
        expect(savedWorkout!.exerciseEntries[0].exerciseId, 'exercise-1');
        expect(exercisesSaveCount, 0);
      },
    );

    testWidgets('submitting an empty or whitespace-only Exercise Entry name is '
        'rejected with no Entry added', (tester) async {
      var workoutSaveCount = 0;

      await _pumpActiveWorkoutScreen(
        tester,
        workout: Workout(id: 'workout-1', startTime: DateTime(2026, 1, 1)),
        exercises: const [],
        onWorkoutChanged: (_) => workoutSaveCount++,
      );

      await tester.enterText(find.byType(TextField).first, '   ');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(workoutSaveCount, 0);
    });

    testWidgets(
      'submitting valid weight and reps on an Exercise Entry adds a Set and '
      'persists the Workout',
      (tester) async {
        Workout? savedWorkout;
        final entry = ExerciseEntry(id: 'entry-1', exerciseId: 'exercise-1');
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1),
          exerciseEntries: [entry],
        );

        await _pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
          onWorkoutChanged: (w) => savedWorkout = w,
        );

        final weightField = find.byKey(const ValueKey('weight-entry-1'));
        final repsField = find.byKey(const ValueKey('reps-entry-1'));

        await tester.enterText(weightField, '60');
        await tester.enterText(repsField, '5');
        await tester.tap(find.byKey(const ValueKey('add-set-entry-1')));
        await tester.pumpAndSettle();

        expect(savedWorkout, isNotNull);
        expect(savedWorkout!.exerciseEntries[0].sets.length, 1);
        expect(savedWorkout!.exerciseEntries[0].sets[0].weight, 60);
        expect(savedWorkout!.exerciseEntries[0].sets[0].reps, 5);
      },
    );

    testWidgets(
      'submitting a non-numeric weight is rejected with no Set added',
      (tester) async {
        var workoutSaveCount = 0;
        final entry = ExerciseEntry(id: 'entry-1', exerciseId: 'exercise-1');
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1),
          exerciseEntries: [entry],
        );

        await _pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
          onWorkoutChanged: (_) => workoutSaveCount++,
        );

        await tester.enterText(
          find.byKey(const ValueKey('weight-entry-1')),
          'not-a-number',
        );
        await tester.enterText(find.byKey(const ValueKey('reps-entry-1')), '5');
        await tester.tap(find.byKey(const ValueKey('add-set-entry-1')));
        await tester.pumpAndSettle();

        expect(workoutSaveCount, 0);
      },
    );

    testWidgets(
      'submitting a non-positive-integer reps count is rejected with no Set '
      'added',
      (tester) async {
        var workoutSaveCount = 0;
        final entry = ExerciseEntry(id: 'entry-1', exerciseId: 'exercise-1');
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1),
          exerciseEntries: [entry],
        );

        await _pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
          onWorkoutChanged: (_) => workoutSaveCount++,
        );

        await tester.enterText(
          find.byKey(const ValueKey('weight-entry-1')),
          '60',
        );
        await tester.enterText(find.byKey(const ValueKey('reps-entry-1')), '0');
        await tester.tap(find.byKey(const ValueKey('add-set-entry-1')));
        await tester.pumpAndSettle();

        expect(workoutSaveCount, 0);
      },
    );

    testWidgets(
      'Finish action is disabled while the Workout has zero logged Sets',
      (tester) async {
        await _pumpActiveWorkoutScreen(
          tester,
          workout: Workout(id: 'workout-1', startTime: DateTime(2026, 1, 1)),
          exercises: const [],
        );

        final finishButton = tester.widget<ElevatedButton>(
          find.byKey(const ValueKey('finish-workout')),
        );

        expect(finishButton.onPressed, isNull);
      },
    );

    testWidgets(
      'an Exercise Entry whose exerciseId has no matching Exercise renders '
      'without throwing',
      (tester) async {
        final entry = ExerciseEntry(id: 'entry-1', exerciseId: 'missing');
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1),
          exerciseEntries: [entry],
        );

        await _pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: const [],
        );

        expect(tester.takeException(), isNull);
        expect(find.text('Unknown Exercise'), findsOneWidget);
      },
    );

    testWidgets(
      'Discard action is available even with zero logged Sets',
      (tester) async {
        await _pumpActiveWorkoutScreen(
          tester,
          workout: Workout(id: 'workout-1', startTime: DateTime(2026, 1, 1)),
          exercises: const [],
        );

        final discardButton = tester.widget<TextButton>(
          find.byKey(const ValueKey('discard-workout')),
        );

        expect(discardButton.onPressed, isNotNull);
      },
    );
  });
}
