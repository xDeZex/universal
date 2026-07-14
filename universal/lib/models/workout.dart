enum WeightUnit { kg, lbs }

class ExerciseSet {
  final String id;
  final num weight;
  final WeightUnit unit;
  final int reps;
  final DateTime loggedAt;

  const ExerciseSet({
    required this.id,
    required this.weight,
    required this.unit,
    required this.reps,
    required this.loggedAt,
  });

  ExerciseSet copyWith({
    num? weight,
    WeightUnit? unit,
    int? reps,
    DateTime? loggedAt,
  }) {
    return ExerciseSet(
      id: id,
      weight: weight ?? this.weight,
      unit: unit ?? this.unit,
      reps: reps ?? this.reps,
      loggedAt: loggedAt ?? this.loggedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'weight': weight,
      'unit': unit.name,
      'reps': reps,
      'loggedAt': loggedAt.toIso8601String(),
    };
  }

  factory ExerciseSet.fromJson(Map<String, dynamic> json) {
    return ExerciseSet(
      id: json['id'] as String,
      weight: json['weight'] as num,
      unit: WeightUnit.values.byName(json['unit'] as String),
      reps: json['reps'] as int,
      loggedAt: DateTime.parse(json['loggedAt'] as String),
    );
  }
}

class ExerciseEntry {
  final String id;
  final String exerciseId;
  final List<ExerciseSet> sets;

  const ExerciseEntry({
    required this.id,
    required this.exerciseId,
    this.sets = const [],
  });

  ExerciseEntry copyWith({String? exerciseId, List<ExerciseSet>? sets}) {
    return ExerciseEntry(
      id: id,
      exerciseId: exerciseId ?? this.exerciseId,
      sets: sets ?? this.sets,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exerciseId': exerciseId,
      'sets': sets.map((set) => set.toJson()).toList(),
    };
  }

  factory ExerciseEntry.fromJson(Map<String, dynamic> json) {
    return ExerciseEntry(
      id: json['id'] as String,
      exerciseId: json['exerciseId'] as String,
      sets: (json['sets'] as List)
          .map((set) => ExerciseSet.fromJson(set as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Workout {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final List<ExerciseEntry> exerciseEntries;

  const Workout({
    required this.id,
    required this.startTime,
    this.endTime,
    this.exerciseEntries = const [],
  });

  bool get isInProgress => endTime == null;

  /// Finds the Exercise Entry with [entryId], or throws if none matches.
  ExerciseEntry _entryOrThrow(String entryId) {
    return exerciseEntries.firstWhere(
      (entry) => entry.id == entryId,
      orElse: () => throw ArgumentError.value(
        entryId,
        'entryId',
        'No Exercise Entry with this id',
      ),
    );
  }

  /// Rebuilds [exerciseEntries] with the entry matching [entryId] replaced
  /// by the result of [update]. Throws if no entry matches.
  Workout _withEntry(
    String entryId,
    ExerciseEntry Function(ExerciseEntry entry) update,
  ) {
    _entryOrThrow(entryId);
    return copyWith(
      exerciseEntries: exerciseEntries
          .map((entry) => entry.id == entryId ? update(entry) : entry)
          .toList(),
    );
  }

  Workout addSet({
    required String entryId,
    required num weight,
    required WeightUnit unit,
    required int reps,
  }) {
    final newSet = ExerciseSet(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      weight: weight,
      unit: unit,
      reps: reps,
      loggedAt: DateTime.now(),
    );

    return _withEntry(
      entryId,
      (entry) => entry.copyWith(sets: [...entry.sets, newSet]),
    );
  }

  Workout editSet({
    required String entryId,
    required String setId,
    required num weight,
    required WeightUnit unit,
    required int reps,
  }) {
    return _withEntry(entryId, (entry) {
      if (!entry.sets.any((set) => set.id == setId)) {
        throw ArgumentError.value(setId, 'setId', 'No Set with this id');
      }
      return entry.copyWith(
        sets: entry.sets
            .map(
              (set) => set.id == setId
                  ? set.copyWith(weight: weight, unit: unit, reps: reps)
                  : set,
            )
            .toList(),
      );
    });
  }

  Workout deleteSet({required String entryId, required String setId}) {
    return _withEntry(entryId, (entry) {
      if (!entry.sets.any((set) => set.id == setId)) {
        throw ArgumentError.value(setId, 'setId', 'No Set with this id');
      }
      return entry.copyWith(
        sets: entry.sets.where((set) => set.id != setId).toList(),
      );
    });
  }

  Workout deleteExerciseEntry({required String entryId}) {
    _entryOrThrow(entryId);
    return copyWith(
      exerciseEntries: exerciseEntries
          .where((entry) => entry.id != entryId)
          .toList(),
    );
  }

  Workout? finish() {
    final allSets = exerciseEntries.expand((entry) => entry.sets);
    if (allSets.isEmpty) {
      return null;
    }

    final mostRecent = allSets.reduce(
      (a, b) => b.loggedAt.isAfter(a.loggedAt) ? b : a,
    );

    return copyWith(endTime: mostRecent.loggedAt);
  }

  Workout copyWith({DateTime? endTime, List<ExerciseEntry>? exerciseEntries}) {
    return Workout(
      id: id,
      startTime: startTime,
      endTime: endTime ?? this.endTime,
      exerciseEntries: exerciseEntries ?? this.exerciseEntries,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'exerciseEntries': exerciseEntries.map((e) => e.toJson()).toList(),
    };
  }

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      exerciseEntries: (json['exerciseEntries'] as List)
          .map((e) => ExerciseEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
