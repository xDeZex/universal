import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal/services/calendar_event_service.dart';
import 'package:universal/models/calendar_event.dart';

void main() {
  setUpAll(() {
    // WidgetController.hitTestWarningShouldBeFatal = true;
  });

  group('CalendarEventService', () {
    late CalendarEventService service;
    late DateTime testDate;
    late CalendarEvent testEvent;
    late CalendarEvent testRestEvent;
    late CalendarEvent testCompletedEvent;

    setUp(() {
      service = CalendarEventService();
      testDate = DateTime(2024, 6, 15);

      testEvent = CalendarEvent(
        id: 'test-1',
        title: 'Push Workout',
        date: testDate,
        trainingSplitId: 'split-1',
        type: CalendarEventType.workout,
        description: 'Upper body workout',
      );

      testRestEvent = CalendarEvent(
        id: 'test-2',
        title: 'Rest Day',
        date: testDate.add(const Duration(days: 1)),
        trainingSplitId: 'split-1',
        type: CalendarEventType.restDay,
      );

      testCompletedEvent = CalendarEvent(
        id: 'test-3',
        title: 'Pull Workout',
        date: testDate.add(const Duration(days: 2)),
        trainingSplitId: 'split-1',
        type: CalendarEventType.workout,
        isCompleted: true,
      );
    });

    test('should initialize as not initialized', () {
      expect(service.isInitialized, isFalse);
    });

    test('should set initialization state correctly', () {
      service.setInitialized(true);
      expect(service.isInitialized, isTrue);

      service.setInitialized(false);
      expect(service.isInitialized, isFalse);
    });

    test('should add single event correctly', () {
      service.addEvent(testEvent);

      expect(service.getEventCount(), equals(1));
      expect(service.getEvent(testEvent.id), equals(testEvent));
    });

    test('should add multiple events correctly', () {
      final events = [testEvent, testRestEvent, testCompletedEvent];
      service.addEvents(events);

      expect(service.getEventCount(), equals(3));
      expect(service.getAllEvents().length, equals(3));
    });

    test('should update existing event correctly', () {
      service.addEvent(testEvent);

      final updatedEvent = testEvent.copyWith(title: 'Updated Push Workout');
      service.updateEvent(updatedEvent);

      expect(service.getEvent(testEvent.id)!.title, equals('Updated Push Workout'));
    });

    test('should not update non-existing event', () {
      final nonExistentEvent = CalendarEvent(
        id: 'non-existent',
        title: 'Non-existent',
        date: testDate,
        trainingSplitId: 'split-1',
      );

      service.updateEvent(nonExistentEvent);
      expect(service.getEventCount(), equals(0));
    });

    test('should delete event correctly', () {
      service.addEvent(testEvent);
      expect(service.getEventCount(), equals(1));

      service.deleteEvent(testEvent.id);
      expect(service.getEventCount(), equals(0));
      expect(service.getEvent(testEvent.id), isNull);
    });

    test('should handle deletion of non-existent event gracefully', () {
      service.deleteEvent('non-existent');
      expect(service.getEventCount(), equals(0));
    });

    test('should get events for specific date correctly', () {
      service.addEvents([testEvent, testRestEvent, testCompletedEvent]);

      final eventsForTestDate = service.getEventsForDate(testDate);
      expect(eventsForTestDate.length, equals(1));
      expect(eventsForTestDate.first.id, equals(testEvent.id));
    });

    test('should get events for training split correctly', () {
      final otherSplitEvent = CalendarEvent(
        id: 'other-split',
        title: 'Other Split Workout',
        date: testDate,
        trainingSplitId: 'split-2',
        type: CalendarEventType.workout,
      );

      service.addEvents([testEvent, testRestEvent, otherSplitEvent]);

      final split1Events = service.getEventsForTrainingSplit('split-1');
      expect(split1Events.length, equals(2));
      expect(split1Events.map((e) => e.id), containsAll([testEvent.id, testRestEvent.id]));
    });

    test('should get events in date range correctly', () {
      service.addEvents([testEvent, testRestEvent, testCompletedEvent]);

      final startDate = testDate;
      final endDate = testDate.add(const Duration(days: 1));

      final eventsInRange = service.getEventsInRange(startDate, endDate);
      expect(eventsInRange.length, equals(2));
      expect(eventsInRange.map((e) => e.id), containsAll([testEvent.id, testRestEvent.id]));
    });

    test('should filter workout events correctly', () {
      service.addEvents([testEvent, testRestEvent, testCompletedEvent]);

      final workoutEvents = service.getWorkoutEvents();
      expect(workoutEvents.length, equals(2));
      expect(workoutEvents.map((e) => e.id), containsAll([testEvent.id, testCompletedEvent.id]));
    });

    test('should filter rest day events correctly', () {
      service.addEvents([testEvent, testRestEvent, testCompletedEvent]);

      final restEvents = service.getRestDayEvents();
      expect(restEvents.length, equals(1));
      expect(restEvents.first.id, equals(testRestEvent.id));
    });

    test('should filter completed events correctly', () {
      service.addEvents([testEvent, testRestEvent, testCompletedEvent]);

      final completedEvents = service.getCompletedEvents();
      expect(completedEvents.length, equals(1));
      expect(completedEvents.first.id, equals(testCompletedEvent.id));
    });

    test('should filter pending events correctly', () {
      service.addEvents([testEvent, testRestEvent, testCompletedEvent]);

      final pendingEvents = service.getPendingEvents();
      expect(pendingEvents.length, equals(2));
      expect(pendingEvents.map((e) => e.id), containsAll([testEvent.id, testRestEvent.id]));
    });

    test('should mark event as completed correctly', () {
      service.addEvent(testEvent);
      expect(service.getEvent(testEvent.id)!.isCompleted, isFalse);

      service.markEventCompleted(testEvent.id);
      expect(service.getEvent(testEvent.id)!.isCompleted, isTrue);
    });

    test('should mark event as pending correctly', () {
      service.addEvent(testCompletedEvent);
      expect(service.getEvent(testCompletedEvent.id)!.isCompleted, isTrue);

      service.markEventPending(testCompletedEvent.id);
      expect(service.getEvent(testCompletedEvent.id)!.isCompleted, isFalse);
    });

    test('should toggle event completion correctly', () {
      service.addEvent(testEvent);
      expect(service.getEvent(testEvent.id)!.isCompleted, isFalse);

      service.toggleEventCompletion(testEvent.id);
      expect(service.getEvent(testEvent.id)!.isCompleted, isTrue);

      service.toggleEventCompletion(testEvent.id);
      expect(service.getEvent(testEvent.id)!.isCompleted, isFalse);
    });

    test('should handle completion operations on non-existent events gracefully', () {
      service.markEventCompleted('non-existent');
      service.markEventPending('non-existent');
      service.toggleEventCompletion('non-existent');

      expect(service.getEventCount(), equals(0));
    });

    test('should count events correctly', () {
      expect(service.getEventCount(), equals(0));

      service.addEvents([testEvent, testRestEvent, testCompletedEvent]);
      expect(service.getEventCount(), equals(3));
      expect(service.getCompletedEventCount(), equals(1));
      expect(service.getPendingEventCount(), equals(2));
    });

    test('should count events for specific date correctly', () {
      service.addEvents([testEvent, testRestEvent, testCompletedEvent]);

      expect(service.getEventCountForDate(testDate), equals(1));
      expect(service.getEventCountForDate(testDate.add(const Duration(days: 1))), equals(1));
      expect(service.getEventCountForDate(testDate.add(const Duration(days: 3))), equals(0));
    });

    test('should check for events existence correctly', () {
      service.addEvents([testEvent, testRestEvent, testCompletedEvent]);

      expect(service.hasEventsForDate(testDate), isTrue);
      expect(service.hasEventsForDate(testDate.add(const Duration(days: 5))), isFalse);

      expect(service.hasEventsInRange(testDate, testDate.add(const Duration(days: 2))), isTrue);
      expect(service.hasEventsInRange(testDate.add(const Duration(days: 5)), testDate.add(const Duration(days: 7))), isFalse);
    });

    test('should clear all events correctly', () {
      service.addEvents([testEvent, testRestEvent, testCompletedEvent]);
      expect(service.getEventCount(), equals(3));

      service.clearAllEvents();
      expect(service.getEventCount(), equals(0));
      expect(service.getAllEvents(), isEmpty);
    });

    test('should clear events for specific training split correctly', () {
      final otherSplitEvent = CalendarEvent(
        id: 'other-split',
        title: 'Other Split Workout',
        date: testDate,
        trainingSplitId: 'split-2',
        type: CalendarEventType.workout,
      );

      service.addEvents([testEvent, testRestEvent, otherSplitEvent]);
      expect(service.getEventCount(), equals(3));

      service.clearEventsForTrainingSplit('split-1');
      expect(service.getEventCount(), equals(1));
      expect(service.getAllEvents().first.id, equals(otherSplitEvent.id));
    });

    test('should search events by title correctly', () {
      service.addEvents([testEvent, testRestEvent, testCompletedEvent]);

      final searchResults = service.searchEvents('push');
      expect(searchResults.length, equals(1));
      expect(searchResults.first.id, equals(testEvent.id));
    });

    test('should search events by description correctly', () {
      service.addEvents([testEvent, testRestEvent, testCompletedEvent]);

      final searchResults = service.searchEvents('upper body');
      expect(searchResults.length, equals(1));
      expect(searchResults.first.id, equals(testEvent.id));
    });

    test('should search events case-insensitively', () {
      service.addEvents([testEvent, testRestEvent, testCompletedEvent]);

      final searchResults = service.searchEvents('PUSH');
      expect(searchResults.length, equals(1));
      expect(searchResults.first.id, equals(testEvent.id));
    });

    test('should load events from map correctly', () {
      final eventsMap = {
        testEvent.id: testEvent,
        testRestEvent.id: testRestEvent,
      };

      service.loadEventsFromMap(eventsMap);
      expect(service.getEventCount(), equals(2));
      expect(service.getEvent(testEvent.id), equals(testEvent));
      expect(service.getEvent(testRestEvent.id), equals(testRestEvent));
    });

    test('should get events as map correctly', () {
      service.addEvents([testEvent, testRestEvent]);

      final eventsMap = service.getEventsAsMap();
      expect(eventsMap.length, equals(2));
      expect(eventsMap[testEvent.id], equals(testEvent));
      expect(eventsMap[testRestEvent.id], equals(testRestEvent));
    });

    test('should notify listeners when events change', () {
      var notificationCount = 0;
      service.addListener(() {
        notificationCount++;
      });

      service.addEvent(testEvent);
      expect(notificationCount, equals(1));

      service.updateEvent(testEvent.copyWith(title: 'Updated'));
      expect(notificationCount, equals(2));

      service.deleteEvent(testEvent.id);
      expect(notificationCount, equals(3));

      service.addEvents([testRestEvent, testCompletedEvent]);
      expect(notificationCount, equals(4));

      service.clearAllEvents();
      expect(notificationCount, equals(5));
    });

    test('should not notify listeners when adding empty event list', () {
      var notificationCount = 0;
      service.addListener(() {
        notificationCount++;
      });

      service.addEvents([]);
      expect(notificationCount, equals(0));
    });
  });
}