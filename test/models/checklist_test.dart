import 'package:flutter_test/flutter_test.dart';
import 'package:universal/models/checklist.dart';

void main() {
  group('ChecklistItem', () {
    test('creates with name and isChecked defaults to false', () {
      final item = ChecklistItem(name: 'Buy milk');

      expect(item.name, 'Buy milk');
      expect(item.isChecked, false);
    });

    test('creates with explicit isChecked value', () {
      final item = ChecklistItem(name: 'Buy milk', isChecked: true);

      expect(item.isChecked, true);
    });

    test('copyWith creates new instance with updated values', () {
      final item = ChecklistItem(name: 'Buy milk');
      final checked = item.copyWith(isChecked: true);

      expect(checked.name, 'Buy milk');
      expect(checked.isChecked, true);
      expect(item.isChecked, false);
    });

    test('copyWith can update name', () {
      final item = ChecklistItem(name: 'Buy milk');
      final renamed = item.copyWith(name: 'Buy bread');

      expect(renamed.name, 'Buy bread');
      expect(item.name, 'Buy milk');
    });

    test('toJson returns correct map', () {
      final item = ChecklistItem(name: 'Buy milk', isChecked: true);
      final json = item.toJson();

      expect(json['name'], 'Buy milk');
      expect(json['isChecked'], true);
    });

    test('fromJson creates correct instance', () {
      final json = {'name': 'Buy milk', 'isChecked': true};
      final item = ChecklistItem.fromJson(json);

      expect(item.name, 'Buy milk');
      expect(item.isChecked, true);
    });
  });

  group('Checklist', () {
    test('creates with name and empty items list', () {
      final checklist = Checklist(name: 'Groceries');

      expect(checklist.name, 'Groceries');
      expect(checklist.items, isEmpty);
    });

    test('creates with provided items', () {
      final items = [
        ChecklistItem(name: 'Milk'),
        ChecklistItem(name: 'Bread'),
      ];
      final checklist = Checklist(name: 'Groceries', items: items);

      expect(checklist.items.length, 2);
    });

    test('addItem adds item at the end of unchecked items', () {
      final checklist = Checklist(name: 'Groceries');

      final updated = checklist.addItem('Milk')!;

      expect(updated.items.length, 1);
      expect(updated.items[0].name, 'Milk');
      expect(updated.items[0].isChecked, false);
    });

    test('addItem trims whitespace from name', () {
      final checklist = Checklist(name: 'Groceries');

      final updated = checklist.addItem('  Milk  ')!;

      expect(updated.items[0].name, 'Milk');
    });

    test('addItem returns same checklist if name is empty after trim', () {
      final checklist = Checklist(name: 'Groceries');

      final updated = checklist.addItem('   ')!;

      expect(updated.items, isEmpty);
    });

    test('addItem detects duplicate case-insensitively and returns null', () {
      final checklist = Checklist(
        name: 'Groceries',
        items: [ChecklistItem(name: 'Milk')],
      );

      final result = checklist.addItem('milk');

      expect(result, isNull);
    });

    test('addItem detects duplicate with different casing', () {
      final checklist = Checklist(
        name: 'Groceries',
        items: [ChecklistItem(name: 'MILK')],
      );

      final result = checklist.addItem('Milk');

      expect(result, isNull);
    });

    test('removeItem removes item by name', () {
      final checklist = Checklist(
        name: 'Groceries',
        items: [
          ChecklistItem(name: 'Milk'),
          ChecklistItem(name: 'Bread'),
        ],
      );

      final updated = checklist.removeItem('Milk');

      expect(updated.items.length, 1);
      expect(updated.items[0].name, 'Bread');
    });

    test('toggleItem changes checked state', () {
      final checklist = Checklist(
        name: 'Groceries',
        items: [ChecklistItem(name: 'Milk')],
      );

      final updated = checklist.toggleItem('Milk');

      expect(updated.items[0].isChecked, true);
    });

    test('toggleItem unchecks checked item', () {
      final checklist = Checklist(
        name: 'Groceries',
        items: [ChecklistItem(name: 'Milk', isChecked: true)],
      );

      final updated = checklist.toggleItem('Milk');

      expect(updated.items[0].isChecked, false);
    });

    test('ordering keeps unchecked items before checked items', () {
      final checklist = Checklist(
        name: 'Groceries',
        items: [
          ChecklistItem(name: 'Milk', isChecked: true),
          ChecklistItem(name: 'Bread', isChecked: false),
          ChecklistItem(name: 'Eggs', isChecked: true),
          ChecklistItem(name: 'Butter', isChecked: false),
        ],
      );

      final ordered = checklist.orderedItems;

      expect(ordered[0].name, 'Bread');
      expect(ordered[1].name, 'Butter');
      expect(ordered[2].name, 'Milk');
      expect(ordered[3].name, 'Eggs');
    });

    test('uncheckedItems returns only unchecked items', () {
      final checklist = Checklist(
        name: 'Groceries',
        items: [
          ChecklistItem(name: 'Milk', isChecked: true),
          ChecklistItem(name: 'Bread', isChecked: false),
        ],
      );

      expect(checklist.uncheckedItems.length, 1);
      expect(checklist.uncheckedItems[0].name, 'Bread');
    });

    test('checkedItems returns only checked items', () {
      final checklist = Checklist(
        name: 'Groceries',
        items: [
          ChecklistItem(name: 'Milk', isChecked: true),
          ChecklistItem(name: 'Bread', isChecked: false),
        ],
      );

      expect(checklist.checkedItems.length, 1);
      expect(checklist.checkedItems[0].name, 'Milk');
    });

    test('uncheckedCount returns count of unchecked items', () {
      final checklist = Checklist(
        name: 'Groceries',
        items: [
          ChecklistItem(name: 'Milk', isChecked: true),
          ChecklistItem(name: 'Bread', isChecked: false),
          ChecklistItem(name: 'Eggs', isChecked: false),
        ],
      );

      expect(checklist.uncheckedCount, 2);
    });

    test('totalCount returns total number of items', () {
      final checklist = Checklist(
        name: 'Groceries',
        items: [
          ChecklistItem(name: 'Milk'),
          ChecklistItem(name: 'Bread'),
        ],
      );

      expect(checklist.totalCount, 2);
    });

    test('reorderUnchecked moves item within unchecked items', () {
      final checklist = Checklist(
        name: 'Groceries',
        items: [
          ChecklistItem(name: 'A', isChecked: false),
          ChecklistItem(name: 'B', isChecked: false),
          ChecklistItem(name: 'C', isChecked: false),
          ChecklistItem(name: 'X', isChecked: true),
        ],
      );

      final updated = checklist.reorderUnchecked(0, 2);
      final unchecked = updated.uncheckedItems;

      expect(unchecked[0].name, 'B');
      expect(unchecked[1].name, 'A');
      expect(unchecked[2].name, 'C');
    });

    test('reorderChecked moves item within checked items', () {
      final checklist = Checklist(
        name: 'Groceries',
        items: [
          ChecklistItem(name: 'A', isChecked: false),
          ChecklistItem(name: 'X', isChecked: true),
          ChecklistItem(name: 'Y', isChecked: true),
          ChecklistItem(name: 'Z', isChecked: true),
        ],
      );

      final updated = checklist.reorderChecked(0, 2);
      final checked = updated.checkedItems;

      expect(checked[0].name, 'Y');
      expect(checked[1].name, 'X');
      expect(checked[2].name, 'Z');
    });

    test('copyWith can update name', () {
      final checklist = Checklist(name: 'Groceries');

      final renamed = checklist.copyWith(name: 'Shopping');

      expect(renamed.name, 'Shopping');
    });

    test('findDuplicateAndUncheck returns updated checklist if duplicate exists', () {
      final checklist = Checklist(
        name: 'Groceries',
        items: [ChecklistItem(name: 'Milk', isChecked: true)],
      );

      final result = checklist.findDuplicateAndUncheck('milk');

      expect(result, isNotNull);
      expect(result!.items[0].isChecked, false);
    });

    test('findDuplicateAndUncheck returns null if no duplicate', () {
      final checklist = Checklist(
        name: 'Groceries',
        items: [ChecklistItem(name: 'Milk')],
      );

      final result = checklist.findDuplicateAndUncheck('Bread');

      expect(result, isNull);
    });

    test('toJson returns correct map', () {
      final checklist = Checklist(
        name: 'Groceries',
        items: [ChecklistItem(name: 'Milk')],
      );

      final json = checklist.toJson();

      expect(json['name'], 'Groceries');
      expect(json['items'], isA<List>());
      expect(json['items'].length, 1);
    });

    test('fromJson creates correct instance', () {
      final json = {
        'name': 'Groceries',
        'items': [
          {'name': 'Milk', 'isChecked': false}
        ],
      };

      final checklist = Checklist.fromJson(json);

      expect(checklist.name, 'Groceries');
      expect(checklist.items.length, 1);
      expect(checklist.items[0].name, 'Milk');
    });
  });
}
