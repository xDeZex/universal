import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal/models/routine.dart';

import 'routine_screen_test_helpers.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('RoutineScreen rename', () {
    testWidgets(
      'tapping the AppBar title opens a rename dialog pre-filled with the '
      'current name, with no separate rename icon',
      (tester) async {
        await pumpRoutineScreen(
          tester,
          routines: [Routine(id: 'routine-1', name: 'Push Day')],
          routineId: 'routine-1',
        );

        expect(find.byIcon(Icons.edit), findsNothing);

        await tester.tap(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.text('Push Day'),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        final field = tester.widget<TextField>(
          find.byKey(const ValueKey('rename-routine-field')),
        );
        expect(field.controller?.text, 'Push Day');
      },
    );

    testWidgets(
      'submitting a valid, non-colliding rename persists via renameRoutine, '
      'updates the title, and closes the dialog',
      (tester) async {
        final repository = await pumpRoutineScreen(
          tester,
          routines: [Routine(id: 'routine-1', name: 'Push Day')],
          routineId: 'routine-1',
        );

        await openRenameDialog(tester, 'Push Day');
        await tester.enterText(
          find.byKey(const ValueKey('rename-routine-field')),
          'Upper Body',
        );
        await tester.tap(find.byKey(const ValueKey('rename-routine-save')));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsNothing);
        expect(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.text('Upper Body'),
          ),
          findsOneWidget,
        );
        expect(repository.routines.single.name, 'Upper Body');
      },
    );

    testWidgets(
      'cancelling the rename dialog leaves the name unchanged and closes '
      'the dialog',
      (tester) async {
        final repository = await pumpRoutineScreen(
          tester,
          routines: [Routine(id: 'routine-1', name: 'Push Day')],
          routineId: 'routine-1',
        );

        await openRenameDialog(tester, 'Push Day');
        await tester.enterText(
          find.byKey(const ValueKey('rename-routine-field')),
          'Upper Body',
        );
        await tester.tap(find.byKey(const ValueKey('rename-routine-cancel')));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsNothing);
        expect(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.text('Push Day'),
          ),
          findsOneWidget,
        );
        expect(repository.routines.single.name, 'Push Day');
      },
    );

    testWidgets(
      'submitting an empty or whitespace-only rename shows an inline '
      'validation error, keeps the dialog open, and leaves the Routine '
      'unchanged',
      (tester) async {
        final repository = await pumpRoutineScreen(
          tester,
          routines: [Routine(id: 'routine-1', name: 'Push Day')],
          routineId: 'routine-1',
        );

        await openRenameDialog(tester, 'Push Day');
        await tester.enterText(
          find.byKey(const ValueKey('rename-routine-field')),
          '   ',
        );
        await tester.tap(find.byKey(const ValueKey('rename-routine-save')));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        expect(repository.routines.single.name, 'Push Day');
        final field = tester.widget<TextField>(
          find.byKey(const ValueKey('rename-routine-field')),
        );
        expect(field.decoration?.errorText, 'Name cannot be empty');
      },
    );

    testWidgets(
      'submitting a rename colliding case-insensitively with another '
      'Routine shows an inline validation error, keeps the dialog open, '
      'and leaves the Routine unchanged',
      (tester) async {
        final repository = await pumpRoutineScreen(
          tester,
          routines: [
            Routine(id: 'routine-1', name: 'Push Day'),
            Routine(id: 'routine-2', name: 'Pull Day'),
          ],
          routineId: 'routine-1',
        );

        await openRenameDialog(tester, 'Push Day');
        await tester.enterText(
          find.byKey(const ValueKey('rename-routine-field')),
          'pull day',
        );
        await tester.tap(find.byKey(const ValueKey('rename-routine-save')));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        expect(
          repository.routines.firstWhere((r) => r.id == 'routine-1').name,
          'Push Day',
        );
        final field = tester.widget<TextField>(
          find.byKey(const ValueKey('rename-routine-field')),
        );
        expect(
          field.decoration?.errorText,
          'A Routine with this name already exists',
        );
      },
    );

    testWidgets(
      'rename remains available (title still tappable, dialog still '
      'succeeds) while the Routine is archived',
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

        await openRenameDialog(tester, 'Push Day');
        expect(find.byType(AlertDialog), findsOneWidget);
        await tester.enterText(
          find.byKey(const ValueKey('rename-routine-field')),
          'Upper Body',
        );
        await tester.tap(find.byKey(const ValueKey('rename-routine-save')));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsNothing);
        expect(repository.routines.single.name, 'Upper Body');
        expect(repository.routines.single.isLocked, isTrue);
      },
    );
  });
}
