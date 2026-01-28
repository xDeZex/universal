import 'package:flutter/material.dart';

import '../models/checklist.dart';

class ItemTile extends StatelessWidget {
  final ChecklistItem item;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const ItemTile({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.drag_handle),
      title: Text(
        item.name,
        style: item.isChecked
            ? const TextStyle(decoration: TextDecoration.lineThrough)
            : null,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: item.isChecked,
            onChanged: (_) => onToggle(),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
