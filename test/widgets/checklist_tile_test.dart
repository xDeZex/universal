import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal/models/checklist.dart';
import 'package:universal/widgets/checklist_tile.dart';

void main() {
  group('ChecklistTile', () {
    testWidgets('displays checklist name', (tester) async {
      final checklist = Checklist(name: 'Groceries');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChecklistTile(
              checklist: checklist,
              onTap: () {},
              onDelete: () {},
              onRename: () {},
            ),
          ),
        ),
      );

      expect(find.text('Groceries'), findsOneWidget);
    });

    testWidgets('displays item count as unchecked/total', (tester) async {
      final checklist = Checklist(
        name: 'Groceries',
        items: [
          ChecklistItem(name: 'Milk'),
          ChecklistItem(name: 'Bread', isChecked: true),
          ChecklistItem(name: 'Eggs'),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChecklistTile(
              checklist: checklist,
              onTap: () {},
              onDelete: () {},
              onRename: () {},
            ),
          ),
        ),
      );

      expect(find.text('2/3'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;
      final checklist = Checklist(name: 'Groceries');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChecklistTile(
              checklist: checklist,
              onTap: () => tapped = true,
              onDelete: () {},
              onRename: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ListTile));
      expect(tapped, isTrue);
    });

    testWidgets('has delete button that calls onDelete', (tester) async {
      bool deleted = false;
      final checklist = Checklist(name: 'Groceries');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChecklistTile(
              checklist: checklist,
              onTap: () {},
              onDelete: () => deleted = true,
              onRename: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.delete));
      expect(deleted, isTrue);
    });

    testWidgets('has rename button that calls onRename', (tester) async {
      bool renamed = false;
      final checklist = Checklist(name: 'Groceries');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChecklistTile(
              checklist: checklist,
              onTap: () {},
              onDelete: () {},
              onRename: () => renamed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.edit));
      expect(renamed, isTrue);
    });

    testWidgets('has drag handle for reordering', (tester) async {
      final checklist = Checklist(name: 'Groceries');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChecklistTile(
              checklist: checklist,
              onTap: () {},
              onDelete: () {},
              onRename: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.drag_handle), findsOneWidget);
    });
  });
}
