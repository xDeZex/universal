class TrainingSplit {
  final String id;
  final String name;
  final List<String> workouts;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  TrainingSplit({
    required this.id,
    required this.name,
    required this.workouts,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
  }) {
    if (name.isEmpty) {
      throw ArgumentError('Training split name cannot be empty');
    }
    
    if (workouts.isEmpty) {
      throw ArgumentError('Training split must have at least one workout');
    }
    
    if (endDate.isBefore(startDate)) {
      throw ArgumentError('End date must be after start date');
    }
  }

  int get durationInDays {
    return endDate.difference(startDate).inDays + 1;
  }

  bool containsDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final startOnly = DateTime(startDate.year, startDate.month, startDate.day);
    final endOnly = DateTime(endDate.year, endDate.month, endDate.day);
    
    return (dateOnly.isAtSameMomentAs(startOnly) || dateOnly.isAfter(startOnly)) &&
           (dateOnly.isAtSameMomentAs(endOnly) || dateOnly.isBefore(endOnly));
  }

  String getWorkoutForDay(int dayIndex) {
    return workouts[dayIndex % workouts.length];
  }

  String? getWorkoutForDate(DateTime date) {
    if (!containsDate(date)) {
      return null;
    }
    
    final daysSinceStart = date.difference(startDate).inDays;
    return getWorkoutForDay(daysSinceStart);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'workouts': workouts,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory TrainingSplit.fromJson(Map<String, dynamic> json) {
    return TrainingSplit(
      id: json['id'] as String,
      name: json['name'] as String,
      workouts: List<String>.from(json['workouts'] as List),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TrainingSplit) return false;

    return id == other.id &&
           name == other.name &&
           _listEquals(workouts, other.workouts) &&
           startDate == other.startDate &&
           endDate == other.endDate &&
           isActive == other.isActive;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      Object.hashAll(workouts),
      startDate,
      endDate,
      isActive,
    );
  }

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }

  @override
  String toString() {
    return 'TrainingSplit{id: $id, name: $name, workouts: $workouts, '
           'startDate: $startDate, endDate: $endDate, isActive: $isActive}';
  }
}