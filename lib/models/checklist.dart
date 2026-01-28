class ChecklistItem {
  final String name;
  final bool isChecked;

  const ChecklistItem({
    required this.name,
    this.isChecked = false,
  });

  ChecklistItem copyWith({String? name, bool? isChecked}) {
    return ChecklistItem(
      name: name ?? this.name,
      isChecked: isChecked ?? this.isChecked,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'isChecked': isChecked};
  }

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      name: json['name'] as String,
      isChecked: json['isChecked'] as bool,
    );
  }
}

class Checklist {
  final String name;
  final List<ChecklistItem> items;

  const Checklist({
    required this.name,
    this.items = const [],
  });

  List<ChecklistItem> get uncheckedItems =>
      items.where((item) => !item.isChecked).toList();

  List<ChecklistItem> get checkedItems =>
      items.where((item) => item.isChecked).toList();

  List<ChecklistItem> get orderedItems => [...uncheckedItems, ...checkedItems];

  int get uncheckedCount => uncheckedItems.length;

  int get totalCount => items.length;

  Checklist? addItem(String itemName) {
    final trimmed = itemName.trim();
    if (trimmed.isEmpty) {
      return Checklist(name: name, items: items);
    }

    if (_hasDuplicate(trimmed)) {
      return null;
    }

    return Checklist(
      name: name,
      items: [...items, ChecklistItem(name: trimmed)],
    );
  }

  bool _hasDuplicate(String itemName) {
    return items.any(
      (item) => item.name.toLowerCase() == itemName.toLowerCase(),
    );
  }

  Checklist removeItem(String itemName) {
    return Checklist(
      name: name,
      items: items.where((item) => item.name != itemName).toList(),
    );
  }

  Checklist toggleItem(String itemName) {
    final item = items.firstWhere((i) => i.name == itemName);
    final toggled = item.copyWith(isChecked: !item.isChecked);

    final unchecked = uncheckedItems.where((i) => i.name != itemName).toList();
    final checked = checkedItems.where((i) => i.name != itemName).toList();

    if (toggled.isChecked) {
      // Checking: add to TOP of Done
      return Checklist(name: name, items: [...unchecked, toggled, ...checked]);
    } else {
      // Unchecking: add to BOTTOM of To Do
      return Checklist(name: name, items: [...unchecked, toggled, ...checked]);
    }
  }

  Checklist reorderUnchecked(int oldIndex, int newIndex) {
    final unchecked = uncheckedItems.toList();
    final checked = checkedItems;

    if (newIndex > oldIndex) newIndex--;
    final item = unchecked.removeAt(oldIndex);
    unchecked.insert(newIndex, item);

    return Checklist(name: name, items: [...unchecked, ...checked]);
  }

  Checklist reorderChecked(int oldIndex, int newIndex) {
    final unchecked = uncheckedItems;
    final checked = checkedItems.toList();

    if (newIndex > oldIndex) newIndex--;
    final item = checked.removeAt(oldIndex);
    checked.insert(newIndex, item);

    return Checklist(name: name, items: [...unchecked, ...checked]);
  }

  Checklist copyWith({String? name, List<ChecklistItem>? items}) {
    return Checklist(
      name: name ?? this.name,
      items: items ?? this.items,
    );
  }

  Checklist? findDuplicateAndUncheck(String itemName) {
    final lowerName = itemName.toLowerCase();
    final index = items.indexWhere(
      (item) => item.name.toLowerCase() == lowerName,
    );

    if (index == -1) return null;

    final newItems = items.toList();
    newItems[index] = newItems[index].copyWith(isChecked: false);

    return Checklist(name: name, items: newItems);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  factory Checklist.fromJson(Map<String, dynamic> json) {
    return Checklist(
      name: json['name'] as String,
      items: (json['items'] as List)
          .map((item) => ChecklistItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
