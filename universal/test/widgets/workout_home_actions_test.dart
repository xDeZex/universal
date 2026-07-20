import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal/widgets/workout_home_actions.dart';

void main() {
  Future<void> pumpActions(
    WidgetTester tester, {
    String primaryLabel = 'Start Workout',
    IconData primaryIcon = Icons.play_arrow,
    VoidCallback? onPrimaryPressed,
    List<WorkoutHomeAction>? secondaryActions,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WorkoutHomeActions(
            primaryLabel: primaryLabel,
            primaryIcon: primaryIcon,
            onPrimaryPressed: onPrimaryPressed ?? () {},
            secondaryActions:
                secondaryActions ??
                [
                  WorkoutHomeAction(
                    label: 'Past Workouts',
                    icon: Icons.history,
                    onPressed: () {},
                  ),
                  WorkoutHomeAction(
                    label: 'Manage Exercises',
                    icon: Icons.fitness_center,
                    onPressed: () {},
                  ),
                  WorkoutHomeAction(
                    label: 'Manage Routines',
                    icon: Icons.list_alt,
                    onPressed: () {},
                  ),
                ],
          ),
        ),
      ),
    );
  }

  group('WorkoutHomeActions', () {
    testWidgets('renders the primary action as a full-width FilledButton', (
      tester,
    ) async {
      await pumpActions(tester, primaryLabel: 'Start Workout');

      expect(find.text('Start Workout'), findsOneWidget);
      expect(find.byType(FilledButton), findsWidgets);

      final buttonFinder = find.ancestor(
        of: find.text('Start Workout'),
        matching: find.byType(FilledButton),
      );
      expect(buttonFinder, findsOneWidget);

      final buttonWidth = tester.getSize(buttonFinder).width;
      final screenWidth = tester.getSize(find.byType(Scaffold)).width;
      expect(buttonWidth, screenWidth);
    });

    testWidgets('tapping the primary action calls onPrimaryPressed', (
      tester,
    ) async {
      var pressed = false;
      await pumpActions(
        tester,
        onPrimaryPressed: () => pressed = true,
      );

      await tester.tap(find.text('Start Workout'));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets(
      'renders each secondary action as a tonal chip with a leading icon',
      (tester) async {
        await pumpActions(tester);

        for (final label in [
          'Past Workouts',
          'Manage Exercises',
          'Manage Routines',
        ]) {
          expect(find.text(label), findsOneWidget);
          final chipFinder = find.ancestor(
            of: find.text(label),
            matching: find.byType(FilledButton),
          );
          expect(chipFinder, findsOneWidget);
        }

        expect(find.byIcon(Icons.history), findsOneWidget);
        expect(find.byIcon(Icons.fitness_center), findsOneWidget);
        expect(find.byIcon(Icons.list_alt), findsOneWidget);
      },
    );

    testWidgets('secondary actions are laid out in a Wrap', (tester) async {
      await pumpActions(tester);

      expect(find.byType(Wrap), findsOneWidget);
    });

    testWidgets('tapping a secondary action calls its own callback', (
      tester,
    ) async {
      String? tapped;
      await pumpActions(
        tester,
        secondaryActions: [
          WorkoutHomeAction(
            label: 'Past Workouts',
            icon: Icons.history,
            onPressed: () => tapped = 'Past Workouts',
          ),
          WorkoutHomeAction(
            label: 'Manage Exercises',
            icon: Icons.fitness_center,
            onPressed: () => tapped = 'Manage Exercises',
          ),
        ],
      );

      await tester.tap(find.text('Manage Exercises'));
      await tester.pump();

      expect(tapped, 'Manage Exercises');
    });

    testWidgets(
      'does not overflow at a real phone width with three secondary actions',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.625;
        addTearDown(tester.view.reset);

        await pumpActions(tester);

        expect(tester.takeException(), isNull);
      },
    );
  });
}
