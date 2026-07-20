import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal/widgets/workout_home_actions.dart';

import 'workout_home_screen_test_helpers.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('WorkoutHomeScreen layout', () {
    testWidgets('renders its actions via WorkoutHomeActions', (tester) async {
      await pumpWorkoutHomeScreen(
        tester,
        initialWorkouts: [],
        initialExercises: [],
      );
      await tester.pumpAndSettle();

      expect(find.byType(WorkoutHomeActions), findsOneWidget);
    });

    testWidgets(
      'does not overflow at a real phone width (issue #208 regression)',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.625;
        addTearDown(tester.view.reset);

        await pumpWorkoutHomeScreen(
          tester,
          initialWorkouts: [],
          initialExercises: [],
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Start Workout'), findsOneWidget);
        expect(find.text('Past Workouts'), findsOneWidget);
        expect(find.text('Manage Exercises'), findsOneWidget);
        expect(find.text('Manage Routines'), findsOneWidget);
      },
    );
  });
}
