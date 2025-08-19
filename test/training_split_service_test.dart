import 'package:flutter_test/flutter_test.dart';
import 'package:universal/models/training_split.dart';
import 'package:universal/models/calendar_event.dart';
import 'package:universal/services/training_split_service.dart';

void main() {
  setUpAll(() {
    WidgetController.hitTestWarningShouldBeFatal = true;
  });

  group('TrainingSplitService', () {
    late TrainingSplitService service;

    setUp(() {
      service = TrainingSplitService();
    });

    group('generateCalendarEvents', () {
      test('should generate events for simple training split', () {
        final split = TrainingSplit(
          id: 'ppl',
          name: 'Push Pull Legs',
          workouts: ['Push', 'Pull', 'Legs'],
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 1, 6),
        );

        final events = service.generateCalendarEvents(split);

        expect(events.length, equals(6));
        
        expect(events[0].title, equals('Push'));
        expect(events[0].date, equals(DateTime(2024, 1, 1)));
        expect(events[0].trainingSplitId, equals('ppl'));
        
        expect(events[1].title, equals('Pull'));
        expect(events[1].date, equals(DateTime(2024, 1, 2)));
        
        expect(events[2].title, equals('Legs'));
        expect(events[2].date, equals(DateTime(2024, 1, 3)));
        
        expect(events[3].title, equals('Push'));
        expect(events[3].date, equals(DateTime(2024, 1, 4)));
        
        expect(events[4].title, equals('Pull'));
        expect(events[4].date, equals(DateTime(2024, 1, 5)));
        
        expect(events[5].title, equals('Legs'));
        expect(events[5].date, equals(DateTime(2024, 1, 6)));
      });

      test('should generate events for upper/lower split', () {
        final split = TrainingSplit(
          id: 'ul',
          name: 'Upper Lower',
          workouts: ['Upper', 'Lower'],
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 1, 4),
        );

        final events = service.generateCalendarEvents(split);

        expect(events.length, equals(4));
        expect(events[0].title, equals('Upper'));
        expect(events[1].title, equals('Lower'));
        expect(events[2].title, equals('Upper'));
        expect(events[3].title, equals('Lower'));
      });

      test('should generate unique IDs for each event', () {
        final split = TrainingSplit(
          id: 'test',
          name: 'Test Split',
          workouts: ['Workout A', 'Workout B'],
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 1, 3),
        );

        final events = service.generateCalendarEvents(split);

        final ids = events.map((e) => e.id).toList();
        final uniqueIds = ids.toSet();
        
        expect(uniqueIds.length, equals(ids.length));
      });

      test('should handle single workout split', () {
        final split = TrainingSplit(
          id: 'daily',
          name: 'Daily Workout',
          workouts: ['Full Body'],
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 1, 3),
        );

        final events = service.generateCalendarEvents(split);

        expect(events.length, equals(3));
        expect(events.every((e) => e.title == 'Full Body'), isTrue);
      });

      test('should set all events as workout type by default', () {
        final split = TrainingSplit(
          id: 'test',
          name: 'Test',
          workouts: ['A', 'B'],
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 1, 2),
        );

        final events = service.generateCalendarEvents(split);

        expect(events.every((e) => e.type == CalendarEventType.workout), isTrue);
        expect(events.every((e) => e.isCompleted == false), isTrue);
      });
    });

    group('generateCalendarEventsWithRestDays', () {
      test('should add rest days between workout days', () {
        final split = TrainingSplit(
          id: 'rest',
          name: 'With Rest',
          workouts: ['Workout A', 'Workout B'],
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 1, 6),
        );

        final events = service.generateCalendarEventsWithRestDays(
          split,
          restDayPattern: [false, false, true], // 2 on, 1 off
        );

        expect(events.length, equals(6));
        expect(events[0].title, equals('Workout A'));
        expect(events[0].type, equals(CalendarEventType.workout));
        expect(events[1].title, equals('Workout B'));
        expect(events[1].type, equals(CalendarEventType.workout));
        expect(events[2].title, equals('Rest Day'));
        expect(events[2].type, equals(CalendarEventType.restDay));
        expect(events[3].title, equals('Workout A'));
        expect(events[4].title, equals('Workout B'));
        expect(events[5].title, equals('Rest Day'));
      });

      test('should handle daily rest pattern', () {
        final split = TrainingSplit(
          id: 'alternate',
          name: 'Alternating',
          workouts: ['Workout'],
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 1, 4),
        );

        final events = service.generateCalendarEventsWithRestDays(
          split,
          restDayPattern: [false, true], // 1 on, 1 off
        );

        expect(events.length, equals(4));
        expect(events[0].title, equals('Workout'));
        expect(events[0].type, equals(CalendarEventType.workout));
        expect(events[1].title, equals('Rest Day'));
        expect(events[1].type, equals(CalendarEventType.restDay));
        expect(events[2].title, equals('Workout'));
        expect(events[3].title, equals('Rest Day'));
      });

      test('should validate rest day pattern is not empty', () {
        final split = TrainingSplit(
          id: 'test',
          name: 'Test',
          workouts: ['Workout'],
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 1, 2),
        );

        expect(
          () => service.generateCalendarEventsWithRestDays(split, restDayPattern: []),
          throwsArgumentError,
        );
      });
    });

    group('getEventsForDate', () {
      test('should return events for specific date', () {
        final split = TrainingSplit(
          id: 'test',
          name: 'Test',
          workouts: ['Workout A', 'Workout B'],
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 1, 3),
        );

        final allEvents = service.generateCalendarEvents(split);
        service.addEvents(allEvents);

        final eventsForDate = service.getEventsForDate(DateTime(2024, 1, 2));

        expect(eventsForDate.length, equals(1));
        expect(eventsForDate[0].title, equals('Workout B'));
        expect(eventsForDate[0].date, equals(DateTime(2024, 1, 2)));
      });

      test('should return empty list for date with no events', () {
        final eventsForDate = service.getEventsForDate(DateTime(2024, 12, 25));
        expect(eventsForDate, isEmpty);
      });

      test('should return multiple events for same date if they exist', () {
        final event1 = CalendarEvent(
          id: 'event1',
          title: 'Morning Workout',
          date: DateTime(2024, 1, 15, 8, 0),
          trainingSplitId: 'split1',
        );

        final event2 = CalendarEvent(
          id: 'event2',
          title: 'Evening Workout',
          date: DateTime(2024, 1, 15, 18, 0),
          trainingSplitId: 'split1',
        );

        service.addEvents([event1, event2]);

        final eventsForDate = service.getEventsForDate(DateTime(2024, 1, 15));
        expect(eventsForDate.length, equals(2));
      });
    });

    group('training split management', () {
      test('should add and retrieve training splits', () {
        final split = TrainingSplit(
          id: 'manage',
          name: 'Management Test',
          workouts: ['A', 'B'],
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 1, 10),
        );

        service.addTrainingSplit(split);

        final retrieved = service.getTrainingSplit('manage');
        expect(retrieved, equals(split));
      });

      test('should return null for non-existent training split', () {
        final retrieved = service.getTrainingSplit('nonexistent');
        expect(retrieved, isNull);
      });

      test('should get all training splits', () {
        final split1 = TrainingSplit(
          id: 'split1',
          name: 'Split One',
          workouts: ['A'],
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 1, 10),
        );

        final split2 = TrainingSplit(
          id: 'split2',
          name: 'Split Two',
          workouts: ['B'],
          startDate: DateTime(2024, 2, 1),
          endDate: DateTime(2024, 2, 10),
        );

        service.addTrainingSplit(split1);
        service.addTrainingSplit(split2);

        final allSplits = service.getAllTrainingSplits();
        expect(allSplits.length, equals(2));
        expect(allSplits.contains(split1), isTrue);
        expect(allSplits.contains(split2), isTrue);
      });

      test('should get active training splits only', () {
        final activeSplit = TrainingSplit(
          id: 'active',
          name: 'Active Split',
          workouts: ['A'],
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 1, 10),
          isActive: true,
        );

        final inactiveSplit = TrainingSplit(
          id: 'inactive',
          name: 'Inactive Split',
          workouts: ['B'],
          startDate: DateTime(2024, 2, 1),
          endDate: DateTime(2024, 2, 10),
          isActive: false,
        );

        service.addTrainingSplit(activeSplit);
        service.addTrainingSplit(inactiveSplit);

        final activeSplits = service.getActiveTrainingSplits();
        expect(activeSplits.length, equals(1));
        expect(activeSplits[0], equals(activeSplit));
      });

      test('should deactivate training split', () {
        final split = TrainingSplit(
          id: 'deactivate',
          name: 'To Deactivate',
          workouts: ['A'],
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 1, 10),
          isActive: true,
        );

        service.addTrainingSplit(split);
        service.deactivateTrainingSplit('deactivate');

        final retrieved = service.getTrainingSplit('deactivate');
        expect(retrieved?.isActive, isFalse);
      });
    });

    group('event management', () {
      test('should mark event as completed', () {
        final event = CalendarEvent(
          id: 'complete',
          title: 'Complete Me',
          date: DateTime(2024, 1, 15),
          trainingSplitId: 'split1',
          isCompleted: false,
        );

        service.addEvents([event]);
        service.markEventCompleted('complete');

        final events = service.getEventsForDate(DateTime(2024, 1, 15));
        expect(events[0].isCompleted, isTrue);
      });

      test('should not error when marking non-existent event as completed', () {
        expect(() => service.markEventCompleted('nonexistent'), returnsNormally);
      });

      test('should get events for training split', () {
        final split = TrainingSplit(
          id: 'filter',
          name: 'Filter Test',
          workouts: ['A', 'B'],
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 1, 3),
        );

        final events = service.generateCalendarEvents(split);
        service.addEvents(events);

        final splitEvents = service.getEventsForTrainingSplit('filter');
        expect(splitEvents.length, equals(3));
        expect(splitEvents.every((e) => e.trainingSplitId == 'filter'), isTrue);
      });
    });

    group('date range queries', () {
      test('should get events in date range', () {
        final split = TrainingSplit(
          id: 'range',
          name: 'Range Test',
          workouts: ['A'],
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 1, 10),
        );

        final events = service.generateCalendarEvents(split);
        service.addEvents(events);

        final rangeEvents = service.getEventsInRange(
          DateTime(2024, 1, 3),
          DateTime(2024, 1, 7),
        );

        expect(rangeEvents.length, equals(5));
        expect(rangeEvents.every((e) => 
          e.date.isAfter(DateTime(2024, 1, 2)) && 
          e.date.isBefore(DateTime(2024, 1, 8))), isTrue);
      });

      test('should include start and end dates in range', () {
        final event1 = CalendarEvent(
          id: 'start',
          title: 'Start Event',
          date: DateTime(2024, 1, 1),
          trainingSplitId: 'split1',
        );

        final event2 = CalendarEvent(
          id: 'end',
          title: 'End Event',
          date: DateTime(2024, 1, 5),
          trainingSplitId: 'split1',
        );

        service.addEvents([event1, event2]);

        final rangeEvents = service.getEventsInRange(
          DateTime(2024, 1, 1),
          DateTime(2024, 1, 5),
        );

        expect(rangeEvents.length, equals(2));
      });
    });
  });
}