import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal/models/exercise.dart';

import '../layout_test_helpers.dart';
import '../support/pump.dart';
import '../support/workout_builder.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ActiveWorkoutScreen layout, visibility, and locked/finished vs in-progress state', () {

    testWidgets(
      'Finish action is disabled while the Workout has zero logged Sets',
      (tester) async {
        await pumpActiveWorkoutScreen(
          tester,
          workout: WorkoutBuilder().build(),
          exercises: const [],
        );

        final finishButton = tester.widget<ElevatedButton>(
          find.byKey(const ValueKey('finish-workout')),
        );

        expect(finishButton.onPressed, isNull);
      },
    );

    testWidgets(
      'Discard action is available even with zero logged Sets',
      (tester) async {
        await pumpActiveWorkoutScreen(
          tester,
          workout: WorkoutBuilder().build(),
          exercises: const [],
        );

        final discardButton = tester.widget<TextButton>(
          find.byKey(const ValueKey('discard-workout')),
        );

        expect(discardButton.onPressed, isNotNull);
      },
    );

    testWidgets(
      'the Discard and Finish buttons stay clear of the bottom system inset '
      '(e.g. a gesture/button navigation bar)',
      (tester) async {
        const bottomInset = 48.0;

        await pumpActiveWorkoutScreen(
          tester,
          workout: WorkoutBuilder().build(),
          exercises: const [],
          mediaQueryData: const MediaQueryData(
            padding: EdgeInsets.only(bottom: bottomInset),
          ),
        );

        expectClearOfBottomInset(
          tester,
          find.byKey(const ValueKey('discard-workout')),
          bottomInset,
        );
        expectClearOfBottomInset(
          tester,
          find.byKey(const ValueKey('finish-workout')),
          bottomInset,
        );
      },
    );

    testWidgets(
      'a finished Workout hides the add-Exercise-Entry field, add-Set '
      'controls, and Discard/Finish buttons',
      (tester) async {
        final entry1 = buildEntry(
          sets: [
            buildSet(reps: 5, loggedAt: DateTime(2026, 1, 1, 10, 30)),
          ],
        );
        final entry2 = buildEntry(
          id: 'entry-2',
          exerciseId: 'exercise-2',
          sets: [
            buildSet(
              id: 'set-2',
              weight: 40,
              reps: 8,
              loggedAt: DateTime(2026, 1, 1, 10, 20),
            ),
          ],
        );
        final workout = WorkoutBuilder(
          startTime: DateTime(2026, 1, 1, 10, 0),
          endTime: DateTime(2026, 1, 1, 10, 30),
          entries: [entry1, entry2],
        ).build();

        await pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: [
            Exercise(id: 'exercise-1', name: 'Bench Press'),
            Exercise(id: 'exercise-2', name: 'Squat'),
          ],
        );

        expect(find.byType(TextField), findsNothing);
        expect(find.byType(ChoiceChip), findsNothing);
        expect(find.byKey(const ValueKey('add-set-bar')), findsNothing);
        expect(
          find.byKey(const ValueKey('discard-workout')),
          findsNothing,
        );
        expect(find.byKey(const ValueKey('finish-workout')), findsNothing);

        expect(find.text('Bench Press'), findsOneWidget);
        expect(
          tester
              .widget<Text>(find.byKey(const ValueKey('set-weight-set-1')))
              .data,
          '60 kg',
        );
        expect(
          tester.widget<Text>(find.byKey(const ValueKey('set-reps-set-1'))).data,
          '5',
        );
        expect(
          tester.widget<Text>(find.byKey(const ValueKey('set-time-set-1'))).data,
          '10:30 AM',
        );
        expect(find.text('Squat'), findsOneWidget);
        expect(
          tester
              .widget<Text>(find.byKey(const ValueKey('set-weight-set-2')))
              .data,
          '40 kg',
        );
        expect(
          tester.widget<Text>(find.byKey(const ValueKey('set-reps-set-2'))).data,
          '8',
        );
        expect(
          tester.widget<Text>(find.byKey(const ValueKey('set-time-set-2'))).data,
          '10:20 AM',
        );
      },
    );

    testWidgets(
      'an in-progress Workout still shows the add-Exercise-Entry field and '
      'Discard/Finish buttons, and selecting its Exercise Entry reveals the '
      'add-Set bar',
      (tester) async {
        final entry = buildEntry();
        final workout = WorkoutBuilder(
          startTime: DateTime(2026, 1, 1, 10, 0),
          entries: [entry],
        ).build();

        await pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
        );

        expect(find.byType(TextField), findsOneWidget);
        expect(find.byKey(const ValueKey('add-set-bar')), findsNothing);
        expect(
          find.byKey(const ValueKey('discard-workout')),
          findsOneWidget,
        );
        expect(find.byKey(const ValueKey('finish-workout')), findsOneWidget);

        await tester.tap(find.byKey(const ValueKey('entry-header-entry-1')));
        await tester.pumpAndSettle();

        expect(find.byKey(const ValueKey('add-set-bar')), findsOneWidget);
      },
    );

    testWidgets(
      'a finished Workout shows its end date as the AppBar title instead '
      'of "Active Workout"',
      (tester) async {
        final workout = WorkoutBuilder(
          startTime: DateTime(2026, 3, 5, 9, 0),
          endTime: DateTime(2026, 3, 5, 9, 30),
        ).build();

        await pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: const [],
        );

        expect(find.text('Active Workout'), findsNothing);
        expect(find.text('Mar 5, 2026'), findsOneWidget);
      },
    );

    testWidgets(
      'an in-progress Workout still shows "Active Workout" as the AppBar '
      'title',
      (tester) async {
        final workout = WorkoutBuilder(
          startTime: DateTime(2026, 3, 5, 9, 0),
        ).build();

        await pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: const [],
        );

        expect(find.text('Active Workout'), findsOneWidget);
      },
    );

    testWidgets(
      'Exercise Entries each render inside a Card with a Divider between '
      'entries',
      (tester) async {
        final entry1 = buildEntry();
        final entry2 = buildEntry(id: 'entry-2', exerciseId: 'exercise-2');
        final workout = WorkoutBuilder(entries: [entry1, entry2]).build();

        await pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: [
            Exercise(id: 'exercise-1', name: 'Bench Press'),
            Exercise(id: 'exercise-2', name: 'Squat'),
          ],
        );

        expect(find.byType(Card), findsNWidgets(2));
        expect(find.byType(Divider), findsOneWidget);
      },
    );

    testWidgets(
      'each Set row within an Exercise Entry is preceded by a Divider, '
      'distinct from the Divider between Exercise Entries',
      (tester) async {
        final entry = buildEntry(
          sets: [
            buildSet(reps: 5, loggedAt: DateTime(2026, 1, 1, 10)),
            buildSet(id: 'set-2', reps: 5, loggedAt: DateTime(2026, 1, 1, 10, 5)),
          ],
        );
        final workout = WorkoutBuilder(entries: [entry]).build();

        await pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
        );

        // One Divider before each of the two Sets; no between-entry Divider
        // since there's only one Exercise Entry.
        expect(find.byType(Divider), findsNWidgets(2));
      },
    );

  });
}
