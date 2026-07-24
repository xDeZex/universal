import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal/models/routine.dart';
import 'package:universal/models/workout.dart';

import 'planned_exercise_row_editor_test_helpers.dart';

void main() {
  group('PlannedExerciseRowEditor layout', () {
    testWidgets('does not overflow at a real phone width for a fixed row', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(tester.view.reset);

      await pumpEditor(
        tester,
        row: const PlannedExerciseRow(
          reps: FixedReps(8),
          weight: PlannedWeight(value: 60, unit: WeightUnit.kg),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(SingleChildScrollView), findsNothing);
      expect(find.byType(Spacer), findsOneWidget);
    });

    testWidgets('does not overflow at a real phone width for a ranged row', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(tester.view.reset);

      await pumpEditor(
        tester,
        row: const PlannedExerciseRow(
          reps: RangeReps(min: 8, max: 12),
          weight: PlannedWeight(value: 60, unit: WeightUnit.kg),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(SingleChildScrollView), findsNothing);
      expect(find.byType(Spacer), findsOneWidget);
    });
  });
}
