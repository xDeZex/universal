import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal/models/routine.dart';
import 'package:universal/models/workout.dart';
import 'package:universal/screens/active_workout_screen.dart';
import 'package:universal/widgets/start_workout_bar.dart';

import 'routine_screen_test_helpers.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('RoutineScreen Start Workout bar', () {
    testWidgets(
      'shows "Start Workout" and starts+navigates when no Workout is in '
      'progress on an active Routine',
      (tester) async {
        final repo = await pumpRoutineScreen(
          tester,
          routines: [Routine(id: 'routine-1', name: 'Push Day')],
          routineId: 'routine-1',
        );

        expect(find.text('Start Workout'), findsOneWidget);
        expect(find.text('Continue Workout'), findsNothing);

        await tester.tap(find.byKey(const ValueKey('start-workout-button')));
        await tester.pumpAndSettle();

        expect(find.byType(ActiveWorkoutScreen), findsOneWidget);
        final started = repo.workouts.firstWhere((w) => w.isInProgress);
        expect(started.routineId, 'routine-1');
      },
    );

    testWidgets(
      'does not start a second Workout if the button callback fires twice '
      'before a rebuild (guards the same race the button label glosses '
      'over)',
      (tester) async {
        final repo = await pumpRoutineScreen(
          tester,
          routines: [Routine(id: 'routine-1', name: 'Push Day')],
          routineId: 'routine-1',
        );

        final bar = tester.widget<StartWorkoutBar>(
          find.byType(StartWorkoutBar),
        );
        bar.onPressed();
        bar.onPressed();

        expect(repo.workouts.where((w) => w.isInProgress).length, 1);
      },
    );

    testWidgets(
      'shows "Continue Workout" and navigates to the in-progress Workout '
      'even when started from a different Routine',
      (tester) async {
        await pumpRoutineScreen(
          tester,
          routines: [
            Routine(id: 'routine-1', name: 'Push Day'),
            Routine(id: 'routine-2', name: 'Pull Day'),
          ],
          routineId: 'routine-1',
          workouts: [
            Workout(
              id: 'workout-1',
              startTime: DateTime(2026, 1, 1),
              routineId: 'routine-2',
            ),
          ],
        );

        expect(find.text('Continue Workout'), findsOneWidget);
        expect(find.text('Start Workout'), findsNothing);

        await tester.tap(find.byKey(const ValueKey('start-workout-button')));
        await tester.pumpAndSettle();

        expect(find.byType(ActiveWorkoutScreen), findsOneWidget);
        final screen = tester.widget<ActiveWorkoutScreen>(
          find.byType(ActiveWorkoutScreen),
        );
        expect(screen.workoutId, 'workout-1');
      },
    );

    testWidgets(
      'shows "Continue Workout" and navigates to the in-progress Workout '
      'even when it was not started from any Routine',
      (tester) async {
        await pumpRoutineScreen(
          tester,
          routines: [Routine(id: 'routine-1', name: 'Push Day')],
          routineId: 'routine-1',
          workouts: [Workout(id: 'workout-1', startTime: DateTime(2026, 1, 1))],
        );

        expect(find.text('Continue Workout'), findsOneWidget);
      },
    );

    testWidgets(
      'is not shown at all when the Routine is archived, regardless of '
      'in-progress state',
      (tester) async {
        await pumpRoutineScreen(
          tester,
          routines: [
            Routine(
              id: 'routine-1',
              name: 'Push Day',
              archivedAt: DateTime(2026, 1, 1),
            ),
          ],
          routineId: 'routine-1',
        );

        expect(find.byType(StartWorkoutBar), findsNothing);
      },
    );

    testWidgets(
      'is not shown on an archived Routine even while a Workout is in '
      'progress',
      (tester) async {
        await pumpRoutineScreen(
          tester,
          routines: [
            Routine(
              id: 'routine-1',
              name: 'Push Day',
              archivedAt: DateTime(2026, 1, 1),
            ),
          ],
          routineId: 'routine-1',
          workouts: [Workout(id: 'workout-1', startTime: DateTime(2026, 1, 1))],
        );

        expect(find.byType(StartWorkoutBar), findsNothing);
      },
    );

    testWidgets('is shown alongside the existing add-field and card list on an '
        'active Routine', (tester) async {
      await pumpRoutineScreen(
        tester,
        routines: [Routine(id: 'routine-1', name: 'Push Day')],
        routineId: 'routine-1',
      );

      expect(find.byType(StartWorkoutBar), findsOneWidget);
      expect(find.text('No Planned Exercises yet'), findsOneWidget);
    });
  });
}
