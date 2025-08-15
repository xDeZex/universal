class WeightEntry {
  final DateTime date;
  final String weight;

  const WeightEntry({
    required this.date,
    required this.weight,
  });

  WeightEntry copyWith({
    DateTime? date,
    String? weight,
  }) {
    return WeightEntry(
      date: date ?? this.date,
      weight: weight ?? this.weight,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'weight': weight,
    };
  }

  factory WeightEntry.fromJson(Map<String, dynamic> json) {
    return WeightEntry(
      date: DateTime.parse(json['date'] as String),
      weight: json['weight'] as String,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeightEntry &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          weight == other.weight;

  @override
  int get hashCode => Object.hash(date, weight);

  @override
  String toString() {
    return 'WeightEntry{date: $date, weight: $weight}';
  }
}