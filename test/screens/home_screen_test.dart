import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal/models/checklist.dart';
import 'package:universal/screens/home_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('HomeScreen', () {
    testWidgets('displays app title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: HomeScreen()),
      );

      expect(find.text('Checklists'), findsOneWidget);
    });

    testWidgets('shows empty state when no checklists', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: HomeScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('No checklists yet'), findsOneWidget);
      expect(find.text('Tap + to create one'), findsOneWidget);
    });

    testWidgets('has FAB to add new checklist', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: HomeScreen()),
      );

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('tapping FAB shows dialog to name checklist', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: HomeScreen()),
      );

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('New Checklist'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('can create a new checklist', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: HomeScreen()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Groceries');
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      expect(find.text('Groceries'), findsOneWidget);
    });

    testWidgets('displays checklists with count', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(
            initialChecklists: [
              Checklist(
                name: 'Groceries',
                items: [
                  ChecklistItem(name: 'Milk'),
                  ChecklistItem(name: 'Bread', isChecked: true),
                ],
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('1/2'), findsOneWidget);
    });

    testWidgets('can delete a checklist', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(
            initialChecklists: [Checklist(name: 'Groceries')],
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      expect(find.text('Groceries'), findsNothing);
      expect(find.text('No checklists yet'), findsOneWidget);
    });

    testWidgets('can rename a checklist', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(
            initialChecklists: [Checklist(name: 'Groceries')],
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      expect(find.text('Rename Checklist'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Shopping');
      await tester.tap(find.text('Rename'));
      await tester.pumpAndSettle();

      expect(find.text('Shopping'), findsOneWidget);
      expect(find.text('Groceries'), findsNothing);
    });

    testWidgets('navigates to checklist screen on tap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(
            initialChecklists: [Checklist(name: 'Groceries')],
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Groceries'));
      await tester.pumpAndSettle();

      expect(find.text('Groceries'), findsOneWidget);
    });
  });
}
