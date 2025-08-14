import '../models/base_item.dart';
import '../models/base_list.dart';

class ListManager<TList extends BaseList<TItem>, TItem extends BaseItem> {
  
  static TList sortListItems<TList extends BaseList<TItem>, TItem extends BaseItem>(
    TList list
  ) {
    final sortedItems = List<TItem>.from(list.items);
    sortedItems.sort((a, b) {
      if (a.isCompleted == b.isCompleted) return 0;
      return a.isCompleted ? 1 : -1;
    });
    return list.copyWithItems(items: sortedItems) as TList;
  }

  static List<TList> reorderLists<TList extends BaseList<TItem>, TItem extends BaseItem>(
    List<TList> lists, 
    int oldIndex, 
    int newIndex
  ) {
    final updatedLists = List<TList>.from(lists);
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final list = updatedLists.removeAt(oldIndex);
    updatedLists.insert(newIndex, list);
    return updatedLists;
  }

  static List<TItem> toggleItemCompletion<TItem extends BaseItem>(
    List<TItem> items,
    String itemId
  ) {
    final itemIndex = items.indexWhere((item) => item.id == itemId);
    if (itemIndex != -1) {
      final updatedItems = List<TItem>.from(items);
      updatedItems[itemIndex] = updatedItems[itemIndex].copyWithCompletion(
        isCompleted: !updatedItems[itemIndex].isCompleted,
      ) as TItem;
      
      // Sort items: incomplete first, completed at bottom
      updatedItems.sort((a, b) {
        if (a.isCompleted == b.isCompleted) return 0;
        return a.isCompleted ? 1 : -1;
      });
      
      return updatedItems;
    }
    return items;
  }

  static List<TItem> reorderItems<TItem extends BaseItem>(
    List<TItem> items,
    int oldIndex,
    int newIndex
  ) {
    final updatedItems = List<TItem>.from(items);
    
    // Get the item being moved
    final itemToMove = updatedItems[oldIndex];
    
    // Find boundaries for incomplete and completed sections
    final incompleteCount = updatedItems.where((item) => !item.isCompleted).length;
    
    // Restrict reordering within the same completion state
    if (itemToMove.isCompleted) {
      // Completed items can only be reordered within completed section
      if (newIndex < incompleteCount) {
        newIndex = incompleteCount;
      }
    } else {
      // Incomplete items can only be reordered within incomplete section
      if (newIndex > incompleteCount) {
        newIndex = incompleteCount;
      }
    }
    
    // Standard reordering logic adjustment
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    
    final item = updatedItems.removeAt(oldIndex);
    updatedItems.insert(newIndex, item);
    return updatedItems;
  }

  static List<TItem> deleteItem<TItem extends BaseItem>(
    List<TItem> items,
    String itemId
  ) {
    return items.where((item) => item.id != itemId).toList();
  }
}