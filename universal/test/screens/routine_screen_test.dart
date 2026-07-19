import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal/models/routine.dart';

import 'routine_screen_test_helpers.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('RoutineScreen', () {
    testWidgets('AppBar shows the Routine\'s name as its title', (
      tester,
    ) async {
      await pumpRoutineScreen(
        tester,
        routines: [Routine(id: 'routine-1', name: 'Push Day')],
        routineId: 'routine-1',
      );

      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Push Day'),
        ),
        findsOneWidget,
      );
    });

    testWidgets(
      'shows the locked banner when the Routine is archived, and no '
      'banner when active',
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

        expect(
          find.text('Archived — unarchive to edit Planned Exercises'),
          findsOneWidget,
        );
      },
    );

    testWidgets('shows no locked banner when the Routine is active', (
      tester,
    ) async {
      await pumpRoutineScreen(
        tester,
        routines: [Routine(id: 'routine-1', name: 'Push Day')],
        routineId: 'routine-1',
      );

      expect(
        find.text('Archived — unarchive to edit Planned Exercises'),
        findsNothing,
      );
    });

    testWidgets(
      'shows a single-line "No Planned Exercises yet" message with no '
      'second hint line when active',
      (tester) async {
        await pumpRoutineScreen(
          tester,
          routines: [Routine(id: 'routine-1', name: 'Push Day')],
          routineId: 'routine-1',
        );

        expect(find.text('No Planned Exercises yet'), findsOneWidget);
        expect(
          find.descendant(
            of: find.byKey(const ValueKey('routine-empty-state')),
            matching: find.byType(Text),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'shows a single-line "No Planned Exercises yet" message with no '
      'second hint line when archived, alongside the locked banner',
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

        expect(find.text('No Planned Exercises yet'), findsOneWidget);
        expect(
          find.text('Archived — unarchive to edit Planned Exercises'),
          findsOneWidget,
        );
      },
    );
  });
}
