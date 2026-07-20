import 'unique_name.dart';
import 'workout.dart';

sealed class RepsTarget {
  const RepsTarget();

  Map<String, dynamic> toJson();

  factory RepsTarget.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    switch (type) {
      case 'fixed':
        return FixedReps.fromJson(json);
      case 'range':
        return RangeReps.fromJson(json);
      default:
        throw ArgumentError.value(type, 'type', 'Unrecognized RepsTarget type');
    }
  }
}

class FixedReps extends RepsTarget {
  final int reps;

  const FixedReps(this.reps);

  @override
  Map<String, dynamic> toJson() => {'type': 'fixed', 'reps': reps};

  factory FixedReps.fromJson(Map<String, dynamic> json) {
    return FixedReps(json['reps'] as int);
  }
}

enum RangeRepsError { invalidRange }

class RangeReps extends RepsTarget {
  final int min;
  final int max;

  const RangeReps({required this.min, required this.max});

  @override
  Map<String, dynamic> toJson() => {'type': 'range', 'min': min, 'max': max};

  factory RangeReps.fromJson(Map<String, dynamic> json) {
    return RangeReps(min: json['min'] as int, max: json['max'] as int);
  }

  static RangeRepsError? validate({required int min, required int max}) {
    if (min >= max) return RangeRepsError.invalidRange;
    return null;
  }
}

class PlannedWeight {
  final num value;
  final WeightUnit unit;

  const PlannedWeight({required this.value, required this.unit});

  Map<String, dynamic> toJson() => {'value': value, 'unit': unit.name};

  factory PlannedWeight.fromJson(Map<String, dynamic> json) {
    return PlannedWeight(
      value: json['value'] as num,
      unit: WeightUnit.values.byName(json['unit'] as String),
    );
  }
}

class PlannedExerciseRow {
  static const defaultWeight = PlannedWeight(value: 0, unit: WeightUnit.kg);

  final RepsTarget reps;
  final PlannedWeight weight;

  const PlannedExerciseRow({required this.reps, required this.weight});

  PlannedExerciseRow copyWith({RepsTarget? reps, PlannedWeight? weight}) {
    return PlannedExerciseRow(
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
    );
  }

  Map<String, dynamic> toJson() => {
    'reps': reps.toJson(),
    'weight': weight.toJson(),
  };

  factory PlannedExerciseRow.fromJson(Map<String, dynamic> json) {
    return PlannedExerciseRow(
      reps: RepsTarget.fromJson(json['reps'] as Map<String, dynamic>),
      weight: json['weight'] == null
          ? defaultWeight
          : PlannedWeight.fromJson(json['weight'] as Map<String, dynamic>),
    );
  }
}

class PlannedExercise {
  final String id;
  final String exerciseId;
  final List<PlannedExerciseRow> rows;

  const PlannedExercise({
    required this.id,
    required this.exerciseId,
    this.rows = const [],
  });

  PlannedExercise copyWith({
    String? exerciseId,
    List<PlannedExerciseRow>? rows,
  }) {
    return PlannedExercise(
      id: id,
      exerciseId: exerciseId ?? this.exerciseId,
      rows: rows ?? this.rows,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'exerciseId': exerciseId,
    'rows': rows.map((row) => row.toJson()).toList(),
  };

  factory PlannedExercise.fromJson(Map<String, dynamic> json) {
    return PlannedExercise(
      id: json['id'] as String,
      exerciseId: json['exerciseId'] as String,
      rows: (json['rows'] as List)
          .map(
            (row) => PlannedExerciseRow.fromJson(row as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

enum RoutineRenameError { blank, duplicate }

/// Sentinel distinguishing "archivedAt not passed" from "archivedAt passed
/// as null" in [Routine.copyWith], since the field must be explicitly
/// clearable to unarchive a Routine.
class _Unset {
  const _Unset();
}

const _unset = _Unset();

class Routine {
  final String id;
  final String name;
  final List<PlannedExercise> plannedExercises;
  final DateTime? archivedAt;

  const Routine({
    required this.id,
    required this.name,
    this.plannedExercises = const [],
    this.archivedAt,
  });

  bool get isLocked => archivedAt != null;

  RoutineRenameError? validateRename(String newName, List<Routine> existing) {
    return _toRenameError(
      validateUniqueName<Routine>(
        candidate: newName,
        existing: existing,
        nameOf: (r) => r.name,
        excludeWhere: (r) => r.id == id,
      ),
    );
  }

  /// Validates a name for a not-yet-created Routine, with no id of its own
  /// to exclude from the collision check.
  static RoutineRenameError? validateNewName(
    String name,
    List<Routine> existing,
  ) {
    return _toRenameError(
      validateUniqueName<Routine>(
        candidate: name,
        existing: existing,
        nameOf: (r) => r.name,
      ),
    );
  }

  static RoutineRenameError? _toRenameError(UniqueNameError? error) {
    return switch (error) {
      UniqueNameError.blank => RoutineRenameError.blank,
      UniqueNameError.duplicate => RoutineRenameError.duplicate,
      null => null,
    };
  }

  Routine copyWith({
    String? name,
    List<PlannedExercise>? plannedExercises,
    Object? archivedAt = _unset,
  }) {
    return Routine(
      id: id,
      name: name ?? this.name,
      plannedExercises: plannedExercises ?? this.plannedExercises,
      archivedAt: identical(archivedAt, _unset)
          ? this.archivedAt
          : archivedAt as DateTime?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'plannedExercises': plannedExercises.map((pe) => pe.toJson()).toList(),
    'archivedAt': archivedAt?.toIso8601String(),
  };

  factory Routine.fromJson(Map<String, dynamic> json) {
    return Routine(
      id: json['id'] as String,
      name: json['name'] as String,
      plannedExercises: (json['plannedExercises'] as List)
          .map((pe) => PlannedExercise.fromJson(pe as Map<String, dynamic>))
          .toList(),
      archivedAt: json['archivedAt'] == null
          ? null
          : DateTime.parse(json['archivedAt'] as String),
    );
  }
}
