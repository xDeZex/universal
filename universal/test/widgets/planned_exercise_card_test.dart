import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal/models/routine.dart';
import 'package:universal/models/workout.dart';
import 'package:universal/widgets/coplanar_card.dart';
import 'package:universal/widgets/planned_exercise_card.dart';

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
  });
}
