import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal/models/exercise.dart';
import 'package:universal/models/workout.dart';
import 'package:universal/repositories/workout_repository.dart';
import 'package:universal/screens/active_workout_screen.dart';
import 'package:universal/services/storage_service.dart';

import 'workout_home_screen_test_helpers.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('WorkoutHomeScreen', () {
    testWidgets('shows Start Workout when no workout is in progress', (
      tester,
    ) async {
      await pumpWorkoutHomeScreen(
        tester,
        initialWorkouts: [],
        initialExercises: [],
      );
      await tester.pumpAndSettle();

      expect(find.text('Start Workout'), findsOneWidget);
      expect(find.text('Continue Workout'), findsNothing);
    });

    testWidgets('shows Continue Workout when a workout is in progress', (
      tester,
    ) async {
      await pumpWorkoutHomeScreen(
        tester,
        initialWorkouts: [
          Workout(id: 'workout-1', startTime: DateTime(2026, 1, 1)),
        ],
        initialExercises: [],
      );
      await tester.pumpAndSettle();

      expect(find.text('Continue Workout'), findsOneWidget);
      expect(find.text('Start Workout'), findsNothing);
    });

    testWidgets(
      'tapping Continue Workout opens the active Workout screen for that workout',
      (tester) async {
        await pumpWorkoutHomeScreen(
          tester,
          initialWorkouts: [
            Workout(id: 'workout-1', startTime: DateTime(2026, 1, 1)),
          ],
          initialExercises: [],
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Continue Workout'));
        await tester.pumpAndSettle();

        final screen = tester.widget<ActiveWorkoutScreen>(
          find.byType(ActiveWorkoutScreen),
        );
        expect(screen.workoutId, 'workout-1');
      },
    );

    testWidgets(
      'tapping Start Workout creates a new in-progress workout, persists it, '
      'and opens the active Workout screen',
      (tester) async {
        await pumpWorkoutHomeScreen(
          tester,
          initialWorkouts: [],
          initialExercises: [],
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Start Workout'));
        await tester.pumpAndSettle();

        final screen = tester.widget<ActiveWorkoutScreen>(
          find.byType(ActiveWorkoutScreen),
        );
        final repo = Provider.of<WorkoutRepository>(
          tester.element(find.byType(ActiveWorkoutScreen)),
          listen: false,
        );
        final workout = repo.workouts.firstWhere(
          (w) => w.id == screen.workoutId,
        );
        expect(workout.isInProgress, isTrue);

        final stored = await StorageService().loadWorkouts();
        expect(stored.length, 1);
        expect(stored[0].id, screen.workoutId);
      },
    );

    testWidgets(
      'tapping Start Workout twice only creates one in-progress workout',
      (tester) async {
        await pumpWorkoutHomeScreen(
          tester,
          initialWorkouts: [],
          initialExercises: [],
        );
        await tester.pumpAndSettle();

        final startButton = find.text('Start Workout');
        await tester.tap(startButton);
        await tester.tap(startButton);
        await tester.pumpAndSettle();

        final stored = await StorageService().loadWorkouts();
        expect(stored.length, 1);
      },
    );

    testWidgets(
      'loads the Workout and Exercise lists from storage on initialization',
      (tester) async {
        final storage = StorageService();
        await storage.saveWorkouts([
          Workout(id: 'workout-1', startTime: DateTime(2026, 1, 1)),
        ]);
        await storage.saveExercises([
          Exercise(id: 'exercise-1', name: 'Bench Press'),
        ]);

        await pumpWorkoutHomeScreenFromStorage(tester);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Continue Workout'));
        await tester.pumpAndSettle();

        final repo = Provider.of<WorkoutRepository>(
          tester.element(find.byType(ActiveWorkoutScreen)),
          listen: false,
        );
        expect(repo.exercises.length, 1);
        expect(repo.exercises[0].name, 'Bench Press');
      },
    );

    testWidgets(
      'defaults to empty lists and shows Start Workout when storage has no '
      'prior data',
      (tester) async {
        await pumpWorkoutHomeScreenFromStorage(tester);
        await tester.pumpAndSettle();

        expect(find.text('Start Workout'), findsOneWidget);
      },
    );

    testWidgets(
      'adding an Exercise Entry and a Set on the active Workout screen '
      'persists both the Workout and the new Exercise to real storage',
      (tester) async {
        await pumpWorkoutHomeScreen(
          tester,
          initialWorkouts: [
            Workout(id: 'workout-1', startTime: DateTime(2026, 1, 1)),
          ],
          initialExercises: [],
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Continue Workout'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField).first, 'Bench Press');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        final storedExercises = await StorageService().loadExercises();
        expect(storedExercises.length, 1);
        expect(storedExercises[0].name, 'Bench Press');

        var storedWorkouts = await StorageService().loadWorkouts();
        expect(storedWorkouts[0].exerciseEntries.length, 1);

        // A newly added Exercise Entry is auto-selected, so the add-Set bar
        // is already showing.
        await tester.tap(find.byKey(const ValueKey('weight-stepper-increment')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('weight-stepper-increment')));
        await tester.pumpAndSettle();
        for (var i = 0; i < 5; i++) {
          await tester.tap(find.byKey(const ValueKey('reps-stepper-increment')));
          await tester.pumpAndSettle();
        }
        await tester.tap(find.byKey(const ValueKey('add-set')));
        await tester.pumpAndSettle();

        storedWorkouts = await StorageService().loadWorkouts();
        expect(storedWorkouts[0].exerciseEntries[0].sets.length, 1);
        expect(storedWorkouts[0].exerciseEntries[0].sets[0].weight, 5);
        expect(storedWorkouts[0].exerciseEntries[0].sets[0].unit, WeightUnit.kg);
        expect(storedWorkouts[0].exerciseEntries[0].sets[0].reps, 5);
      },
    );

    testWidgets(
      'finishing a Workout on the active Workout screen persists it and '
      'returns to the Workout home screen showing Start Workout',
      (tester) async {
        final loggedSetTime = DateTime(2026, 1, 1, 10, 30);
        final entry = ExerciseEntry(
          id: 'entry-1',
          exerciseId: 'exercise-1',
          sets: [
            ExerciseSet(
              id: 'set-1',
              weight: 60,
              unit: WeightUnit.kg,
              reps: 5,
              loggedAt: loggedSetTime,
            ),
          ],
        );

        await pumpWorkoutHomeScreen(
          tester,
          initialWorkouts: [
            Workout(
              id: 'workout-1',
              startTime: DateTime(2026, 1, 1, 10, 0),
              exerciseEntries: [entry],
            ),
          ],
          initialExercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Continue Workout'));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const ValueKey('finish-workout')));
        await tester.pumpAndSettle();

        expect(find.byType(ActiveWorkoutScreen), findsNothing);
        expect(find.text('Start Workout'), findsOneWidget);

        final stored = await StorageService().loadWorkouts();
        expect(stored[0].isInProgress, isFalse);
        expect(stored[0].endTime, loggedSetTime);
      },
    );

    testWidgets(
      'discarding a Workout on the active Workout screen deletes it from '
      'storage and returns to the Workout home screen showing Start Workout',
      (tester) async {
        final entry = ExerciseEntry(
          id: 'entry-1',
          exerciseId: 'exercise-1',
          sets: [
            ExerciseSet(
              id: 'set-1',
              weight: 60,
              unit: WeightUnit.kg,
              reps: 5,
              loggedAt: DateTime(2026, 1, 1, 10, 30),
            ),
          ],
        );

        await pumpWorkoutHomeScreen(
          tester,
          initialWorkouts: [
            Workout(
              id: 'workout-1',
              startTime: DateTime(2026, 1, 1, 10, 0),
              exerciseEntries: [entry],
            ),
          ],
          initialExercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Continue Workout'));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const ValueKey('discard-workout')));
        await tester.pumpAndSettle();

        expect(find.byType(ActiveWorkoutScreen), findsNothing);
        expect(find.text('Start Workout'), findsOneWidget);

        final stored = await StorageService().loadWorkouts();
        expect(stored, isEmpty);
      },
    );
  });
}
