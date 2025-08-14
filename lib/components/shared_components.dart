import 'package:flutter/material.dart';
import '../models/base_item.dart';

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

class IncompleteItemsSection<T extends BaseItem> extends StatelessWidget {
  final List<T> items;
  final String listId;
  final void Function(int, int) onReorder;
  final Widget Function(T item, int index) itemBuilder;
  final String sectionTitle;

  const IncompleteItemsSection({
    super.key,
    required this.items,
    required this.listId,
    required this.onReorder,
    required this.itemBuilder,
    required this.sectionTitle,
  });

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: SectionHeader(
            icon: Icons.checklist,
            title: '$sectionTitle (${items.length})',
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        SliverReorderableList(
          itemCount: items.length,
          onReorder: onReorder,
          itemBuilder: (context, index) {
            final item = items[index];
            return itemBuilder(item, index);
          },
        ),
      ],
    );
  }
}

class CompletedItemsSection<T extends BaseItem> extends StatelessWidget {
  final List<T> items;
  final String listId;
  final Widget Function(T item, int index) itemBuilder;

  const CompletedItemsSection({
    super.key,
    required this.items,
    required this.listId,
    required this.itemBuilder,
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
              return itemBuilder(item, index);
            },
            childCount: items.length,
          ),
        ),
      ],
    );
  }
}

class ItemCard<T extends BaseItem> extends StatelessWidget {
  final T item;
  final String listId;
  final int index;
  final bool showDragHandle;
  final void Function(String listId, String itemId) onToggleCompletion;
  final void Function(String listId, String itemId) onDelete;
  final Widget Function(T item)? titleBuilder;

  const ItemCard({
    super.key,
    required this.item,
    required this.listId,
    required this.index,
    required this.showDragHandle,
    required this.onToggleCompletion,
    required this.onDelete,
    this.titleBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: _buildCheckbox(context),
        title: titleBuilder?.call(item) ?? _buildTitle(context),
        trailing: _buildTrailing(context),
      ),
    );
  }

  Widget _buildCheckbox(BuildContext context) {
    return Checkbox(
      value: item.isCompleted,
      onChanged: (bool? value) {
        onToggleCompletion(listId, item.id);
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
              onDelete(listId, item.id);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}