import 'package:flutter/material.dart';

import '../models/checklist.dart';

class ChecklistTile extends StatelessWidget {
  final Checklist checklist;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onRename;

  const ChecklistTile({
    super.key,
    required this.checklist,
    required this.onTap,
    required this.onDelete,
    required this.onRename,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.drag_handle),
      title: Text(checklist.name),
      subtitle: Text('${checklist.uncheckedCount}/${checklist.totalCount}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: onRename,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: onDelete,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
