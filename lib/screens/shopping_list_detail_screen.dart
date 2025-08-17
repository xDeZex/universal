import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shopping_app_state.dart';
import '../models/shopping_list.dart';
import '../models/shopping_item.dart';

class ShoppingListDetailScreen extends StatelessWidget {
  static const double _sectionPadding = 16.0;
  static const double _dividerPadding = 8.0;
  
  final ShoppingList shoppingList;

  const ShoppingListDetailScreen({
    super.key,
    required this.shoppingList,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFAB(context),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(shoppingList.name),
    );
  }

  Widget _buildBody() {
    return Consumer<ShoppingAppState>(
      builder: (context, appState, child) {
        final currentList = _getCurrentList(appState);

        if (currentList.items.isEmpty) {
          return _buildEmptyState(context);
        }

        final itemGroups = _separateItems(currentList);
        
        return CustomScrollView(
          slivers: [
            if (itemGroups.incompleteItems.isNotEmpty)
              IncompleteItemsSection(
                items: itemGroups.incompleteItems,
                listId: currentList.id,
                onReorder: (oldIndex, newIndex) => 
                  _handleIncompleteItemReorder(appState, currentList.id, oldIndex, newIndex),
              ),

            if (_shouldShowDivider(itemGroups))
              _buildSectionDivider(context),

            if (itemGroups.completedItems.isNotEmpty)
              CompletedItemsSection(
                items: itemGroups.completedItems,
                listId: currentList.id,
              ),
          ],
        );
      },
    );
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showAddItemDialog(context),
      child: const Icon(Icons.add),
    );
  }

  ShoppingList _getCurrentList(ShoppingAppState appState) {
    return appState.shoppingLists.firstWhere((list) => list.id == shoppingList.id);
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Text(
        'No items in this list yet.\nTap the + button to add items!',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
      ),
    );
  }

  ItemGroups _separateItems(ShoppingList list) {
    final incompleteItems = list.items.where((item) => !item.isCompleted).toList();
    final completedItems = list.items.where((item) => item.isCompleted).toList();
    return ItemGroups(incompleteItems: incompleteItems, completedItems: completedItems);
  }

  bool _shouldShowDivider(ItemGroups itemGroups) {
    return itemGroups.incompleteItems.isNotEmpty && itemGroups.completedItems.isNotEmpty;
  }

  Widget _buildSectionDivider(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: _sectionPadding, vertical: _dividerPadding),
        child: Divider(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
          thickness: 1,
        ),
      ),
    );
  }

  void _handleIncompleteItemReorder(ShoppingAppState appState, String listId, int oldIndex, int newIndex) {
    appState.reorderItems(listId, oldIndex, newIndex);
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

// Helper classes
class ItemGroups {
  final List<ShoppingItem> incompleteItems;
  final List<ShoppingItem> completedItems;

  const ItemGroups({
    required this.incompleteItems,
    required this.completedItems,
  });
}

// Widget classes
class IncompleteItemsSection extends StatelessWidget {
  
  final List<ShoppingItem> items;
  final String listId;
  final void Function(int, int) onReorder;

  const IncompleteItemsSection({
    super.key,
    required this.items,
    required this.listId,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: SectionHeader(
            icon: Icons.shopping_cart_outlined,
            title: 'Shopping List (${items.length})',
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        SliverReorderableList(
          itemCount: items.length,
          onReorder: onReorder,
          itemBuilder: (context, index) {
            final item = items[index];
            return ItemCard(
              key: ValueKey(item.id),
              item: item,
              listId: listId,
              index: index,
              showDragHandle: true,
            );
          },
        ),
      ],
    );
  }
}

class CompletedItemsSection extends StatelessWidget {
  final List<ShoppingItem> items;
  final String listId;

  const CompletedItemsSection({
    super.key,
    required this.items,
    required this.listId,
  });

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: SectionHeader(
            icon: Icons.check_circle_outline,
            title: 'Completed (${items.length})',
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final item = items[index];
              return ItemCard(
                key: ValueKey(item.id),
                item: item,
                listId: listId,
                index: index,
                showDragHandle: false,
              );
            },
            childCount: items.length,
          ),
        ),
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  static const double _sectionPadding = 16.0;
  static const double _iconSize = 20.0;
  
  final IconData icon;
  final String title;
  final Color color;

  const SectionHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(_sectionPadding),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: _iconSize,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class ItemCard extends StatelessWidget {
  final ShoppingItem item;
  final String listId;
  final int index;
  final bool showDragHandle;

  const ItemCard({
    super.key,
    required this.item,
    required this.listId,
    required this.index,
    required this.showDragHandle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: _buildCheckbox(context),
        title: _buildTitle(context),
        trailing: _buildTrailing(context),
      ),
    );
  }

  Widget _buildCheckbox(BuildContext context) {
    return Checkbox(
      value: item.isCompleted,
      onChanged: (bool? value) {
        context.read<ShoppingAppState>().toggleItemCompletion(listId, item.id);
      },
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      item.name,
      style: TextStyle(
        decoration: item.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
        color: item.isCompleted
            ? Theme.of(context).colorScheme.onSurfaceVariant
            : Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildTrailing(BuildContext context) {
    if (showDragHandle) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDeleteButton(context),
          ReorderableDragStartListener(
            index: index,
            child: const Icon(Icons.drag_handle),
          ),
        ],
      );
    }
    return _buildDeleteButton(context);
  }

  Widget _buildDeleteButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.delete),
      onPressed: () => _showDeleteConfirmation(context),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ShoppingAppState>().deleteItemFromList(listId, item.id);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}