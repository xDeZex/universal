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
  final RepsTarget reps;
  final PlannedWeight? weight;

  const PlannedExerciseRow({required this.reps, this.weight});

  PlannedExerciseRow copyWith({RepsTarget? reps, PlannedWeight? weight}) {
    return PlannedExerciseRow(
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
    );
  }

  Map<String, dynamic> toJson() => {
    'reps': reps.toJson(),
    'weight': weight?.toJson(),
  };

  factory PlannedExerciseRow.fromJson(Map<String, dynamic> json) {
    return PlannedExerciseRow(
      reps: RepsTarget.fromJson(json['reps'] as Map<String, dynamic>),
      weight: json['weight'] == null
          ? null
          : PlannedWeight.fromJson(json['weight'] as Map<String, dynamic>),
    );
  }
}
