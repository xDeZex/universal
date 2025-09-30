import 'package:flutter/material.dart';

enum CalendarEventType {
  workout,
  restDay,
  general,
}

class CalendarEvent {
  final String id;
  final String title;
  final DateTime date;
  final String trainingSplitId;
  final CalendarEventType type;
  final String? description;
  final String? time; // Optional time (e.g., "14:30", "2:30 PM") - DEPRECATED
  final TimeOfDay? startTime; // Start time for the event
  final Duration? duration; // Duration of the event (null = all day)
  final bool isAllDay; // Whether this is an all-day event
  final bool isCompleted;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.trainingSplitId,
    this.type = CalendarEventType.general,
    this.description,
    this.time,
    this.startTime,
    this.duration,
    this.isAllDay = true,
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

  /// Get the end time of the event (null if all-day or no duration)
  TimeOfDay? get endTime {
    if (isAllDay || startTime == null || duration == null) return null;

    final startMinutes = startTime!.hour * 60 + startTime!.minute;
    final endMinutes = startMinutes + duration!.inMinutes;

    return TimeOfDay(
      hour: (endMinutes ~/ 60) % 24,
      minute: endMinutes % 60,
    );
  }

  /// Get a formatted time string for display
  String get timeDisplayString {
    if (isAllDay) return 'All day';

    // Use new time fields if available
    if (startTime != null) {
      if (duration == null) {
        return _formatTimeOfDay(startTime!);
      }

      final end = endTime;
      if (end == null) return _formatTimeOfDay(startTime!);

      return '${_formatTimeOfDay(startTime!)} - ${_formatTimeOfDay(end)}';
    }

    // Fallback to legacy time field for backward compatibility
    if (time != null && time!.isNotEmpty) {
      return time!;
    }

    return '';
  }

  /// Format TimeOfDay to 24-hour format string
  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

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
    String? time,
    TimeOfDay? startTime,
    Duration? duration,
    bool? isAllDay,
    bool? isCompleted,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      trainingSplitId: trainingSplitId ?? this.trainingSplitId,
      type: type ?? this.type,
      description: description ?? this.description,
      time: time ?? this.time,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
      isAllDay: isAllDay ?? this.isAllDay,
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
      'time': time,
      'startTime': startTime != null ? '${startTime!.hour}:${startTime!.minute}' : null,
      'duration': duration?.inMinutes,
      'isAllDay': isAllDay,
      'isCompleted': isCompleted,
    };
  }

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    TimeOfDay? startTime;
    if (json['startTime'] != null) {
      try {
        final parts = (json['startTime'] as String).split(':');
        startTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      } catch (e) {
        // Ignore parsing errors for backward compatibility
        startTime = null;
      }
    }

    Duration? duration;
    if (json['duration'] != null) {
      try {
        duration = Duration(minutes: json['duration'] as int);
      } catch (e) {
        // Ignore parsing errors for backward compatibility
        duration = null;
      }
    }

    // For backward compatibility, if isAllDay is not present, determine based on other fields
    bool isAllDay = true;
    if (json.containsKey('isAllDay')) {
      isAllDay = json['isAllDay'] as bool? ?? true;
    } else {
      // Legacy events: if they have time data, they're not all-day
      isAllDay = json['time'] == null && startTime == null;
    }

    return CalendarEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      trainingSplitId: json['trainingSplitId'] as String,
      type: CalendarEventType.values.byName(json['type'] as String),
      description: json['description'] as String?,
      time: json['time'] as String?,
      startTime: startTime,
      duration: duration,
      isAllDay: isAllDay,
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
           time == other.time &&
           startTime == other.startTime &&
           duration == other.duration &&
           isAllDay == other.isAllDay &&
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
      time,
      startTime,
      duration,
      isAllDay,
      isCompleted,
    );
  }

  @override
  String toString() {
    return 'CalendarEvent{id: $id, title: $title, date: $date, '
           'trainingSplitId: $trainingSplitId, type: $type, '
           'description: $description, time: $time, startTime: $startTime, '
           'duration: $duration, isAllDay: $isAllDay, isCompleted: $isCompleted}';
  }
}