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

  group('ActiveWorkoutScreen Exercise Entry creation', () {
    testWidgets(
      'submitting a new Exercise Entry name adds an entry and persists both '
      'the Workout and the Exercise list',
      (tester) async {
        final repository = await pumpActiveWorkoutScreen(
          tester,
          workout: WorkoutBuilder().build(),
          exercises: const [],
        );

        await tester.enterText(find.byType(TextField).first, 'Bench Press');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        final saved = repository.workouts.firstWhere(
          (w) => w.id == 'workout-1',
        );
        expect(saved.exerciseEntries.length, 1);
        expect(repository.exercises.length, 1);
        expect(repository.exercises[0].name, 'Bench Press');
        expect(
          saved.exerciseEntries[0].exerciseId,
          repository.exercises[0].id,
        );
      },
    );

    testWidgets(
      'submitting an Exercise Entry name matching an existing Exercise '
      'reuses it and does not persist a new Exercise list',
      (tester) async {
        final existing = Exercise(id: 'exercise-1', name: 'Bench Press');

        final repository = await pumpActiveWorkoutScreen(
          tester,
          workout: WorkoutBuilder().build(),
          exercises: [existing],
        );

        await tester.enterText(find.byType(TextField).first, 'bench press');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        final saved = repository.workouts.firstWhere(
          (w) => w.id == 'workout-1',
        );
        expect(saved.exerciseEntries.length, 1);
        expect(saved.exerciseEntries[0].exerciseId, 'exercise-1');
        expect(repository.exercises.length, 1);
      },
    );

    testWidgets('submitting an empty or whitespace-only Exercise Entry name is '
        'rejected with no Entry added', (tester) async {
      final repository = await pumpActiveWorkoutScreen(
        tester,
        workout: WorkoutBuilder().build(),
        exercises: const [],
      );
      var notified = false;
      repository.addListener(() => notified = true);

      await tester.enterText(find.byType(TextField).first, '   ');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(notified, isFalse);
    });

    testWidgets(
      'a freshly added Exercise Entry is selected and its add-Set bar shows '
      'a kg/lbs unit toggle',
      (tester) async {
        await pumpActiveWorkoutScreen(
          tester,
          workout: WorkoutBuilder().build(),
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
      'an Exercise Entry whose exerciseId has no matching Exercise renders '
      'without throwing',
      (tester) async {
        final workout = WorkoutBuilder(
          entries: [buildEntry(exerciseId: 'missing')],
        ).build();

        await pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: const [],
        );

        expect(tester.takeException(), isNull);
        expect(find.text('Unknown Exercise'), findsOneWidget);
      },
    );

    testWidgets(
      'submitting a new Exercise Entry name via the add button dismisses '
      'the keyboard',
      (tester) async {
        await pumpActiveWorkoutScreen(
          tester,
          workout: WorkoutBuilder().build(),
          exercises: const [],
        );

        await tester.enterText(find.byType(TextField).first, 'Bench Press');
        await tester.pump();

        await tester.tap(
          find.byKey(const ValueKey('add-exercise-entry-button')),
        );
        await tester.pumpAndSettle();

        expect(tester.testTextInput.isVisible, isFalse);
      },
    );

    testWidgets(
      'a Workout with zero Exercise Entries renders with no selection and '
      'no exception',
      (tester) async {
        await pumpActiveWorkoutScreen(
          tester,
          workout: WorkoutBuilder().build(),
          exercises: const [],
        );

        expect(tester.takeException(), isNull);
        final entryTiles = tester
            .widgetList<Material>(find.byType(Material))
            .where(
              (m) =>
                  m.key is ValueKey &&
                  '${(m.key as ValueKey).value}'.startsWith('entry-'),
            );
        expect(entryTiles, isEmpty);
      },
    );
  });
}
