import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/shopping_list.dart';
import 'shopping_list_detail_screen.dart';

class ShoppingListsScreen extends StatelessWidget {
  const ShoppingListsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Lists'),
      ),
      body: Consumer<ShoppingAppState>(
        builder: (context, appState, child) {
          if (appState.shoppingLists.isEmpty) {
            return Center(
              child: Text(
                'No shopping lists yet.\nTap the + button to create one!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
              ),
            );
          }

          return ReorderableListView.builder(
            itemCount: appState.shoppingLists.length,
            onReorder: (oldIndex, newIndex) {
              appState.reorderShoppingLists(oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              final shoppingList = appState.shoppingLists[index];
              return Card(
                key: ValueKey(shoppingList.id),
                child: ListTile(
                  title: Text(shoppingList.name),
                  subtitle: Text(
                    '${shoppingList.completedItems}/${shoppingList.totalItems} items completed',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (shoppingList.isCompleted)
                        const Icon(Icons.check_circle, color: Colors.green),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _showDeleteConfirmation(context, appState, shoppingList),
                      ),
                      ReorderableDragStartListener(
                        index: index,
                        child: const Icon(Icons.drag_handle),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ShoppingListDetailScreen(
                          shoppingList: shoppingList,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddListDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, ShoppingAppState appState, ShoppingList shoppingList) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete List'),
          content: Text('Are you sure you want to delete "${shoppingList.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                appState.deleteShoppingList(shoppingList.id);
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showAddListDialog(BuildContext context) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('New Shopping List'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'List name',
              hintText: 'Enter list name',
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
                  context.read<ShoppingAppState>().addShoppingList(controller.text.trim());
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}