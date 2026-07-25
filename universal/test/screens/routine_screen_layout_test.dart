import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:universal/models/routine.dart';
import 'package:universal/repositories/workout_repository.dart';
import 'package:universal/screens/routine_screen.dart';

import '../layout_test_helpers.dart';

void main() {
  group('RoutineScreen layout', () {
    testWidgets(
      'the Start Workout button stays clear of the bottom system inset '
      '(e.g. a gesture/button navigation bar)',
      (tester) async {
        const bottomInset = 48.0;
        final repository = WorkoutRepository(
          initialRoutines: [Routine(id: 'routine-1', name: 'Push Day')],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                padding: EdgeInsets.only(bottom: bottomInset),
              ),
              child: ChangeNotifierProvider<WorkoutRepository>.value(
                value: repository,
                child: const RoutineScreen(routineId: 'routine-1'),
              ),
            ),
          ),
        );

        expectClearOfBottomInset(
          tester,
          find.byKey(const ValueKey('start-workout-button')),
          bottomInset,
        );
      },
    );
  });
}
