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

Future<void> _tapAndSettle(WidgetTester tester, String key) async {
  await tester.tap(find.byKey(ValueKey(key)));
  await tester.pumpAndSettle();
}

String _weightStepperValue(WidgetTester tester) => tester
    .widget<Text>(find.byKey(const ValueKey('weight-stepper-value')))
    .data!;

String _repsStepperValue(WidgetTester tester) => tester
    .widget<Text>(find.byKey(const ValueKey('reps-stepper-value')))
    .data!;

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
      'adding a Set via the bottom bar adds it to the selected Exercise '
      'Entry and persists the Workout',
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

        await tester.tap(find.byKey(const ValueKey('entry-header-entry-1')));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const ValueKey('weight-stepper-increment')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('weight-stepper-increment')));
        await tester.pumpAndSettle();
        for (var i = 0; i < 5; i++) {
          await tester.tap(find.byKey(const ValueKey('reps-stepper-increment')));
          await tester.pumpAndSettle();
        }
        await tester.tap(find.byKey(const ValueKey('add-set')));
        await tester.pumpAndSettle();

        expect(savedWorkout, isNotNull);
        expect(savedWorkout!.exerciseEntries[0].sets.length, 1);
        expect(savedWorkout!.exerciseEntries[0].sets[0].weight, 5);
        expect(savedWorkout!.exerciseEntries[0].sets[0].unit, WeightUnit.kg);
        expect(savedWorkout!.exerciseEntries[0].sets[0].reps, 5);
      },
    );

    testWidgets(
      'a freshly added Exercise Entry is selected and its add-Set bar shows '
      'a kg/lbs unit toggle',
      (tester) async {
        await _pumpActiveWorkoutScreen(
          tester,
          workout: Workout(id: 'workout-1', startTime: DateTime(2026, 1, 1)),
          exercises: const [],
        );

        await tester.enterText(find.byType(TextField).first, 'Bench Press');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        expect(find.byKey(const ValueKey('unit-kg')), findsOneWidget);
        expect(find.byKey(const ValueKey('unit-lbs')), findsOneWidget);
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

        await tester.tap(find.byKey(const ValueKey('entry-header-entry-1')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('unit-lbs')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('weight-stepper-increment')));
        await tester.pumpAndSettle();
        for (var i = 0; i < 8; i++) {
          await tester.tap(find.byKey(const ValueKey('reps-stepper-increment')));
          await tester.pumpAndSettle();
        }
        await tester.tap(find.byKey(const ValueKey('add-set')));
        await tester.pumpAndSettle();

        expect(savedWorkout, isNotNull);
        expect(savedWorkout!.exerciseEntries[0].sets[0].unit, WeightUnit.lbs);
        expect(savedWorkout!.exerciseEntries[0].sets[0].weight, 5);
        expect(savedWorkout!.exerciseEntries[0].sets[0].reps, 8);
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

        await tester.tap(find.byKey(const ValueKey('entry-header-entry-1')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('unit-lbs')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('weight-stepper-increment')));
        await tester.pumpAndSettle();
        for (var i = 0; i < 8; i++) {
          await tester.tap(find.byKey(const ValueKey('reps-stepper-increment')));
          await tester.pumpAndSettle();
        }
        await tester.tap(find.byKey(const ValueKey('add-set')));
        await tester.pumpAndSettle();

        // The unit chip should still read lbs without re-selecting it.
        expect(
          tester.widget<ChoiceChip>(find.byKey(const ValueKey('unit-lbs'))).selected,
          isTrue,
        );

        await tester.tap(find.byKey(const ValueKey('weight-stepper-increment')));
        await tester.pumpAndSettle();
        for (var i = 0; i < 6; i++) {
          await tester.tap(find.byKey(const ValueKey('reps-stepper-increment')));
          await tester.pumpAndSettle();
        }
        await tester.tap(find.byKey(const ValueKey('add-set')));
        await tester.pumpAndSettle();

        expect(savedWorkout, isNotNull);
        expect(savedWorkout!.exerciseEntries[0].sets.length, 2);
        expect(savedWorkout!.exerciseEntries[0].sets[1].unit, WeightUnit.lbs);
        expect(savedWorkout!.exerciseEntries[0].sets[1].reps, 6);
      },
    );

    testWidgets(
      'a logged Set is displayed with its weight (incl. unit) and reps',
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

        await tester.tap(find.byKey(const ValueKey('entry-header-entry-1')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('unit-lbs')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('weight-stepper-increment')));
        await tester.pumpAndSettle();
        for (var i = 0; i < 8; i++) {
          await tester.tap(find.byKey(const ValueKey('reps-stepper-increment')));
          await tester.pumpAndSettle();
        }
        await tester.tap(find.byKey(const ValueKey('add-set')));
        await tester.pumpAndSettle();

        expect(find.text('5 lbs'), findsOneWidget);
        expect(find.text('8'), findsOneWidget);
      },
    );

    testWidgets(
      'a logged Set on a finished Workout additionally shows its logged time',
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

        expect(
          tester
              .widget<Text>(find.byKey(const ValueKey('set-weight-set-1')))
              .data,
          '50 kg',
        );
        expect(
          tester.widget<Text>(find.byKey(const ValueKey('set-reps-set-1'))).data,
          '8',
        );
        expect(
          tester.widget<Text>(find.byKey(const ValueKey('set-time-set-1'))).data,
          '6:42 PM',
        );
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
        expect(find.byKey(const ValueKey('add-set-bar')), findsNothing);
        expect(
          find.byKey(const ValueKey('discard-workout')),
          findsNothing,
        );
        expect(find.byKey(const ValueKey('finish-workout')), findsNothing);

        expect(find.text('Bench Press'), findsOneWidget);
        expect(
          tester
              .widget<Text>(find.byKey(const ValueKey('set-weight-set-1')))
              .data,
          '60 kg',
        );
        expect(
          tester.widget<Text>(find.byKey(const ValueKey('set-reps-set-1'))).data,
          '5',
        );
        expect(
          tester.widget<Text>(find.byKey(const ValueKey('set-time-set-1'))).data,
          '10:30 AM',
        );
        expect(find.text('Squat'), findsOneWidget);
        expect(
          tester
              .widget<Text>(find.byKey(const ValueKey('set-weight-set-2')))
              .data,
          '40 kg',
        );
        expect(
          tester.widget<Text>(find.byKey(const ValueKey('set-reps-set-2'))).data,
          '8',
        );
        expect(
          tester.widget<Text>(find.byKey(const ValueKey('set-time-set-2'))).data,
          '10:20 AM',
        );
      },
    );

    testWidgets(
      'an in-progress Workout still shows the add-Exercise-Entry field and '
      'Discard/Finish buttons, and selecting its Exercise Entry reveals the '
      'add-Set bar',
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

        expect(find.byType(TextField), findsOneWidget);
        expect(find.byKey(const ValueKey('add-set-bar')), findsNothing);
        expect(
          find.byKey(const ValueKey('discard-workout')),
          findsOneWidget,
        );
        expect(find.byKey(const ValueKey('finish-workout')), findsOneWidget);

        await tester.tap(find.byKey(const ValueKey('entry-header-entry-1')));
        await tester.pumpAndSettle();

        expect(find.byKey(const ValueKey('add-set-bar')), findsOneWidget);
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
        expect(
          tester
              .widget<Text>(find.byKey(const ValueKey('set-weight-set-1')))
              .data,
          '60 kg',
        );
        expect(
          tester.widget<Text>(find.byKey(const ValueKey('set-reps-set-1'))).data,
          '8',
        );
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
        expect(
          tester
              .widget<Text>(find.byKey(const ValueKey('set-weight-set-1')))
              .data,
          '60 kg',
        );
        expect(
          tester.widget<Text>(find.byKey(const ValueKey('set-reps-set-1'))).data,
          '8',
        );
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

    testWidgets(
      'Exercise Entries render as flat rows (no Card) with a Divider '
      'between entries',
      (tester) async {
        final entry1 = ExerciseEntry(id: 'entry-1', exerciseId: 'exercise-1');
        final entry2 = ExerciseEntry(id: 'entry-2', exerciseId: 'exercise-2');
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1),
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

        expect(find.byType(Card), findsNothing);
        expect(find.byType(Divider), findsOneWidget);
      },
    );

    testWidgets(
      'each Set row within an Exercise Entry is preceded by a Divider, '
      'distinct from the Divider between Exercise Entries',
      (tester) async {
        final entry = ExerciseEntry(
          id: 'entry-1',
          exerciseId: 'exercise-1',
          sets: [
            ExerciseSet(
              id: 'set-1',
              weight: 60,
              unit: WeightUnit.kg,
              reps: 5,
              loggedAt: DateTime(2026, 1, 1, 10),
            ),
            ExerciseSet(
              id: 'set-2',
              weight: 60,
              unit: WeightUnit.kg,
              reps: 5,
              loggedAt: DateTime(2026, 1, 1, 10, 5),
            ),
          ],
        );
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

        // One Divider before each of the two Sets; no between-entry Divider
        // since there's only one Exercise Entry.
        expect(find.byType(Divider), findsNWidgets(2));
      },
    );

    testWidgets(
      'tapping an in-progress Exercise Entry selects it and tints its rows',
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

        final expectedTint = Theme.of(
          tester.element(find.byType(Scaffold)),
        ).colorScheme.secondaryContainer;

        expect(
          tester.widget<Material>(find.byKey(const ValueKey('entry-entry-1'))).color,
          isNot(expectedTint),
        );

        await tester.tap(find.byKey(const ValueKey('entry-header-entry-1')));
        await tester.pumpAndSettle();

        expect(
          tester.widget<Material>(find.byKey(const ValueKey('entry-entry-1'))).color,
          expectedTint,
        );
      },
    );

    testWidgets(
      'selecting a different Exercise Entry un-tints the previously '
      'selected one',
      (tester) async {
        final entry1 = ExerciseEntry(id: 'entry-1', exerciseId: 'exercise-1');
        final entry2 = ExerciseEntry(id: 'entry-2', exerciseId: 'exercise-2');
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1),
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

        final expectedTint = Theme.of(
          tester.element(find.byType(Scaffold)),
        ).colorScheme.secondaryContainer;

        await tester.tap(find.byKey(const ValueKey('entry-header-entry-1')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('entry-header-entry-2')));
        await tester.pumpAndSettle();

        expect(
          tester.widget<Material>(find.byKey(const ValueKey('entry-entry-1'))).color,
          isNot(expectedTint),
        );
        expect(
          tester.widget<Material>(find.byKey(const ValueKey('entry-entry-2'))).color,
          expectedTint,
        );
      },
    );

    testWidgets(
      'adding a new Exercise Entry selects it, tinting its rows',
      (tester) async {
        Workout? savedWorkout;

        await _pumpActiveWorkoutScreen(
          tester,
          workout: Workout(id: 'workout-1', startTime: DateTime(2026, 1, 1)),
          exercises: const [],
          onWorkoutChanged: (w) => savedWorkout = w,
        );

        await tester.enterText(find.byType(TextField).first, 'Bench Press');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        final expectedTint = Theme.of(
          tester.element(find.byType(Scaffold)),
        ).colorScheme.secondaryContainer;
        final newEntryId = savedWorkout!.exerciseEntries[0].id;

        expect(
          tester
              .widget<Material>(find.byKey(ValueKey('entry-$newEntryId')))
              .color,
          expectedTint,
        );
      },
    );

    testWidgets(
      'a Workout with zero Exercise Entries renders with no selection and '
      'no exception',
      (tester) async {
        await _pumpActiveWorkoutScreen(
          tester,
          workout: Workout(id: 'workout-1', startTime: DateTime(2026, 1, 1)),
          exercises: const [],
        );

        expect(tester.takeException(), isNull);
        final entryTiles = tester
            .widgetList<Material>(find.byType(Material))
            .where(
              (m) => m.key is ValueKey && '${(m.key as ValueKey).value}'.startsWith('entry-'),
            );
        expect(entryTiles, isEmpty);
      },
    );

    testWidgets(
      'deleting the currently selected Exercise Entry clears the '
      'selection instead of falling back to another entry',
      (tester) async {
        final entry1 = ExerciseEntry(id: 'entry-1', exerciseId: 'exercise-1');
        final entry2 = ExerciseEntry(id: 'entry-2', exerciseId: 'exercise-2');
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1),
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

        final expectedTint = Theme.of(
          tester.element(find.byType(Scaffold)),
        ).colorScheme.secondaryContainer;

        await tester.tap(find.byKey(const ValueKey('entry-header-entry-1')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('delete-entry-entry-1')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('confirm-delete-confirm')));
        await tester.pumpAndSettle();

        expect(
          tester.widget<Material>(find.byKey(const ValueKey('entry-entry-2'))).color,
          isNot(expectedTint),
        );
      },
    );

    testWidgets(
      'deleting a non-selected Exercise Entry leaves the current '
      'selection unchanged',
      (tester) async {
        final entry1 = ExerciseEntry(id: 'entry-1', exerciseId: 'exercise-1');
        final entry2 = ExerciseEntry(id: 'entry-2', exerciseId: 'exercise-2');
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1),
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

        final expectedTint = Theme.of(
          tester.element(find.byType(Scaffold)),
        ).colorScheme.secondaryContainer;

        await tester.tap(find.byKey(const ValueKey('entry-header-entry-1')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('delete-entry-entry-2')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('confirm-delete-confirm')));
        await tester.pumpAndSettle();

        expect(
          tester.widget<Material>(find.byKey(const ValueKey('entry-entry-1'))).color,
          expectedTint,
        );
      },
    );

    testWidgets(
      'tapping an Exercise Entry on a Locked Workout does not select it or '
      'show the selected-state tint',
      (tester) async {
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
        );

        final expectedTint = Theme.of(
          tester.element(find.byType(Scaffold)),
        ).colorScheme.secondaryContainer;

        await tester.tap(find.byKey(const ValueKey('entry-header-entry-1')));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(
          tester.widget<Material>(find.byKey(const ValueKey('entry-entry-1'))).color,
          isNot(expectedTint),
        );
      },
    );

    testWidgets(
      'the add-Set bar has a distinct surface tone and is seamed off from '
      'the Discard/Finish row',
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

        await tester.tap(find.byKey(const ValueKey('entry-header-entry-1')));
        await tester.pumpAndSettle();

        final expectedTone = Theme.of(
          tester.element(find.byType(Scaffold)),
        ).colorScheme.surfaceContainerHighest;

        final bar = tester.widget<Container>(
          find.byKey(const ValueKey('add-set-bar')),
        );
        expect(bar.color, expectedTone);

        // With a single Exercise Entry the only Divider present is the seam
        // between the add-Set bar and the Discard/Finish row.
        expect(find.byType(Divider), findsOneWidget);

        final barBottom = tester
            .getBottomLeft(find.byKey(const ValueKey('add-set-bar')))
            .dy;
        final discardTop = tester
            .getTopLeft(find.byKey(const ValueKey('discard-workout')))
            .dy;
        expect(barBottom, lessThanOrEqualTo(discardTop));
      },
    );

    testWidgets(
      'the add-Set bar is hidden when no Exercise Entry is selected and on '
      'a Locked Workout',
      (tester) async {
        final entry = ExerciseEntry(id: 'entry-1', exerciseId: 'exercise-1');
        final inProgress = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1),
          exerciseEntries: [entry],
        );

        await _pumpActiveWorkoutScreen(
          tester,
          workout: inProgress,
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
        );

        expect(find.byKey(const ValueKey('add-set-bar')), findsNothing);

        final loggedAt = DateTime(2026, 1, 1, 10, 0);
        final lockedEntry = ExerciseEntry(
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
        final locked = Workout(
          id: 'workout-2',
          startTime: DateTime(2026, 1, 1, 9, 0),
          endTime: loggedAt,
          exerciseEntries: [lockedEntry],
        );

        await _pumpActiveWorkoutScreen(
          tester,
          workout: locked,
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
        );

        expect(find.byKey(const ValueKey('add-set-bar')), findsNothing);
      },
    );

    testWidgets(
      'the add-Set bar arranges weight, unit toggle, and reps controls in a '
      'single row above a full-width Add Set button',
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

        await tester.tap(find.byKey(const ValueKey('entry-header-entry-1')));
        await tester.pumpAndSettle();

        expect(find.byType(FilledButton), findsOneWidget);

        final weightY = tester
            .getCenter(find.byKey(const ValueKey('weight-stepper-value')))
            .dy;
        final unitKgY = tester
            .getCenter(find.byKey(const ValueKey('unit-kg')))
            .dy;
        final repsY = tester
            .getCenter(find.byKey(const ValueKey('reps-stepper-value')))
            .dy;
        expect(weightY, closeTo(unitKgY, 1));
        expect(weightY, closeTo(repsY, 1));

        final buttonTop = tester
            .getTopLeft(find.byKey(const ValueKey('add-set')))
            .dy;
        expect(weightY, lessThan(buttonTop));

        final barLeft = tester
            .getTopLeft(find.byKey(const ValueKey('add-set-bar')))
            .dx;
        final barRight = tester
            .getTopRight(find.byKey(const ValueKey('add-set-bar')))
            .dx;
        final buttonLeft = tester
            .getTopLeft(find.byKey(const ValueKey('add-set')))
            .dx;
        final buttonRight = tester
            .getTopRight(find.byKey(const ValueKey('add-set')))
            .dx;
        expect(
          buttonRight - buttonLeft,
          greaterThan((barRight - barLeft) * 0.8),
        );
      },
    );

    testWidgets(
      'the weight stepper steps by 2.5 in kg and 5 in lbs and can go '
      'negative; the reps stepper has a minimum of zero',
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

        await tester.tap(find.byKey(const ValueKey('entry-header-entry-1')));
        await tester.pumpAndSettle();

        expect(_weightStepperValue(tester), '0');
        expect(_repsStepperValue(tester), '0');

        await _tapAndSettle(tester, 'weight-stepper-decrement');
        expect(_weightStepperValue(tester), '-2.5');

        await _tapAndSettle(tester, 'weight-stepper-increment');
        expect(_weightStepperValue(tester), '0');

        await _tapAndSettle(tester, 'weight-stepper-increment');
        expect(_weightStepperValue(tester), '2.5');

        await _tapAndSettle(tester, 'unit-lbs');
        await _tapAndSettle(tester, 'weight-stepper-decrement');
        expect(_weightStepperValue(tester), '-2.5');

        await _tapAndSettle(tester, 'weight-stepper-decrement');
        expect(_weightStepperValue(tester), '-7.5');

        await _tapAndSettle(tester, 'weight-stepper-increment');
        await _tapAndSettle(tester, 'weight-stepper-increment');
        expect(_weightStepperValue(tester), '2.5');

        await _tapAndSettle(tester, 'reps-stepper-decrement');
        expect(_repsStepperValue(tester), '0');

        await _tapAndSettle(tester, 'reps-stepper-increment');
        expect(_repsStepperValue(tester), '1');
      },
    );

    testWidgets(
      'the Add Set button is disabled while the reps stepper is at zero',
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

        await tester.tap(find.byKey(const ValueKey('entry-header-entry-1')));
        await tester.pumpAndSettle();

        FilledButton addSetButton() => tester.widget<FilledButton>(
          find.byKey(const ValueKey('add-set')),
        );

        expect(addSetButton().onPressed, isNull);

        await tester.tap(find.byKey(const ValueKey('weight-stepper-increment')));
        await tester.pumpAndSettle();
        expect(addSetButton().onPressed, isNull);

        await tester.tap(find.byKey(const ValueKey('reps-stepper-increment')));
        await tester.pumpAndSettle();
        expect(addSetButton().onPressed, isNotNull);
      },
    );

    testWidgets(
      'tapping Add Set adds a Set to the selected Exercise Entry stamped '
      'with the current time',
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

        await tester.tap(find.byKey(const ValueKey('entry-header-entry-1')));
        await tester.pumpAndSettle();

        final before = DateTime.now();
        await tester.tap(find.byKey(const ValueKey('weight-stepper-increment')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('reps-stepper-increment')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('add-set')));
        await tester.pumpAndSettle();
        final after = DateTime.now();

        expect(savedWorkout, isNotNull);
        final set = savedWorkout!.exerciseEntries[0].sets.single;
        expect(set.weight, 2.5);
        expect(set.unit, WeightUnit.kg);
        expect(set.reps, 1);
        expect(
          set.loggedAt.isAfter(before.subtract(const Duration(seconds: 1))),
          isTrue,
        );
        expect(
          set.loggedAt.isBefore(after.add(const Duration(seconds: 1))),
          isTrue,
        );
      },
    );

    testWidgets(
      'the unit defaults to kg for a freshly selected Exercise Entry with '
      'no logged Sets yet',
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

        await tester.tap(find.byKey(const ValueKey('entry-header-entry-1')));
        await tester.pumpAndSettle();

        final kgChip = tester.widget<ChoiceChip>(
          find.byKey(const ValueKey('unit-kg')),
        );
        expect(kgChip.selected, isTrue);
      },
    );

    testWidgets(
      'switching the selected Exercise Entry resets the weight and reps '
      'steppers to zero while keeping each entry\'s unit sticky',
      (tester) async {
        Workout? savedWorkout;
        final entry1 = ExerciseEntry(id: 'entry-1', exerciseId: 'exercise-1');
        final entry2 = ExerciseEntry(id: 'entry-2', exerciseId: 'exercise-2');
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1),
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

        // Log an lbs Set against entry-2 so lbs becomes sticky for it.
        await _tapAndSettle(tester, 'entry-header-entry-2');
        await _tapAndSettle(tester, 'unit-lbs');
        await _tapAndSettle(tester, 'weight-stepper-increment');
        await _tapAndSettle(tester, 'reps-stepper-increment');
        await _tapAndSettle(tester, 'add-set');

        // Bump the weight stepper on entry-2 again without submitting.
        await _tapAndSettle(tester, 'weight-stepper-increment');
        expect(_weightStepperValue(tester), '5');

        // Switch to entry-1, which has never had a Set logged (defaults to kg).
        await _tapAndSettle(tester, 'entry-header-entry-1');

        expect(_weightStepperValue(tester), '0');
        expect(_repsStepperValue(tester), '0');
        expect(
          tester.widget<ChoiceChip>(find.byKey(const ValueKey('unit-kg'))).selected,
          isTrue,
        );

        // Switch back to entry-2: unit is sticky lbs, steppers reset to zero.
        await _tapAndSettle(tester, 'entry-header-entry-2');

        expect(_weightStepperValue(tester), '0');
        expect(_repsStepperValue(tester), '0');
        expect(
          tester.widget<ChoiceChip>(find.byKey(const ValueKey('unit-lbs'))).selected,
          isTrue,
        );

        expect(savedWorkout, isNotNull);
        expect(savedWorkout!.exerciseEntries[1].sets.single.unit, WeightUnit.lbs);
      },
    );
  });
}
