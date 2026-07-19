import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal/models/exercise.dart';
import 'package:universal/models/workout.dart';
import 'package:universal/screens/active_workout_screen.dart';
import 'package:universal/screens/past_workouts_screen.dart';
import 'package:universal/services/storage_service.dart';

import 'workout_home_screen_test_helpers.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('WorkoutHomeScreen Past Workouts entry point', () {
    testWidgets(
      'shows a Past Workouts action below Start Workout even with no '
      'finished Workouts',
      (tester) async {
        await pumpWorkoutHomeScreen(
          tester,
          initialWorkouts: [],
          initialExercises: [],
        );
        await tester.pumpAndSettle();

        expect(find.text('Past Workouts'), findsOneWidget);

        final startPosition = tester.getCenter(find.text('Start Workout'));
        final pastWorkoutsPosition = tester.getCenter(
          find.text('Past Workouts'),
        );
        expect(pastWorkoutsPosition.dy, greaterThan(startPosition.dy));
      },
    );

    testWidgets(
      'shows a Past Workouts action below Continue Workout when a Workout '
      'is in progress',
      (tester) async {
        await pumpWorkoutHomeScreen(
          tester,
          initialWorkouts: [
            Workout(id: 'workout-1', startTime: DateTime(2026, 1, 1)),
          ],
          initialExercises: [],
        );
        await tester.pumpAndSettle();

        expect(find.text('Past Workouts'), findsOneWidget);

        final continuePosition = tester.getCenter(
          find.text('Continue Workout'),
        );
        final pastWorkoutsPosition = tester.getCenter(
          find.text('Past Workouts'),
        );
        expect(pastWorkoutsPosition.dy, greaterThan(continuePosition.dy));
      },
    );

    testWidgets(
      'editing a Set from a Past Workout\'s detail view persists the change '
      'to storage, and reopening that Workout\'s detail view reflects it',
      (tester) async {
        final loggedAt = DateTime(2026, 1, 1, 10, 30);
        final entry = ExerciseEntry(
          id: 'entry-1',
          exerciseId: 'exercise-1',
          sets: [
            ExerciseSet(
              id: 'set-1',
              weight: 60,
              unit: WeightUnit.kg,
              reps: 5,
              loggedAt: loggedAt,
            ),
          ],
        );
        final finishedWorkout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1, 10, 0),
          endTime: loggedAt,
          exerciseEntries: [entry],
        );

        await pumpWorkoutHomeScreen(
          tester,
          initialWorkouts: [finishedWorkout],
          initialExercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Past Workouts'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('past-workout-workout-1')));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const ValueKey('set-set-1')));
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const ValueKey('edit-weight-stepper-set-1-increment')),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('edit-submit-set-1')));
        await tester.pumpAndSettle();

        final stored = await StorageService().loadWorkouts();
        expect(stored[0].exerciseEntries[0].sets[0].weight, 62.5);

        // Reopen the detail view: back out to the Workout home screen, then
        // navigate to Past Workouts again so it's rebuilt from the current
        // (post-edit) Workout list, rather than reusing the stale list it
        // was first pushed with.
        Navigator.of(
          tester.element(find.byType(ActiveWorkoutScreen)),
        ).popUntil((route) => route.isFirst);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Past Workouts'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('past-workout-workout-1')));
        await tester.pumpAndSettle();

        final screen = tester.widget<ActiveWorkoutScreen>(
          find.byType(ActiveWorkoutScreen),
        );
        expect(screen.workoutId, 'workout-1');

        // Confirms the reopened view reads live from WorkoutRepository
        // rather than reusing the stale list it was first pushed with.
        expect(
          tester
              .widget<Text>(find.byKey(const ValueKey('set-weight-set-1')))
              .data,
          '62.5 kg',
        );
      },
    );

    testWidgets(
      'tapping Past Workouts navigates to the Past Workouts list screen',
      (tester) async {
        await pumpWorkoutHomeScreen(
          tester,
          initialWorkouts: [],
          initialExercises: [],
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Past Workouts'));
        await tester.pumpAndSettle();

        expect(find.byType(PastWorkoutsScreen), findsOneWidget);
      },
    );
  });
}
