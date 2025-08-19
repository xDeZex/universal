import 'package:collection/collection.dart';
import 'set_entry.dart';

class WeightEntry {
  final DateTime date;
  final String weight;
  final List<SetEntry> setEntries;

  const WeightEntry({
    required this.date,
    required this.weight,
    this.setEntries = const [],
  });

  WeightEntry copyWith({
    DateTime? date,
    String? weight,
    List<SetEntry>? setEntries,
  }) {
    return WeightEntry(
      date: date ?? this.date,
      weight: weight ?? this.weight,
      setEntries: setEntries ?? this.setEntries,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'weight': weight,
      if (setEntries.isNotEmpty) 'setEntries': setEntries.map((e) => e.toJson()).toList(),
    };
  }

  factory WeightEntry.fromJson(Map<String, dynamic> json) {
    List<SetEntry> setEntries = <SetEntry>[];
    
    if (json.containsKey('setEntries') && json['setEntries'] != null) {
      final setEntriesList = json['setEntries'] as List<dynamic>;
      setEntries = setEntriesList
          .map((entry) => SetEntry.fromJson(entry as Map<String, dynamic>))
          .toList();
    } else if (json.containsKey('sets') && json.containsKey('reps')) {
      // Handle backward compatibility: convert old format to new format
      final sets = json['sets'] as int?;
      final reps = json['reps'] as int?;
      if (sets != null && reps != null) {
        // Create SetEntry objects from the old sets/reps format
        for (int i = 0; i < sets; i++) {
          setEntries.add(SetEntry(reps: reps));
        }
      }
    }

    return WeightEntry(
      date: DateTime.parse(json['date'] as String),
      weight: json['weight'] as String,
      setEntries: setEntries,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeightEntry &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          weight == other.weight &&
          const ListEquality().equals(setEntries, other.setEntries);

  @override
  int get hashCode => Object.hash(date, weight, const ListEquality().hash(setEntries));

  @override
  String toString() {
    return 'WeightEntry{date: $date, weight: $weight, setEntries: $setEntries}';
  }

  /// Returns true if this entry uses the new format with individual sets
  bool get hasDetailedSets => setEntries.isNotEmpty;

  /// Gets the total number of sets performed
  int get totalSets => setEntries.length;

  /// Gets the total reps performed across all sets
  int get totalReps => setEntries.fold(0, (sum, set) => sum + set.reps);

  /// Gets a formatted string showing sets and reps
  String get setsRepsDisplay {
    if (setEntries.isEmpty) {
      return '';
    }
    return setEntries.map((set) => '${set.reps}').join(', ');
  }
}