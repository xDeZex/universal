import 'exercise.dart';
import 'base_list.dart';

class WorkoutList with BaseListMixin<Exercise> implements BaseList<Exercise> {
  @override
  final String id;
  @override
  final String name;
  final List<Exercise> exercises;
  @override
  final DateTime createdAt;

  const WorkoutList({
    required this.id,
    required this.name,
    required this.exercises,
    required this.createdAt,
  });

  WorkoutList copyWith({
    String? id,
    String? name,
    List<Exercise>? exercises,
    DateTime? createdAt,
  }) {
    return WorkoutList(
      id: id ?? this.id,
      name: name ?? this.name,
      exercises: exercises ?? this.exercises,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Exercise> get items => exercises;

  int get totalExercises => exercises.length;

  int get completedExercises => exercises.where((exercise) => exercise.isCompleted).length;

  @override
  BaseList<Exercise> copyWithItems({required List<Exercise> items}) {
    return copyWith(exercises: items);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'exercises': exercises.map((exercise) => exercise.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory WorkoutList.fromJson(Map<String, dynamic> json) {
    return WorkoutList(
      id: json['id'] as String,
      name: json['name'] as String,
      exercises: (json['exercises'] as List<dynamic>? ?? [])
          .map((exerciseJson) => Exercise.fromJson(exerciseJson as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutList &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          exercises == other.exercises &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(id, name, exercises, createdAt);

  @override
  String toString() {
    return 'WorkoutList{id: $id, name: $name, exercises: $exercises, createdAt: $createdAt}';
  }
}