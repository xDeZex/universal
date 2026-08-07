import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal/models/exercise.dart';

import '../support/pump.dart';
import '../support/workout_builder.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ActiveWorkoutScreen Exercise Entry autocomplete', () {
    testWidgets(
      'typing a substring shows a dropdown of matching existing Exercise '
      'names, alphabetically ordered',
      (tester) async {
        await pumpActiveWorkoutScreen(
          tester,
          workout: WorkoutBuilder().build(),
          exercises: [
            Exercise(id: 'ex-1', name: 'Zercise Press'),
            Exercise(id: 'ex-2', name: 'Bench Press'),
            Exercise(id: 'ex-3', name: 'Overhead Press'),
            Exercise(id: 'ex-4', name: 'Squat'),
          ],
        );

        await tester.enterText(find.byType(TextField).first, 'press');
        await tester.pump();

        final suggestionTexts = tester
            .widgetList<Text>(
              find.descendant(
                of: find.byKey(
                  const ValueKey('add-exercise-entry-suggestions'),
                ),
                matching: find.byType(Text),
              ),
            )
            .map((t) => t.data)
            .toList();

        expect(suggestionTexts, [
          'Bench Press',
          'Overhead Press',
          'Zercise Press',
        ]);
      },
    );

    testWidgets('typing text with no matches hides the dropdown', (
      tester,
    ) async {
      await pumpActiveWorkoutScreen(
        tester,
        workout: WorkoutBuilder().build(),
        exercises: [Exercise(id: 'ex-1', name: 'Bench Press')],
      );

      await tester.enterText(find.byType(TextField).first, 'nonexistent');
      await tester.pump();

      expect(
        find.byKey(const ValueKey('add-exercise-entry-suggestions')),
        findsNothing,
      );
    });

    testWidgets(
      'tapping a suggestion fills the field with the full name and does '
      'not submit',
      (tester) async {
        final repository = await pumpActiveWorkoutScreen(
          tester,
          workout: WorkoutBuilder().build(),
          exercises: [Exercise(id: 'ex-1', name: 'Bench Press')],
        );
        var notified = false;
        repository.addListener(() => notified = true);

        await tester.enterText(find.byType(TextField).first, 'bench');
        await tester.pump();

        await tester.tap(find.text('Bench Press'));
        await tester.pump();

        final textField = tester.widget<TextField>(
          find.byType(TextField).first,
        );
        expect(textField.controller!.text, 'Bench Press');
        expect(notified, isFalse);
        expect(
          find.byKey(const ValueKey('add-exercise-entry-suggestions')),
          findsNothing,
        );
      },
    );

    testWidgets(
      'submitting after tapping a suggestion reuses that Exercise by id, '
      'without creating a new one',
      (tester) async {
        final existing = Exercise(id: 'exercise-1', name: 'Bench Press');
        final repository = await pumpActiveWorkoutScreen(
          tester,
          workout: WorkoutBuilder().build(),
          exercises: [existing],
        );

        await tester.enterText(find.byType(TextField).first, 'bench');
        await tester.pump();
        await tester.tap(find.text('Bench Press'));
        await tester.pump();
        await tester.tap(
          find.byKey(const ValueKey('add-exercise-entry-button')),
        );
        await tester.pumpAndSettle();

        final saved = repository.workouts.firstWhere(
          (w) => w.id == 'workout-1',
        );
        expect(saved.exerciseEntries.length, 1);
        expect(saved.exerciseEntries[0].exerciseId, 'exercise-1');
        expect(repository.exercises.length, 1);
      },
    );

    testWidgets(
      'submitting a typed name with no matching suggestion still creates a '
      'new Exercise',
      (tester) async {
        final existing = Exercise(id: 'exercise-1', name: 'Bench Press');
        final repository = await pumpActiveWorkoutScreen(
          tester,
          workout: WorkoutBuilder().build(),
          exercises: [existing],
        );

        await tester.enterText(find.byType(TextField).first, 'Squat Rack');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        final saved = repository.workouts.firstWhere(
          (w) => w.id == 'workout-1',
        );
        expect(saved.exerciseEntries.length, 1);
        expect(repository.exercises.length, 2);
        expect(
          repository.exercises.map((e) => e.name),
          containsAll(['Bench Press', 'Squat Rack']),
        );
      },
    );
  });
}
