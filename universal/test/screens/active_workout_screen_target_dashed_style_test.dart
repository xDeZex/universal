import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal/models/exercise.dart';
import 'package:universal/models/routine.dart';
import 'package:universal/models/workout.dart';

import '../support/pump.dart';
import '../support/workout_builder.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ActiveWorkoutScreen target-row dashed styling', () {
    testWidgets(
      'an unfilled target row shows a dashed badge and no tap handler, with '
      'no dashed time cell while the Workout is in progress',
      (tester) async {
        final entry = buildEntry(
          targets: const [
            PlannedExerciseRow(
              reps: FixedReps(10),
              weight: PlannedWeight(value: 60, unit: WeightUnit.kg),
            ),
          ],
        );
        final workout = WorkoutBuilder(
          startTime: DateTime(2026, 1, 1, 9, 0),
          entries: [entry],
        ).build();

        await pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
        );

        expect(
          find.byKey(const ValueKey('target-badge-0-entry-1')),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byKey(const ValueKey('target-0-entry-1')),
            matching: find.byType(CircleAvatar),
          ),
          findsNothing,
        );
        expect(
          find.descendant(
            of: find.byKey(const ValueKey('target-0-entry-1')),
            matching: find.byType(InkWell),
          ),
          findsNothing,
        );
        expect(
          find.byKey(const ValueKey('target-time-0-entry-1')),
          findsNothing,
        );
      },
    );

    testWidgets(
      'an unfilled target row on a Locked Workout shows a dashed time cell',
      (tester) async {
        final loggedAt = DateTime(2026, 1, 1, 10, 0);
        final entry = buildEntry(
          targets: const [
            PlannedExerciseRow(
              reps: FixedReps(10),
              weight: PlannedWeight(value: 60, unit: WeightUnit.kg),
            ),
          ],
        );
        final workout = WorkoutBuilder(
          startTime: DateTime(2026, 1, 1, 9, 0),
          endTime: loggedAt,
          entries: [entry],
        ).build();

        await pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
        );

        expect(
          find.byKey(const ValueKey('target-time-0-entry-1')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'consecutive identical target rows render as separate rows, never '
      'grouped',
      (tester) async {
        const identicalRow = PlannedExerciseRow(
          reps: FixedReps(10),
          weight: PlannedWeight(value: 60, unit: WeightUnit.kg),
        );
        final entry = buildEntry(
          targets: const [identicalRow, identicalRow, identicalRow],
        );
        final workout = WorkoutBuilder(
          startTime: DateTime(2026, 1, 1, 9, 0),
          entries: [entry],
        ).build();

        await pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
        );

        expect(find.byKey(const ValueKey('target-0-entry-1')), findsOneWidget);
        expect(find.byKey(const ValueKey('target-1-entry-1')), findsOneWidget);
        expect(find.byKey(const ValueKey('target-2-entry-1')), findsOneWidget);
        expect(find.textContaining('×'), findsNothing);
      },
    );

    testWidgets(
      'two logged Sets consuming two identical targets leave one dashed row '
      'at position three, ungrouped',
      (tester) async {
        const identicalRow = PlannedExerciseRow(
          reps: FixedReps(10),
          weight: PlannedWeight(value: 60, unit: WeightUnit.kg),
        );
        final entry = buildEntry(
          sets: [
            buildSet(reps: 10, loggedAt: DateTime(2026, 1, 1, 10, 0)),
            buildSet(
              id: 'set-2',
              reps: 10,
              loggedAt: DateTime(2026, 1, 1, 10, 5),
            ),
          ],
          targets: const [identicalRow, identicalRow, identicalRow],
        );
        final workout = WorkoutBuilder(
          startTime: DateTime(2026, 1, 1, 9, 0),
          entries: [entry],
        ).build();

        await pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
        );

        expect(find.byKey(const ValueKey('set-set-1')), findsOneWidget);
        expect(find.byKey(const ValueKey('set-set-2')), findsOneWidget);
        expect(find.byKey(const ValueKey('target-0-entry-1')), findsNothing);
        expect(find.byKey(const ValueKey('target-1-entry-1')), findsNothing);
        expect(find.byKey(const ValueKey('target-2-entry-1')), findsOneWidget);
        expect(find.textContaining('×'), findsNothing);
      },
    );
  });
}
