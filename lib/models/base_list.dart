import 'base_item.dart';

mixin BaseListMixin<T extends BaseItem> {
  List<T> get items;
  
  int get totalItems => items.length;
  int get completedItems => items.where((item) => item.isCompleted).length;
  bool get isCompleted => items.isNotEmpty && completedItems == totalItems;
}

abstract class BaseList<T extends BaseItem> {
  String get id;
  String get name;
  List<T> get items;
  DateTime get createdAt;
  
  BaseList<T> copyWithItems({required List<T> items});
  Map<String, dynamic> toJson();
}