import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal/models/exercise.dart';
import 'package:universal/widgets/planned_exercise_add_field.dart';

void main() {
  Future<void> pumpField(
    WidgetTester tester, {
    required List<Exercise> exercises,
    void Function(String name)? onAdd,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PlannedExerciseAddField(
            exercises: exercises,
            onAdd: onAdd ?? (_) {},
          ),
        ),
      ),
    );
  }

  group('PlannedExerciseAddField autocomplete dropdown', () {
    testWidgets(
      'typing text with a case-insensitive substring match shows a dropdown '
      'of matches, alphabetically ordered',
      (tester) async {
        await pumpField(
          tester,
          exercises: [
            Exercise(id: 'ex-1', name: 'Zercise Press'),
            Exercise(id: 'ex-2', name: 'Bench Press'),
            Exercise(id: 'ex-3', name: 'Overhead Press'),
            Exercise(id: 'ex-4', name: 'Squat'),
          ],
        );

        await tester.enterText(
          find.byKey(const ValueKey('add-planned-exercise-field')),
          'press',
        );
        await tester.pump();

        final suggestionTexts = tester
            .widgetList<Text>(
              find.descendant(
                of: find.byKey(
                  const ValueKey('add-planned-exercise-suggestions'),
                ),
                matching: find.byType(Text),
              ),
            )
            .map((t) => t.data)
            .toList();

        expect(suggestionTexts, [
          'Bench Press',
          'Overhead Press',
          'Zercise Press',
        ]);
      },
    );

    testWidgets('the dropdown never shows an "add as new" row', (
      tester,
    ) async {
      await pumpField(
        tester,
        exercises: [Exercise(id: 'ex-1', name: 'Bench Press')],
      );

      await tester.enterText(
        find.byKey(const ValueKey('add-planned-exercise-field')),
        'bench',
      );
      await tester.pump();

      expect(
        find.descendant(
          of: find.byKey(const ValueKey('add-planned-exercise-suggestions')),
          matching: find.byType(ListTile),
        ),
        findsOneWidget,
      );
    });

    testWidgets('typing text with no matches hides the dropdown', (
      tester,
    ) async {
      await pumpField(
        tester,
        exercises: [Exercise(id: 'ex-1', name: 'Bench Press')],
      );

      await tester.enterText(
        find.byKey(const ValueKey('add-planned-exercise-field')),
        'nonexistent',
      );
      await tester.pump();

      expect(
        find.byKey(const ValueKey('add-planned-exercise-suggestions')),
        findsNothing,
      );
    });

    testWidgets(
      'tapping a suggestion fills the field with the full name and does not '
      'submit',
      (tester) async {
        var addCalls = 0;
        await pumpField(
          tester,
          exercises: [Exercise(id: 'ex-1', name: 'Bench Press')],
          onAdd: (_) => addCalls++,
        );

        await tester.enterText(
          find.byKey(const ValueKey('add-planned-exercise-field')),
          'bench',
        );
        await tester.pump();

        await tester.tap(find.text('Bench Press'));
        await tester.pump();

        final textField = tester.widget<TextField>(
          find.byKey(const ValueKey('add-planned-exercise-field')),
        );
        expect(textField.controller!.text, 'Bench Press');
        expect(addCalls, 0);
      },
    );

    testWidgets(
      'a long list of matches scrolls within the dropdown rather than being '
      'capped',
      (tester) async {
        final exercises = List.generate(
          20,
          (i) =>
              Exercise(id: 'ex-$i', name: 'Exercise ${String.fromCharCode(65 + i)}'),
        );
        await pumpField(tester, exercises: exercises);

        await tester.enterText(
          find.byKey(const ValueKey('add-planned-exercise-field')),
          'Exercise',
        );
        await tester.pump();

        expect(find.text('Exercise A'), findsOneWidget);
        expect(find.text('Exercise T'), findsNothing);

        await tester.drag(
          find.byKey(const ValueKey('add-planned-exercise-suggestions')),
          const Offset(0, -2000),
        );
        await tester.pump();

        expect(find.text('Exercise T'), findsOneWidget);
      },
    );
  });
}
