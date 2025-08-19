import '../models/training_split.dart';
import '../models/calendar_event.dart';
import '../utils/id_generator.dart';

class TrainingSplitService {
  final Map<String, TrainingSplit> _trainingSplits = {};
  final Map<String, CalendarEvent> _calendarEvents = {};

  List<CalendarEvent> generateCalendarEvents(TrainingSplit split) {
    final events = <CalendarEvent>[];
    
    for (int i = 0; i < split.durationInDays; i++) {
      final date = split.startDate.add(Duration(days: i));
      final workout = split.getWorkoutForDay(i);
      
      final event = CalendarEvent(
        id: IdGenerator.generateUniqueId(),
        title: workout,
        date: date,
        trainingSplitId: split.id,
        type: CalendarEventType.workout,
      );
      
      events.add(event);
    }
    
    return events;
  }

  List<CalendarEvent> generateCalendarEventsWithRestDays(
    TrainingSplit split, {
    required List<bool> restDayPattern,
  }) {
    if (restDayPattern.isEmpty) {
      throw ArgumentError('Rest day pattern cannot be empty');
    }

    final events = <CalendarEvent>[];
    int workoutIndex = 0;
    
    for (int i = 0; i < split.durationInDays; i++) {
      final date = split.startDate.add(Duration(days: i));
      final isRestDay = restDayPattern[i % restDayPattern.length];
      
      CalendarEvent event;
      if (isRestDay) {
        event = CalendarEvent(
          id: IdGenerator.generateUniqueId(),
          title: 'Rest Day',
          date: date,
          trainingSplitId: split.id,
          type: CalendarEventType.restDay,
        );
      } else {
        final workout = split.getWorkoutForDay(workoutIndex);
        workoutIndex++;
        
        event = CalendarEvent(
          id: IdGenerator.generateUniqueId(),
          title: workout,
          date: date,
          trainingSplitId: split.id,
          type: CalendarEventType.workout,
        );
      }
      
      events.add(event);
    }
    
    return events;
  }

  void addTrainingSplit(TrainingSplit split) {
    _trainingSplits[split.id] = split;
  }

  TrainingSplit? getTrainingSplit(String id) {
    return _trainingSplits[id];
  }

  List<TrainingSplit> getAllTrainingSplits() {
    return _trainingSplits.values.toList();
  }

  List<TrainingSplit> getActiveTrainingSplits() {
    return _trainingSplits.values
        .where((split) => split.isActive)
        .toList();
  }

  void deactivateTrainingSplit(String id) {
    final split = _trainingSplits[id];
    if (split != null) {
      final deactivatedSplit = TrainingSplit(
        id: split.id,
        name: split.name,
        workouts: split.workouts,
        startDate: split.startDate,
        endDate: split.endDate,
        isActive: false,
      );
      _trainingSplits[id] = deactivatedSplit;
    }
  }

  void addEvents(List<CalendarEvent> events) {
    for (final event in events) {
      _calendarEvents[event.id] = event;
    }
  }

  List<CalendarEvent> getEventsForDate(DateTime date) {
    return _calendarEvents.values
        .where((event) => event.isOnDate(date))
        .toList();
  }

  List<CalendarEvent> getEventsForTrainingSplit(String trainingSplitId) {
    return _calendarEvents.values
        .where((event) => event.trainingSplitId == trainingSplitId)
        .toList();
  }

  List<CalendarEvent> getEventsInRange(DateTime startDate, DateTime endDate) {
    return _calendarEvents.values
        .where((event) {
          final eventDate = DateTime(event.date.year, event.date.month, event.date.day);
          final start = DateTime(startDate.year, startDate.month, startDate.day);
          final end = DateTime(endDate.year, endDate.month, endDate.day);
          
          return (eventDate.isAtSameMomentAs(start) || eventDate.isAfter(start)) &&
                 (eventDate.isAtSameMomentAs(end) || eventDate.isBefore(end));
        })
        .toList();
  }

  void markEventCompleted(String eventId) {
    final event = _calendarEvents[eventId];
    if (event != null) {
      final completedEvent = event.copyWith(isCompleted: true);
      _calendarEvents[eventId] = completedEvent;
    }
  }

  void clearAllData() {
    _trainingSplits.clear();
    _calendarEvents.clear();
  }
}