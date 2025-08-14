abstract class BaseItem {
  String get id;
  String get name;
  bool get isCompleted;
  
  BaseItem copyWithCompletion({required bool isCompleted});
  Map<String, dynamic> toJson();
}