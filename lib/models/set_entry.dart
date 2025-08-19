class SetEntry {
  final int reps;
  final String? weight;
  final String? notes;

  const SetEntry({
    required this.reps,
    this.weight,
    this.notes,
  });

  SetEntry copyWith({
    int? reps,
    String? weight,
    String? notes,
  }) {
    return SetEntry(
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reps': reps,
      if (weight != null) 'weight': weight,
      if (notes != null) 'notes': notes,
    };
  }

  factory SetEntry.fromJson(Map<String, dynamic> json) {
    return SetEntry(
      reps: json['reps'] as int,
      weight: json['weight'] as String?,
      notes: json['notes'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SetEntry &&
          runtimeType == other.runtimeType &&
          reps == other.reps &&
          weight == other.weight &&
          notes == other.notes;

  @override
  int get hashCode => Object.hash(reps, weight, notes);

  @override
  String toString() {
    return 'SetEntry{reps: $reps, weight: $weight, notes: $notes}';
  }
}