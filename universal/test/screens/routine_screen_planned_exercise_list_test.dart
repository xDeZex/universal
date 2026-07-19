import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal/models/exercise.dart';
import 'package:universal/models/routine.dart';
import 'package:universal/models/workout.dart';
import 'package:universal/repositories/workout_repository.dart';
import 'package:universal/screens/routine_screen.dart';

Future<WorkoutRepository> _pumpRoutineScreen(
  WidgetTester tester, {
  required List<Routine> routines,
  required List<Exercise> exercises,
  required String routineId,
}) async {
  final repository = WorkoutRepository(
    initialWorkouts: const [],
    initialExercises: exercises,
    initialRoutines: routines,
  );
  await tester.pumpWidget(
    MaterialApp(
      home: ChangeNotifierProvider<WorkoutRepository>.value(
        value: repository,
        child: RoutineScreen(routineId: routineId),
      ),
    ),
  );
  return repository;
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('RoutineScreen Planned Exercise list', () {
    testWidgets(
      'renders each Planned Exercise as a card, in stored order, instead '
      'of the empty state',
      (tester) async {
        final first = PlannedExercise(id: 'pe-1', exerciseId: 'exercise-1');
        final second = PlannedExercise(id: 'pe-2', exerciseId: 'exercise-2');
        await _pumpRoutineScreen(
          tester,
          routines: [
            Routine(
              id: 'routine-1',
              name: 'Push Day',
              plannedExercises: [first, second],
            ),
          ],
          exercises: [
            Exercise(id: 'exercise-1', name: 'Bench Press'),
            Exercise(id: 'exercise-2', name: 'Overhead Press'),
          ],
          routineId: 'routine-1',
        );

        expect(find.byKey(const ValueKey('routine-empty-state')), findsNothing);
        expect(find.byKey(const ValueKey('pe-1')), findsOneWidget);
        expect(find.byKey(const ValueKey('pe-2')), findsOneWidget);
        expect(
          tester.getTopLeft(find.byKey(const ValueKey('pe-1'))).dy,
          lessThan(tester.getTopLeft(find.byKey(const ValueKey('pe-2'))).dy),
        );
      },
    );

    testWidgets(
      "card header shows the referenced Exercise's current name, "
      'reflecting a rename rather than a stale copy',
      (tester) async {
        final planned = PlannedExercise(id: 'pe-1', exerciseId: 'exercise-1');
        final repository = await _pumpRoutineScreen(
          tester,
          routines: [
            Routine(
              id: 'routine-1',
              name: 'Push Day',
              plannedExercises: [planned],
            ),
          ],
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
          routineId: 'routine-1',
        );

        expect(find.text('Bench Press'), findsOneWidget);

        repository.renameExercise('exercise-1', 'Barbell Bench Press');
        await tester.pump();

        expect(find.text('Bench Press'), findsNothing);
        expect(find.text('Barbell Bench Press'), findsOneWidget);
      },
    );

    testWidgets(
      "a card's rows render as a read-only line per row, with no tap "
      'interaction',
      (tester) async {
        final planned = PlannedExercise(
          id: 'pe-1',
          exerciseId: 'exercise-1',
          rows: const [
            PlannedExerciseRow(
              reps: RangeReps(min: 8, max: 12),
              weight: PlannedWeight(value: 60, unit: WeightUnit.kg),
            ),
            PlannedExerciseRow(reps: FixedReps(6)),
          ],
        );
        await _pumpRoutineScreen(
          tester,
          routines: [
            Routine(
              id: 'routine-1',
              name: 'Push Day',
              plannedExercises: [planned],
            ),
          ],
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
          routineId: 'routine-1',
        );

        expect(find.text('8–12 reps @ 60 kg'), findsOneWidget);
        expect(find.text('6 reps · no weight'), findsOneWidget);
        expect(
          find.ancestor(
            of: find.text('8–12 reps @ 60 kg'),
            matching: find.byType(InkWell),
          ),
          findsNothing,
        );
        expect(
          find.ancestor(
            of: find.text('8–12 reps @ 60 kg'),
            matching: find.byType(GestureDetector),
          ),
          findsNothing,
        );
      },
    );
  });
}
