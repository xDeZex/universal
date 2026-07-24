import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal/models/workout.dart';
import 'package:universal/widgets/exercise_entry_tile.dart';

void main() {
  group('ExerciseEntryTile', () {
    testWidgets('zebra-shades alternating set rows', (tester) async {
      final entry = ExerciseEntry(
        id: 'entry-1',
        exerciseId: 'exercise-1',
        sets: [
          ExerciseSet(
            id: 'set-1',
            weight: 60,
            unit: WeightUnit.kg,
            reps: 8,
            loggedAt: DateTime(2026, 1, 1, 10, 0),
          ),
          ExerciseSet(
            id: 'set-2',
            weight: 60,
            unit: WeightUnit.kg,
            reps: 8,
            loggedAt: DateTime(2026, 1, 1, 10, 5),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExerciseEntryTile(
              entry: entry,
              exerciseName: 'Bench Press',
              locked: false,
              selected: false,
              onSelect: () {},
              onEditSet: (_, _, _, _) {},
              onDeleteSet: (_) {},
              onDeleteEntry: () {},
            ),
          ),
        ),
      );

      final theme = Theme.of(tester.element(find.byType(Scaffold)));
      final expectedZebra = theme.colorScheme.surfaceContainerHighest
          .withValues(alpha: 0.5);

      Color? colorAboveSetRow(String setId) {
        final container = tester.firstWidget<Container>(
          find.ancestor(
            of: find.byKey(ValueKey('set-$setId')),
            matching: find.byType(Container),
          ),
        );
        return container.color;
      }

      expect(colorAboveSetRow('set-1'), isNull);
      expect(colorAboveSetRow('set-2'), expectedZebra);
    });
  });
}
