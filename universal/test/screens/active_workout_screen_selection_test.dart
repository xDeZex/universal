import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal/models/exercise.dart';
import 'package:universal/models/workout.dart';
import 'package:universal/widgets/selection_accent_border.dart';

import 'active_workout_screen_test_helpers.dart';

bool _entryIsSelected(WidgetTester tester, String entryId) {
  return tester
      .widget<SelectionAccentBorder>(
        find.descendant(
          of: find.byKey(ValueKey('entry-$entryId')),
          matching: find.byType(SelectionAccentBorder),
        ),
      )
      .selected;
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ActiveWorkoutScreen Exercise Entry selection and the add-Set bar', () {
    testWidgets(
      'tapping an in-progress Exercise Entry selects it and shows the '
      'accent border on its rows',
      (tester) async {
        final entry = ExerciseEntry(id: 'entry-1', exerciseId: 'exercise-1');
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1),
          exerciseEntries: [entry],
        );

        await pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
        );

        expect(_entryIsSelected(tester, 'entry-1'), isFalse);

        await tester.tap(find.byKey(const ValueKey('entry-header-entry-1')));
        await tester.pumpAndSettle();

        expect(_entryIsSelected(tester, 'entry-1'), isTrue);
      },
    );

    testWidgets(
      'selecting a different Exercise Entry clears the accent border on '
      'the previously selected one',
      (tester) async {
        final entry1 = ExerciseEntry(id: 'entry-1', exerciseId: 'exercise-1');
        final entry2 = ExerciseEntry(id: 'entry-2', exerciseId: 'exercise-2');
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1),
          exerciseEntries: [entry1, entry2],
        );

        await pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: [
            Exercise(id: 'exercise-1', name: 'Bench Press'),
            Exercise(id: 'exercise-2', name: 'Squat'),
          ],
        );

        await tester.tap(find.byKey(const ValueKey('entry-header-entry-1')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('entry-header-entry-2')));
        await tester.pumpAndSettle();

        expect(_entryIsSelected(tester, 'entry-1'), isFalse);
        expect(_entryIsSelected(tester, 'entry-2'), isTrue);
      },
    );

    testWidgets(
      'adding a new Exercise Entry selects it, showing the accent border '
      'on its rows',
      (tester) async {
        final repository = await pumpActiveWorkoutScreen(
          tester,
          workout: Workout(id: 'workout-1', startTime: DateTime(2026, 1, 1)),
          exercises: const [],
        );

        await tester.enterText(find.byType(TextField).first, 'Bench Press');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        final saved = repository.workouts.firstWhere(
          (w) => w.id == 'workout-1',
        );
        final newEntryId = saved.exerciseEntries[0].id;

        expect(_entryIsSelected(tester, newEntryId), isTrue);
      },
    );

    testWidgets('deleting the currently selected Exercise Entry clears the '
        'selection instead of falling back to another entry', (tester) async {
      final entry1 = ExerciseEntry(id: 'entry-1', exerciseId: 'exercise-1');
      final entry2 = ExerciseEntry(id: 'entry-2', exerciseId: 'exercise-2');
      final workout = Workout(
        id: 'workout-1',
        startTime: DateTime(2026, 1, 1),
        exerciseEntries: [entry1, entry2],
      );

      await pumpActiveWorkoutScreen(
        tester,
        workout: workout,
        exercises: [
          Exercise(id: 'exercise-1', name: 'Bench Press'),
          Exercise(id: 'exercise-2', name: 'Squat'),
        ],
      );

      await tester.tap(find.byKey(const ValueKey('entry-header-entry-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('delete-entry-entry-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('confirm-delete-confirm')));
      await tester.pumpAndSettle();

      expect(_entryIsSelected(tester, 'entry-2'), isFalse);
    });

    testWidgets('deleting a non-selected Exercise Entry leaves the current '
        'selection unchanged', (tester) async {
      final entry1 = ExerciseEntry(id: 'entry-1', exerciseId: 'exercise-1');
      final entry2 = ExerciseEntry(id: 'entry-2', exerciseId: 'exercise-2');
      final workout = Workout(
        id: 'workout-1',
        startTime: DateTime(2026, 1, 1),
        exerciseEntries: [entry1, entry2],
      );

      await pumpActiveWorkoutScreen(
        tester,
        workout: workout,
        exercises: [
          Exercise(id: 'exercise-1', name: 'Bench Press'),
          Exercise(id: 'exercise-2', name: 'Squat'),
        ],
      );

      await tester.tap(find.byKey(const ValueKey('entry-header-entry-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('delete-entry-entry-2')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('confirm-delete-confirm')));
      await tester.pumpAndSettle();

      expect(_entryIsSelected(tester, 'entry-1'), isTrue);
    });

    testWidgets(
      'tapping an Exercise Entry on a Locked Workout does not select it or '
      'show the accent border',
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

        await pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
        );

        await tester.tap(find.byKey(const ValueKey('entry-header-entry-1')));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(_entryIsSelected(tester, 'entry-1'), isFalse);
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

        await pumpActiveWorkoutScreen(
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

        await pumpActiveWorkoutScreen(
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

        await pumpActiveWorkoutScreen(
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

        await pumpActiveWorkoutScreen(
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

    testWidgets('the weight stepper steps by 2.5 in kg and 5 in lbs and can go '
        'negative; the reps stepper has a minimum of zero', (tester) async {
      final entry = ExerciseEntry(id: 'entry-1', exerciseId: 'exercise-1');
      final workout = Workout(
        id: 'workout-1',
        startTime: DateTime(2026, 1, 1),
        exerciseEntries: [entry],
      );

      await pumpActiveWorkoutScreen(
        tester,
        workout: workout,
        exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
      );

      await tester.tap(find.byKey(const ValueKey('entry-header-entry-1')));
      await tester.pumpAndSettle();

      expect(weightStepperValue(tester), '0');
      expect(repsStepperValue(tester), '0');

      await tapAndSettle(tester, 'weight-stepper-decrement');
      expect(weightStepperValue(tester), '-2.5');

      await tapAndSettle(tester, 'weight-stepper-increment');
      expect(weightStepperValue(tester), '0');

      await tapAndSettle(tester, 'weight-stepper-increment');
      expect(weightStepperValue(tester), '2.5');

      await tapAndSettle(tester, 'unit-lbs');
      await tapAndSettle(tester, 'weight-stepper-decrement');
      expect(weightStepperValue(tester), '-2.5');

      await tapAndSettle(tester, 'weight-stepper-decrement');
      expect(weightStepperValue(tester), '-7.5');

      await tapAndSettle(tester, 'weight-stepper-increment');
      await tapAndSettle(tester, 'weight-stepper-increment');
      expect(weightStepperValue(tester), '2.5');

      await tapAndSettle(tester, 'reps-stepper-decrement');
      expect(repsStepperValue(tester), '0');

      await tapAndSettle(tester, 'reps-stepper-increment');
      expect(repsStepperValue(tester), '1');
    });

    testWidgets(
      'the Add Set button is disabled while the reps stepper is at zero',
      (tester) async {
        final entry = ExerciseEntry(id: 'entry-1', exerciseId: 'exercise-1');
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1),
          exerciseEntries: [entry],
        );

        await pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
        );

        await tester.tap(find.byKey(const ValueKey('entry-header-entry-1')));
        await tester.pumpAndSettle();

        FilledButton addSetButton() =>
            tester.widget<FilledButton>(find.byKey(const ValueKey('add-set')));

        expect(addSetButton().onPressed, isNull);

        await tester.tap(
          find.byKey(const ValueKey('weight-stepper-increment')),
        );
        await tester.pumpAndSettle();
        expect(addSetButton().onPressed, isNull);

        await tester.tap(find.byKey(const ValueKey('reps-stepper-increment')));
        await tester.pumpAndSettle();
        expect(addSetButton().onPressed, isNotNull);
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

        await pumpActiveWorkoutScreen(
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
        final entry1 = ExerciseEntry(id: 'entry-1', exerciseId: 'exercise-1');
        final entry2 = ExerciseEntry(id: 'entry-2', exerciseId: 'exercise-2');
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1),
          exerciseEntries: [entry1, entry2],
        );

        final repository = await pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: [
            Exercise(id: 'exercise-1', name: 'Bench Press'),
            Exercise(id: 'exercise-2', name: 'Squat'),
          ],
        );

        // Log an lbs Set against entry-2 so lbs becomes sticky for it.
        await tapAndSettle(tester, 'entry-header-entry-2');
        await tapAndSettle(tester, 'unit-lbs');
        await tapAndSettle(tester, 'weight-stepper-increment');
        await tapAndSettle(tester, 'reps-stepper-increment');
        await tapAndSettle(tester, 'add-set');

        // Bump the weight stepper on entry-2 again without submitting.
        await tapAndSettle(tester, 'weight-stepper-increment');
        expect(weightStepperValue(tester), '5');

        // Switch to entry-1, which has never had a Set logged (defaults to kg).
        await tapAndSettle(tester, 'entry-header-entry-1');

        expect(weightStepperValue(tester), '0');
        expect(repsStepperValue(tester), '0');
        expect(
          tester
              .widget<ChoiceChip>(find.byKey(const ValueKey('unit-kg')))
              .selected,
          isTrue,
        );

        // Switch back to entry-2: unit is sticky lbs, steppers reset to zero.
        await tapAndSettle(tester, 'entry-header-entry-2');

        expect(weightStepperValue(tester), '0');
        expect(repsStepperValue(tester), '0');
        expect(
          tester
              .widget<ChoiceChip>(find.byKey(const ValueKey('unit-lbs')))
              .selected,
          isTrue,
        );

        final saved = repository.workouts.firstWhere(
          (w) => w.id == 'workout-1',
        );
        expect(saved.exerciseEntries[1].sets.single.unit, WeightUnit.lbs);
      },
    );
  });
}
