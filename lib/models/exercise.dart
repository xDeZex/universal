import 'base_item.dart';
import 'weight_entry.dart';

class Exercise implements BaseItem {
  @override
  final String id;
  @override
  final String name;
  final String? sets;
  final String? reps;
  final String? weight;
  final String? notes;
  final List<WeightEntry> weightHistory;
  @override
  final bool isCompleted;

  const Exercise({
    required this.id,
    required this.name,
    this.sets,
    this.reps,
    this.weight,
    this.notes,
    this.weightHistory = const [],
    this.isCompleted = false,
  });

  Exercise copyWith({
    String? id,
    String? name,
    String? sets,
    String? reps,
    String? weight,
    String? notes,
    List<WeightEntry>? weightHistory,
    bool? isCompleted,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      notes: notes ?? this.notes,
      weightHistory: weightHistory ?? this.weightHistory,
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
      'weightHistory': weightHistory.map((entry) => entry.toJson()).toList(),
      'isCompleted': isCompleted,
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    List<WeightEntry> weightHistory = <WeightEntry>[];
    
    if (json.containsKey('weightHistory') && json['weightHistory'] != null) {
      final weightHistoryList = json['weightHistory'] as List<dynamic>;
      weightHistory = weightHistoryList
          .map((entry) => WeightEntry.fromJson(entry as Map<String, dynamic>))
          .toList();
    }

    return Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      sets: json['sets'] as String?,
      reps: json['reps'] as String?,
      weight: json['weight'] as String?,
      notes: json['notes'] as String?,
      weightHistory: weightHistory,
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
          weightHistory == other.weightHistory &&
          isCompleted == other.isCompleted;

  @override
  int get hashCode => Object.hash(id, name, sets, reps, weight, notes, weightHistory, isCompleted);

  @override
  String toString() {
    return 'Exercise{id: $id, name: $name, sets: $sets, reps: $reps, weight: $weight, notes: $notes, weightHistory: $weightHistory, isCompleted: $isCompleted}';
  }

  WeightEntry? get todaysWeight {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));
    
    return weightHistory
        .where((entry) => entry.date.isAfter(todayStart) && entry.date.isBefore(todayEnd))
        .lastOrNull;
  }
}