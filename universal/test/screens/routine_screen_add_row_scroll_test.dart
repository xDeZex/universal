import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal/models/routine.dart';
import 'package:universal/models/weight_unit.dart';

import '../support/pump.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('RoutineScreen add target row scroll behavior', () {
    testWidgets(
      'adding a target row to a Planned Exercise whose existing rows already '
      'fill the viewport scrolls the new row into view',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2310);
        tester.view.devicePixelRatio = 2.625;
        addTearDown(tester.view.reset);

        final plannedExercise = PlannedExercise(
          id: 'planned-1',
          exerciseId: 'exercise-1',
          rows: List.generate(
            10,
            (i) => const PlannedExerciseRow(
              reps: FixedReps(5),
              weight: PlannedWeight(value: 60, unit: WeightUnit.kg),
            ),
          ),
        );

        final repository = await pumpRoutineScreen(
          tester,
          routines: [
            Routine(
              id: 'routine-1',
              name: 'Push Day',
              plannedExercises: [plannedExercise],
            ),
          ],
          routineId: 'routine-1',
        );

        await tester.tap(
          find.byKey(const ValueKey('add-planned-exercise-row-planned-1')),
        );
        await tester.pumpAndSettle();

        final newRowIndex = repository.routines
            .firstWhere((r) => r.id == 'routine-1')
            .plannedExercises
            .first
            .rows
            .length -
            1;

        final listRect = tester.getRect(find.byType(ReorderableListView));
        final newRowRect = tester.getRect(
          find.byKey(ValueKey('planned-exercise-row-planned-1-$newRowIndex')),
        );

        expect(newRowRect.top, greaterThanOrEqualTo(listRect.top));
        expect(newRowRect.bottom, lessThanOrEqualTo(listRect.bottom));
      },
    );
  });
}
