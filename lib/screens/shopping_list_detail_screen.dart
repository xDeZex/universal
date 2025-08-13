import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/shopping_list.dart';

class ShoppingListDetailScreen extends StatelessWidget {
  final ShoppingList shoppingList;

  const ShoppingListDetailScreen({
    super.key,
    required this.shoppingList,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(shoppingList.name),
      ),
      body: Consumer<ShoppingAppState>(
        builder: (context, appState, child) {
          final currentList = appState.shoppingLists
              .firstWhere((list) => list.id == shoppingList.id);

          if (currentList.items.isEmpty) {
            return Center(
              child: Text(
                'No items in this list yet.\nTap the + button to add items!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
              ),
            );
          }

          return ReorderableListView.builder(
            itemCount: currentList.items.length,
            onReorder: (int oldIndex, int newIndex) {
              appState.reorderItems(currentList.id, oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              final item = currentList.items[index];
              return Card(
                key: ValueKey(item.id),
                child: ListTile(
                  leading: Checkbox(
                    value: item.isCompleted,
                    onChanged: (bool? value) {
                      appState.toggleItemCompletion(currentList.id, item.id);
                    },
                  ),
                  title: Text(
                    item.name,
                    style: TextStyle(
                      decoration: item.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: item.isCompleted
                          ? Theme.of(context).colorScheme.onSurfaceVariant
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Delete Item'),
                                content: Text('Are you sure you want to delete "${item.name}"?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      appState.deleteItemFromList(currentList.id, item.id);
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Delete'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                      ReorderableDragStartListener(
                        index: index,
                        child: const Icon(Icons.drag_handle),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddItemDialog(BuildContext context) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Item'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Item name',
              hintText: 'Enter item name',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  context.read<ShoppingAppState>().addItemToList(
                    shoppingList.id,
                    controller.text.trim(),
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}