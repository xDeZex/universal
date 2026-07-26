import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal/models/exercise.dart';
import 'package:universal/widgets/coplanar_card.dart';

import '../support/pump.dart';
import '../support/workout_builder.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('PastWorkoutsScreen row rendering', () {
    testWidgets(
      'row shows the end date and a comma-joined list of Exercise Entry '
      'names in entry order, including an entry with zero logged Sets',
      (tester) async {
        final withSets = buildEntry(
          sets: [buildSet(reps: 5, loggedAt: DateTime(2026, 3, 5, 9, 20))],
        );
        final zeroSets = buildEntry(id: 'entry-2', exerciseId: 'exercise-2');
        final workout = WorkoutBuilder(
          id: 'w1',
          startTime: DateTime(2026, 3, 5, 9, 0),
          endTime: DateTime(2026, 3, 5, 9, 30),
          entries: [withSets, zeroSets],
        ).build();

        await pumpPastWorkoutsScreen(
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
            .map((e) => buildEntry(id: 'entry-${e.id}', exerciseId: e.id))
            .toList();
        final workout = WorkoutBuilder(
          id: 'w1',
          startTime: DateTime(2026, 3, 5, 9, 0),
          endTime: DateTime(2026, 3, 5, 9, 30),
          entries: entries,
        ).build();

        await pumpPastWorkoutsScreen(
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

    testWidgets('each row in the list renders inside a CoplanarCard', (
      tester,
    ) async {
      final first = WorkoutBuilder(
        id: 'w-first',
        startTime: DateTime(2026, 1, 1, 9, 0),
        endTime: DateTime(2026, 1, 1, 9, 30),
      ).build();
      final second = WorkoutBuilder(
        id: 'w-second',
        startTime: DateTime(2026, 1, 2, 9, 0),
        endTime: DateTime(2026, 1, 2, 9, 30),
      ).build();

      await pumpPastWorkoutsScreen(
        tester,
        workouts: [first, second],
        exercises: const [],
      );

      expect(find.byType(CoplanarCard), findsNWidgets(2));
      expect(
        find.descendant(
          of: find.byType(CoplanarCard),
          matching: find.byType(ListTile),
        ),
        findsNWidgets(2),
      );
    });

    testWidgets(
      'row summary shows "Unknown Exercise" for an Exercise Entry whose '
      'exerciseId has no matching Exercise',
      (tester) async {
        final entry = buildEntry(exerciseId: 'missing');
        final workout = WorkoutBuilder(
          id: 'w1',
          startTime: DateTime(2026, 1, 1, 9, 0),
          endTime: DateTime(2026, 1, 1, 9, 30),
          entries: [entry],
        ).build();

        await pumpPastWorkoutsScreen(
          tester,
          workouts: [workout],
          exercises: const [],
        );

        expect(find.text('Unknown Exercise'), findsOneWidget);
      },
    );
  });
}
