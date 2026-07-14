import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal/models/exercise.dart';
import 'package:universal/repositories/workout_repository.dart';
import 'package:universal/screens/manage_exercises_screen.dart';
import 'package:universal/widgets/exercise_tile.dart';

Future<WorkoutRepository> _pumpManageExercisesScreen(
  WidgetTester tester, {
  required List<Exercise> exercises,
}) async {
  final repository = WorkoutRepository(
    initialWorkouts: const [],
    initialExercises: exercises,
  );
  await tester.pumpWidget(
    MaterialApp(
      home: ChangeNotifierProvider<WorkoutRepository>.value(
        value: repository,
        child: const ManageExercisesScreen(),
      ),
    ),
  );
  return repository;
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ManageExercisesScreen', () {
    testWidgets(
      'lists Exercises sorted alphabetically by name, case-insensitively',
      (tester) async {
        await _pumpManageExercisesScreen(
          tester,
          // Deliberately out of alphabetical order, and mixed casing, so the
          // test can only pass if the screen sorts case-insensitively rather
          // than preserving input order.
          exercises: [
            Exercise(id: 'ex-banana', name: 'Banana'),
            Exercise(id: 'ex-cherry', name: 'cherry'),
            Exercise(id: 'ex-apple', name: 'apple'),
          ],
        );

        final keys = find
            .byType(ExerciseTile)
            .evaluate()
            .map((e) => e.widget.key)
            .toList();

        expect(keys, [
          const ValueKey('exercise-ex-apple'),
          const ValueKey('exercise-ex-banana'),
          const ValueKey('exercise-ex-cherry'),
        ]);
      },
    );

    testWidgets(
      'shows a "No Exercises yet" empty state with a hint to log a Workout, '
      'and no list rows, when there are no Exercises',
      (tester) async {
        await _pumpManageExercisesScreen(tester, exercises: []);

        expect(find.text('No Exercises yet'), findsOneWidget);
        expect(find.textContaining('Workout'), findsOneWidget);
        expect(find.byType(ExerciseTile), findsNothing);
      },
    );

    testWidgets(
      'shows no add/create control when the Exercise list is empty',
      (tester) async {
        await _pumpManageExercisesScreen(tester, exercises: []);

        expect(find.byType(FloatingActionButton), findsNothing);
        expect(find.byIcon(Icons.add), findsNothing);
      },
    );

    testWidgets(
      'shows no add/create control when Exercises are present',
      (tester) async {
        await _pumpManageExercisesScreen(
          tester,
          exercises: [Exercise(id: 'ex-1', name: 'Bench Press')],
        );

        expect(find.byType(FloatingActionButton), findsNothing);
        expect(find.byIcon(Icons.add), findsNothing);
      },
    );

    testWidgets(
      'tapping an Exercise row opens a rename dialog pre-filled with its '
      'current name',
      (tester) async {
        await _pumpManageExercisesScreen(
          tester,
          exercises: [Exercise(id: 'ex-1', name: 'Bench Press')],
        );

        await tester.tap(find.text('Bench Press'));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        final field = tester.widget<TextField>(find.byType(TextField));
        expect(field.controller?.text, 'Bench Press');
      },
    );

    testWidgets(
      'cancelling the rename dialog leaves the Exercise unchanged and '
      'closes the dialog',
      (tester) async {
        final repository = await _pumpManageExercisesScreen(
          tester,
          exercises: [Exercise(id: 'ex-1', name: 'Bench Press')],
        );

        await tester.tap(find.text('Bench Press'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const ValueKey('rename-exercise-field')),
          'Incline Bench Press',
        );
        await tester.tap(find.byKey(const ValueKey('rename-exercise-cancel')));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsNothing);
        expect(find.text('Bench Press'), findsOneWidget);
        expect(find.text('Incline Bench Press'), findsNothing);
        expect(repository.exercises[0].name, 'Bench Press');
      },
    );

    testWidgets(
      'submitting a valid new name renames the Exercise, persists the '
      'updated list, and closes the dialog',
      (tester) async {
        final repository = await _pumpManageExercisesScreen(
          tester,
          exercises: [Exercise(id: 'ex-1', name: 'Bench Press')],
        );

        await tester.tap(find.text('Bench Press'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const ValueKey('rename-exercise-field')),
          'Incline Bench Press',
        );
        await tester.tap(find.byKey(const ValueKey('rename-exercise-save')));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsNothing);
        expect(find.text('Incline Bench Press'), findsOneWidget);
        expect(find.text('Bench Press'), findsNothing);
        final renamed = repository.exercises.firstWhere(
          (e) => e.id == 'ex-1',
        );
        expect(renamed.name, 'Incline Bench Press');
      },
    );

    testWidgets(
      'submitting the Exercise\'s own current name with different casing '
      'succeeds, since it does not collide with any other Exercise',
      (tester) async {
        final repository = await _pumpManageExercisesScreen(
          tester,
          exercises: [
            Exercise(id: 'ex-1', name: 'Bench Press'),
            Exercise(id: 'ex-2', name: 'Squat'),
          ],
        );

        await tester.tap(find.text('Bench Press'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const ValueKey('rename-exercise-field')),
          'bench press',
        );
        await tester.tap(find.byKey(const ValueKey('rename-exercise-save')));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsNothing);
        expect(
          repository.exercises.firstWhere((e) => e.id == 'ex-1').name,
          'bench press',
        );
      },
    );

    testWidgets(
      'submitting the Exercise\'s own current name unchanged succeeds, '
      'since it does not collide with any other Exercise',
      (tester) async {
        final repository = await _pumpManageExercisesScreen(
          tester,
          exercises: [
            Exercise(id: 'ex-1', name: 'Bench Press'),
            Exercise(id: 'ex-2', name: 'Squat'),
          ],
        );

        await tester.tap(find.text('Bench Press'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('rename-exercise-save')));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsNothing);
        expect(
          repository.exercises.firstWhere((e) => e.id == 'ex-1').name,
          'Bench Press',
        );
      },
    );

    testWidgets(
      'submitting an empty or whitespace-only name shows an inline '
      'validation error, keeps the dialog open, and leaves the Exercise '
      'unchanged',
      (tester) async {
        final repository = await _pumpManageExercisesScreen(
          tester,
          exercises: [Exercise(id: 'ex-1', name: 'Bench Press')],
        );

        await tester.tap(find.text('Bench Press'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const ValueKey('rename-exercise-field')),
          '   ',
        );
        await tester.tap(find.byKey(const ValueKey('rename-exercise-save')));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text('Bench Press'), findsOneWidget);
        expect(repository.exercises[0].name, 'Bench Press');

        final field = tester.widget<TextField>(
          find.byKey(const ValueKey('rename-exercise-field')),
        );
        expect(field.decoration?.errorText, isNotNull);
      },
    );

    testWidgets(
      'submitting a name matching another existing Exercise '
      'case-insensitively shows an inline validation error, keeps the '
      'dialog open, and leaves the Exercise unchanged',
      (tester) async {
        final repository = await _pumpManageExercisesScreen(
          tester,
          exercises: [
            Exercise(id: 'ex-1', name: 'Bench Press'),
            Exercise(id: 'ex-2', name: 'Squat'),
          ],
        );

        await tester.tap(find.text('Bench Press'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const ValueKey('rename-exercise-field')),
          'squat',
        );
        await tester.tap(find.byKey(const ValueKey('rename-exercise-save')));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text('Bench Press'), findsOneWidget);
        expect(
          repository.exercises.firstWhere((e) => e.id == 'ex-1').name,
          'Bench Press',
        );

        final field = tester.widget<TextField>(
          find.byKey(const ValueKey('rename-exercise-field')),
        );
        expect(field.decoration?.errorText, isNotNull);
      },
    );
  });
}
