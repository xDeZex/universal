import 'package:flutter_test/flutter_test.dart';
import 'package:universal/models/shopping_list.dart';
import 'package:universal/models/shopping_item.dart';

void main() {
  group('ShoppingList', () {
    late DateTime testDate;
    late List<ShoppingItem> testItems;

    setUp(() {
      testDate = DateTime(2024, 1, 15, 10, 30);
      testItems = [
        const ShoppingItem(id: '1', name: 'Item 1', isCompleted: false),
        const ShoppingItem(id: '2', name: 'Item 2', isCompleted: true),
        const ShoppingItem(id: '3', name: 'Item 3', isCompleted: false),
      ];
    });

    test('should create ShoppingList with required fields', () {
      final list = ShoppingList(
        id: 'list1',
        name: 'Test List',
        items: testItems,
        createdAt: testDate,
      );

      expect(list.id, 'list1');
      expect(list.name, 'Test List');
      expect(list.items, testItems);
      expect(list.createdAt, testDate);
    });

    test('should handle Swedish characters in list name', () {
      final list = ShoppingList(
        id: 'list1',
        name: 'Handlingslista för veckan',
        items: [],
        createdAt: testDate,
      );

      expect(list.name, 'Handlingslista för veckan');
    });

    test('should calculate totalItems correctly', () {
      final list = ShoppingList(
        id: 'list1',
        name: 'Test List',
        items: testItems,
        createdAt: testDate,
      );

      expect(list.totalItems, 3);
    });

    test('should calculate totalItems correctly for empty list', () {
      final list = ShoppingList(
        id: 'list1',
        name: 'Empty List',
        items: [],
        createdAt: testDate,
      );

      expect(list.totalItems, 0);
    });

    test('should calculate completedItems correctly', () {
      final list = ShoppingList(
        id: 'list1',
        name: 'Test List',
        items: testItems,
        createdAt: testDate,
      );

      expect(list.completedItems, 1); // Only Item 2 is completed
    });

    test('should calculate completedItems correctly for empty list', () {
      final list = ShoppingList(
        id: 'list1',
        name: 'Empty List',
        items: [],
        createdAt: testDate,
      );

      expect(list.completedItems, 0);
    });

    test('should calculate isCompleted correctly when all items completed', () {
      final allCompletedItems = [
        const ShoppingItem(id: '1', name: 'Item 1', isCompleted: true),
        const ShoppingItem(id: '2', name: 'Item 2', isCompleted: true),
      ];

      final list = ShoppingList(
        id: 'list1',
        name: 'Completed List',
        items: allCompletedItems,
        createdAt: testDate,
      );

      expect(list.isCompleted, true);
    });

    test('should calculate isCompleted correctly when not all items completed', () {
      final list = ShoppingList(
        id: 'list1',
        name: 'Partial List',
        items: testItems,
        createdAt: testDate,
      );

      expect(list.isCompleted, false);
    });

    test('should calculate isCompleted correctly for empty list', () {
      final list = ShoppingList(
        id: 'list1',
        name: 'Empty List',
        items: [],
        createdAt: testDate,
      );

      expect(list.isCompleted, false); // Empty list is not completed
    });

    test('should create copy with updated fields using copyWith', () {
      final originalList = ShoppingList(
        id: 'list1',
        name: 'Original List',
        items: testItems,
        createdAt: testDate,
      );

      final updatedItems = [
        const ShoppingItem(id: '4', name: 'New Item', isCompleted: false),
      ];

      final updatedList = originalList.copyWith(
        name: 'Updated List',
        items: updatedItems,
      );

      expect(updatedList.id, 'list1'); // Unchanged
      expect(updatedList.name, 'Updated List');
      expect(updatedList.items, updatedItems);
      expect(updatedList.createdAt, testDate); // Unchanged
      
      // Original should be unchanged
      expect(originalList.name, 'Original List');
      expect(originalList.items, testItems);
    });

    test('should serialize to JSON correctly', () {
      final list = ShoppingList(
        id: 'list123',
        name: 'Test List',
        items: [
          const ShoppingItem(id: '1', name: 'Item 1', isCompleted: false),
          const ShoppingItem(id: '2', name: 'Item 2', isCompleted: true),
        ],
        createdAt: DateTime(2024, 1, 15, 10, 30),
      );

      final json = list.toJson();

      expect(json['id'], 'list123');
      expect(json['name'], 'Test List');
      expect(json['createdAt'], '2024-01-15T10:30:00.000');
      expect(json['items'], [
        {'id': '1', 'name': 'Item 1', 'isCompleted': false},
        {'id': '2', 'name': 'Item 2', 'isCompleted': true},
      ]);
    });

    test('should serialize Swedish characters to JSON correctly', () {
      final list = ShoppingList(
        id: 'list1',
        name: 'Veckohandling från ICA',
        items: [
          const ShoppingItem(id: '1', name: 'mjölk och äpplen', isCompleted: false),
        ],
        createdAt: testDate,
      );

      final json = list.toJson();

      expect(json['name'], 'Veckohandling från ICA');
      expect(json['items'][0]['name'], 'mjölk och äpplen');
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'id': 'list456',
        'name': 'Deserialized List',
        'createdAt': '2024-01-15T10:30:00.000',
        'items': [
          {'id': '1', 'name': 'Item 1', 'isCompleted': false},
          {'id': '2', 'name': 'Item 2', 'isCompleted': true},
        ],
      };

      final list = ShoppingList.fromJson(json);

      expect(list.id, 'list456');
      expect(list.name, 'Deserialized List');
      expect(list.createdAt, DateTime(2024, 1, 15, 10, 30));
      expect(list.items.length, 2);
      expect(list.items[0].name, 'Item 1');
      expect(list.items[0].isCompleted, false);
      expect(list.items[1].name, 'Item 2');
      expect(list.items[1].isCompleted, true);
    });

    test('should deserialize Swedish characters from JSON correctly', () {
      final json = {
        'id': 'list1',
        'name': 'Handlingslista med åäö',
        'createdAt': '2024-01-15T10:30:00.000',
        'items': [
          {'id': '1', 'name': 'kött och fågel', 'isCompleted': false},
        ],
      };

      final list = ShoppingList.fromJson(json);

      expect(list.name, 'Handlingslista med åäö');
      expect(list.items[0].name, 'kött och fågel');
    });

    test('should handle round-trip JSON serialization', () {
      final originalList = ShoppingList(
        id: 'roundtrip',
        name: 'Round-trip test åäö',
        items: [
          const ShoppingItem(id: '1', name: 'mjölk', isCompleted: true),
          const ShoppingItem(id: '2', name: 'äpplen', isCompleted: false),
        ],
        createdAt: DateTime(2024, 2, 20, 15, 45),
      );

      final json = originalList.toJson();
      final deserializedList = ShoppingList.fromJson(json);

      expect(deserializedList.id, originalList.id);
      expect(deserializedList.name, originalList.name);
      expect(deserializedList.createdAt, originalList.createdAt);
      expect(deserializedList.items.length, originalList.items.length);
      expect(deserializedList.totalItems, originalList.totalItems);
      expect(deserializedList.completedItems, originalList.completedItems);
      expect(deserializedList.isCompleted, originalList.isCompleted);
    });

    test('should handle empty items list in JSON serialization', () {
      final list = ShoppingList(
        id: 'empty',
        name: 'Empty List',
        items: [],
        createdAt: testDate,
      );

      final json = list.toJson();
      final deserializedList = ShoppingList.fromJson(json);

      expect(deserializedList.items, isEmpty);
      expect(deserializedList.totalItems, 0);
      expect(deserializedList.completedItems, 0);
      expect(deserializedList.isCompleted, false);
    });
  });
}