import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal/models/checklist.dart';
import 'package:universal/widgets/item_tile.dart';

void main() {
  group('ItemTile', () {
    testWidgets('displays item name', (tester) async {
      final item = ChecklistItem(name: 'Buy milk');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ItemTile(
              item: item,
              onToggle: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('Buy milk'), findsOneWidget);
    });

    testWidgets('shows unchecked checkbox for unchecked item', (tester) async {
      final item = ChecklistItem(name: 'Buy milk', isChecked: false);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ItemTile(
              item: item,
              onToggle: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, false);
    });

    testWidgets('shows checked checkbox for checked item', (tester) async {
      final item = ChecklistItem(name: 'Buy milk', isChecked: true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ItemTile(
              item: item,
              onToggle: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, true);
    });

    testWidgets('calls onToggle when checkbox tapped', (tester) async {
      bool toggled = false;
      final item = ChecklistItem(name: 'Buy milk');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ItemTile(
              item: item,
              onToggle: () => toggled = true,
              onDelete: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Checkbox));
      expect(toggled, isTrue);
    });

    testWidgets('has delete button that calls onDelete', (tester) async {
      bool deleted = false;
      final item = ChecklistItem(name: 'Buy milk');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ItemTile(
              item: item,
              onToggle: () {},
              onDelete: () => deleted = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.delete));
      expect(deleted, isTrue);
    });

    testWidgets('has drag handle for reordering', (tester) async {
      final item = ChecklistItem(name: 'Buy milk');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ItemTile(
              item: item,
              onToggle: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.drag_handle), findsOneWidget);
    });

    testWidgets('checked item has strikethrough text', (tester) async {
      final item = ChecklistItem(name: 'Buy milk', isChecked: true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ItemTile(
              item: item,
              onToggle: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Buy milk'));
      expect(
        textWidget.style?.decoration,
        TextDecoration.lineThrough,
      );
    });
  });
}
