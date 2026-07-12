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
        expect(savedWorkout!.exerciseEntries[0].sets[0].unit, WeightUnit.kg);
        expect(savedWorkout!.exerciseEntries[0].sets[0].reps, 5);
      },
    );

    testWidgets(
      'a freshly added Exercise Entry shows a kg/lbs unit toggle next to the '
      'weight and reps fields',
      (tester) async {
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
        );

        expect(find.byKey(const ValueKey('unit-kg-entry-1')), findsOneWidget);
        expect(find.byKey(const ValueKey('unit-lbs-entry-1')), findsOneWidget);
      },
    );

    testWidgets(
      'selecting lbs before submitting a Set includes lbs on the created Set',
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

        await tester.tap(find.byKey(const ValueKey('unit-lbs-entry-1')));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const ValueKey('weight-entry-1')),
          '135',
        );
        await tester.enterText(find.byKey(const ValueKey('reps-entry-1')), '8');
        await tester.tap(find.byKey(const ValueKey('add-set-entry-1')));
        await tester.pumpAndSettle();

        expect(savedWorkout, isNotNull);
        expect(savedWorkout!.exerciseEntries[0].sets[0].unit, WeightUnit.lbs);
      },
    );

    testWidgets(
      'the unit toggle stays on lbs for the next Set after logging one with '
      'lbs on the same Exercise Entry',
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

        await tester.tap(find.byKey(const ValueKey('unit-lbs-entry-1')));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const ValueKey('weight-entry-1')),
          '135',
        );
        await tester.enterText(find.byKey(const ValueKey('reps-entry-1')), '8');
        await tester.tap(find.byKey(const ValueKey('add-set-entry-1')));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const ValueKey('weight-entry-1')),
          '140',
        );
        await tester.enterText(find.byKey(const ValueKey('reps-entry-1')), '6');
        await tester.tap(find.byKey(const ValueKey('add-set-entry-1')));
        await tester.pumpAndSettle();

        expect(savedWorkout, isNotNull);
        expect(savedWorkout!.exerciseEntries[0].sets.length, 2);
        expect(savedWorkout!.exerciseEntries[0].sets[1].unit, WeightUnit.lbs);
      },
    );

    testWidgets(
      'a logged Set is displayed as "<reps> reps at <weight> <unit>"',
      (tester) async {
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
        );

        await tester.tap(find.byKey(const ValueKey('unit-lbs-entry-1')));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const ValueKey('weight-entry-1')),
          '135',
        );
        await tester.enterText(find.byKey(const ValueKey('reps-entry-1')), '8');
        await tester.tap(find.byKey(const ValueKey('add-set-entry-1')));
        await tester.pumpAndSettle();

        expect(find.text('8 reps at 135 lbs'), findsOneWidget);
      },
    );

    testWidgets(
      'a logged Set on a finished Workout is displayed as "<reps> reps at '
      '<weight> <unit> — <loggedAt time>"',
      (tester) async {
        final entry = ExerciseEntry(
          id: 'entry-1',
          exerciseId: 'exercise-1',
          sets: [
            ExerciseSet(
              id: 'set-1',
              weight: 50,
              unit: WeightUnit.kg,
              reps: 8,
              loggedAt: DateTime(2026, 1, 1, 18, 42),
            ),
          ],
        );
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1, 18, 0),
          endTime: DateTime(2026, 1, 1, 18, 42),
          exerciseEntries: [entry],
        );

        await _pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
        );

        expect(find.text('8 reps at 50 kg — 6:42 PM'), findsOneWidget);
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

    testWidgets(
      'the Discard and Finish buttons stay clear of the bottom system inset '
      '(e.g. a gesture/button navigation bar)',
      (tester) async {
        const bottomInset = 48.0;

        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                padding: EdgeInsets.only(bottom: bottomInset),
              ),
              child: ActiveWorkoutScreen(
                workout: Workout(
                  id: 'workout-1',
                  startTime: DateTime(2026, 1, 1),
                ),
                exercises: const [],
                onWorkoutChanged: (_) {},
                onExercisesChanged: (_) {},
                onWorkoutDiscarded: (_) {},
              ),
            ),
          ),
        );

        final screenHeight =
            tester.view.physicalSize.height / tester.view.devicePixelRatio;
        final maxAllowedY = screenHeight - bottomInset;

        final discardBottom = tester.getBottomLeft(
          find.byKey(const ValueKey('discard-workout')),
        );
        final finishBottom = tester.getBottomLeft(
          find.byKey(const ValueKey('finish-workout')),
        );

        expect(discardBottom.dy, lessThanOrEqualTo(maxAllowedY));
        expect(finishBottom.dy, lessThanOrEqualTo(maxAllowedY));
      },
    );

    testWidgets(
      'a finished Workout hides the add-Exercise-Entry field, add-Set '
      'controls, and Discard/Finish buttons',
      (tester) async {
        final entry1 = ExerciseEntry(
          id: 'entry-1',
          exerciseId: 'exercise-1',
          sets: [
            ExerciseSet(
              id: 'set-1',
              weight: 60,
              unit: WeightUnit.kg,
              reps: 5,
              loggedAt: DateTime(2026, 1, 1, 10, 30),
            ),
          ],
        );
        final entry2 = ExerciseEntry(
          id: 'entry-2',
          exerciseId: 'exercise-2',
          sets: [
            ExerciseSet(
              id: 'set-2',
              weight: 40,
              unit: WeightUnit.kg,
              reps: 8,
              loggedAt: DateTime(2026, 1, 1, 10, 20),
            ),
          ],
        );
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1, 10, 0),
          endTime: DateTime(2026, 1, 1, 10, 30),
          exerciseEntries: [entry1, entry2],
        );

        await _pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: [
            Exercise(id: 'exercise-1', name: 'Bench Press'),
            Exercise(id: 'exercise-2', name: 'Squat'),
          ],
        );

        expect(find.byType(TextField), findsNothing);
        expect(find.byType(ChoiceChip), findsNothing);
        expect(find.byKey(const ValueKey('add-set-entry-1')), findsNothing);
        expect(find.byKey(const ValueKey('add-set-entry-2')), findsNothing);
        expect(
          find.byKey(const ValueKey('discard-workout')),
          findsNothing,
        );
        expect(find.byKey(const ValueKey('finish-workout')), findsNothing);

        expect(find.text('Bench Press'), findsOneWidget);
        expect(find.text('5 reps at 60 kg — 10:30 AM'), findsOneWidget);
        expect(find.text('Squat'), findsOneWidget);
        expect(find.text('8 reps at 40 kg — 10:20 AM'), findsOneWidget);
      },
    );

    testWidgets(
      'an in-progress Workout still shows the add-Exercise-Entry field, '
      'add-Set controls, and Discard/Finish buttons',
      (tester) async {
        final entry = ExerciseEntry(id: 'entry-1', exerciseId: 'exercise-1');
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1, 10, 0),
          exerciseEntries: [entry],
        );

        await _pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
        );

        expect(find.byType(TextField), findsNWidgets(3));
        expect(find.byKey(const ValueKey('add-set-entry-1')), findsOneWidget);
        expect(
          find.byKey(const ValueKey('discard-workout')),
          findsOneWidget,
        );
        expect(find.byKey(const ValueKey('finish-workout')), findsOneWidget);
      },
    );

    testWidgets(
      'a finished Workout shows its end date as the AppBar title instead '
      'of "Active Workout"',
      (tester) async {
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 3, 5, 9, 0),
          endTime: DateTime(2026, 3, 5, 9, 30),
        );

        await _pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: const [],
        );

        expect(find.text('Active Workout'), findsNothing);
        expect(find.text('Mar 5, 2026'), findsOneWidget);
      },
    );

    testWidgets(
      'an in-progress Workout still shows "Active Workout" as the AppBar '
      'title',
      (tester) async {
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 3, 5, 9, 0),
        );

        await _pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: const [],
        );

        expect(find.text('Active Workout'), findsOneWidget);
      },
    );

    testWidgets(
      'tapping a logged Set opens an edit dialog pre-filled with its '
      'current weight, unit, and reps',
      (tester) async {
        final entry = ExerciseEntry(
          id: 'entry-1',
          exerciseId: 'exercise-1',
          sets: [
            ExerciseSet(
              id: 'set-1',
              weight: 60,
              unit: WeightUnit.kg,
              reps: 8,
              loggedAt: DateTime(2026, 1, 1, 10, 0),
            ),
          ],
        );
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1, 9, 0),
          exerciseEntries: [entry],
        );

        await _pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
        );

        await tester.tap(find.byKey(const ValueKey('set-set-1')));
        await tester.pumpAndSettle();

        final weightField = tester.widget<TextField>(
          find.byKey(const ValueKey('edit-weight-set-1')),
        );
        final repsField = tester.widget<TextField>(
          find.byKey(const ValueKey('edit-reps-set-1')),
        );
        final kgChip = tester.widget<ChoiceChip>(
          find.byKey(const ValueKey('edit-unit-kg-set-1')),
        );

        expect(weightField.controller!.text, '60');
        expect(repsField.controller!.text, '8');
        expect(kgChip.selected, isTrue);
      },
    );

    testWidgets(
      'submitting valid new values from the edit dialog updates the Set '
      'and leaves loggedAt unchanged',
      (tester) async {
        Workout? savedWorkout;
        final loggedAt = DateTime(2026, 1, 1, 10, 0);
        final entry = ExerciseEntry(
          id: 'entry-1',
          exerciseId: 'exercise-1',
          sets: [
            ExerciseSet(
              id: 'set-1',
              weight: 60,
              unit: WeightUnit.kg,
              reps: 8,
              loggedAt: loggedAt,
            ),
          ],
        );
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1, 9, 0),
          exerciseEntries: [entry],
        );

        await _pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
          onWorkoutChanged: (w) => savedWorkout = w,
        );

        await tester.tap(find.byKey(const ValueKey('set-set-1')));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const ValueKey('edit-weight-set-1')),
          '65',
        );
        await tester.enterText(
          find.byKey(const ValueKey('edit-reps-set-1')),
          '6',
        );
        await tester.tap(find.byKey(const ValueKey('edit-unit-lbs-set-1')));
        await tester.tap(find.byKey(const ValueKey('edit-submit-set-1')));
        await tester.pumpAndSettle();

        expect(savedWorkout, isNotNull);
        final updatedSet = savedWorkout!.exerciseEntries[0].sets[0];
        expect(updatedSet.weight, 65);
        expect(updatedSet.unit, WeightUnit.lbs);
        expect(updatedSet.reps, 6);
        expect(updatedSet.loggedAt, loggedAt);
      },
    );

    testWidgets(
      'submitting a non-numeric weight from the edit dialog is rejected, '
      'leaving the Set unchanged',
      (tester) async {
        var workoutSaveCount = 0;
        final entry = ExerciseEntry(
          id: 'entry-1',
          exerciseId: 'exercise-1',
          sets: [
            ExerciseSet(
              id: 'set-1',
              weight: 60,
              unit: WeightUnit.kg,
              reps: 8,
              loggedAt: DateTime(2026, 1, 1, 10, 0),
            ),
          ],
        );
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1, 9, 0),
          exerciseEntries: [entry],
        );

        await _pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
          onWorkoutChanged: (_) => workoutSaveCount++,
        );

        await tester.tap(find.byKey(const ValueKey('set-set-1')));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const ValueKey('edit-weight-set-1')),
          'not-a-number',
        );
        await tester.tap(find.byKey(const ValueKey('edit-submit-set-1')));
        await tester.pumpAndSettle();

        expect(workoutSaveCount, 0);
        expect(find.byKey(const ValueKey('edit-weight-set-1')), findsOneWidget);
      },
    );

    testWidgets(
      'submitting a non-positive-integer reps count from the edit dialog is '
      'rejected, leaving the Set unchanged',
      (tester) async {
        var workoutSaveCount = 0;
        final entry = ExerciseEntry(
          id: 'entry-1',
          exerciseId: 'exercise-1',
          sets: [
            ExerciseSet(
              id: 'set-1',
              weight: 60,
              unit: WeightUnit.kg,
              reps: 8,
              loggedAt: DateTime(2026, 1, 1, 10, 0),
            ),
          ],
        );
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1, 9, 0),
          exerciseEntries: [entry],
        );

        await _pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
          onWorkoutChanged: (_) => workoutSaveCount++,
        );

        await tester.tap(find.byKey(const ValueKey('set-set-1')));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const ValueKey('edit-reps-set-1')),
          '0',
        );
        await tester.tap(find.byKey(const ValueKey('edit-submit-set-1')));
        await tester.pumpAndSettle();

        expect(workoutSaveCount, 0);
        expect(find.byKey(const ValueKey('edit-reps-set-1')), findsOneWidget);
      },
    );

    testWidgets(
      'submitting a zero or negative weight from the edit dialog is '
      'accepted, same as adding a Set',
      (tester) async {
        Workout? savedWorkout;
        final entry = ExerciseEntry(
          id: 'entry-1',
          exerciseId: 'exercise-1',
          sets: [
            ExerciseSet(
              id: 'set-1',
              weight: 60,
              unit: WeightUnit.kg,
              reps: 8,
              loggedAt: DateTime(2026, 1, 1, 10, 0),
            ),
          ],
        );
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1, 9, 0),
          exerciseEntries: [entry],
        );

        await _pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
          onWorkoutChanged: (w) => savedWorkout = w,
        );

        await tester.tap(find.byKey(const ValueKey('set-set-1')));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const ValueKey('edit-weight-set-1')),
          '-10',
        );
        await tester.tap(find.byKey(const ValueKey('edit-submit-set-1')));
        await tester.pumpAndSettle();

        expect(savedWorkout, isNotNull);
        expect(savedWorkout!.exerciseEntries[0].sets[0].weight, -10);
      },
    );

    testWidgets(
      'tapping a logged Set belonging to a Locked Workout opens the same '
      'edit dialog and behaves identically to an in-progress Workout',
      (tester) async {
        Workout? savedWorkout;
        final loggedAt = DateTime(2026, 1, 1, 10, 0);
        final entry = ExerciseEntry(
          id: 'entry-1',
          exerciseId: 'exercise-1',
          sets: [
            ExerciseSet(
              id: 'set-1',
              weight: 60,
              unit: WeightUnit.kg,
              reps: 8,
              loggedAt: loggedAt,
            ),
          ],
        );
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1, 9, 0),
          endTime: loggedAt,
          exerciseEntries: [entry],
        );

        await _pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
          onWorkoutChanged: (w) => savedWorkout = w,
        );

        await tester.tap(find.byKey(const ValueKey('set-set-1')));
        await tester.pumpAndSettle();

        expect(find.byKey(const ValueKey('edit-weight-set-1')), findsOneWidget);

        await tester.enterText(
          find.byKey(const ValueKey('edit-weight-set-1')),
          '70',
        );
        await tester.tap(find.byKey(const ValueKey('edit-submit-set-1')));
        await tester.pumpAndSettle();

        expect(savedWorkout, isNotNull);
        expect(savedWorkout!.exerciseEntries[0].sets[0].weight, 70);
        expect(savedWorkout!.exerciseEntries[0].sets[0].loggedAt, loggedAt);
      },
    );

    testWidgets(
      'cancelling the edit dialog closes it without persisting or changing '
      'the Set',
      (tester) async {
        var workoutSaveCount = 0;
        final entry = ExerciseEntry(
          id: 'entry-1',
          exerciseId: 'exercise-1',
          sets: [
            ExerciseSet(
              id: 'set-1',
              weight: 60,
              unit: WeightUnit.kg,
              reps: 8,
              loggedAt: DateTime(2026, 1, 1, 10, 0),
            ),
          ],
        );
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1, 9, 0),
          exerciseEntries: [entry],
        );

        await _pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
          onWorkoutChanged: (_) => workoutSaveCount++,
        );

        await tester.tap(find.byKey(const ValueKey('set-set-1')));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const ValueKey('edit-weight-set-1')),
          '999',
        );
        await tester.tap(find.byKey(const ValueKey('edit-cancel-set-1')));
        await tester.pumpAndSettle();

        expect(workoutSaveCount, 0);
        expect(find.byKey(const ValueKey('edit-weight-set-1')), findsNothing);
        expect(find.text('8 reps at 60 kg'), findsOneWidget);
      },
    );

    testWidgets(
      'the Set edit dialog has a Delete action that opens a confirmation '
      'dialog',
      (tester) async {
        final entry = ExerciseEntry(
          id: 'entry-1',
          exerciseId: 'exercise-1',
          sets: [
            ExerciseSet(
              id: 'set-1',
              weight: 60,
              unit: WeightUnit.kg,
              reps: 8,
              loggedAt: DateTime(2026, 1, 1, 10, 0),
            ),
          ],
        );
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1, 9, 0),
          exerciseEntries: [entry],
        );

        await _pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
        );

        await tester.tap(find.byKey(const ValueKey('set-set-1')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('edit-delete-set-1')));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey('confirm-delete-confirm')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('confirm-delete-cancel')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'confirming the delete-Set confirmation removes the Set from its '
      'Exercise Entry',
      (tester) async {
        Workout? savedWorkout;
        final entry = ExerciseEntry(
          id: 'entry-1',
          exerciseId: 'exercise-1',
          sets: [
            ExerciseSet(
              id: 'set-1',
              weight: 60,
              unit: WeightUnit.kg,
              reps: 8,
              loggedAt: DateTime(2026, 1, 1, 10, 0),
            ),
            ExerciseSet(
              id: 'set-2',
              weight: 20,
              unit: WeightUnit.kg,
              reps: 10,
              loggedAt: DateTime(2026, 1, 1, 10, 10),
            ),
          ],
        );
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1, 9, 0),
          exerciseEntries: [entry],
        );

        await _pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
          onWorkoutChanged: (w) => savedWorkout = w,
        );

        await tester.tap(find.byKey(const ValueKey('set-set-1')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('edit-delete-set-1')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('confirm-delete-confirm')));
        await tester.pumpAndSettle();

        expect(savedWorkout, isNotNull);
        expect(savedWorkout!.exerciseEntries[0].sets.length, 1);
        expect(savedWorkout!.exerciseEntries[0].sets[0].id, 'set-2');
      },
    );

    testWidgets(
      'cancelling the delete-Set confirmation leaves the Set unchanged',
      (tester) async {
        var workoutSaveCount = 0;
        final entry = ExerciseEntry(
          id: 'entry-1',
          exerciseId: 'exercise-1',
          sets: [
            ExerciseSet(
              id: 'set-1',
              weight: 60,
              unit: WeightUnit.kg,
              reps: 8,
              loggedAt: DateTime(2026, 1, 1, 10, 0),
            ),
          ],
        );
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1, 9, 0),
          exerciseEntries: [entry],
        );

        await _pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
          onWorkoutChanged: (_) => workoutSaveCount++,
        );

        await tester.tap(find.byKey(const ValueKey('set-set-1')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('edit-delete-set-1')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('confirm-delete-cancel')));
        await tester.pumpAndSettle();

        expect(workoutSaveCount, 0);
      },
    );

    testWidgets(
      'deleting the only remaining Set under an Exercise Entry leaves that '
      'Entry listed with zero Sets, not removed',
      (tester) async {
        Workout? savedWorkout;
        final entry = ExerciseEntry(
          id: 'entry-1',
          exerciseId: 'exercise-1',
          sets: [
            ExerciseSet(
              id: 'set-1',
              weight: 60,
              unit: WeightUnit.kg,
              reps: 8,
              loggedAt: DateTime(2026, 1, 1, 10, 0),
            ),
          ],
        );
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1, 9, 0),
          exerciseEntries: [entry],
        );

        await _pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
          onWorkoutChanged: (w) => savedWorkout = w,
        );

        await tester.tap(find.byKey(const ValueKey('set-set-1')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('edit-delete-set-1')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('confirm-delete-confirm')));
        await tester.pumpAndSettle();

        expect(savedWorkout, isNotNull);
        expect(savedWorkout!.exerciseEntries.length, 1);
        expect(savedWorkout!.exerciseEntries[0].id, 'entry-1');
        expect(savedWorkout!.exerciseEntries[0].sets, isEmpty);
      },
    );

    testWidgets(
      'deleting a Set belonging to a Locked Workout succeeds identically '
      'to an in-progress Workout',
      (tester) async {
        Workout? savedWorkout;
        final loggedAt = DateTime(2026, 1, 1, 10, 0);
        final entry = ExerciseEntry(
          id: 'entry-1',
          exerciseId: 'exercise-1',
          sets: [
            ExerciseSet(
              id: 'set-1',
              weight: 60,
              unit: WeightUnit.kg,
              reps: 8,
              loggedAt: loggedAt,
            ),
          ],
        );
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1, 9, 0),
          endTime: loggedAt,
          exerciseEntries: [entry],
        );

        await _pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
          onWorkoutChanged: (w) => savedWorkout = w,
        );

        await tester.tap(find.byKey(const ValueKey('set-set-1')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('edit-delete-set-1')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('confirm-delete-confirm')));
        await tester.pumpAndSettle();

        expect(savedWorkout, isNotNull);
        expect(savedWorkout!.exerciseEntries[0].sets, isEmpty);
      },
    );

    testWidgets(
      "each Exercise Entry's name header has a delete icon that opens a "
      'confirmation dialog',
      (tester) async {
        final entry = ExerciseEntry(id: 'entry-1', exerciseId: 'exercise-1');
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1, 9, 0),
          exerciseEntries: [entry],
        );

        await _pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
        );

        await tester.tap(find.byKey(const ValueKey('delete-entry-entry-1')));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey('confirm-delete-confirm')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('confirm-delete-cancel')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'confirming the delete-Exercise-Entry confirmation removes the '
      'Exercise Entry and all of its Sets, leaving other Entries untouched',
      (tester) async {
        Workout? savedWorkout;
        final entry1 = ExerciseEntry(
          id: 'entry-1',
          exerciseId: 'exercise-1',
          sets: [
            ExerciseSet(
              id: 'set-1',
              weight: 60,
              unit: WeightUnit.kg,
              reps: 8,
              loggedAt: DateTime(2026, 1, 1, 10, 0),
            ),
          ],
        );
        final entry2 = ExerciseEntry(id: 'entry-2', exerciseId: 'exercise-2');
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1, 9, 0),
          exerciseEntries: [entry1, entry2],
        );

        await _pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: [
            Exercise(id: 'exercise-1', name: 'Bench Press'),
            Exercise(id: 'exercise-2', name: 'Squat'),
          ],
          onWorkoutChanged: (w) => savedWorkout = w,
        );

        await tester.tap(find.byKey(const ValueKey('delete-entry-entry-1')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('confirm-delete-confirm')));
        await tester.pumpAndSettle();

        expect(savedWorkout, isNotNull);
        expect(savedWorkout!.exerciseEntries.length, 1);
        expect(savedWorkout!.exerciseEntries[0].id, 'entry-2');
      },
    );

    testWidgets(
      'cancelling the delete-Exercise-Entry confirmation leaves the '
      'Exercise Entry and its Sets unchanged',
      (tester) async {
        var workoutSaveCount = 0;
        final entry = ExerciseEntry(
          id: 'entry-1',
          exerciseId: 'exercise-1',
          sets: [
            ExerciseSet(
              id: 'set-1',
              weight: 60,
              unit: WeightUnit.kg,
              reps: 8,
              loggedAt: DateTime(2026, 1, 1, 10, 0),
            ),
          ],
        );
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1, 9, 0),
          exerciseEntries: [entry],
        );

        await _pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
          onWorkoutChanged: (_) => workoutSaveCount++,
        );

        await tester.tap(find.byKey(const ValueKey('delete-entry-entry-1')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('confirm-delete-cancel')));
        await tester.pumpAndSettle();

        expect(workoutSaveCount, 0);
        expect(find.text('Bench Press'), findsOneWidget);
        expect(find.text('8 reps at 60 kg'), findsOneWidget);
      },
    );

    testWidgets(
      'deleting an Exercise Entry belonging to a Locked Workout succeeds '
      'identically to an in-progress Workout',
      (tester) async {
        Workout? savedWorkout;
        final loggedAt = DateTime(2026, 1, 1, 10, 0);
        final entry = ExerciseEntry(
          id: 'entry-1',
          exerciseId: 'exercise-1',
          sets: [
            ExerciseSet(
              id: 'set-1',
              weight: 60,
              unit: WeightUnit.kg,
              reps: 8,
              loggedAt: loggedAt,
            ),
          ],
        );
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1, 9, 0),
          endTime: loggedAt,
          exerciseEntries: [entry],
        );

        await _pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
          onWorkoutChanged: (w) => savedWorkout = w,
        );

        await tester.tap(find.byKey(const ValueKey('delete-entry-entry-1')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('confirm-delete-confirm')));
        await tester.pumpAndSettle();

        expect(savedWorkout, isNotNull);
        expect(savedWorkout!.exerciseEntries, isEmpty);
      },
    );

    testWidgets(
      'deleting every Exercise Entry from a Locked Workout leaves it '
      'Locked with zero Exercise Entries, with no guard preventing it',
      (tester) async {
        Workout? savedWorkout;
        final loggedAt = DateTime(2026, 1, 1, 10, 0);
        final entry = ExerciseEntry(
          id: 'entry-1',
          exerciseId: 'exercise-1',
          sets: [
            ExerciseSet(
              id: 'set-1',
              weight: 60,
              unit: WeightUnit.kg,
              reps: 8,
              loggedAt: loggedAt,
            ),
          ],
        );
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1, 9, 0),
          endTime: loggedAt,
          exerciseEntries: [entry],
        );

        await _pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
          onWorkoutChanged: (w) => savedWorkout = w,
        );

        await tester.tap(find.byKey(const ValueKey('delete-entry-entry-1')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('confirm-delete-confirm')));
        await tester.pumpAndSettle();

        expect(savedWorkout, isNotNull);
        expect(savedWorkout!.exerciseEntries, isEmpty);
        expect(savedWorkout!.isInProgress, isFalse);
        expect(savedWorkout!.endTime, loggedAt);
      },
    );
  });
}
