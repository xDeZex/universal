import 'package:flutter_test/flutter_test.dart';
import 'package:universal/models/shopping_item.dart';

void main() {
  group('ShoppingItem', () {
    test('should create ShoppingItem with required fields', () {
      const item = ShoppingItem(
        id: '1',
        name: 'Test Item',
      );

      expect(item.id, '1');
      expect(item.name, 'Test Item');
      expect(item.isCompleted, false);
    });

    test('should create ShoppingItem with isCompleted true', () {
      const item = ShoppingItem(
        id: '1',
        name: 'Test Item',
        isCompleted: true,
      );

      expect(item.isCompleted, true);
    });

    test('should handle Swedish characters correctly', () {
      const item = ShoppingItem(
        id: '1',
        name: 'mjölk och äpplen på köket',
      );

      expect(item.name, 'mjölk och äpplen på köket');
    });

    test('should create copy with updated fields using copyWith', () {
      const originalItem = ShoppingItem(
        id: '1',
        name: 'Test Item',
        isCompleted: false,
      );

      final updatedItem = originalItem.copyWith(
        isCompleted: true,
      );

      expect(updatedItem.id, '1');
      expect(updatedItem.name, 'Test Item');
      expect(updatedItem.isCompleted, true);
      expect(originalItem.isCompleted, false); // Original unchanged
    });

    test('should create copy with updated name using copyWith', () {
      const originalItem = ShoppingItem(
        id: '1',
        name: 'Test Item',
      );

      final updatedItem = originalItem.copyWith(
        name: 'Updated Item',
      );

      expect(updatedItem.name, 'Updated Item');
      expect(originalItem.name, 'Test Item'); // Original unchanged
    });

    test('should serialize to JSON correctly', () {
      const item = ShoppingItem(
        id: '123',
        name: 'Test Item',
        isCompleted: true,
      );

      final json = item.toJson();

      expect(json, {
        'id': '123',
        'name': 'Test Item',
        'isCompleted': true,
      });
    });

    test('should serialize Swedish characters to JSON correctly', () {
      const item = ShoppingItem(
        id: '1',
        name: 'mjölk och äpplen',
        isCompleted: false,
      );

      final json = item.toJson();

      expect(json['name'], 'mjölk och äpplen');
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'id': '456',
        'name': 'Deserialized Item',
        'isCompleted': true,
      };

      final item = ShoppingItem.fromJson(json);

      expect(item.id, '456');
      expect(item.name, 'Deserialized Item');
      expect(item.isCompleted, true);
    });

    test('should deserialize from JSON with missing isCompleted field', () {
      final json = {
        'id': '789',
        'name': 'Item without completion',
      };

      final item = ShoppingItem.fromJson(json);

      expect(item.id, '789');
      expect(item.name, 'Item without completion');
      expect(item.isCompleted, false); // Should default to false
    });

    test('should deserialize Swedish characters from JSON correctly', () {
      final json = {
        'id': '1',
        'name': 'kött och fågel från Åhléns',
        'isCompleted': false,
      };

      final item = ShoppingItem.fromJson(json);

      expect(item.name, 'kött och fågel från Åhléns');
    });

    test('should handle round-trip JSON serialization', () {
      const originalItem = ShoppingItem(
        id: '999',
        name: 'Round-trip test åäö',
        isCompleted: true,
      );

      final json = originalItem.toJson();
      final deserializedItem = ShoppingItem.fromJson(json);

      expect(deserializedItem.id, originalItem.id);
      expect(deserializedItem.name, originalItem.name);
      expect(deserializedItem.isCompleted, originalItem.isCompleted);
    });
  });
}