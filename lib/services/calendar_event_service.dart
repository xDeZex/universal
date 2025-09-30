import 'package:flutter/foundation.dart';
import '../models/calendar_event.dart';

class CalendarEventService extends ChangeNotifier {
  final Map<String, CalendarEvent> _events = {};
  bool _isInitialized = false;

  CalendarEventService();

  bool get isInitialized => _isInitialized;

  void setInitialized(bool initialized) {
    _isInitialized = initialized;
  }

  void addEvent(CalendarEvent event) {
    _events[event.id] = event;
    notifyListeners();
  }

  void addEvents(List<CalendarEvent> events) {
    for (final event in events) {
      _events[event.id] = event;
    }
    if (events.isNotEmpty) {
      notifyListeners();
    }
  }

  void updateEvent(CalendarEvent event) {
    if (_events.containsKey(event.id)) {
      _events[event.id] = event;
      notifyListeners();
    }
  }

  void deleteEvent(String eventId) {
    if (_events.remove(eventId) != null) {
      notifyListeners();
    }
  }

  CalendarEvent? getEvent(String eventId) {
    return _events[eventId];
  }

  List<CalendarEvent> getAllEvents() {
    return _events.values.toList();
  }

  List<CalendarEvent> getEventsForDate(DateTime date) {
    return _events.values
        .where((event) => event.isOnDate(date))
        .toList();
  }

  List<CalendarEvent> getEventsForTrainingSplit(String trainingSplitId) {
    return _events.values
        .where((event) => event.trainingSplitId == trainingSplitId)
        .toList();
  }

  List<CalendarEvent> getEventsInRange(DateTime startDate, DateTime endDate) {
    return _events.values
        .where((event) {
          final eventDate = DateTime(event.date.year, event.date.month, event.date.day);
          final start = DateTime(startDate.year, startDate.month, startDate.day);
          final end = DateTime(endDate.year, endDate.month, endDate.day);

          return (eventDate.isAtSameMomentAs(start) || eventDate.isAfter(start)) &&
                 (eventDate.isAtSameMomentAs(end) || eventDate.isBefore(end));
        })
        .toList();
  }

  List<CalendarEvent> getWorkoutEvents() {
    return _events.values
        .where((event) => event.type == CalendarEventType.workout)
        .toList();
  }

  List<CalendarEvent> getRestDayEvents() {
    return _events.values
        .where((event) => event.type == CalendarEventType.restDay)
        .toList();
  }

  List<CalendarEvent> getCompletedEvents() {
    return _events.values
        .where((event) => event.isCompleted)
        .toList();
  }

  List<CalendarEvent> getPendingEvents() {
    return _events.values
        .where((event) => !event.isCompleted)
        .toList();
  }

  void markEventCompleted(String eventId) {
    final event = _events[eventId];
    if (event != null) {
      final completedEvent = event.copyWith(isCompleted: true);
      _events[eventId] = completedEvent;
      notifyListeners();
    }
  }

  void markEventPending(String eventId) {
    final event = _events[eventId];
    if (event != null) {
      final pendingEvent = event.copyWith(isCompleted: false);
      _events[eventId] = pendingEvent;
      notifyListeners();
    }
  }

  void toggleEventCompletion(String eventId) {
    final event = _events[eventId];
    if (event != null) {
      final toggledEvent = event.copyWith(isCompleted: !event.isCompleted);
      _events[eventId] = toggledEvent;
      notifyListeners();
    }
  }

  int getEventCount() {
    return _events.length;
  }

  int getEventCountForDate(DateTime date) {
    return getEventsForDate(date).length;
  }

  int getCompletedEventCount() {
    return getCompletedEvents().length;
  }

  int getPendingEventCount() {
    return getPendingEvents().length;
  }

  bool hasEventsForDate(DateTime date) {
    return getEventsForDate(date).isNotEmpty;
  }

  bool hasEventsInRange(DateTime startDate, DateTime endDate) {
    return getEventsInRange(startDate, endDate).isNotEmpty;
  }

  void clearAllEvents() {
    if (_events.isNotEmpty) {
      _events.clear();
      notifyListeners();
    }
  }

  void clearEventsForTrainingSplit(String trainingSplitId) {
    final eventsToRemove = _events.values
        .where((event) => event.trainingSplitId == trainingSplitId)
        .map((event) => event.id)
        .toList();

    if (eventsToRemove.isNotEmpty) {
      for (final eventId in eventsToRemove) {
        _events.remove(eventId);
      }
      notifyListeners();
    }
  }

  List<CalendarEvent> searchEvents(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _events.values
        .where((event) =>
            event.title.toLowerCase().contains(lowercaseQuery) ||
            (event.description?.toLowerCase().contains(lowercaseQuery) ?? false))
        .toList();
  }

  void loadEventsFromMap(Map<String, CalendarEvent> events) {
    _events.clear();
    _events.addAll(events);
    notifyListeners();
  }

  Map<String, CalendarEvent> getEventsAsMap() {
    return Map.from(_events);
  }
}