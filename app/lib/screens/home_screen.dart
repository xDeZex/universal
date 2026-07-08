import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/checklist.dart';
import '../services/storage_service.dart';
import '../services/update_service.dart';
import '../widgets/checklist_tile.dart';
import 'checklist_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final List<Checklist>? initialChecklists;

  const HomeScreen({super.key, this.initialChecklists});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storage = StorageService();
  List<Checklist> _checklists = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChecklists();
  }

  Future<void> _loadChecklists() async {
    if (widget.initialChecklists != null) {
      setState(() {
        _checklists = widget.initialChecklists!;
        _isLoading = false;
      });
      return;
    }

    final checklists = await _storage.loadChecklists();
    setState(() {
      _checklists = checklists;
      _isLoading = false;
    });
  }

  Future<void> _saveChecklists() async {
    await _storage.saveChecklists(_checklists);
  }

  void _addChecklist() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Checklist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Checklist name'),
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
                setState(() {
                  _checklists = [..._checklists, Checklist(name: name)];
                });
                _saveChecklists();
              }
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  List<Checklist> _replaceAt(int index, Checklist updated) => [
        ..._checklists.sublist(0, index),
        updated,
        ..._checklists.sublist(index + 1),
      ];

  void _deleteChecklist(int index) {
    setState(() {
      _checklists = [
        ..._checklists.sublist(0, index),
        ..._checklists.sublist(index + 1),
      ];
    });
    _saveChecklists();
  }

  void _renameChecklist(int index) {
    final controller = TextEditingController(text: _checklists[index].name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Checklist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Checklist name'),
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
                setState(() {
                  _checklists = _replaceAt(
                    index,
                    _checklists[index].copyWith(name: name),
                  );
                });
                _saveChecklists();
              }
              Navigator.pop(context);
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _reorderChecklists(int oldIndex, int newIndex) {
    setState(() {
      final item = _checklists[oldIndex];
      final newList = List<Checklist>.from(_checklists);
      newList.removeAt(oldIndex);
      newList.insert(newIndex, item);
      _checklists = newList;
    });
    _saveChecklists();
  }

  void _onChecklistChanged(int index, Checklist updated) {
    setState(() {
      _checklists = _replaceAt(index, updated);
    });
    _saveChecklists();
  }

  void _openChecklist(int index) {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => ChecklistScreen(
          checklist: _checklists[index],
          onChanged: (updated) => _onChecklistChanged(index, updated),
        ),
      ),
    );
  }

  void _openSettings() {
    Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showUpdateBadge =
        context.watch<UpdateService>().status == UpdateStatus.updateAvailable;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checklists'),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: showUpdateBadge,
              child: const Icon(Icons.settings),
            ),
            onPressed: _openSettings,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _checklists.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('No checklists yet'),
                      SizedBox(height: 8),
                      Text('Tap + to create one'),
                    ],
                  ),
                )
              : ReorderableListView.builder(
                  itemCount: _checklists.length,
                  onReorderItem: _reorderChecklists,
                  itemBuilder: (context, index) {
                    return ChecklistTile(
                      key: ValueKey(_checklists[index].name + index.toString()),
                      checklist: _checklists[index],
                      onTap: () => _openChecklist(index),
                      onDelete: () => _deleteChecklist(index),
                      onRename: () => _renameChecklist(index),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addChecklist,
        child: const Icon(Icons.add),
      ),
    );
  }
}
