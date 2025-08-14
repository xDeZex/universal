import 'base_item.dart';

class ShoppingItem implements BaseItem {
  @override
  final String id;
  @override
  final String name;
  @override
  final bool isCompleted;

  const ShoppingItem({
    required this.id,
    required this.name,
    this.isCompleted = false,
  });

  ShoppingItem copyWith({
    String? id,
    String? name,
    bool? isCompleted,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  BaseItem copyWithCompletion({required bool isCompleted}) {
    return copyWith(isCompleted: isCompleted);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isCompleted': isCompleted,
    };
  }

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      id: json['id'] as String,
      name: json['name'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}