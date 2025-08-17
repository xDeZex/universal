import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shopping_app_state.dart';
import '../models/base_item.dart';
import '../models/base_list.dart';
import 'shared_components.dart';

class ItemGroups<T extends BaseItem> {
  final List<T> incompleteItems;
  final List<T> completedItems;

  const ItemGroups({
    required this.incompleteItems,
    required this.completedItems,
  });
}

class GenericDetailScreen<TList extends BaseList<TItem>, TItem extends BaseItem> extends StatelessWidget {
  static const double _sectionPadding = 16.0;
  static const double _dividerPadding = 8.0;
  
  final TList list;
  final TList Function(ShoppingAppState appState) getCurrentList;
  final void Function(ShoppingAppState appState, String listId, int oldIndex, int newIndex) onReorder;
  final void Function(String listId, String itemId) onToggleCompletion;
  final void Function(String listId, String itemId) onDelete;
  final void Function(BuildContext context, String listId) onAddItem;
  final Widget Function(TItem item)? titleBuilder;
  final String sectionTitle;

  const GenericDetailScreen({
    super.key,
    required this.list,
    required this.getCurrentList,
    required this.onReorder,
    required this.onToggleCompletion,
    required this.onDelete,
    required this.onAddItem,
    required this.sectionTitle,
    this.titleBuilder,
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
      title: Text(list.name),
    );
  }

  Widget _buildBody() {
    return Consumer<ShoppingAppState>(
      builder: (context, appState, child) {
        final currentList = getCurrentList(appState);

        if (currentList.items.isEmpty) {
          return _buildEmptyState(context);
        }

        final itemGroups = _separateItems(currentList);
        
        return CustomScrollView(
          slivers: [
            if (itemGroups.incompleteItems.isNotEmpty)
              IncompleteItemsSection<TItem>(
                items: itemGroups.incompleteItems,
                listId: currentList.id,
                sectionTitle: sectionTitle,
                onReorder: (oldIndex, newIndex) => 
                  onReorder(appState, currentList.id, oldIndex, newIndex),
                itemBuilder: (item, index) => ItemCard<TItem>(
                  key: ValueKey(item.id),
                  item: item,
                  listId: currentList.id,
                  index: index,
                  showDragHandle: true,
                  onToggleCompletion: onToggleCompletion,
                  onDelete: onDelete,
                  titleBuilder: titleBuilder,
                ),
              ),

            if (_shouldShowDivider(itemGroups))
              _buildSectionDivider(context),

            if (itemGroups.completedItems.isNotEmpty)
              CompletedItemsSection<TItem>(
                items: itemGroups.completedItems,
                listId: currentList.id,
                itemBuilder: (item, index) => ItemCard<TItem>(
                  key: ValueKey(item.id),
                  item: item,
                  listId: currentList.id,
                  index: index,
                  showDragHandle: false,
                  onToggleCompletion: onToggleCompletion,
                  onDelete: onDelete,
                  titleBuilder: titleBuilder,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => onAddItem(context, list.id),
      child: const Icon(Icons.add),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Text(
        'No items in this list yet.\\nTap the + button to add items!',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
      ),
    );
  }

  ItemGroups<TItem> _separateItems(TList list) {
    final incompleteItems = list.items.where((item) => !item.isCompleted).toList();
    final completedItems = list.items.where((item) => item.isCompleted).toList();
    return ItemGroups(incompleteItems: incompleteItems, completedItems: completedItems);
  }

  bool _shouldShowDivider(ItemGroups<TItem> itemGroups) {
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
}