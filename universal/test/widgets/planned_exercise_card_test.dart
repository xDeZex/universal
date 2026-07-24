import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal/models/routine.dart';
import 'package:universal/models/workout.dart';
import 'package:universal/widgets/coplanar_card.dart';
import 'package:universal/widgets/planned_exercise_card.dart';
import 'package:universal/widgets/selection_accent_border.dart';

void main() {
  group('PlannedExerciseCard', () {
    testWidgets('renders its content inside a CoplanarCard', (tester) async {
      final plannedExercise = PlannedExercise(
        id: 'planned-1',
        exerciseId: 'exercise-1',
        rows: const [
          PlannedExerciseRow(
            reps: FixedReps(5),
            weight: PlannedWeight(value: 60, unit: WeightUnit.kg),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlannedExerciseCard(
              plannedExercise: plannedExercise,
              exerciseName: 'Bench Press',
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.byType(CoplanarCard), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(CoplanarCard),
          matching: find.text('Bench Press'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(CoplanarCard),
          matching: find.text('5 reps @ 60 kg'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('wraps the open row in a selected SelectionAccentBorder', (
      tester,
    ) async {
      final plannedExercise = PlannedExercise(
        id: 'planned-1',
        exerciseId: 'exercise-1',
        rows: const [
          PlannedExerciseRow(
            reps: FixedReps(5),
            weight: PlannedWeight(value: 60, unit: WeightUnit.kg),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlannedExerciseCard(
              plannedExercise: plannedExercise,
              exerciseName: 'Bench Press',
              onDelete: () {},
              openRowIndex: 0,
              onRowTap: (_) {},
              onRowChanged: (_, _) {},
            ),
          ),
        ),
      );

      final accentBorder = tester.widget<SelectionAccentBorder>(
        find.byType(SelectionAccentBorder),
      );
      expect(accentBorder.selected, isTrue);
    });

    testWidgets('opening a row does not shift its content sideways', (
      tester,
    ) async {
      final plannedExercise = PlannedExercise(
        id: 'planned-1',
        exerciseId: 'exercise-1',
        rows: const [
          PlannedExerciseRow(
            reps: FixedReps(5),
            weight: PlannedWeight(value: 60, unit: WeightUnit.kg),
          ),
        ],
      );

      Widget buildCard({required int? openRowIndex}) {
        return MaterialApp(
          home: Scaffold(
            body: PlannedExerciseCard(
              plannedExercise: plannedExercise,
              exerciseName: 'Bench Press',
              onDelete: () {},
              openRowIndex: openRowIndex,
              onRowTap: (_) {},
              onRowChanged: (_, _) {},
            ),
          ),
        );
      }

      await tester.pumpWidget(buildCard(openRowIndex: null));
      final closedX = tester
          .getTopLeft(
            find.byKey(const ValueKey('planned-exercise-row-planned-1-0')),
          )
          .dx;

      await tester.pumpWidget(buildCard(openRowIndex: 0));
      final openX = tester
          .getTopLeft(
            find.byKey(const ValueKey('planned-exercise-row-planned-1-0')),
          )
          .dx;

      expect(openX, closedX);
    });

    testWidgets('zebra-shades alternating closed rows', (tester) async {
      final plannedExercise = PlannedExercise(
        id: 'planned-1',
        exerciseId: 'exercise-1',
        rows: const [
          PlannedExerciseRow(
            reps: FixedReps(5),
            weight: PlannedWeight(value: 60, unit: WeightUnit.kg),
          ),
          PlannedExerciseRow(
            reps: FixedReps(8),
            weight: PlannedWeight(value: 40, unit: WeightUnit.kg),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlannedExerciseCard(
              plannedExercise: plannedExercise,
              exerciseName: 'Bench Press',
              onDelete: () {},
            ),
          ),
        ),
      );

      final theme = Theme.of(tester.element(find.byType(Scaffold)));
      final expectedZebra = theme.colorScheme.surfaceContainerHighest
          .withValues(alpha: 0.5);

      Color? colorAboveRow(int index) {
        final container = tester.widget<Container>(
          find.ancestor(
            of: find.byKey(ValueKey('planned-exercise-row-planned-1-$index')),
            matching: find.byType(Container),
          ),
        );
        return container.color;
      }

      expect(colorAboveRow(0), isNull);
      expect(colorAboveRow(1), expectedZebra);
    });
  });
}
