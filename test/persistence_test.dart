import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopping_list_app/main.dart';

void main() {
  group('Data Persistence', () {
    setUp(() async {
      // Reset SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    group('Save Data', () {
      test('should save shopping lists to SharedPreferences when adding list', () async {
        final appState = ShoppingAppState();
        await Future.delayed(const Duration(milliseconds: 10));
        
        appState.addShoppingList('Test List');
        
        // Wait for async save operation
        await Future.delayed(const Duration(milliseconds: 10));
        
        final prefs = await SharedPreferences.getInstance();
        final savedData = prefs.getString('shopping_lists');
        expect(savedData, isNotNull);
        
        final jsonList = json.decode(savedData!) as List<dynamic>;
        expect(jsonList.length, 1);
        expect(jsonList[0]['name'], 'Test List');
      });

      test('should save shopping lists with Swedish characters', () async {
        final appState = ShoppingAppState();
        await Future.delayed(const Duration(milliseconds: 10));
        
        appState.addShoppingList('Veckohandling för familjen');
        
        await Future.delayed(const Duration(milliseconds: 10));
        
        final prefs = await SharedPreferences.getInstance();
        final savedData = prefs.getString('shopping_lists');
        final jsonList = json.decode(savedData!) as List<dynamic>;
        expect(jsonList[0]['name'], 'Veckohandling för familjen');
      });

      test('should save items when adding to list', () async {
        final appState = ShoppingAppState();
        await Future.delayed(const Duration(milliseconds: 10));
        
        appState.addShoppingList('Test List');
        final listId = appState.shoppingLists[0].id;
        appState.addItemToList(listId, 'Test Item');
        
        await Future.delayed(const Duration(milliseconds: 10));
        
        final prefs = await SharedPreferences.getInstance();
        final savedData = prefs.getString('shopping_lists');
        final jsonList = json.decode(savedData!) as List<dynamic>;
        final items = jsonList[0]['items'] as List<dynamic>;
        
        expect(items.length, 1);
        expect(items[0]['name'], 'Test Item');
        expect(items[0]['isCompleted'], false);
      });

      test('should save items with Swedish characters', () async {
        final appState = ShoppingAppState();
        await Future.delayed(const Duration(milliseconds: 10));
        
        appState.addShoppingList('Test List');
        final listId = appState.shoppingLists[0].id;
        appState.addItemToList(listId, 'mjölk och äpplen');
        
        await Future.delayed(const Duration(milliseconds: 10));
        
        final prefs = await SharedPreferences.getInstance();
        final savedData = prefs.getString('shopping_lists');
        final jsonList = json.decode(savedData!) as List<dynamic>;
        final items = jsonList[0]['items'] as List<dynamic>;
        
        expect(items[0]['name'], 'mjölk och äpplen');
      });

      test('should save completion status changes', () async {
        final appState = ShoppingAppState();
        await Future.delayed(const Duration(milliseconds: 10));
        
        appState.addShoppingList('Test List');
        final listId = appState.shoppingLists[0].id;
        appState.addItemToList(listId, 'Test Item');
        final itemId = appState.shoppingLists[0].items[0].id;
        
        appState.toggleItemCompletion(listId, itemId);
        
        await Future.delayed(const Duration(milliseconds: 10));
        
        final prefs = await SharedPreferences.getInstance();
        final savedData = prefs.getString('shopping_lists');
        final jsonList = json.decode(savedData!) as List<dynamic>;
        final items = jsonList[0]['items'] as List<dynamic>;
        
        expect(items[0]['isCompleted'], true);
      });

      test('should save reordered items', () async {
        final appState = ShoppingAppState();
        await Future.delayed(const Duration(milliseconds: 10));
        
        appState.addShoppingList('Test List');
        final listId = appState.shoppingLists[0].id;
        appState.addItemToList(listId, 'Item 1');
        appState.addItemToList(listId, 'Item 2');
        appState.addItemToList(listId, 'Item 3');
        
        appState.reorderItems(listId, 0, 3);
        
        await Future.delayed(const Duration(milliseconds: 10));
        
        final prefs = await SharedPreferences.getInstance();
        final savedData = prefs.getString('shopping_lists');
        final jsonList = json.decode(savedData!) as List<dynamic>;
        final items = jsonList[0]['items'] as List<dynamic>;
        
        expect(items[0]['name'], 'Item 2');
        expect(items[1]['name'], 'Item 3');
        expect(items[2]['name'], 'Item 1');
      });

      test('should save after deleting items', () async {
        final appState = ShoppingAppState();
        await Future.delayed(const Duration(milliseconds: 10));
        
        appState.addShoppingList('Test List');
        final listId = appState.shoppingLists[0].id;
        appState.addItemToList(listId, 'Item 1');
        appState.addItemToList(listId, 'Item 2');
        
        final item1Id = appState.shoppingLists[0].items[0].id;
        appState.deleteItemFromList(listId, item1Id);
        
        await Future.delayed(const Duration(milliseconds: 10));
        
        final prefs = await SharedPreferences.getInstance();
        final savedData = prefs.getString('shopping_lists');
        final jsonList = json.decode(savedData!) as List<dynamic>;
        final items = jsonList[0]['items'] as List<dynamic>;
        
        expect(items.length, 1);
        expect(items[0]['name'], 'Item 2');
      });

      test('should save after deleting shopping lists', () async {
        final appState = ShoppingAppState();
        await Future.delayed(const Duration(milliseconds: 10));
        
        appState.addShoppingList('List 1');
        appState.addShoppingList('List 2');
        
        final list1Id = appState.shoppingLists[0].id;
        appState.deleteShoppingList(list1Id);
        
        await Future.delayed(const Duration(milliseconds: 10));
        
        final prefs = await SharedPreferences.getInstance();
        final savedData = prefs.getString('shopping_lists');
        final jsonList = json.decode(savedData!) as List<dynamic>;
        
        expect(jsonList.length, 1);
        expect(jsonList[0]['name'], 'List 2');
      });
    });

    group('Load Data', () {
      test('should load shopping lists from SharedPreferences on initialization', () async {
        // Pre-populate SharedPreferences
        final testData = [
          {
            'id': 'list1',
            'name': 'Loaded List',
            'createdAt': '2024-01-15T10:30:00.000',
            'items': [
              {'id': '1', 'name': 'Loaded Item', 'isCompleted': true},
            ],
          },
        ];
        
        SharedPreferences.setMockInitialValues({
          'shopping_lists': json.encode(testData),
        });
        
        final appState = ShoppingAppState();
        await Future.delayed(const Duration(milliseconds: 10));
        
        expect(appState.shoppingLists.length, 1);
        expect(appState.shoppingLists[0].name, 'Loaded List');
        expect(appState.shoppingLists[0].items.length, 1);
        expect(appState.shoppingLists[0].items[0].name, 'Loaded Item');
        expect(appState.shoppingLists[0].items[0].isCompleted, true);
      });

      test('should load shopping lists with Swedish characters', () async {
        final testData = [
          {
            'id': 'list1',
            'name': 'Handlingslista med åäö',
            'createdAt': '2024-01-15T10:30:00.000',
            'items': [
              {'id': '1', 'name': 'mjölk och äpplen', 'isCompleted': false},
            ],
          },
        ];
        
        SharedPreferences.setMockInitialValues({
          'shopping_lists': json.encode(testData),
        });
        
        final appState = ShoppingAppState();
        await Future.delayed(const Duration(milliseconds: 10));
        
        expect(appState.shoppingLists[0].name, 'Handlingslista med åäö');
        expect(appState.shoppingLists[0].items[0].name, 'mjölk och äpplen');
      });

      test('should load multiple shopping lists with multiple items', () async {
        final testData = [
          {
            'id': 'list1',
            'name': 'List 1',
            'createdAt': '2024-01-15T10:30:00.000',
            'items': [
              {'id': '1', 'name': 'Item 1', 'isCompleted': false},
              {'id': '2', 'name': 'Item 2', 'isCompleted': true},
            ],
          },
          {
            'id': 'list2',
            'name': 'List 2',
            'createdAt': '2024-01-16T11:00:00.000',
            'items': [
              {'id': '3', 'name': 'Item 3', 'isCompleted': false},
            ],
          },
        ];
        
        SharedPreferences.setMockInitialValues({
          'shopping_lists': json.encode(testData),
        });
        
        final appState = ShoppingAppState();
        await Future.delayed(const Duration(milliseconds: 10));
        
        expect(appState.shoppingLists.length, 2);
        expect(appState.shoppingLists[0].name, 'List 1');
        expect(appState.shoppingLists[0].items.length, 2);
        expect(appState.shoppingLists[1].name, 'List 2');
        expect(appState.shoppingLists[1].items.length, 1);
      });

      test('should handle empty SharedPreferences gracefully', () async {
        SharedPreferences.setMockInitialValues({});
        
        final appState = ShoppingAppState();
        await Future.delayed(const Duration(milliseconds: 10));
        
        expect(appState.shoppingLists, isEmpty);
      });

      test('should handle corrupted data in SharedPreferences gracefully', () async {
        SharedPreferences.setMockInitialValues({
          'shopping_lists': 'invalid json data',
        });
        
        final appState = ShoppingAppState();
        await Future.delayed(const Duration(milliseconds: 10));
        
        expect(appState.shoppingLists, isEmpty);
      });

      test('should preserve creation dates when loading', () async {
        final testDate = DateTime(2024, 1, 15, 10, 30);
        final testData = [
          {
            'id': 'list1',
            'name': 'Test List',
            'createdAt': testDate.toIso8601String(),
            'items': [],
          },
        ];
        
        SharedPreferences.setMockInitialValues({
          'shopping_lists': json.encode(testData),
        });
        
        final appState = ShoppingAppState();
        await Future.delayed(const Duration(milliseconds: 10));
        
        expect(appState.shoppingLists[0].createdAt, testDate);
      });
    });

    group('Data Persistence Integration', () {
      test('should maintain data across app state recreation', () async {
        // Create first app state and add data
        final appState1 = ShoppingAppState();
        await Future.delayed(const Duration(milliseconds: 10));
        
        appState1.addShoppingList('Persistent List');
        final listId = appState1.shoppingLists[0].id;
        appState1.addItemToList(listId, 'Persistent Item');
        
        await Future.delayed(const Duration(milliseconds: 10));
        
        // Create second app state (simulating app restart)
        final appState2 = ShoppingAppState();
        await Future.delayed(const Duration(milliseconds: 10));
        
        expect(appState2.shoppingLists.length, 1);
        expect(appState2.shoppingLists[0].name, 'Persistent List');
        expect(appState2.shoppingLists[0].items.length, 1);
        expect(appState2.shoppingLists[0].items[0].name, 'Persistent Item');
      });

      test('should maintain Swedish characters across app state recreation', () async {
        final appState1 = ShoppingAppState();
        await Future.delayed(const Duration(milliseconds: 10));
        
        appState1.addShoppingList('Handlingslista åäö');
        final listId = appState1.shoppingLists[0].id;
        appState1.addItemToList(listId, 'mjölk och kött');
        
        await Future.delayed(const Duration(milliseconds: 10));
        
        final appState2 = ShoppingAppState();
        await Future.delayed(const Duration(milliseconds: 10));
        
        expect(appState2.shoppingLists[0].name, 'Handlingslista åäö');
        expect(appState2.shoppingLists[0].items[0].name, 'mjölk och kött');
      });

      test('should maintain item order across app state recreation', () async {
        final appState1 = ShoppingAppState();
        await Future.delayed(const Duration(milliseconds: 10));
        
        appState1.addShoppingList('Order Test');
        final listId = appState1.shoppingLists[0].id;
        appState1.addItemToList(listId, 'First');
        appState1.addItemToList(listId, 'Second');
        appState1.addItemToList(listId, 'Third');
        
        // Reorder items
        appState1.reorderItems(listId, 0, 3);
        
        await Future.delayed(const Duration(milliseconds: 10));
        
        final appState2 = ShoppingAppState();
        await Future.delayed(const Duration(milliseconds: 10));
        
        expect(appState2.shoppingLists[0].items[0].name, 'Second');
        expect(appState2.shoppingLists[0].items[1].name, 'Third');
        expect(appState2.shoppingLists[0].items[2].name, 'First');
      });

      test('should maintain completion status across app state recreation', () async {
        final appState1 = ShoppingAppState();
        await Future.delayed(const Duration(milliseconds: 10));
        
        appState1.addShoppingList('Completion Test');
        final listId = appState1.shoppingLists[0].id;
        appState1.addItemToList(listId, 'Completed Item');
        appState1.addItemToList(listId, 'Incomplete Item');
        
        final completedItemId = appState1.shoppingLists[0].items[0].id;
        appState1.toggleItemCompletion(listId, completedItemId);
        
        await Future.delayed(const Duration(milliseconds: 10));
        
        final appState2 = ShoppingAppState();
        await Future.delayed(const Duration(milliseconds: 10));
        
        // After sorting: incomplete items come first, completed items at bottom
        expect(appState2.shoppingLists[0].items[0].isCompleted, false);
        expect(appState2.shoppingLists[0].items[0].name, 'Incomplete Item');
        expect(appState2.shoppingLists[0].items[1].isCompleted, true);
        expect(appState2.shoppingLists[0].items[1].name, 'Completed Item');
      });
    });
  });
}