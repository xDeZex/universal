import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal/models/exercise.dart';
import 'package:universal/models/workout.dart';
import 'package:universal/screens/active_workout_screen.dart';
import 'package:universal/screens/past_workouts_screen.dart';

Future<void> _pumpPastWorkoutsScreen(
  WidgetTester tester, {
  required List<Workout> workouts,
  required List<Exercise> exercises,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: PastWorkoutsScreen(workouts: workouts, exercises: exercises),
    ),
  );
}

void main() {
  group('PastWorkoutsScreen', () {
    testWidgets(
      'lists only finished Workouts, excluding any in-progress Workout',
      (tester) async {
        final finished = Workout(
          id: 'w-finished',
          startTime: DateTime(2026, 1, 1, 9, 0),
          endTime: DateTime(2026, 1, 1, 9, 30),
        );
        final inProgress = Workout(
          id: 'w-progress',
          startTime: DateTime(2026, 1, 2, 9, 0),
        );

        await _pumpPastWorkoutsScreen(
          tester,
          workouts: [finished, inProgress],
          exercises: const [],
        );

        expect(
          find.byKey(const ValueKey('past-workout-w-finished')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('past-workout-w-progress')),
          findsNothing,
        );
      },
    );

    testWidgets('orders finished Workouts by endTime descending', (
      tester,
    ) async {
      final oldest = Workout(
        id: 'w-oldest',
        startTime: DateTime(2026, 1, 1, 9, 0),
        endTime: DateTime(2026, 1, 1, 9, 30),
      );
      final newest = Workout(
        id: 'w-newest',
        startTime: DateTime(2026, 1, 3, 9, 0),
        endTime: DateTime(2026, 1, 3, 9, 30),
      );
      final middle = Workout(
        id: 'w-middle',
        startTime: DateTime(2026, 1, 2, 9, 0),
        endTime: DateTime(2026, 1, 2, 9, 30),
      );

      await _pumpPastWorkoutsScreen(
        tester,
        // Deliberately out of order, so the test can only pass if the
        // screen itself sorts rather than preserving input order.
        workouts: [middle, oldest, newest],
        exercises: const [],
      );

      final keys = find
          .byType(ListTile)
          .evaluate()
          .map((e) => e.widget.key)
          .toList();

      expect(keys, [
        const ValueKey('past-workout-w-newest'),
        const ValueKey('past-workout-w-middle'),
        const ValueKey('past-workout-w-oldest'),
      ]);
    });

    testWidgets(
      'row shows the end date and a comma-joined list of Exercise Entry '
      'names in entry order, including an entry with zero logged Sets',
      (tester) async {
        final withSets = ExerciseEntry(
          id: 'entry-1',
          exerciseId: 'exercise-1',
          sets: [
            ExerciseSet(
              id: 'set-1',
              weight: 60,
              unit: WeightUnit.kg,
              reps: 5,
              loggedAt: DateTime(2026, 3, 5, 9, 20),
            ),
          ],
        );
        final zeroSets = ExerciseEntry(
          id: 'entry-2',
          exerciseId: 'exercise-2',
        );
        final workout = Workout(
          id: 'w1',
          startTime: DateTime(2026, 3, 5, 9, 0),
          endTime: DateTime(2026, 3, 5, 9, 30),
          exerciseEntries: [withSets, zeroSets],
        );

        await _pumpPastWorkoutsScreen(
          tester,
          workouts: [workout],
          exercises: [
            Exercise(id: 'exercise-1', name: 'Bench Press'),
            Exercise(id: 'exercise-2', name: 'Squat'),
          ],
        );

        expect(find.text('Mar 5, 2026'), findsOneWidget);
        expect(find.text('Bench Press, Squat'), findsOneWidget);
      },
    );

    testWidgets(
      'truncates an overflowing exercise summary with an ellipsis instead '
      'of wrapping or overflowing the row',
      (tester) async {
        final longNames = List.generate(
          20,
          (i) => Exercise(id: 'exercise-$i', name: 'Exercise Number $i'),
        );
        final entries = longNames
            .map((e) => ExerciseEntry(id: 'entry-${e.id}', exerciseId: e.id))
            .toList();
        final workout = Workout(
          id: 'w1',
          startTime: DateTime(2026, 3, 5, 9, 0),
          endTime: DateTime(2026, 3, 5, 9, 30),
          exerciseEntries: entries,
        );

        await _pumpPastWorkoutsScreen(
          tester,
          workouts: [workout],
          exercises: longNames,
        );

        final summaryText = tester.widget<Text>(
          find.text(
            longNames.map((e) => e.name).join(', '),
            findRichText: false,
          ),
        );

        expect(summaryText.maxLines, 1);
        expect(summaryText.overflow, TextOverflow.ellipsis);
      },
    );

    testWidgets(
      'shows a centered "No past workouts yet" message and no list rows '
      'when there are no finished Workouts',
      (tester) async {
        final inProgress = Workout(
          id: 'w-progress',
          startTime: DateTime(2026, 1, 1, 9, 0),
        );

        await _pumpPastWorkoutsScreen(
          tester,
          workouts: [inProgress],
          exercises: const [],
        );

        expect(find.text('No past workouts yet'), findsOneWidget);
        expect(find.byType(ListTile), findsNothing);
        expect(
          tester.widget<Center>(
            find.ancestor(
              of: find.text('No past workouts yet'),
              matching: find.byType(Center),
            ),
          ),
          isNotNull,
        );
      },
    );

    testWidgets(
      'shows list rows instead of the empty-state message when at least '
      'one finished Workout exists',
      (tester) async {
        final finished = Workout(
          id: 'w-finished',
          startTime: DateTime(2026, 1, 1, 9, 0),
          endTime: DateTime(2026, 1, 1, 9, 30),
        );

        await _pumpPastWorkoutsScreen(
          tester,
          workouts: [finished],
          exercises: const [],
        );

        expect(find.text('No past workouts yet'), findsNothing);
        expect(find.byType(ListTile), findsOneWidget);
      },
    );

    testWidgets(
      'tapping a row opens the Active Workout screen for that Workout in '
      'read-only mode, including its zero-Set Exercise Entry',
      (tester) async {
        final withSets = ExerciseEntry(
          id: 'entry-1',
          exerciseId: 'exercise-1',
          sets: [
            ExerciseSet(
              id: 'set-1',
              weight: 60,
              unit: WeightUnit.kg,
              reps: 5,
              loggedAt: DateTime(2026, 1, 1, 9, 20),
            ),
          ],
        );
        final zeroSets = ExerciseEntry(
          id: 'entry-2',
          exerciseId: 'exercise-2',
        );
        final workout = Workout(
          id: 'w-finished',
          startTime: DateTime(2026, 1, 1, 9, 0),
          endTime: DateTime(2026, 1, 1, 9, 30),
          exerciseEntries: [withSets, zeroSets],
        );

        await _pumpPastWorkoutsScreen(
          tester,
          workouts: [workout],
          exercises: [
            Exercise(id: 'exercise-1', name: 'Bench Press'),
            Exercise(id: 'exercise-2', name: 'Squat'),
          ],
        );

        await tester.tap(find.byKey(const ValueKey('past-workout-w-finished')));
        await tester.pumpAndSettle();

        final screen = tester.widget<ActiveWorkoutScreen>(
          find.byType(ActiveWorkoutScreen),
        );
        expect(screen.workout.id, 'w-finished');

        expect(find.text('Bench Press'), findsOneWidget);
        expect(find.text('Squat'), findsOneWidget);
        expect(find.text('5 reps at 60 kg — 9:20 AM'), findsOneWidget);
        expect(find.byType(TextField), findsNothing);
        expect(find.byKey(const ValueKey('discard-workout')), findsNothing);
        expect(find.byKey(const ValueKey('finish-workout')), findsNothing);
      },
    );

    testWidgets(
      'row summary shows "Unknown Exercise" for an Exercise Entry whose '
      'exerciseId has no matching Exercise',
      (tester) async {
        final entry = ExerciseEntry(id: 'entry-1', exerciseId: 'missing');
        final workout = Workout(
          id: 'w1',
          startTime: DateTime(2026, 1, 1, 9, 0),
          endTime: DateTime(2026, 1, 1, 9, 30),
          exerciseEntries: [entry],
        );

        await _pumpPastWorkoutsScreen(
          tester,
          workouts: [workout],
          exercises: const [],
        );

        expect(find.text('Unknown Exercise'), findsOneWidget);
      },
    );
  });
}
