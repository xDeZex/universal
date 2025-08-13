import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/shopping_list.dart';
import '../models/shopping_item.dart';

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

          final incompleteItems = currentList.items.where((item) => !item.isCompleted).toList();
          final completedItems = currentList.items.where((item) => item.isCompleted).toList();

          return CustomScrollView(
            slivers: [
              // Incomplete Items Section
              if (incompleteItems.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Shopping List (${incompleteItems.length})',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverReorderableList(
                  itemCount: incompleteItems.length,
                  onReorder: (int oldIndex, int newIndex) {
                    // Convert to global indices
                    final globalOldIndex = oldIndex;
                    final globalNewIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;
                    appState.reorderItems(currentList.id, globalOldIndex, globalNewIndex);
                  },
                  itemBuilder: (context, index) {
                    final item = incompleteItems[index];
                    return _buildItemCard(context, item, index, appState, currentList.id);
                  },
                ),
              ],

              // Divider between sections
              if (incompleteItems.isNotEmpty && completedItems.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Divider(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                      thickness: 1,
                    ),
                  ),
                ),

              // Completed Items Section
              if (completedItems.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Completed (${completedItems.length})',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = completedItems[index];
                      return _buildCompletedItemCard(context, item, appState, currentList.id);
                    },
                    childCount: completedItems.length,
                  ),
                ),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, ShoppingItem item, int index, ShoppingAppState appState, String listId) {
    return Card(
      key: ValueKey(item.id),
      child: ListTile(
        leading: Checkbox(
          value: item.isCompleted,
          onChanged: (bool? value) {
            appState.toggleItemCompletion(listId, item.id);
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
                            appState.deleteItemFromList(listId, item.id);
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
  }

  Widget _buildCompletedItemCard(BuildContext context, ShoppingItem item, ShoppingAppState appState, String listId) {
    return Card(
      key: ValueKey(item.id),
      child: ListTile(
        leading: Checkbox(
          value: item.isCompleted,
          onChanged: (bool? value) {
            appState.toggleItemCompletion(listId, item.id);
          },
        ),
        title: Text(
          item.name,
          style: TextStyle(
            decoration: TextDecoration.lineThrough,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: IconButton(
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
                        appState.deleteItemFromList(listId, item.id);
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