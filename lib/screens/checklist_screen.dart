import 'package:flutter/material.dart';

import '../models/checklist.dart';
import '../widgets/item_tile.dart';

class ChecklistScreen extends StatefulWidget {
  final Checklist checklist;
  final void Function(Checklist) onChanged;

  const ChecklistScreen({
    super.key,
    required this.checklist,
    required this.onChanged,
  });

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  late Checklist _checklist;

  @override
  void initState() {
    super.initState();
    _checklist = widget.checklist;
  }

  void _addItem() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Item'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Item name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                final result = _checklist.addItem(name);
                if (result == null) {
                  final unchecked = _checklist.findDuplicateAndUncheck(name);
                  if (unchecked != null) {
                    setState(() => _checklist = unchecked);
                    widget.onChanged(_checklist);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Item already exists - moved to unchecked'),
                      ),
                    );
                  }
                } else {
                  setState(() => _checklist = result);
                  widget.onChanged(_checklist);
                }
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _toggleItem(String name) {
    setState(() {
      _checklist = _checklist.toggleItem(name);
    });
    widget.onChanged(_checklist);
  }

  void _deleteItem(String name) {
    setState(() {
      _checklist = _checklist.removeItem(name);
    });
    widget.onChanged(_checklist);
  }

  void _reorderUnchecked(int oldIndex, int newIndex) {
    setState(() {
      _checklist = _checklist.reorderUnchecked(oldIndex, newIndex);
    });
    widget.onChanged(_checklist);
  }

  void _reorderChecked(int oldIndex, int newIndex) {
    setState(() {
      _checklist = _checklist.reorderChecked(oldIndex, newIndex);
    });
    widget.onChanged(_checklist);
  }

  @override
  Widget build(BuildContext context) {
    final unchecked = _checklist.uncheckedItems;
    final checked = _checklist.checkedItems;
    final hasItems = unchecked.isNotEmpty || checked.isNotEmpty;

    return Scaffold(
        appBar: AppBar(
          title: Text(_checklist.name),
        ),
        body: !hasItems
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('No items yet'),
                    SizedBox(height: 8),
                    Text('Tap + to add one'),
                  ],
                ),
              )
            : ListView(
                children: [
                  if (unchecked.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'To Do',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: unchecked.length,
                      onReorder: _reorderUnchecked,
                      itemBuilder: (context, index) {
                        final item = unchecked[index];
                        return ItemTile(
                          key: ValueKey('unchecked-${item.name}'),
                          item: item,
                          onToggle: () => _toggleItem(item.name),
                          onDelete: () => _deleteItem(item.name),
                        );
                      },
                    ),
                  ],
                  if (checked.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Done',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: checked.length,
                      onReorder: _reorderChecked,
                      itemBuilder: (context, index) {
                        final item = checked[index];
                        return ItemTile(
                          key: ValueKey('checked-${item.name}'),
                          item: item,
                          onToggle: () => _toggleItem(item.name),
                          onDelete: () => _deleteItem(item.name),
                        );
                      },
                    ),
                  ],
                ],
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addItem,
          child: const Icon(Icons.add),
        ),
    );
  }
}
