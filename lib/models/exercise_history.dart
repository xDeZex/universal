import 'weight_entry.dart';

class ExerciseHistory {
  final String exerciseName;
  final List<WeightEntry> weightHistory;
  final DateTime createdAt;
  final DateTime lastUsed;

  const ExerciseHistory({
    required this.exerciseName,
    required this.weightHistory,
    required this.createdAt,
    required this.lastUsed,
  });

  ExerciseHistory copyWith({
    String? exerciseName,
    List<WeightEntry>? weightHistory,
    DateTime? createdAt,
    DateTime? lastUsed,
  }) {
    return ExerciseHistory(
      exerciseName: exerciseName ?? this.exerciseName,
      weightHistory: weightHistory ?? this.weightHistory,
      createdAt: createdAt ?? this.createdAt,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exerciseName': exerciseName,
      'weightHistory': weightHistory.map((entry) => entry.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'lastUsed': lastUsed.toIso8601String(),
    };
  }

  factory ExerciseHistory.fromJson(Map<String, dynamic> json) {
    return ExerciseHistory(
      exerciseName: json['exerciseName'] as String,
      weightHistory: (json['weightHistory'] as List<dynamic>?)
              ?.map((entryJson) => WeightEntry.fromJson(entryJson as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUsed: DateTime.parse(json['lastUsed'] as String),
    );
  }

  WeightEntry? get todaysWeight {
    final now = DateTime.now();
    return weightHistory.cast<WeightEntry?>().firstWhere(
      (entry) => entry != null && 
                 entry.date.year == now.year && 
                 entry.date.month == now.month && 
                 entry.date.day == now.day,
      orElse: () => null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExerciseHistory &&
        other.exerciseName == exerciseName &&
        other.weightHistory.length == weightHistory.length &&
        other.createdAt == createdAt &&
        other.lastUsed == lastUsed;
  }

  @override
  int get hashCode {
    return Object.hash(
      exerciseName,
      weightHistory.length,
      createdAt,
      lastUsed,
    );
  }
}