import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal/models/exercise.dart';
import 'package:universal/models/workout.dart';
import 'package:universal/screens/active_workout_screen.dart';
import 'package:universal/screens/workout_home_screen.dart';
import 'package:universal/services/storage_service.dart';

Future<void> _pumpWorkoutHomeScreen(
  WidgetTester tester, {
  List<Workout>? initialWorkouts,
  List<Exercise>? initialExercises,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: WorkoutHomeScreen(
        initialWorkouts: initialWorkouts,
        initialExercises: initialExercises,
      ),
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('WorkoutHomeScreen', () {
    testWidgets('shows Start Workout when no workout is in progress', (
      tester,
    ) async {
      await _pumpWorkoutHomeScreen(
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
      await _pumpWorkoutHomeScreen(
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
        await _pumpWorkoutHomeScreen(
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
        expect(screen.workout.id, 'workout-1');
      },
    );

    testWidgets(
      'tapping Start Workout creates a new in-progress workout, persists it, '
      'and opens the active Workout screen',
      (tester) async {
        await _pumpWorkoutHomeScreen(
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
        expect(screen.workout.isInProgress, isTrue);

        final stored = await StorageService().loadWorkouts();
        expect(stored.length, 1);
        expect(stored[0].id, screen.workout.id);
      },
    );

    testWidgets(
      'tapping Start Workout twice only creates one in-progress workout',
      (tester) async {
        await _pumpWorkoutHomeScreen(
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

        await tester.pumpWidget(const MaterialApp(home: WorkoutHomeScreen()));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Continue Workout'));
        await tester.pumpAndSettle();

        final screen = tester.widget<ActiveWorkoutScreen>(
          find.byType(ActiveWorkoutScreen),
        );
        expect(screen.exercises.length, 1);
        expect(screen.exercises[0].name, 'Bench Press');
      },
    );

    testWidgets(
      'defaults to empty lists and shows Start Workout when storage has no '
      'prior data',
      (tester) async {
        await tester.pumpWidget(const MaterialApp(home: WorkoutHomeScreen()));
        await tester.pumpAndSettle();

        expect(find.text('Start Workout'), findsOneWidget);
      },
    );

    testWidgets(
      'adding an Exercise Entry and a Set on the active Workout screen '
      'persists both the Workout and the new Exercise to real storage',
      (tester) async {
        await _pumpWorkoutHomeScreen(
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
        final entryId = storedWorkouts[0].exerciseEntries[0].id;

        await tester.enterText(
          find.byKey(ValueKey('weight-$entryId')),
          '60',
        );
        await tester.enterText(find.byKey(ValueKey('reps-$entryId')), '5');
        await tester.tap(find.byKey(ValueKey('add-set-$entryId')));
        await tester.pumpAndSettle();

        storedWorkouts = await StorageService().loadWorkouts();
        expect(storedWorkouts[0].exerciseEntries[0].sets.length, 1);
        expect(storedWorkouts[0].exerciseEntries[0].sets[0].weight, 60);
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
              reps: 5,
              loggedAt: loggedSetTime,
            ),
          ],
        );

        await _pumpWorkoutHomeScreen(
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
              reps: 5,
              loggedAt: DateTime(2026, 1, 1, 10, 30),
            ),
          ],
        );

        await _pumpWorkoutHomeScreen(
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

    testWidgets(
      'discarding a Workout id that is already finished (e.g. a stale '
      'callback invocation racing a Finish) leaves it unchanged in storage',
      (tester) async {
        final finishedWorkout = Workout(
          id: 'workout-finished',
          startTime: DateTime(2026, 1, 1, 9, 0),
          endTime: DateTime(2026, 1, 1, 9, 30),
        );
        final inProgressWorkout = Workout(
          id: 'workout-in-progress',
          startTime: DateTime(2026, 1, 1, 10, 0),
        );

        await _pumpWorkoutHomeScreen(
          tester,
          initialWorkouts: [finishedWorkout, inProgressWorkout],
          initialExercises: [],
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Continue Workout'));
        await tester.pumpAndSettle();

        // The callback doesn't distinguish which Workout is currently open on
        // screen from which id it's called with — invoke it directly with a
        // Workout id that is already finished, as could happen if a stale
        // Discard tap fires after a Finish has already persisted.
        final onWorkoutDiscarded = tester
            .widget<ActiveWorkoutScreen>(find.byType(ActiveWorkoutScreen))
            .onWorkoutDiscarded;
        onWorkoutDiscarded('workout-finished');
        await tester.pumpAndSettle();

        final stored = await StorageService().loadWorkouts();
        expect(stored.map((w) => w.id), contains('workout-finished'));
        expect(
          stored.firstWhere((w) => w.id == 'workout-finished').isInProgress,
          isFalse,
        );
      },
    );
  });
}
