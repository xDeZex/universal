class WeightEntry {
  final DateTime date;
  final String weight;
  final int? sets;
  final int? reps;

  const WeightEntry({
    required this.date,
    required this.weight,
    this.sets,
    this.reps,
  });

  WeightEntry copyWith({
    DateTime? date,
    String? weight,
    int? sets,
    int? reps,
  }) {
    return WeightEntry(
      date: date ?? this.date,
      weight: weight ?? this.weight,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'weight': weight,
      if (sets != null) 'sets': sets,
      if (reps != null) 'reps': reps,
    };
  }

  factory WeightEntry.fromJson(Map<String, dynamic> json) {
    return WeightEntry(
      date: DateTime.parse(json['date'] as String),
      weight: json['weight'] as String,
      sets: json['sets'] as int?,
      reps: json['reps'] as int?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeightEntry &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          weight == other.weight &&
          sets == other.sets &&
          reps == other.reps;

  @override
  int get hashCode => Object.hash(date, weight, sets, reps);

  @override
  String toString() {
    return 'WeightEntry{date: $date, weight: $weight, sets: $sets, reps: $reps}';
  }
}