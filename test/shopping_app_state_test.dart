import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopping_list_app/providers/shopping_app_state.dart';
import 'package:shopping_list_app/models/weight_entry.dart';

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

      test('should preserve manual reordering without automatic sorting', () {
        appState.addShoppingList('Test List');
        final listId = appState.shoppingLists[0].id;
        appState.addItemToList(listId, 'First Item');
        appState.addItemToList(listId, 'Second Item');
        appState.addItemToList(listId, 'Third Item');
        
        // Verify initial order
        expect(appState.shoppingLists[0].items[0].name, 'First Item');
        expect(appState.shoppingLists[0].items[1].name, 'Second Item');
        expect(appState.shoppingLists[0].items[2].name, 'Third Item');
        
        // Manually reorder: move Third Item to first position
        appState.reorderItems(listId, 2, 0);
        
        // Verify the manual reordering is preserved
        expect(appState.shoppingLists[0].items[0].name, 'Third Item');
        expect(appState.shoppingLists[0].items[1].name, 'First Item');
        expect(appState.shoppingLists[0].items[2].name, 'Second Item');
        
        // All items should still be incomplete (not automatically sorted)
        expect(appState.shoppingLists[0].items.every((item) => !item.isCompleted), true);
        
        // Verify the custom order is maintained - no automatic sorting occurred
        expect(appState.shoppingLists[0].items[0].name, 'Third Item');
        expect(appState.shoppingLists[0].items[1].name, 'First Item');
        expect(appState.shoppingLists[0].items[2].name, 'Second Item');
      });

      test('should preserve reordering when mixing completed and incomplete items', () {
        appState.addShoppingList('Test List');
        final listId = appState.shoppingLists[0].id;
        appState.addItemToList(listId, 'Incomplete A');
        appState.addItemToList(listId, 'Incomplete B');
        appState.addItemToList(listId, 'Will Complete');
        
        // Complete the third item - this will trigger automatic sorting
        final itemToCompleteId = appState.shoppingLists[0].items[2].id;
        appState.toggleItemCompletion(listId, itemToCompleteId);
        
        // After completion, completed item should be at bottom
        expect(appState.shoppingLists[0].items[0].name, 'Incomplete A');
        expect(appState.shoppingLists[0].items[1].name, 'Incomplete B');
        expect(appState.shoppingLists[0].items[2].name, 'Will Complete');
        expect(appState.shoppingLists[0].items[2].isCompleted, true);
        
        // Now manually reorder within the incomplete section
        appState.reorderItems(listId, 0, 2); // Move Incomplete A to position after Incomplete B (index 2, which becomes 1 after adjustment)
        
        // Verify the manual reordering within incomplete section is preserved
        expect(appState.shoppingLists[0].items[0].name, 'Incomplete B');
        expect(appState.shoppingLists[0].items[1].name, 'Incomplete A');
        expect(appState.shoppingLists[0].items[2].name, 'Will Complete');
        expect(appState.shoppingLists[0].items[2].isCompleted, true);
        
        // Verify the completed item stays at bottom and incomplete order is preserved
        expect(appState.shoppingLists[0].items[0].isCompleted, false);
        expect(appState.shoppingLists[0].items[1].isCompleted, false);
        expect(appState.shoppingLists[0].items[2].isCompleted, true);
      });

      test('should correctly reorder items without double adjustment', () {
        appState.addShoppingList('Test List');
        final listId = appState.shoppingLists[0].id;
        appState.addItemToList(listId, 'First');
        appState.addItemToList(listId, 'Second');
        appState.addItemToList(listId, 'Third');
        
        // Simulate what the UI layer (_handleIncompleteItemReorder) now does:
        // When dragging First (index 0) down to position after Second (index 1),
        // the UI receives oldIndex=0, newIndex=2 from ReorderableList
        final oldIndex = 0;
        final newIndex = 2;
        
        // The fixed UI handler passes indices directly to business logic
        appState.reorderItems(listId, oldIndex, newIndex);
        
        // The business logic handles the standard Flutter reordering adjustment
        // Expected result: Second, First, Third (First should be at index 1)
        expect(appState.shoppingLists[0].items[0].name, 'Second');
        expect(appState.shoppingLists[0].items[1].name, 'First');
        expect(appState.shoppingLists[0].items[2].name, 'Third');
      });
    });

    group('Shopping List Reordering', () {
      test('should reorder shopping lists correctly when moving forward', () {
        appState.addShoppingList('List A');
        appState.addShoppingList('List B');
        appState.addShoppingList('List C');
        
        // Move List A (index 0) to position after List C (index 2)
        appState.reorderShoppingLists(0, 3);
        
        expect(appState.shoppingLists[0].name, 'List B');
        expect(appState.shoppingLists[1].name, 'List C');
        expect(appState.shoppingLists[2].name, 'List A');
      });

      test('should reorder shopping lists correctly when moving backward', () {
        appState.addShoppingList('List A');
        appState.addShoppingList('List B');
        appState.addShoppingList('List C');
        
        // Move List C (index 2) to position before List A (index 0)
        appState.reorderShoppingLists(2, 0);
        
        expect(appState.shoppingLists[0].name, 'List C');
        expect(appState.shoppingLists[1].name, 'List A');
        expect(appState.shoppingLists[2].name, 'List B');
      });

      test('should preserve shopping list properties during reordering', () {
        appState.addShoppingList('List A');
        appState.addShoppingList('List B');
        
        // Add items to first list to verify properties are preserved
        final listAId = appState.shoppingLists[0].id;
        appState.addItemToList(listAId, 'Item 1');
        appState.addItemToList(listAId, 'Item 2');
        
        // Reorder the lists
        appState.reorderShoppingLists(0, 2);
        
        // List A should now be at position 1 (index 1) and maintain its items
        expect(appState.shoppingLists[1].name, 'List A');
        expect(appState.shoppingLists[1].items.length, 2);
        expect(appState.shoppingLists[1].items[0].name, 'Item 1');
        expect(appState.shoppingLists[1].items[1].name, 'Item 2');
      });

      test('should handle reordering with Swedish characters correctly', () {
        appState.addShoppingList('Handlingslista A');
        appState.addShoppingList('Köplista B');
        appState.addShoppingList('Inköpslista C');
        
        // Move middle list to first position
        appState.reorderShoppingLists(1, 0);
        
        expect(appState.shoppingLists[0].name, 'Köplista B');
        expect(appState.shoppingLists[1].name, 'Handlingslista A');
        expect(appState.shoppingLists[2].name, 'Inköpslista C');
      });

      test('should handle edge case reordering gracefully', () {
        appState.addShoppingList('Only List');
        
        // Try to reorder when there's only one list (should not crash)
        appState.reorderShoppingLists(0, 0);
        
        expect(appState.shoppingLists.length, 1);
        expect(appState.shoppingLists[0].name, 'Only List');
      });
    });

    group('Workout Exercise Reordering', () {
      test('should correctly reorder exercises without double adjustment', () {
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        appState.addExerciseToWorkout(workoutId, 'First Exercise');
        appState.addExerciseToWorkout(workoutId, 'Second Exercise');
        appState.addExerciseToWorkout(workoutId, 'Third Exercise');
        
        // Simulate what the UI layer (_handleIncompleteExerciseReorder) now does:
        // When dragging First Exercise (index 0) down to position after Second Exercise (index 1),
        // the UI receives oldIndex=0, newIndex=2 from ReorderableList
        final oldIndex = 0;
        final newIndex = 2;
        
        // The fixed UI handler passes indices directly to business logic
        appState.reorderExercises(workoutId, oldIndex, newIndex);
        
        // The business logic handles the standard Flutter reordering adjustment
        // Expected result: Second Exercise, First Exercise, Third Exercise (First Exercise should be at index 1)
        expect(appState.workoutLists[0].exercises[0].name, 'Second Exercise');
        expect(appState.workoutLists[0].exercises[1].name, 'First Exercise');
        expect(appState.workoutLists[0].exercises[2].name, 'Third Exercise');
      });
    });

    group('Exercise Weight Tracking', () {
      test('should save weight for exercise correctly', () {
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        appState.addExerciseToWorkout(workoutId, 'Bench Press', weight: '80kg');
        final exerciseId = appState.workoutLists[0].exercises[0].id;
        
        // Save weight for today
        appState.saveWeightForExercise(workoutId, exerciseId, '85kg');
        
        final exercise = appState.workoutLists[0].exercises[0];
        expect(exercise.weightHistory.length, 1);
        expect(exercise.weightHistory[0].weight, '85kg');
        expect(exercise.weightHistory[0].date.year, DateTime.now().year);
        expect(exercise.weightHistory[0].date.month, DateTime.now().month);
        expect(exercise.weightHistory[0].date.day, DateTime.now().day);
      });

      test('should handle multiple weight saves for same exercise', () {
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        appState.addExerciseToWorkout(workoutId, 'Bench Press', weight: '80kg');
        final exerciseId = appState.workoutLists[0].exercises[0].id;
        
        // Save multiple weights
        appState.saveWeightForExercise(workoutId, exerciseId, '85kg');
        appState.saveWeightForExercise(workoutId, exerciseId, '87kg');
        appState.saveWeightForExercise(workoutId, exerciseId, '90kg');
        
        final exercise = appState.workoutLists[0].exercises[0];
        expect(exercise.weightHistory.length, 3);
        expect(exercise.weightHistory[0].weight, '85kg');
        expect(exercise.weightHistory[1].weight, '87kg');
        expect(exercise.weightHistory[2].weight, '90kg');
      });

      test('should save weight for exercise with complete exercise data', () {
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        appState.addExerciseToWorkout(
          workoutId, 
          'Bench Press',
          sets: '3',
          reps: '10',
          weight: '80kg',
          notes: 'Good form',
        );
        final exerciseId = appState.workoutLists[0].exercises[0].id;
        
        // Save weight for today
        appState.saveWeightForExercise(workoutId, exerciseId, '85kg');
        
        final exercise = appState.workoutLists[0].exercises[0];
        expect(exercise.name, 'Bench Press');
        expect(exercise.sets, '3');
        expect(exercise.reps, '10');
        expect(exercise.weight, '80kg');
        expect(exercise.notes, 'Good form');
        expect(exercise.weightHistory.length, 1);
        expect(exercise.weightHistory[0].weight, '85kg');
      });

      test('should handle saving weight for non-existent workout', () {
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        appState.addExerciseToWorkout(workoutId, 'Bench Press', weight: '80kg');
        final exerciseId = appState.workoutLists[0].exercises[0].id;
        
        // Try to save weight for non-existent workout
        appState.saveWeightForExercise('non-existent-workout-id', exerciseId, '85kg');
        
        // Exercise should be unchanged
        final exercise = appState.workoutLists[0].exercises[0];
        expect(exercise.weightHistory.length, 0);
      });

      test('should handle saving weight for non-existent exercise', () {
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        appState.addExerciseToWorkout(workoutId, 'Bench Press', weight: '80kg');
        
        // Try to save weight for non-existent exercise
        appState.saveWeightForExercise(workoutId, 'non-existent-exercise-id', '85kg');
        
        // Exercise should be unchanged
        final exercise = appState.workoutLists[0].exercises[0];
        expect(exercise.weightHistory.length, 0);
      });

      test('should preserve other exercise properties when saving weight', () {
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        appState.addExerciseToWorkout(
          workoutId, 
          'Bench Press',
          sets: '3',
          reps: '10',
          weight: '80kg',
          notes: 'Good form',
        );
        final exerciseId = appState.workoutLists[0].exercises[0].id;
        
        // Toggle completion before saving weight
        appState.toggleExerciseCompletion(workoutId, exerciseId);
        
        // Save weight
        appState.saveWeightForExercise(workoutId, exerciseId, '85kg');
        
        final exercise = appState.workoutLists[0].exercises[0];
        expect(exercise.name, 'Bench Press');
        expect(exercise.sets, '3');
        expect(exercise.reps, '10');
        expect(exercise.weight, '80kg');
        expect(exercise.notes, 'Good form');
        expect(exercise.isCompleted, true);
        expect(exercise.weightHistory.length, 1);
        expect(exercise.weightHistory[0].weight, '85kg');
      });

      test('should save different weights for different exercises', () {
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        appState.addExerciseToWorkout(workoutId, 'Bench Press', weight: '80kg');
        appState.addExerciseToWorkout(workoutId, 'Squat', weight: '100kg');
        
        final benchId = appState.workoutLists[0].exercises[0].id;
        final squatId = appState.workoutLists[0].exercises[1].id;
        
        // Save different weights for each exercise
        appState.saveWeightForExercise(workoutId, benchId, '85kg');
        appState.saveWeightForExercise(workoutId, squatId, '105kg');
        
        final benchExercise = appState.workoutLists[0].exercises[0];
        final squatExercise = appState.workoutLists[0].exercises[1];
        
        expect(benchExercise.weightHistory.length, 1);
        expect(benchExercise.weightHistory[0].weight, '85kg');
        
        expect(squatExercise.weightHistory.length, 1);
        expect(squatExercise.weightHistory[0].weight, '105kg');
      });

      test('should handle bodyweight exercises', () {
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        appState.addExerciseToWorkout(workoutId, 'Push ups', weight: 'bodyweight');
        final exerciseId = appState.workoutLists[0].exercises[0].id;
        
        // Save bodyweight+additional weight
        appState.saveWeightForExercise(workoutId, exerciseId, 'bodyweight + 10kg');
        
        final exercise = appState.workoutLists[0].exercises[0];
        expect(exercise.weightHistory.length, 1);
        expect(exercise.weightHistory[0].weight, 'bodyweight + 10kg');
      });
    });

    group('Enhanced Weight Tracking Features', () {
      test('should save weight entry with sets and reps', () {
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        appState.addExerciseToWorkout(workoutId, 'Bench Press');
        final exerciseId = appState.workoutLists[0].exercises[0].id;
        
        // Save weight with sets and reps
        appState.saveWeightForExercise(workoutId, exerciseId, '85kg', sets: 3, reps: 10);
        
        final exercise = appState.workoutLists[0].exercises[0];
        expect(exercise.weightHistory.length, 1);
        final entry = exercise.weightHistory[0];
        expect(entry.weight, '85kg');
        expect(entry.sets, 3);
        expect(entry.reps, 10);
      });

      test('should save weight entry with custom date', () {
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        appState.addExerciseToWorkout(workoutId, 'Bench Press');
        final exerciseId = appState.workoutLists[0].exercises[0].id;
        
        final customDate = DateTime(2024, 1, 15, 10, 30);
        appState.saveWeightForExercise(workoutId, exerciseId, '85kg', date: customDate);
        
        final exercise = appState.workoutLists[0].exercises[0];
        expect(exercise.weightHistory.length, 1);
        final entry = exercise.weightHistory[0];
        expect(entry.weight, '85kg');
        expect(entry.date, customDate);
      });

      test('should save weight entry with all parameters', () {
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        appState.addExerciseToWorkout(workoutId, 'Bench Press');
        final exerciseId = appState.workoutLists[0].exercises[0].id;
        
        final customDate = DateTime(2024, 1, 15, 14, 20);
        appState.saveWeightForExercise(
          workoutId, 
          exerciseId, 
          '85kg', 
          sets: 4, 
          reps: 8, 
          date: customDate
        );
        
        final exercise = appState.workoutLists[0].exercises[0];
        expect(exercise.weightHistory.length, 1);
        final entry = exercise.weightHistory[0];
        expect(entry.weight, '85kg');
        expect(entry.sets, 4);
        expect(entry.reps, 8);
        expect(entry.date, customDate);
      });

      test('should allow multiple entries for the same date', () {
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        appState.addExerciseToWorkout(workoutId, 'Bench Press');
        final exerciseId = appState.workoutLists[0].exercises[0].id;
        
        final sameDate = DateTime(2024, 1, 15);
        // Save multiple entries for the same date (e.g., morning and evening workouts)
        appState.saveWeightForExercise(workoutId, exerciseId, '80kg', sets: 3, reps: 10, date: sameDate.add(Duration(hours: 9)));
        appState.saveWeightForExercise(workoutId, exerciseId, '85kg', sets: 4, reps: 8, date: sameDate.add(Duration(hours: 18)));
        
        final exercise = appState.workoutLists[0].exercises[0];
        expect(exercise.weightHistory.length, 2);
        
        final entry1 = exercise.weightHistory[0];
        expect(entry1.weight, '80kg');
        expect(entry1.sets, 3);
        expect(entry1.reps, 10);
        
        final entry2 = exercise.weightHistory[1];
        expect(entry2.weight, '85kg');
        expect(entry2.sets, 4);
        expect(entry2.reps, 8);
      });

      test('should inherit sets and reps from exercise when not provided', () {
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        appState.addExerciseToWorkout(workoutId, 'Bench Press', sets: '3', reps: '12');
        final exerciseId = appState.workoutLists[0].exercises[0].id;
        
        // Save weight without specifying sets/reps - should inherit from exercise
        appState.saveWeightForExercise(workoutId, exerciseId, '85kg');
        
        final exercise = appState.workoutLists[0].exercises[0];
        expect(exercise.weightHistory.length, 1);
        final entry = exercise.weightHistory[0];
        expect(entry.weight, '85kg');
        expect(entry.sets, 3); // Inherited from exercise
        expect(entry.reps, 12); // Inherited from exercise
      });

      test('should save to global exercise history with sets and reps', () {
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        appState.addExerciseToWorkout(workoutId, 'Bench Press');
        final exerciseId = appState.workoutLists[0].exercises[0].id;
        
        appState.saveWeightForExercise(workoutId, exerciseId, '85kg', sets: 3, reps: 10);
        
        final globalHistory = appState.getExerciseHistory('Bench Press');
        expect(globalHistory, isNotNull);
        expect(globalHistory!.weightHistory.length, 1);
        final entry = globalHistory.weightHistory[0];
        expect(entry.weight, '85kg');
        expect(entry.sets, 3);
        expect(entry.reps, 10);
      });
    });

    group('Delete Weight Entries', () {
      test('should delete specific weight entry correctly', () {
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        appState.addExerciseToWorkout(workoutId, 'Bench Press', weight: '80kg');
        final exerciseId = appState.workoutLists[0].exercises[0].id;
        
        // Add multiple weight entries
        appState.saveWeightForExercise(workoutId, exerciseId, '80kg');
        appState.saveWeightForExercise(workoutId, exerciseId, '85kg');
        appState.saveWeightForExercise(workoutId, exerciseId, '90kg');
        
        final exercise = appState.workoutLists[0].exercises[0];
        expect(exercise.weightHistory.length, 3);
        
        // Verify entries now have unique timestamps
        final entries = exercise.weightHistory;
        expect(entries[0].date != entries[1].date, true);
        expect(entries[1].date != entries[2].date, true);
        
        // Store the initial count and the entry to delete
        final initialCount = exercise.weightHistory.length;
        final entryToDelete = exercise.weightHistory[1];
        
        // Delete the specific entry
        appState.deleteWeightEntry(workoutId, exerciseId, entryToDelete.date);
        
        final updatedExercise = appState.workoutLists[0].exercises[0];
        // Verify that exactly one entry was deleted
        expect(updatedExercise.weightHistory.length, initialCount - 1);
        // Verify that the correct entry was deleted (should be the 85kg entry)
        expect(updatedExercise.weightHistory.any((entry) => entry.weight == '85kg'), false);
        expect(updatedExercise.weightHistory.any((entry) => entry.weight == '80kg'), true);
        expect(updatedExercise.weightHistory.any((entry) => entry.weight == '90kg'), true);
      });

      test('should delete today\'s weight entry correctly', () {
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        appState.addExerciseToWorkout(workoutId, 'Bench Press', weight: '80kg');
        final exerciseId = appState.workoutLists[0].exercises[0].id;
        
        // Save weight for today
        appState.saveWeightForExercise(workoutId, exerciseId, '85kg');
        
        var exercise = appState.workoutLists[0].exercises[0];
        expect(exercise.weightHistory.length, 1);
        expect(exercise.todaysWeight, isNotNull);
        expect(exercise.todaysWeight!.weight, '85kg');
        
        // Delete today's weight
        appState.deleteTodaysWeightForExercise(workoutId, exerciseId);
        
        exercise = appState.workoutLists[0].exercises[0];
        expect(exercise.weightHistory.length, 0);
        expect(exercise.todaysWeight, isNull);
      });

      test('should handle deleting weight for non-existent workout', () {
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        appState.addExerciseToWorkout(workoutId, 'Bench Press', weight: '80kg');
        final exerciseId = appState.workoutLists[0].exercises[0].id;
        
        // Save weight entry
        appState.saveWeightForExercise(workoutId, exerciseId, '85kg');
        
        // Try to delete from non-existent workout
        appState.deleteWeightEntry('non-existent-workout-id', exerciseId, DateTime.now());
        
        // Weight history should remain unchanged
        final exercise = appState.workoutLists[0].exercises[0];
        expect(exercise.weightHistory.length, 1);
      });

      test('should handle deleting weight for non-existent exercise', () {
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        appState.addExerciseToWorkout(workoutId, 'Bench Press', weight: '80kg');
        final exerciseId = appState.workoutLists[0].exercises[0].id;
        
        // Save weight entry
        appState.saveWeightForExercise(workoutId, exerciseId, '85kg');
        
        // Try to delete from non-existent exercise
        appState.deleteWeightEntry(workoutId, 'non-existent-exercise-id', DateTime.now());
        
        // Weight history should remain unchanged
        final exercise = appState.workoutLists[0].exercises[0];
        expect(exercise.weightHistory.length, 1);
      });

      test('should handle deleting non-existent weight entry', () {
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        appState.addExerciseToWorkout(workoutId, 'Bench Press', weight: '80kg');
        final exerciseId = appState.workoutLists[0].exercises[0].id;
        
        // Save weight entry
        appState.saveWeightForExercise(workoutId, exerciseId, '85kg');
        
        // Try to delete entry with different date
        final differentDate = DateTime.now().subtract(const Duration(days: 1));
        appState.deleteWeightEntry(workoutId, exerciseId, differentDate);
        
        // Weight history should remain unchanged
        final exercise = appState.workoutLists[0].exercises[0];
        expect(exercise.weightHistory.length, 1);
      });

      test('should handle deleting today\'s weight when none exists', () {
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        appState.addExerciseToWorkout(workoutId, 'Bench Press', weight: '80kg');
        final exerciseId = appState.workoutLists[0].exercises[0].id;
        
        // Try to delete today's weight without saving any
        appState.deleteTodaysWeightForExercise(workoutId, exerciseId);
        
        // Should not crash and weight history should remain empty
        final exercise = appState.workoutLists[0].exercises[0];
        expect(exercise.weightHistory.length, 0);
      });

      test('should delete only today\'s weight when multiple entries exist', () {
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        appState.addExerciseToWorkout(workoutId, 'Bench Press', weight: '80kg');
        final exerciseId = appState.workoutLists[0].exercises[0].id;
        
        // Create a past entry by directly adding to history
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final pastEntry = WeightEntry(date: yesterday, weight: '75kg');
        
        final exercise = appState.workoutLists[0].exercises[0];
        final updatedExercise = exercise.copyWith(
          weightHistory: [pastEntry],
        );
        appState.updateExercise(workoutId, exerciseId, updatedExercise);
        
        // Save today's weight
        appState.saveWeightForExercise(workoutId, exerciseId, '85kg');
        
        var currentExercise = appState.workoutLists[0].exercises[0];
        expect(currentExercise.weightHistory.length, 2);
        expect(currentExercise.todaysWeight!.weight, '85kg');
        
        // Delete today's weight
        appState.deleteTodaysWeightForExercise(workoutId, exerciseId);
        
        currentExercise = appState.workoutLists[0].exercises[0];
        expect(currentExercise.weightHistory.length, 1);
        expect(currentExercise.weightHistory[0].weight, '75kg');
        expect(currentExercise.todaysWeight, isNull);
      });
    });

    group('Persistent Exercise History', () {
      test('should preserve weight history when exercise is deleted from workout', () {
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        appState.addExerciseToWorkout(workoutId, 'Bench Press', weight: '80kg');
        final exerciseId = appState.workoutLists[0].exercises[0].id;
        
        // Save weight entries
        appState.saveWeightForExercise(workoutId, exerciseId, '80kg');
        appState.saveWeightForExercise(workoutId, exerciseId, '85kg');
        
        // Verify exercise has weight history
        var exercise = appState.workoutLists[0].exercises[0];
        expect(exercise.weightHistory.length, 2);
        
        // Verify global exercise history was created
        var globalHistory = appState.getExerciseHistory('Bench Press');
        expect(globalHistory, isNotNull);
        expect(globalHistory!.weightHistory.length, 2);
        expect(globalHistory.exerciseName, 'Bench Press');
        
        // Delete the exercise from the workout
        appState.deleteExerciseFromWorkout(workoutId, exerciseId);
        
        // Verify exercise is removed from workout
        expect(appState.workoutLists[0].exercises.length, 0);
        
        // Verify global exercise history is preserved
        globalHistory = appState.getExerciseHistory('Bench Press');
        expect(globalHistory, isNotNull);
        expect(globalHistory!.weightHistory.length, 2);
        expect(globalHistory.weightHistory[0].weight, '80kg');
        expect(globalHistory.weightHistory[1].weight, '85kg');
      });

      test('should show deleted exercises in weight tracking screen', () {
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        appState.addExerciseToWorkout(workoutId, 'Deadlift', weight: '100kg');
        final exerciseId = appState.workoutLists[0].exercises[0].id;
        
        // Save weight entry
        appState.saveWeightForExercise(workoutId, exerciseId, '100kg');
        
        // Delete the exercise
        appState.deleteExerciseFromWorkout(workoutId, exerciseId);
        
        // Get all exercise histories with weights
        final historiesWithWeights = appState.getAllExerciseHistoriesWithWeights();
        expect(historiesWithWeights.length, 1);
        expect(historiesWithWeights[0].exerciseName, 'Deadlift');
        expect(historiesWithWeights[0].weightHistory.length, 1);
      });

      test('should merge weight history for exercise with same name across workouts', () {
        // Add exercise to first workout
        appState.addWorkoutList('Push Workout');
        final workout1Id = appState.workoutLists[0].id;
        appState.addExerciseToWorkout(workout1Id, 'Push Ups', weight: 'bodyweight');
        final exercise1Id = appState.workoutLists[0].exercises[0].id;
        
        // Add exercise to second workout
        appState.addWorkoutList('Calisthenics');
        final workout2Id = appState.workoutLists[1].id;
        appState.addExerciseToWorkout(workout2Id, 'Push Ups', weight: 'bodyweight + 10kg');
        final exercise2Id = appState.workoutLists[1].exercises[0].id;
        
        // Save weights from both exercises
        appState.saveWeightForExercise(workout1Id, exercise1Id, 'bodyweight');
        appState.saveWeightForExercise(workout2Id, exercise2Id, 'bodyweight + 5kg');
        appState.saveWeightForExercise(workout1Id, exercise1Id, 'bodyweight + 2kg');
        
        // Verify global history combines both
        final globalHistory = appState.getExerciseHistory('Push Ups');
        expect(globalHistory, isNotNull);
        expect(globalHistory!.weightHistory.length, 3);
        
        // Verify unique exercise name (case insensitive)
        final historiesWithWeights = appState.getAllExerciseHistoriesWithWeights();
        final pushUpsHistories = historiesWithWeights.where((h) => 
            h.exerciseName.toLowerCase() == 'push ups').toList();
        expect(pushUpsHistories.length, 1);
      });

      test('should delete weight entries from global history correctly', () {
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        appState.addExerciseToWorkout(workoutId, 'Squats', weight: '60kg');
        final exerciseId = appState.workoutLists[0].exercises[0].id;
        
        // Save multiple weight entries
        appState.saveWeightForExercise(workoutId, exerciseId, '60kg');
        appState.saveWeightForExercise(workoutId, exerciseId, '65kg');
        appState.saveWeightForExercise(workoutId, exerciseId, '70kg');
        
        var globalHistory = appState.getExerciseHistory('Squats');
        expect(globalHistory!.weightHistory.length, 3);
        
        // Delete middle entry from global history
        final entryToDelete = globalHistory.weightHistory[1];
        appState.deleteWeightFromExerciseHistory('Squats', entryToDelete.date);
        
        // Verify deletion
        globalHistory = appState.getExerciseHistory('Squats');
        expect(globalHistory!.weightHistory.length, 2);
        expect(globalHistory.weightHistory.any((entry) => entry.weight == '65kg'), false);
        expect(globalHistory.weightHistory.any((entry) => entry.weight == '60kg'), true);
        expect(globalHistory.weightHistory.any((entry) => entry.weight == '70kg'), true);
      });

      test('should not create duplicate entries when adding exercise back after deletion', () {
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        appState.addExerciseToWorkout(workoutId, 'Pull Ups', weight: 'bodyweight');
        final exerciseId = appState.workoutLists[0].exercises[0].id;
        
        // Save weight entry
        appState.saveWeightForExercise(workoutId, exerciseId, 'bodyweight + 5kg');
        
        // Verify global history has one entry
        var globalHistory = appState.getExerciseHistory('Pull Ups');
        expect(globalHistory!.weightHistory.length, 1);
        
        // Delete the exercise
        appState.deleteExerciseFromWorkout(workoutId, exerciseId);
        expect(appState.workoutLists[0].exercises.length, 0);
        
        // Global history should still exist
        globalHistory = appState.getExerciseHistory('Pull Ups');
        expect(globalHistory!.weightHistory.length, 1);
        
        // Add the exercise back
        appState.addExerciseToWorkout(workoutId, 'Pull Ups', weight: 'bodyweight');
        final newExerciseId = appState.workoutLists[0].exercises[0].id;
        
        // Save another weight entry
        appState.saveWeightForExercise(workoutId, newExerciseId, 'bodyweight + 10kg');
        
        // Global history should have both entries, no duplicates
        globalHistory = appState.getExerciseHistory('Pull Ups');
        expect(globalHistory!.weightHistory.length, 2);
        
        // Verify unique exercise in weight tracking
        final historiesWithWeights = appState.getAllExerciseHistoriesWithWeights();
        final pullUpsHistories = historiesWithWeights.where((h) => 
            h.exerciseName.toLowerCase() == 'pull ups').toList();
        expect(pullUpsHistories.length, 1);
        expect(pullUpsHistories[0].weightHistory.length, 2);
      });
    });

    group('Exercise Recommendations', () {
      test('should return empty list when no exercise history exists', () {
        // Create a workout but no exercise history
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        
        final recommendations = appState.getExerciseNamesWithLogsNotInWorkout(workoutId);
        
        expect(recommendations, isEmpty);
      });

      test('should return empty list when no exercises have weight logs', () {
        // Create workout and exercise history without weight logs
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        
        // Add exercise history with empty weight history
        appState.addOrUpdateExerciseHistory('Push Ups', WeightEntry(
          date: DateTime.now(),
          weight: '80kg',
        ));
        final history = appState.getExerciseHistory('Push Ups')!;
        final updatedHistory = history.copyWith(weightHistory: []); // Clear weight history
        appState.deleteWeightFromExerciseHistory('Push Ups', DateTime.now());
        
        final recommendations = appState.getExerciseNamesWithLogsNotInWorkout(workoutId);
        
        expect(recommendations, isEmpty);
      });

      test('should return exercise names with logs not in current workout', () {
        // Create workout with one exercise
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        appState.addExerciseToWorkout(workoutId, 'Push Ups');
        
        // Add exercise histories with weight logs
        appState.addOrUpdateExerciseHistory('Push Ups', WeightEntry(
          date: DateTime.now(),
          weight: '80kg',
        ));
        appState.addOrUpdateExerciseHistory('Pull Ups', WeightEntry(
          date: DateTime.now(),
          weight: '75kg',
        ));
        appState.addOrUpdateExerciseHistory('Squats', WeightEntry(
          date: DateTime.now(),
          weight: '100kg',
        ));
        
        final recommendations = appState.getExerciseNamesWithLogsNotInWorkout(workoutId);
        
        // Should return Pull Ups and Squats, but not Push Ups (already in workout)
        expect(recommendations.length, 2);
        expect(recommendations, contains('Pull Ups'));
        expect(recommendations, contains('Squats'));
        expect(recommendations, isNot(contains('Push Ups')));
      });

      test('should return all exercises with logs when workout is empty', () {
        // Create empty workout
        appState.addWorkoutList('Empty Workout');
        final workoutId = appState.workoutLists[0].id;
        
        // Add exercise histories with weight logs
        appState.addOrUpdateExerciseHistory('Push Ups', WeightEntry(
          date: DateTime.now(),
          weight: '80kg',
        ));
        appState.addOrUpdateExerciseHistory('Pull Ups', WeightEntry(
          date: DateTime.now(),
          weight: '75kg',
        ));
        
        final recommendations = appState.getExerciseNamesWithLogsNotInWorkout(workoutId);
        
        expect(recommendations.length, 2);
        expect(recommendations, contains('Push Ups'));
        expect(recommendations, contains('Pull Ups'));
      });

      test('should be case insensitive when filtering existing exercises', () {
        // Create workout with exercise in different case
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        appState.addExerciseToWorkout(workoutId, 'push ups'); // lowercase
        
        // Add exercise history with different case
        appState.addOrUpdateExerciseHistory('Push Ups', WeightEntry( // title case
          date: DateTime.now(),
          weight: '80kg',
        ));
        appState.addOrUpdateExerciseHistory('PULL UPS', WeightEntry( // uppercase
          date: DateTime.now(),
          weight: '75kg',
        ));
        
        final recommendations = appState.getExerciseNamesWithLogsNotInWorkout(workoutId);
        
        // Should only return PULL UPS, not Push Ups (filtered due to case insensitive match)
        expect(recommendations.length, 1);
        expect(recommendations, contains('PULL UPS'));
        expect(recommendations, isNot(contains('Push Ups')));
      });

      test('should sort recommendations by most recently used first', () async {
        // Create empty workout
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        
        final oldDate = DateTime.now().subtract(const Duration(days: 5));
        final recentDate = DateTime.now().subtract(const Duration(hours: 1));
        
        // Add old exercise first, then add a delay to ensure different timestamps
        appState.addOrUpdateExerciseHistory('Old Exercise', WeightEntry(
          date: oldDate,
          weight: '80kg',
        ));
        
        // Wait to ensure different lastUsed timestamp
        await Future.delayed(const Duration(milliseconds: 10));
        
        appState.addOrUpdateExerciseHistory('Recent Exercise', WeightEntry(
          date: recentDate,
          weight: '75kg',
        ));
        
        final recommendations = appState.getExerciseNamesWithLogsNotInWorkout(workoutId);
        
        expect(recommendations.length, 2);
        // Recent Exercise should come first due to more recent lastUsed timestamp
        expect(recommendations[0], 'Recent Exercise');
        expect(recommendations[1], 'Old Exercise');
      });

      test('should handle non-existent workout gracefully', () {
        // Add some exercise history
        appState.addOrUpdateExerciseHistory('Push Ups', WeightEntry(
          date: DateTime.now(),
          weight: '80kg',
        ));
        
        final recommendations = appState.getExerciseNamesWithLogsNotInWorkout('non-existent-id');
        
        // Should return all exercises since workout doesn't exist (empty exercise list)
        expect(recommendations.length, 1);
        expect(recommendations, contains('Push Ups'));
      });

      test('should exclude exercises with only empty weight history', () {
        // Create workout
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        
        // Add exercise with weight log
        appState.addOrUpdateExerciseHistory('Valid Exercise', WeightEntry(
          date: DateTime.now(),
          weight: '80kg',
        ));
        
        // Add exercise without weight logs by manually creating empty history
        final emptyHistory = appState.getExerciseHistory('Empty Exercise');
        if (emptyHistory == null) {
          // Create exercise history with empty weight history
          appState.addOrUpdateExerciseHistory('Empty Exercise', WeightEntry(
            date: DateTime.now(),
            weight: '80kg',
          ));
          // Then remove the weight entry
          appState.deleteWeightFromExerciseHistory('Empty Exercise', DateTime.now());
        }
        
        final recommendations = appState.getExerciseNamesWithLogsNotInWorkout(workoutId);
        
        // Should only return Valid Exercise
        expect(recommendations.length, 1);
        expect(recommendations, contains('Valid Exercise'));
        expect(recommendations, isNot(contains('Empty Exercise')));
      });
    });
  });
}