import '../models/shopping_list.dart';
import '../models/shopping_item.dart';
import '../utils/id_generator.dart';
import 'list_manager.dart';

class ShoppingService {
  static ShoppingList addItemToList(ShoppingList list, String itemName) {
    final newItem = ShoppingItem(
      id: IdGenerator.generateUniqueId(),
      name: itemName,
    );
    final updatedItems = List<ShoppingItem>.from(list.items)..add(newItem);
    return list.copyWith(items: updatedItems);
  }

  static ShoppingList toggleItemCompletion(ShoppingList list, String itemId) {
    final updatedItems = ListManager.toggleItemCompletion(list.items, itemId);
    return list.copyWith(items: updatedItems);
  }

  static ShoppingList deleteItemFromList(ShoppingList list, String itemId) {
    final updatedItems = ListManager.deleteItem(list.items, itemId);
    return list.copyWith(items: updatedItems);
  }

  static ShoppingList reorderItems(ShoppingList list, int oldIndex, int newIndex) {
    final updatedItems = ListManager.reorderItems(list.items, oldIndex, newIndex);
    return list.copyWith(items: updatedItems);
  }

  static ShoppingList createShoppingList(String name) {
    return ShoppingList(
      id: IdGenerator.generateUniqueId(),
      name: name,
      items: [],
      createdAt: DateTime.now(),
    );
  }

  static List<ShoppingList> addToCollection(List<ShoppingList> shoppingLists, String name) {
    final newList = createShoppingList(name);
    return List<ShoppingList>.from(shoppingLists)..add(newList);
  }

  static List<ShoppingList> deleteFromCollection(List<ShoppingList> shoppingLists, String id) {
    return shoppingLists.where((list) => list.id != id).toList();
  }

  static List<ShoppingList> reorderCollection(List<ShoppingList> shoppingLists, int oldIndex, int newIndex) {
    return ListManager.reorderLists(shoppingLists, oldIndex, newIndex);
  }
}