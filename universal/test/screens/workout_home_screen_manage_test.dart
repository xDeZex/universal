import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal/models/exercise.dart';
import 'package:universal/models/routine.dart';
import 'package:universal/models/workout.dart';
import 'package:universal/screens/manage_exercises_screen.dart';
import 'package:universal/screens/manage_routines_screen.dart';

import 'workout_home_screen_test_helpers.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('WorkoutHomeScreen Manage Exercises entry point', () {
    testWidgets(
      'shows a Manage Exercises action next to Past Workouts, at the same '
      'vertical position',
      (tester) async {
        await pumpWorkoutHomeScreen(
          tester,
          initialWorkouts: [],
          initialExercises: [],
        );
        await tester.pumpAndSettle();

        expect(find.text('Manage Exercises'), findsOneWidget);

        final pastWorkoutsPosition = tester.getCenter(
          find.text('Past Workouts'),
        );
        final manageExercisesPosition = tester.getCenter(
          find.text('Manage Exercises'),
        );
        expect(manageExercisesPosition.dy, pastWorkoutsPosition.dy);
        expect(manageExercisesPosition.dx, isNot(pastWorkoutsPosition.dx));
      },
    );

    testWidgets(
      'tapping Manage Exercises opens the Manage Exercises screen showing '
      'every stored Exercise',
      (tester) async {
        await pumpWorkoutHomeScreen(
          tester,
          initialWorkouts: [],
          initialExercises: [
            Exercise(id: 'exercise-1', name: 'Bench Press'),
            Exercise(id: 'exercise-2', name: 'Squat'),
          ],
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Manage Exercises'));
        await tester.pumpAndSettle();

        expect(find.byType(ManageExercisesScreen), findsOneWidget);
        expect(find.text('Bench Press'), findsOneWidget);
        expect(find.text('Squat'), findsOneWidget);
      },
    );

    testWidgets(
      'Manage Exercises action is available and opens the screen even with '
      'a Workout in progress',
      (tester) async {
        await pumpWorkoutHomeScreen(
          tester,
          initialWorkouts: [
            Workout(id: 'workout-1', startTime: DateTime(2026, 1, 1)),
          ],
          initialExercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
        );
        await tester.pumpAndSettle();

        expect(find.text('Manage Exercises'), findsOneWidget);

        await tester.tap(find.text('Manage Exercises'));
        await tester.pumpAndSettle();

        expect(find.byType(ManageExercisesScreen), findsOneWidget);
      },
    );
  });

  group('WorkoutHomeScreen Manage Routines entry point', () {
    testWidgets(
      'shows a Manage Routines action next to Manage Exercises, at the same '
      'vertical position',
      (tester) async {
        await pumpWorkoutHomeScreen(
          tester,
          initialWorkouts: [],
          initialExercises: [],
        );
        await tester.pumpAndSettle();

        expect(find.text('Manage Routines'), findsOneWidget);

        final manageExercisesPosition = tester.getCenter(
          find.text('Manage Exercises'),
        );
        final manageRoutinesPosition = tester.getCenter(
          find.text('Manage Routines'),
        );
        expect(manageRoutinesPosition.dy, manageExercisesPosition.dy);
        expect(manageRoutinesPosition.dx, isNot(manageExercisesPosition.dx));
      },
    );

    testWidgets(
      'tapping Manage Routines opens the Manage Routines screen showing '
      'every stored Routine',
      (tester) async {
        await pumpWorkoutHomeScreen(
          tester,
          initialWorkouts: [],
          initialExercises: [],
          initialRoutines: [
            Routine(id: 'routine-1', name: 'Push Day'),
            Routine(id: 'routine-2', name: 'Pull Day'),
          ],
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Manage Routines'));
        await tester.pumpAndSettle();

        expect(find.byType(ManageRoutinesScreen), findsOneWidget);
        expect(find.text('Push Day'), findsOneWidget);
        expect(find.text('Pull Day'), findsOneWidget);
      },
    );

    testWidgets(
      'Manage Routines action is available and opens the screen even with '
      'a Workout in progress',
      (tester) async {
        await pumpWorkoutHomeScreen(
          tester,
          initialWorkouts: [
            Workout(id: 'workout-1', startTime: DateTime(2026, 1, 1)),
          ],
          initialExercises: [],
          initialRoutines: [Routine(id: 'routine-1', name: 'Push Day')],
        );
        await tester.pumpAndSettle();

        expect(find.text('Manage Routines'), findsOneWidget);

        await tester.tap(find.text('Manage Routines'));
        await tester.pumpAndSettle();

        expect(find.byType(ManageRoutinesScreen), findsOneWidget);
      },
    );
  });
}
