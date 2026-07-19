import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal/models/routine.dart';
import 'package:universal/repositories/workout_repository.dart';
import 'package:universal/screens/manage_routines_screen.dart';
import 'package:universal/screens/routine_screen.dart';
import 'package:universal/widgets/routine_tile.dart';

Future<WorkoutRepository> _pumpManageRoutinesScreen(
  WidgetTester tester, {
  required List<Routine> routines,
}) async {
  final repository = WorkoutRepository(
    initialWorkouts: const [],
    initialExercises: const [],
    initialRoutines: routines,
  );
  await tester.pumpWidget(
    MaterialApp(
      home: ChangeNotifierProvider<WorkoutRepository>.value(
        value: repository,
        child: const ManageRoutinesScreen(),
      ),
    ),
  );
  return repository;
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ManageRoutinesScreen', () {
    testWidgets(
      'lists active Routines sorted alphabetically by name, '
      'case-insensitively, followed by an Archived section',
      (tester) async {
        await _pumpManageRoutinesScreen(
          tester,
          // Deliberately out of alphabetical order, mixed casing, and with
          // an archived Routine interleaved, so the test can only pass if
          // the screen both sorts case-insensitively and sections archived
          // Routines separately rather than preserving input order.
          routines: [
            Routine(id: 'routine-push', name: 'Push Day'),
            Routine(
              id: 'routine-full-body',
              name: 'Full Body A',
              archivedAt: DateTime(2026, 1, 1),
            ),
            Routine(id: 'routine-pull', name: 'pull day'),
          ],
        );

        final tileKeys = find
            .byType(RoutineTile)
            .evaluate()
            .map((e) => e.widget.key)
            .toList();

        expect(tileKeys, [
          const ValueKey('routine-routine-pull'),
          const ValueKey('routine-routine-push'),
          const ValueKey('routine-routine-full-body'),
        ]);
        expect(find.text('Archived'), findsOneWidget);

        final archivedPosition = tester.getCenter(find.text('Archived'));
        final pushDayPosition = tester.getCenter(find.text('Push Day'));
        expect(archivedPosition.dy, greaterThan(pushDayPosition.dy));
      },
    );

    testWidgets(
      'shows no Archived section label when no Routine is archived',
      (tester) async {
        await _pumpManageRoutinesScreen(
          tester,
          routines: [Routine(id: 'routine-1', name: 'Push Day')],
        );

        expect(find.text('Archived'), findsNothing);
      },
    );

    testWidgets(
      'shows an empty-state message and no list rows when there are no '
      'Routines at all',
      (tester) async {
        await _pumpManageRoutinesScreen(tester, routines: []);

        expect(find.text('No Routines yet'), findsOneWidget);
        expect(find.byType(RoutineTile), findsNothing);
      },
    );

    testWidgets(
      'tapping an active Routine row navigates to that Routine\'s '
      'RoutineScreen',
      (tester) async {
        await _pumpManageRoutinesScreen(
          tester,
          routines: [Routine(id: 'routine-1', name: 'Push Day')],
        );

        await tester.tap(find.text('Push Day'));
        await tester.pumpAndSettle();

        expect(find.byType(RoutineScreen), findsOneWidget);
        final screen = tester.widget<RoutineScreen>(
          find.byType(RoutineScreen),
        );
        expect(screen.routineId, 'routine-1');
      },
    );

    testWidgets(
      'tapping an archived Routine row navigates to that Routine\'s '
      'RoutineScreen',
      (tester) async {
        await _pumpManageRoutinesScreen(
          tester,
          routines: [
            Routine(
              id: 'routine-1',
              name: 'Full Body A',
              archivedAt: DateTime(2026, 1, 1),
            ),
          ],
        );

        await tester.tap(find.text('Full Body A'));
        await tester.pumpAndSettle();

        expect(find.byType(RoutineScreen), findsOneWidget);
        final screen = tester.widget<RoutineScreen>(
          find.byType(RoutineScreen),
        );
        expect(screen.routineId, 'routine-1');
      },
    );

    testWidgets(
      'tapping the FloatingActionButton opens a Create Routine dialog with '
      'a name field and Cancel/Create actions',
      (tester) async {
        await _pumpManageRoutinesScreen(tester, routines: []);

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        expect(
          find.byKey(const ValueKey('create-routine-field')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('create-routine-cancel')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('create-routine-create')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'cancelling the Create Routine dialog closes it and creates no '
      'Routine',
      (tester) async {
        final repository = await _pumpManageRoutinesScreen(
          tester,
          routines: [],
        );

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const ValueKey('create-routine-field')),
          'Pull Day',
        );
        await tester.tap(find.byKey(const ValueKey('create-routine-cancel')));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsNothing);
        expect(repository.routines, isEmpty);
      },
    );

    testWidgets(
      'submitting a valid, non-colliding name closes the dialog, creates '
      'the Routine, and navigates directly into its RoutineScreen',
      (tester) async {
        final repository = await _pumpManageRoutinesScreen(
          tester,
          routines: [Routine(id: 'routine-existing', name: 'Push Day')],
        );

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const ValueKey('create-routine-field')),
          'Pull Day',
        );
        await tester.tap(find.byKey(const ValueKey('create-routine-create')));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsNothing);
        expect(repository.routines.length, 2);
        final created = repository.routines.firstWhere(
          (r) => r.id != 'routine-existing',
        );
        expect(created.name, 'Pull Day');

        expect(find.byType(RoutineScreen), findsOneWidget);
        final screen = tester.widget<RoutineScreen>(
          find.byType(RoutineScreen),
        );
        expect(screen.routineId, created.id);
      },
    );

    testWidgets(
      'submitting an empty or whitespace-only name shows an inline '
      'validation error, keeps the dialog open, and creates no Routine',
      (tester) async {
        final repository = await _pumpManageRoutinesScreen(
          tester,
          routines: [],
        );

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const ValueKey('create-routine-field')),
          '   ',
        );
        await tester.tap(find.byKey(const ValueKey('create-routine-create')));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        expect(repository.routines, isEmpty);

        final field = tester.widget<TextField>(
          find.byKey(const ValueKey('create-routine-field')),
        );
        expect(field.decoration?.errorText, 'Name cannot be empty');
      },
    );

    testWidgets(
      'submitting a name matching an existing Routine case-insensitively '
      'shows an inline validation error, keeps the dialog open, and '
      'creates no second Routine',
      (tester) async {
        final repository = await _pumpManageRoutinesScreen(
          tester,
          routines: [Routine(id: 'routine-1', name: 'Push Day')],
        );

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const ValueKey('create-routine-field')),
          'push day',
        );
        await tester.tap(find.byKey(const ValueKey('create-routine-create')));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        expect(repository.routines.length, 1);

        final field = tester.widget<TextField>(
          find.byKey(const ValueKey('create-routine-field')),
        );
        expect(
          field.decoration?.errorText,
          'A Routine with this name already exists',
        );
      },
    );
  });
}
