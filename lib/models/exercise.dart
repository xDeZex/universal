import 'base_item.dart';

class Exercise implements BaseItem {
  @override
  final String id;
  @override
  final String name;
  final String? sets;
  final String? reps;
  final String? weight;
  final String? notes;
  @override
  final bool isCompleted;

  const Exercise({
    required this.id,
    required this.name,
    this.sets,
    this.reps,
    this.weight,
    this.notes,
    this.isCompleted = false,
  });

  Exercise copyWith({
    String? id,
    String? name,
    String? sets,
    String? reps,
    String? weight,
    String? notes,
    bool? isCompleted,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      notes: notes ?? this.notes,
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
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'notes': notes,
      'isCompleted': isCompleted,
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      sets: json['sets'] as String?,
      reps: json['reps'] as String?,
      weight: json['weight'] as String?,
      notes: json['notes'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Exercise &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          sets == other.sets &&
          reps == other.reps &&
          weight == other.weight &&
          notes == other.notes &&
          isCompleted == other.isCompleted;

  @override
  int get hashCode => Object.hash(id, name, sets, reps, weight, notes, isCompleted);

  @override
  String toString() {
    return 'Exercise{id: $id, name: $name, sets: $sets, reps: $reps, weight: $weight, notes: $notes, isCompleted: $isCompleted}';
  }
}