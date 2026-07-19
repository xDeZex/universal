import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal/models/routine.dart';

import 'routine_screen_test_helpers.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('RoutineScreen archive/unarchive', () {
    testWidgets(
      'tapping the archive icon on an active Routine archives it '
      'immediately with no confirmation dialog',
      (tester) async {
        final repository = await pumpRoutineScreen(
          tester,
          routines: [Routine(id: 'routine-1', name: 'Push Day')],
          routineId: 'routine-1',
        );

        expect(find.byIcon(Icons.archive), findsOneWidget);
        expect(find.byIcon(Icons.unarchive), findsNothing);

        await tester.tap(
          find.byKey(const ValueKey('routine-archive-toggle')),
        );
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsNothing);
        expect(find.byType(Dialog), findsNothing);
        expect(repository.routines.single.isLocked, isTrue);
        expect(find.byIcon(Icons.unarchive), findsOneWidget);
        expect(find.byIcon(Icons.archive), findsNothing);
      },
    );

    testWidgets(
      'tapping the unarchive icon on an archived Routine unarchives it '
      'immediately with no confirmation dialog',
      (tester) async {
        final repository = await pumpRoutineScreen(
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

        expect(find.byIcon(Icons.unarchive), findsOneWidget);
        expect(find.byIcon(Icons.archive), findsNothing);

        await tester.tap(
          find.byKey(const ValueKey('routine-archive-toggle')),
        );
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsNothing);
        expect(repository.routines.single.isLocked, isFalse);
        expect(find.byIcon(Icons.archive), findsOneWidget);
        expect(find.byIcon(Icons.unarchive), findsNothing);
      },
    );
  });
}
