import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal/models/exercise.dart';
import 'package:universal/models/workout.dart';

import 'active_workout_screen_test_helpers.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group(
    'ActiveWorkoutScreen Exercise Entry creation scroll behavior with a '
    'long list',
    () {
      testWidgets(
        'adding a new Exercise Entry to a list long enough that entries '
        'beyond the cache extent are not yet built still scrolls the new '
        'entry into view',
        (tester) async {
          tester.view.physicalSize = const Size(1080, 2400);
          tester.view.devicePixelRatio = 2.625;
          addTearDown(tester.view.reset);

          final entries = List.generate(
            20,
            (i) => ExerciseEntry(id: 'entry-$i', exerciseId: 'exercise-$i'),
          );
          final exercises = List.generate(
            20,
            (i) => Exercise(id: 'exercise-$i', name: 'Exercise $i'),
          );
          final workout = Workout(
            id: 'workout-1',
            startTime: DateTime(2026, 1, 1),
            exerciseEntries: entries,
          );

          final repository = await pumpActiveWorkoutScreen(
            tester,
            workout: workout,
            exercises: exercises,
          );

          await tester.enterText(find.byType(TextField).first, 'Bench Press');
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pumpAndSettle();

          final saved = repository.workouts.firstWhere(
            (w) => w.id == 'workout-1',
          );
          final newEntryId = saved.exerciseEntries.last.id;

          final listRect = tester.getRect(find.byType(ListView));
          final newEntryRect = tester.getRect(
            find.byKey(ValueKey('entry-header-$newEntryId')),
          );

          expect(newEntryRect.top, greaterThanOrEqualTo(listRect.top));
          expect(newEntryRect.bottom, lessThanOrEqualTo(listRect.bottom));
        },
      );
    },
  );
}
