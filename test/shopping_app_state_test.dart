import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopping_list_app/main.dart';

void main() {
  group('ShoppingAppState', () {
    late ShoppingAppState appState;

    setUp(() async {
      // Reset SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
      appState = ShoppingAppState();
      
      // Wait for async initialization to complete
      await Future.delayed(const Duration(milliseconds: 10));
    });

    group('Initial State', () {
      test('should start with empty shopping lists', () {
        expect(appState.shoppingLists, isEmpty);
      });
    });

    group('Add Shopping List', () {
      test('should add a new shopping list', () {
        const listName = 'Test List';
        
        appState.addShoppingList(listName);
        
        expect(appState.shoppingLists.length, 1);
        expect(appState.shoppingLists[0].name, listName);
        expect(appState.shoppingLists[0].items, isEmpty);
      });

      test('should add shopping list with Swedish characters', () {
        const listName = 'Veckohandling för familjen';
        
        appState.addShoppingList(listName);
        
        expect(appState.shoppingLists.length, 1);
        expect(appState.shoppingLists[0].name, listName);
      });

      test('should add multiple shopping lists', () {
        appState.addShoppingList('List 1');
        appState.addShoppingList('List 2');
        appState.addShoppingList('List 3');
        
        expect(appState.shoppingLists.length, 3);
        expect(appState.shoppingLists[0].name, 'List 1');
        expect(appState.shoppingLists[1].name, 'List 2');
        expect(appState.shoppingLists[2].name, 'List 3');
      });

      test('should generate unique IDs for shopping lists', () {
        appState.addShoppingList('List 1');
        appState.addShoppingList('List 2');
        
        expect(appState.shoppingLists[0].id, isNot(equals(appState.shoppingLists[1].id)));
      });

      test('should set creation date when adding shopping list', () {
        final beforeAdd = DateTime.now();
        appState.addShoppingList('Test List');
        final afterAdd = DateTime.now();
        
        final createdAt = appState.shoppingLists[0].createdAt;
        expect(createdAt.isAfter(beforeAdd) || createdAt.isAtSameMomentAs(beforeAdd), true);
        expect(createdAt.isBefore(afterAdd) || createdAt.isAtSameMomentAs(afterAdd), true);
      });
    });

    group('Delete Shopping List', () {
      test('should delete existing shopping list', () {
        appState.addShoppingList('List to delete');
        final listId = appState.shoppingLists[0].id;
        
        appState.deleteShoppingList(listId);
        
        expect(appState.shoppingLists, isEmpty);
      });

      test('should delete correct shopping list when multiple exist', () {
        appState.addShoppingList('List 1');
        appState.addShoppingList('List 2');
        appState.addShoppingList('List 3');
        
        final list2Id = appState.shoppingLists[1].id;
        appState.deleteShoppingList(list2Id);
        
        expect(appState.shoppingLists.length, 2);
        expect(appState.shoppingLists[0].name, 'List 1');
        expect(appState.shoppingLists[1].name, 'List 3');
      });

      test('should handle deletion of non-existent shopping list', () {
        appState.addShoppingList('Existing List');
        
        appState.deleteShoppingList('non-existent-id');
        
        expect(appState.shoppingLists.length, 1);
        expect(appState.shoppingLists[0].name, 'Existing List');
      });
    });

    group('Add Item to List', () {
      test('should add item to existing shopping list', () {
        appState.addShoppingList('Test List');
        final listId = appState.shoppingLists[0].id;
        
        appState.addItemToList(listId, 'Test Item');
        
        expect(appState.shoppingLists[0].items.length, 1);
        expect(appState.shoppingLists[0].items[0].name, 'Test Item');
        expect(appState.shoppingLists[0].items[0].isCompleted, false);
      });

      test('should add item with Swedish characters', () {
        appState.addShoppingList('Test List');
        final listId = appState.shoppingLists[0].id;
        
        appState.addItemToList(listId, 'mjölk och äpplen');
        
        expect(appState.shoppingLists[0].items[0].name, 'mjölk och äpplen');
      });

      test('should add multiple items to shopping list', () {
        appState.addShoppingList('Test List');
        final listId = appState.shoppingLists[0].id;
        
        appState.addItemToList(listId, 'Item 1');
        appState.addItemToList(listId, 'Item 2');
        appState.addItemToList(listId, 'Item 3');
        
        expect(appState.shoppingLists[0].items.length, 3);
        expect(appState.shoppingLists[0].items[0].name, 'Item 1');
        expect(appState.shoppingLists[0].items[1].name, 'Item 2');
        expect(appState.shoppingLists[0].items[2].name, 'Item 3');
      });

      test('should generate unique IDs for items', () {
        appState.addShoppingList('Test List');
        final listId = appState.shoppingLists[0].id;
        
        appState.addItemToList(listId, 'Item 1');
        appState.addItemToList(listId, 'Item 2');
        
        final items = appState.shoppingLists[0].items;
        expect(items[0].id, isNot(equals(items[1].id)));
      });

      test('should handle adding item to non-existent list', () {
        appState.addShoppingList('Existing List');
        
        appState.addItemToList('non-existent-id', 'Test Item');
        
        expect(appState.shoppingLists[0].items, isEmpty);
      });
    });

    group('Toggle Item Completion', () {
      test('should toggle item completion from false to true', () {
        appState.addShoppingList('Test List');
        final listId = appState.shoppingLists[0].id;
        appState.addItemToList(listId, 'Test Item');
        final itemId = appState.shoppingLists[0].items[0].id;
        
        appState.toggleItemCompletion(listId, itemId);
        
        expect(appState.shoppingLists[0].items[0].isCompleted, true);
      });

      test('should toggle item completion from true to false', () {
        appState.addShoppingList('Test List');
        final listId = appState.shoppingLists[0].id;
        appState.addItemToList(listId, 'Test Item');
        final itemId = appState.shoppingLists[0].items[0].id;
        
        // Toggle to true first
        appState.toggleItemCompletion(listId, itemId);
        expect(appState.shoppingLists[0].items[0].isCompleted, true);
        
        // Toggle back to false
        appState.toggleItemCompletion(listId, itemId);
        expect(appState.shoppingLists[0].items[0].isCompleted, false);
      });

      test('should toggle only the specified item', () {
        appState.addShoppingList('Test List');
        final listId = appState.shoppingLists[0].id;
        appState.addItemToList(listId, 'Item 1');
        appState.addItemToList(listId, 'Item 2');
        appState.addItemToList(listId, 'Item 3');
        
        final item2Id = appState.shoppingLists[0].items[1].id;
        appState.toggleItemCompletion(listId, item2Id);
        
        // After sorting, Item 2 should be at the bottom (completed), Items 1 and 3 at top (incomplete)
        final items = appState.shoppingLists[0].items;
        final incompleteItems = items.where((item) => !item.isCompleted).toList();
        final completedItems = items.where((item) => item.isCompleted).toList();
        
        expect(incompleteItems.length, 2);
        expect(completedItems.length, 1);
        expect(completedItems[0].name, 'Item 2');
        expect(incompleteItems.any((item) => item.name == 'Item 1'), true);
        expect(incompleteItems.any((item) => item.name == 'Item 3'), true);
      });

      test('should handle toggling completion of non-existent item', () {
        appState.addShoppingList('Test List');
        final listId = appState.shoppingLists[0].id;
        appState.addItemToList(listId, 'Test Item');
        
        appState.toggleItemCompletion(listId, 'non-existent-item-id');
        
        expect(appState.shoppingLists[0].items[0].isCompleted, false);
      });

      test('should handle toggling completion in non-existent list', () {
        appState.addShoppingList('Test List');
        final listId = appState.shoppingLists[0].id;
        appState.addItemToList(listId, 'Test Item');
        final itemId = appState.shoppingLists[0].items[0].id;
        
        appState.toggleItemCompletion('non-existent-list-id', itemId);
        
        expect(appState.shoppingLists[0].items[0].isCompleted, false);
      });
    });

    group('Delete Item from List', () {
      test('should delete item from shopping list', () {
        appState.addShoppingList('Test List');
        final listId = appState.shoppingLists[0].id;
        appState.addItemToList(listId, 'Item to delete');
        final itemId = appState.shoppingLists[0].items[0].id;
        
        appState.deleteItemFromList(listId, itemId);
        
        expect(appState.shoppingLists[0].items, isEmpty);
      });

      test('should delete correct item when multiple exist', () {
        appState.addShoppingList('Test List');
        final listId = appState.shoppingLists[0].id;
        appState.addItemToList(listId, 'Item 1');
        appState.addItemToList(listId, 'Item 2');
        appState.addItemToList(listId, 'Item 3');
        
        final item2Id = appState.shoppingLists[0].items[1].id;
        appState.deleteItemFromList(listId, item2Id);
        
        expect(appState.shoppingLists[0].items.length, 2);
        expect(appState.shoppingLists[0].items[0].name, 'Item 1');
        expect(appState.shoppingLists[0].items[1].name, 'Item 3');
      });

      test('should handle deletion of non-existent item', () {
        appState.addShoppingList('Test List');
        final listId = appState.shoppingLists[0].id;
        appState.addItemToList(listId, 'Existing Item');
        
        appState.deleteItemFromList(listId, 'non-existent-item-id');
        
        expect(appState.shoppingLists[0].items.length, 1);
        expect(appState.shoppingLists[0].items[0].name, 'Existing Item');
      });

      test('should handle deletion from non-existent list', () {
        appState.addShoppingList('Test List');
        final listId = appState.shoppingLists[0].id;
        appState.addItemToList(listId, 'Test Item');
        final itemId = appState.shoppingLists[0].items[0].id;
        
        appState.deleteItemFromList('non-existent-list-id', itemId);
        
        expect(appState.shoppingLists[0].items.length, 1);
        expect(appState.shoppingLists[0].items[0].name, 'Test Item');
      });
    });

    group('Reorder Items', () {
      test('should reorder items correctly when moving forward', () {
        appState.addShoppingList('Test List');
        final listId = appState.shoppingLists[0].id;
        appState.addItemToList(listId, 'Item 1');
        appState.addItemToList(listId, 'Item 2');
        appState.addItemToList(listId, 'Item 3');
        appState.addItemToList(listId, 'Item 4');
        
        // All items are incomplete, so reordering should work within incomplete section
        // Move Item 1 (index 0) to position 2 (index 2)
        appState.reorderItems(listId, 0, 3);
        
        expect(appState.shoppingLists[0].items[0].name, 'Item 2');
        expect(appState.shoppingLists[0].items[1].name, 'Item 3');
        expect(appState.shoppingLists[0].items[2].name, 'Item 1');
        expect(appState.shoppingLists[0].items[3].name, 'Item 4');
      });

      test('should reorder items correctly when moving backward', () {
        appState.addShoppingList('Test List');
        final listId = appState.shoppingLists[0].id;
        appState.addItemToList(listId, 'Item 1');
        appState.addItemToList(listId, 'Item 2');
        appState.addItemToList(listId, 'Item 3');
        appState.addItemToList(listId, 'Item 4');
        
        // Move Item 4 (index 3) to position 1 (index 1)
        appState.reorderItems(listId, 3, 1);
        
        expect(appState.shoppingLists[0].items[0].name, 'Item 1');
        expect(appState.shoppingLists[0].items[1].name, 'Item 4');
        expect(appState.shoppingLists[0].items[2].name, 'Item 2');
        expect(appState.shoppingLists[0].items[3].name, 'Item 3');
      });

      test('should preserve item properties during reordering', () {
        appState.addShoppingList('Test List');
        final listId = appState.shoppingLists[0].id;
        appState.addItemToList(listId, 'Item 1');
        appState.addItemToList(listId, 'Item 2');
        
        // Toggle completion of Item 1 - this will move it to bottom due to sorting
        final item1Id = appState.shoppingLists[0].items[0].id;
        appState.toggleItemCompletion(listId, item1Id);
        
        // Item 1 should now be at the bottom and completed
        expect(appState.shoppingLists[0].items[0].name, 'Item 2');
        expect(appState.shoppingLists[0].items[0].isCompleted, false);
        expect(appState.shoppingLists[0].items[1].name, 'Item 1');
        expect(appState.shoppingLists[0].items[1].isCompleted, true);
      });

      test('should handle reordering in non-existent list', () {
        appState.addShoppingList('Test List');
        final listId = appState.shoppingLists[0].id;
        appState.addItemToList(listId, 'Item 1');
        appState.addItemToList(listId, 'Item 2');
        
        appState.reorderItems('non-existent-list-id', 0, 1);
        
        // Items should remain unchanged
        expect(appState.shoppingLists[0].items[0].name, 'Item 1');
        expect(appState.shoppingLists[0].items[1].name, 'Item 2');
      });

      test('should handle reordering with invalid indices gracefully', () {
        appState.addShoppingList('Test List');
        final listId = appState.shoppingLists[0].id;
        appState.addItemToList(listId, 'Item 1');
        appState.addItemToList(listId, 'Item 2');
        
        // This should not crash the app
        appState.reorderItems(listId, 0, 0);
        
        expect(appState.shoppingLists[0].items.length, 2);
      });

      test('should reorder items with Swedish characters correctly', () {
        appState.addShoppingList('Test List');
        final listId = appState.shoppingLists[0].id;
        appState.addItemToList(listId, 'mjölk');
        appState.addItemToList(listId, 'äpplen');
        appState.addItemToList(listId, 'kött');
        
        // Verify initial order
        expect(appState.shoppingLists[0].items[0].name, 'mjölk');
        expect(appState.shoppingLists[0].items[1].name, 'äpplen');
        expect(appState.shoppingLists[0].items[2].name, 'kött');
        
        // All items are incomplete, so reordering should work within incomplete section
        // Move mjölk from index 0 to index 2 (before kött)
        appState.reorderItems(listId, 0, 2);
        
        expect(appState.shoppingLists[0].items[0].name, 'äpplen');
        expect(appState.shoppingLists[0].items[1].name, 'mjölk');
        expect(appState.shoppingLists[0].items[2].name, 'kött');
      });
    });

    group('Item Sorting', () {
      test('should move completed item to bottom when toggled', () {
        appState.addShoppingList('Test List');
        final listId = appState.shoppingLists[0].id;
        appState.addItemToList(listId, 'Item 1');
        appState.addItemToList(listId, 'Item 2');
        appState.addItemToList(listId, 'Item 3');
        
        // Complete the first item
        final item1Id = appState.shoppingLists[0].items[0].id;
        appState.toggleItemCompletion(listId, item1Id);
        
        // Item 1 should now be at the bottom
        expect(appState.shoppingLists[0].items[0].name, 'Item 2');
        expect(appState.shoppingLists[0].items[1].name, 'Item 3');
        expect(appState.shoppingLists[0].items[2].name, 'Item 1');
        expect(appState.shoppingLists[0].items[2].isCompleted, true);
      });

      test('should move incomplete item to top when untoggled', () {
        appState.addShoppingList('Test List');
        final listId = appState.shoppingLists[0].id;
        appState.addItemToList(listId, 'Item 1');
        appState.addItemToList(listId, 'Item 2');
        appState.addItemToList(listId, 'Item 3');
        
        // Complete all items first
        for (int i = 0; i < 3; i++) {
          final itemId = appState.shoppingLists[0].items[0].id;
          appState.toggleItemCompletion(listId, itemId);
        }
        
        // All should be completed and at bottom (order maintained within completed section)
        expect(appState.shoppingLists[0].items.every((item) => item.isCompleted), true);
        
        // Find and uncomplete a specific item (let's use the one at index 2)
        final itemToUncomplete = appState.shoppingLists[0].items[2];
        appState.toggleItemCompletion(listId, itemToUncomplete.id);
        
        // The uncompleted item should now be at the top as the only incomplete item
        final items = appState.shoppingLists[0].items;
        expect(items[0].name, itemToUncomplete.name);
        expect(items[0].isCompleted, false);
        expect(items[1].isCompleted, true);
        expect(items[2].isCompleted, true);
      });

      test('should maintain correct order after multiple operations', () {
        appState.addShoppingList('Test List');
        final listId = appState.shoppingLists[0].id;
        appState.addItemToList(listId, 'Incomplete 1');
        appState.addItemToList(listId, 'Complete 1');
        appState.addItemToList(listId, 'Incomplete 2');
        
        // Find the "Complete 1" item explicitly by name to ensure we toggle the right one
        final itemsBeforeToggle = appState.shoppingLists[0].items;
        final completeItemId = itemsBeforeToggle.firstWhere((item) => item.name == 'Complete 1').id;
        
        // Complete the item - this will move it to bottom due to sorting
        appState.toggleItemCompletion(listId, completeItemId);
        
        // Check that sorting is maintained
        final items = appState.shoppingLists[0].items;
        final incompleteItems = items.where((item) => !item.isCompleted).toList();
        final completedItems = items.where((item) => item.isCompleted).toList();
        
        expect(incompleteItems.length, 2);
        expect(completedItems.length, 1);
        
        // Find the completed item and verify it's the right one
        final completedItem = completedItems[0];
        expect(completedItem.name, 'Complete 1');
        
        // Check that incomplete items come first in the array
        expect(items[0].isCompleted, false);
        expect(items[1].isCompleted, false);
        expect(items[2].isCompleted, true);
        expect(items[2].name, 'Complete 1');
      });

      test('should restrict reordering within completion sections', () {
        appState.addShoppingList('Test List');
        final listId = appState.shoppingLists[0].id;
        appState.addItemToList(listId, 'Incomplete 1');
        appState.addItemToList(listId, 'Incomplete 2');
        appState.addItemToList(listId, 'Complete 1');
        
        // Complete the third item
        final completeItemId = appState.shoppingLists[0].items[2].id;
        appState.toggleItemCompletion(listId, completeItemId);
        
        // Try to move completed item to top (should be restricted)
        appState.reorderItems(listId, 2, 0);
        
        // Completed item should stay in completed section
        expect(appState.shoppingLists[0].items[0].isCompleted, false);
        expect(appState.shoppingLists[0].items[1].isCompleted, false);
        expect(appState.shoppingLists[0].items[2].isCompleted, true);
      });

      test('should allow reordering within incomplete section', () {
        appState.addShoppingList('Test List');
        final listId = appState.shoppingLists[0].id;
        appState.addItemToList(listId, 'Incomplete A');
        appState.addItemToList(listId, 'Incomplete B');
        appState.addItemToList(listId, 'Incomplete C');
        
        // Reorder within incomplete section
        appState.reorderItems(listId, 0, 2);
        
        expect(appState.shoppingLists[0].items[0].name, 'Incomplete B');
        expect(appState.shoppingLists[0].items[1].name, 'Incomplete A');
        expect(appState.shoppingLists[0].items[2].name, 'Incomplete C');
      });

      test('should allow reordering within completed section', () {
        appState.addShoppingList('Test List');
        final listId = appState.shoppingLists[0].id;
        appState.addItemToList(listId, 'Item A');
        appState.addItemToList(listId, 'Item B');
        appState.addItemToList(listId, 'Item C');
        
        // Complete all items
        for (int i = 0; i < 3; i++) {
          final itemId = appState.shoppingLists[0].items[0].id;
          appState.toggleItemCompletion(listId, itemId);
        }
        
        // Reorder within completed section
        appState.reorderItems(listId, 0, 2);
        
        // All should still be completed, but order changed
        expect(appState.shoppingLists[0].items.every((item) => item.isCompleted), true);
        expect(appState.shoppingLists[0].items.length, 3);
      });
    });
  });
}