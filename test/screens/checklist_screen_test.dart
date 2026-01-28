import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal/models/checklist.dart';
import 'package:universal/screens/checklist_screen.dart';

void main() {
  group('ChecklistScreen', () {
    testWidgets('displays checklist name in app bar', (tester) async {
      final checklist = Checklist(name: 'Groceries');

      await tester.pumpWidget(
        MaterialApp(home: ChecklistScreen(checklist: checklist)),
      );

      expect(find.text('Groceries'), findsOneWidget);
    });

    testWidgets('shows empty state when no items', (tester) async {
      final checklist = Checklist(name: 'Groceries');

      await tester.pumpWidget(
        MaterialApp(home: ChecklistScreen(checklist: checklist)),
      );

      expect(find.text('No items yet'), findsOneWidget);
      expect(find.text('Tap + to add one'), findsOneWidget);
    });

    testWidgets('has FAB to add new item', (tester) async {
      final checklist = Checklist(name: 'Groceries');

      await tester.pumpWidget(
        MaterialApp(home: ChecklistScreen(checklist: checklist)),
      );

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('tapping FAB shows dialog to add item', (tester) async {
      final checklist = Checklist(name: 'Groceries');

      await tester.pumpWidget(
        MaterialApp(home: ChecklistScreen(checklist: checklist)),
      );

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Add Item'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('can add a new item', (tester) async {
      final checklist = Checklist(name: 'Groceries');

      await tester.pumpWidget(
        MaterialApp(home: ChecklistScreen(checklist: checklist)),
      );

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Milk');
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(find.text('Milk'), findsOneWidget);
    });

    testWidgets('displays unchecked items in unchecked section', (tester) async {
      final checklist = Checklist(
        name: 'Groceries',
        items: [
          ChecklistItem(name: 'Milk', isChecked: false),
          ChecklistItem(name: 'Bread', isChecked: true),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(home: ChecklistScreen(checklist: checklist)),
      );

      expect(find.text('Milk'), findsOneWidget);
      expect(find.text('Bread'), findsOneWidget);
    });

    testWidgets('can toggle item checked state', (tester) async {
      final checklist = Checklist(
        name: 'Groceries',
        items: [ChecklistItem(name: 'Milk', isChecked: false)],
      );

      await tester.pumpWidget(
        MaterialApp(home: ChecklistScreen(checklist: checklist)),
      );

      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, true);
    });

    testWidgets('can delete an item', (tester) async {
      final checklist = Checklist(
        name: 'Groceries',
        items: [ChecklistItem(name: 'Milk')],
      );

      await tester.pumpWidget(
        MaterialApp(home: ChecklistScreen(checklist: checklist)),
      );

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      expect(find.text('Milk'), findsNothing);
      expect(find.text('No items yet'), findsOneWidget);
    });

    testWidgets('shows snackbar when adding duplicate', (tester) async {
      final checklist = Checklist(
        name: 'Groceries',
        items: [ChecklistItem(name: 'Milk', isChecked: true)],
      );

      await tester.pumpWidget(
        MaterialApp(home: ChecklistScreen(checklist: checklist)),
      );

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'milk');
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Item already exists - moved to unchecked'), findsOneWidget);
    });

    testWidgets('duplicate item is unchecked when added again', (tester) async {
      final checklist = Checklist(
        name: 'Groceries',
        items: [ChecklistItem(name: 'Milk', isChecked: true)],
      );

      await tester.pumpWidget(
        MaterialApp(home: ChecklistScreen(checklist: checklist)),
      );

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'milk');
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, false);
    });

    testWidgets('displays section headers', (tester) async {
      final checklist = Checklist(
        name: 'Groceries',
        items: [
          ChecklistItem(name: 'Milk', isChecked: false),
          ChecklistItem(name: 'Bread', isChecked: true),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(home: ChecklistScreen(checklist: checklist)),
      );

      expect(find.text('To Do'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
    });
  });
}
