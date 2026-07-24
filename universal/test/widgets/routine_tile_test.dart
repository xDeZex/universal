import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal/models/routine.dart';
import 'package:universal/widgets/coplanar_card.dart';
import 'package:universal/widgets/routine_tile.dart';

void main() {
  group('RoutineTile', () {
    testWidgets('renders its ListTile inside a CoplanarCard', (tester) async {
      final routine = Routine(id: 'routine-1', name: 'Push Day');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoutineTile(routine: routine, onTap: () {}),
          ),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(CoplanarCard),
          matching: find.byType(ListTile),
        ),
        findsOneWidget,
      );
      expect(find.text('Push Day'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;
      final routine = Routine(id: 'routine-1', name: 'Push Day');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoutineTile(routine: routine, onTap: () => tapped = true),
          ),
        ),
      );

      await tester.tap(find.byType(ListTile));
      expect(tapped, isTrue);
    });
  });
}
