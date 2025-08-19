enum CalendarEventType {
  workout,
  restDay,
}

class CalendarEvent {
  final String id;
  final String title;
  final DateTime date;
  final String trainingSplitId;
  final CalendarEventType type;
  final String? description;
  final bool isCompleted;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.trainingSplitId,
    this.type = CalendarEventType.workout,
    this.description,
    this.isCompleted = false,
  }) {
    if (id.isEmpty) {
      throw ArgumentError('Calendar event id cannot be empty');
    }
    
    if (title.isEmpty) {
      throw ArgumentError('Calendar event title cannot be empty');
    }
  }

  bool get isWorkout => type == CalendarEventType.workout;

  String get dateString {
    return '${date.year.toString().padLeft(4, '0')}-'
           '${date.month.toString().padLeft(2, '0')}-'
           '${date.day.toString().padLeft(2, '0')}';
  }

  bool isOnDate(DateTime targetDate) {
    return date.year == targetDate.year &&
           date.month == targetDate.month &&
           date.day == targetDate.day;
  }

  CalendarEvent copyWith({
    String? id,
    String? title,
    DateTime? date,
    String? trainingSplitId,
    CalendarEventType? type,
    String? description,
    bool? isCompleted,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      trainingSplitId: trainingSplitId ?? this.trainingSplitId,
      type: type ?? this.type,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'trainingSplitId': trainingSplitId,
      'type': type.name,
      'description': description,
      'isCompleted': isCompleted,
    };
  }

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      trainingSplitId: json['trainingSplitId'] as String,
      type: CalendarEventType.values.byName(json['type'] as String),
      description: json['description'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CalendarEvent) return false;

    return id == other.id &&
           title == other.title &&
           date == other.date &&
           trainingSplitId == other.trainingSplitId &&
           type == other.type &&
           description == other.description &&
           isCompleted == other.isCompleted;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      date,
      trainingSplitId,
      type,
      description,
      isCompleted,
    );
  }

  @override
  String toString() {
    return 'CalendarEvent{id: $id, title: $title, date: $date, '
           'trainingSplitId: $trainingSplitId, type: $type, '
           'description: $description, isCompleted: $isCompleted}';
  }
}