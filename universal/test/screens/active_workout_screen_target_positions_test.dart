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

  group('ActiveWorkoutScreen target-row positional rendering', () {
    testWidgets(
      'row i shows the logged Set at that position when one exists, else the '
      'target at that position',
      (tester) async {
        final entry = buildEntry(
          sets: [
            buildSet(reps: 10, loggedAt: DateTime(2026, 1, 1, 10, 0)),
          ],
          targets: const [
            PlannedExerciseRow(
              reps: FixedReps(99),
              weight: PlannedWeight(value: 999, unit: WeightUnit.kg),
            ),
            PlannedExerciseRow(
              reps: FixedReps(8),
              weight: PlannedWeight(value: 65, unit: WeightUnit.kg),
            ),
            PlannedExerciseRow(
              reps: FixedReps(6),
              weight: PlannedWeight(value: 70, unit: WeightUnit.kg),
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

        expect(find.byKey(const ValueKey('set-set-1')), findsOneWidget);
        expect(
          tester
              .widget<Text>(find.byKey(const ValueKey('set-weight-set-1')))
              .data,
          '60 kg',
        );

        expect(find.byKey(const ValueKey('target-1-entry-1')), findsOneWidget);
        expect(
          tester
              .widget<Text>(
                find.byKey(const ValueKey('target-weight-1-entry-1')),
              )
              .data,
          '65 kg',
        );
        expect(
          tester
              .widget<Text>(find.byKey(const ValueKey('target-reps-1-entry-1')))
              .data,
          '8',
        );

        expect(find.byKey(const ValueKey('target-2-entry-1')), findsOneWidget);
        expect(
          tester
              .widget<Text>(
                find.byKey(const ValueKey('target-weight-2-entry-1')),
              )
              .data,
          '70 kg',
        );

        expect(find.text('999 kg'), findsNothing);
        expect(find.byKey(const ValueKey('target-0-entry-1')), findsNothing);
      },
    );

    testWidgets(
      'a ranged target formats its reps column as "min–max"',
      (tester) async {
        final entry = buildEntry(
          targets: const [
            PlannedExerciseRow(
              reps: RangeReps(min: 8, max: 12),
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
          tester
              .widget<Text>(find.byKey(const ValueKey('target-reps-0-entry-1')))
              .data,
          '8–12',
        );
      },
    );

    testWidgets(
      'an Exercise Entry with null targets renders identically to today, '
      'with no dashed rows',
      (tester) async {
        final entry = buildEntry(
          sets: [
            buildSet(reps: 10, loggedAt: DateTime(2026, 1, 1, 10, 0)),
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

        expect(find.byKey(const ValueKey('set-set-1')), findsOneWidget);
        expect(find.byKey(const ValueKey('target-0-entry-1')), findsNothing);
        expect(find.byKey(const ValueKey('target-1-entry-1')), findsNothing);
      },
    );

    testWidgets(
      'more logged Sets than targets renders the excess Sets normally after '
      'the target-derived rows are exhausted',
      (tester) async {
        final entry = buildEntry(
          sets: [
            buildSet(reps: 10, loggedAt: DateTime(2026, 1, 1, 10, 0)),
            buildSet(
              id: 'set-2',
              weight: 65,
              reps: 8,
              loggedAt: DateTime(2026, 1, 1, 10, 5),
            ),
            buildSet(
              id: 'set-3',
              weight: 70,
              reps: 6,
              loggedAt: DateTime(2026, 1, 1, 10, 10),
            ),
          ],
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

        expect(find.byKey(const ValueKey('set-set-1')), findsOneWidget);
        expect(find.byKey(const ValueKey('set-set-2')), findsOneWidget);
        expect(find.byKey(const ValueKey('set-set-3')), findsOneWidget);
        expect(find.byKey(const ValueKey('target-0-entry-1')), findsNothing);
      },
    );
  });
}
