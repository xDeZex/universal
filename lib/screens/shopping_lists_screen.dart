import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/shopping_list.dart';
import 'shopping_list_detail_screen.dart';

class ShoppingListsScreen extends StatelessWidget {
  final bool showAppBar;
  
  const ShoppingListsScreen({super.key, this.showAppBar = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Consumer<ShoppingAppState>(
        builder: (context, appState, child) => _buildBody(context, appState),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  PreferredSizeWidget? _buildAppBar() {
    if (!showAppBar) return null;
    
    return AppBar(
      title: const Text('Shopping Lists'),
    );
  }

  Widget _buildBody(BuildContext context, ShoppingAppState appState) {
    if (appState.shoppingLists.isEmpty) {
      return _buildEmptyState(context);
    }

    return _buildShoppingList(context, appState);
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Text(
        'No shopping lists yet.\nTap the + button to create one!',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
      ),
    );
  }

  Widget _buildShoppingList(BuildContext context, ShoppingAppState appState) {
    return ReorderableListView.builder(
      itemCount: appState.shoppingLists.length,
      onReorder: (oldIndex, newIndex) => appState.reorderShoppingLists(oldIndex, newIndex),
      itemBuilder: (context, index) => _buildShoppingListCard(context, appState, appState.shoppingLists[index], index),
    );
  }

  Widget _buildShoppingListCard(BuildContext context, ShoppingAppState appState, ShoppingList shoppingList, int index) {
    return Card(
      key: ValueKey(shoppingList.id),
      child: ListTile(
        title: _buildListTitle(shoppingList),
        subtitle: _buildListSubtitle(shoppingList),
        trailing: _buildListActions(context, appState, shoppingList, index),
        onTap: () => _navigateToListDetail(context, shoppingList),
      ),
    );
  }

  Widget _buildListTitle(ShoppingList shoppingList) {
    return Text(shoppingList.name);
  }

  Widget _buildListSubtitle(ShoppingList shoppingList) {
    return Text(
      '${shoppingList.completedItems}/${shoppingList.totalItems} items completed',
    );
  }

  Widget _buildListActions(BuildContext context, ShoppingAppState appState, ShoppingList shoppingList, int index) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (shoppingList.isCompleted) _buildCompletionIcon(),
        _buildDeleteButton(context, appState, shoppingList),
        _buildDragHandle(index),
      ],
    );
  }

  Widget _buildCompletionIcon() {
    return const Icon(Icons.check_circle, color: Colors.green);
  }

  Widget _buildDeleteButton(BuildContext context, ShoppingAppState appState, ShoppingList shoppingList) {
    return IconButton(
      icon: const Icon(Icons.delete),
      onPressed: () => _showDeleteConfirmation(context, appState, shoppingList),
    );
  }

  Widget _buildDragHandle(int index) {
    return ReorderableDragStartListener(
      index: index,
      child: const Icon(Icons.drag_handle),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showAddListDialog(context),
      child: const Icon(Icons.add),
    );
  }

  // ============================================================================
  // Helper Methods - Navigation
  // ============================================================================

  void _navigateToListDetail(BuildContext context, ShoppingList shoppingList) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ShoppingListDetailScreen(
          shoppingList: shoppingList,
        ),
      ),
    );
  }

  // ============================================================================
  // Helper Methods - Dialog Management
  // ============================================================================

  void _showDeleteConfirmation(BuildContext context, ShoppingAppState appState, ShoppingList shoppingList) {
    showDialog(
      context: context,
      builder: (BuildContext context) => _buildDeleteConfirmationDialog(context, appState, shoppingList),
    );
  }

  Widget _buildDeleteConfirmationDialog(BuildContext context, ShoppingAppState appState, ShoppingList shoppingList) {
    return AlertDialog(
      title: const Text('Delete List'),
      content: Text('Are you sure you want to delete "${shoppingList.name}"?'),
      actions: [
        _buildDialogCancelButton(context),
        _buildDialogDeleteButton(context, appState, shoppingList),
      ],
    );
  }

  Widget _buildDialogCancelButton(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.of(context).pop(),
      child: const Text('Cancel'),
    );
  }

  Widget _buildDialogDeleteButton(BuildContext context, ShoppingAppState appState, ShoppingList shoppingList) {
    return TextButton(
      onPressed: () {
        appState.deleteShoppingList(shoppingList.id);
        Navigator.of(context).pop();
      },
      child: const Text('Delete'),
    );
  }

  void _showAddListDialog(BuildContext context) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) => _buildAddListDialog(context, controller),
    );
  }

  Widget _buildAddListDialog(BuildContext context, TextEditingController controller) {
    return AlertDialog(
      title: const Text('New Shopping List'),
      content: _buildListNameField(controller),
      actions: [
        _buildDialogCancelButton(context),
        _buildDialogCreateButton(context, controller),
      ],
    );
  }

  Widget _buildListNameField(TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'List name',
        hintText: 'Enter list name',
      ),
      autofocus: true,
    );
  }

  Widget _buildDialogCreateButton(BuildContext context, TextEditingController controller) {
    return TextButton(
      onPressed: () {
        if (controller.text.trim().isNotEmpty) {
          context.read<ShoppingAppState>().addShoppingList(controller.text.trim());
          Navigator.of(context).pop();
        }
      },
      child: const Text('Create'),
    );
  }
}