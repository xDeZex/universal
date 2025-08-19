import 'package:flutter_test/flutter_test.dart';
import 'package:universal/models/calendar_event.dart';

void main() {
  setUpAll(() {
    WidgetController.hitTestWarningShouldBeFatal = true;
  });

  group('CalendarEvent Model', () {
    group('constructor', () {
      test('should create calendar event with required fields', () {
        final event = CalendarEvent(
          id: 'event1',
          title: 'Push Workout',
          date: DateTime(2024, 1, 15),
          trainingSplitId: 'split1',
        );

        expect(event.id, equals('event1'));
        expect(event.title, equals('Push Workout'));
        expect(event.date, equals(DateTime(2024, 1, 15)));
        expect(event.trainingSplitId, equals('split1'));
        expect(event.type, equals(CalendarEventType.workout));
        expect(event.isCompleted, isFalse);
        expect(event.description, isNull);
      });

      test('should create calendar event with optional fields', () {
        final event = CalendarEvent(
          id: 'event2',
          title: 'Pull Workout',
          date: DateTime(2024, 1, 16),
          trainingSplitId: 'split1',
          type: CalendarEventType.restDay,
          description: 'Focus on back and biceps',
          isCompleted: true,
        );

        expect(event.type, equals(CalendarEventType.restDay));
        expect(event.description, equals('Focus on back and biceps'));
        expect(event.isCompleted, isTrue);
      });

      test('should validate that title is not empty', () {
        expect(
          () => CalendarEvent(
            id: 'invalid',
            title: '',
            date: DateTime(2024, 1, 15),
            trainingSplitId: 'split1',
          ),
          throwsArgumentError,
        );
      });

      test('should validate that id is not empty', () {
        expect(
          () => CalendarEvent(
            id: '',
            title: 'Workout',
            date: DateTime(2024, 1, 15),
            trainingSplitId: 'split1',
          ),
          throwsArgumentError,
        );
      });
    });

    group('JSON serialization', () {
      test('should serialize to JSON correctly', () {
        final event = CalendarEvent(
          id: 'event1',
          title: 'Push Workout',
          date: DateTime(2024, 1, 15),
          trainingSplitId: 'split1',
          type: CalendarEventType.workout,
          description: 'Chest, shoulders, triceps',
          isCompleted: true,
        );

        final json = event.toJson();

        expect(json['id'], equals('event1'));
        expect(json['title'], equals('Push Workout'));
        expect(json['date'], equals('2024-01-15T00:00:00.000'));
        expect(json['trainingSplitId'], equals('split1'));
        expect(json['type'], equals('workout'));
        expect(json['description'], equals('Chest, shoulders, triceps'));
        expect(json['isCompleted'], equals(true));
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'id': 'event2',
          'title': 'Pull Workout',
          'date': '2024-01-16T00:00:00.000',
          'trainingSplitId': 'split1',
          'type': 'workout',
          'description': 'Back and biceps',
          'isCompleted': false,
        };

        final event = CalendarEvent.fromJson(json);

        expect(event.id, equals('event2'));
        expect(event.title, equals('Pull Workout'));
        expect(event.date, equals(DateTime(2024, 1, 16)));
        expect(event.trainingSplitId, equals('split1'));
        expect(event.type, equals(CalendarEventType.workout));
        expect(event.description, equals('Back and biceps'));
        expect(event.isCompleted, isFalse);
      });

      test('should handle JSON without optional fields', () {
        final json = {
          'id': 'event3',
          'title': 'Legs Workout',
          'date': '2024-01-17T00:00:00.000',
          'trainingSplitId': 'split1',
          'type': 'workout',
        };

        final event = CalendarEvent.fromJson(json);

        expect(event.description, isNull);
        expect(event.isCompleted, isFalse);
      });

      test('should handle round-trip JSON serialization', () {
        final originalEvent = CalendarEvent(
          id: 'roundtrip',
          title: 'Rest Day',
          date: DateTime(2024, 1, 18),
          trainingSplitId: 'split1',
          type: CalendarEventType.restDay,
          description: 'Active recovery',
        );

        final json = originalEvent.toJson();
        final deserializedEvent = CalendarEvent.fromJson(json);

        expect(deserializedEvent.id, equals(originalEvent.id));
        expect(deserializedEvent.title, equals(originalEvent.title));
        expect(deserializedEvent.date, equals(originalEvent.date));
        expect(deserializedEvent.trainingSplitId, equals(originalEvent.trainingSplitId));
        expect(deserializedEvent.type, equals(originalEvent.type));
        expect(deserializedEvent.description, equals(originalEvent.description));
        expect(deserializedEvent.isCompleted, equals(originalEvent.isCompleted));
      });
    });

    group('CalendarEventType', () {
      test('should convert enum to string correctly', () {
        expect(CalendarEventType.workout.name, equals('workout'));
        expect(CalendarEventType.restDay.name, equals('restDay'));
      });

      test('should parse string to enum correctly', () {
        expect(CalendarEventType.values.byName('workout'), equals(CalendarEventType.workout));
        expect(CalendarEventType.values.byName('restDay'), equals(CalendarEventType.restDay));
      });
    });

    group('utility methods', () {
      test('should check if event is on specific date', () {
        final event = CalendarEvent(
          id: 'dateCheck',
          title: 'Workout',
          date: DateTime(2024, 1, 15, 10, 30), // With time
          trainingSplitId: 'split1',
        );

        expect(event.isOnDate(DateTime(2024, 1, 15)), isTrue);
        expect(event.isOnDate(DateTime(2024, 1, 15, 14, 0)), isTrue);
        expect(event.isOnDate(DateTime(2024, 1, 14)), isFalse);
        expect(event.isOnDate(DateTime(2024, 1, 16)), isFalse);
      });

      test('should check if event is a workout', () {
        final workoutEvent = CalendarEvent(
          id: 'workout',
          title: 'Push',
          date: DateTime(2024, 1, 15),
          trainingSplitId: 'split1',
          type: CalendarEventType.workout,
        );

        final restEvent = CalendarEvent(
          id: 'rest',
          title: 'Rest',
          date: DateTime(2024, 1, 16),
          trainingSplitId: 'split1',
          type: CalendarEventType.restDay,
        );

        expect(workoutEvent.isWorkout, isTrue);
        expect(restEvent.isWorkout, isFalse);
      });

      test('should create completed copy of event', () {
        final event = CalendarEvent(
          id: 'original',
          title: 'Push Workout',
          date: DateTime(2024, 1, 15),
          trainingSplitId: 'split1',
          isCompleted: false,
        );

        final completedEvent = event.copyWith(isCompleted: true);

        expect(completedEvent.id, equals(event.id));
        expect(completedEvent.title, equals(event.title));
        expect(completedEvent.date, equals(event.date));
        expect(completedEvent.trainingSplitId, equals(event.trainingSplitId));
        expect(completedEvent.isCompleted, isTrue);
      });

      test('should create copy with modified fields', () {
        final event = CalendarEvent(
          id: 'original',
          title: 'Push Workout',
          date: DateTime(2024, 1, 15),
          trainingSplitId: 'split1',
        );

        final modifiedEvent = event.copyWith(
          title: 'Modified Push Workout',
          description: 'Updated description',
        );

        expect(modifiedEvent.title, equals('Modified Push Workout'));
        expect(modifiedEvent.description, equals('Updated description'));
        expect(modifiedEvent.id, equals(event.id));
        expect(modifiedEvent.date, equals(event.date));
      });
    });

    group('equality and hashCode', () {
      test('should be equal when all properties match', () {
        final event1 = CalendarEvent(
          id: 'same',
          title: 'Same Event',
          date: DateTime(2024, 1, 15),
          trainingSplitId: 'split1',
          type: CalendarEventType.workout,
          description: 'Same description',
          isCompleted: true,
        );

        final event2 = CalendarEvent(
          id: 'same',
          title: 'Same Event',
          date: DateTime(2024, 1, 15),
          trainingSplitId: 'split1',
          type: CalendarEventType.workout,
          description: 'Same description',
          isCompleted: true,
        );

        expect(event1, equals(event2));
        expect(event1.hashCode, equals(event2.hashCode));
      });

      test('should not be equal when properties differ', () {
        final event1 = CalendarEvent(
          id: 'different1',
          title: 'Event One',
          date: DateTime(2024, 1, 15),
          trainingSplitId: 'split1',
        );

        final event2 = CalendarEvent(
          id: 'different2',
          title: 'Event Two',
          date: DateTime(2024, 1, 15),
          trainingSplitId: 'split1',
        );

        expect(event1, isNot(equals(event2)));
      });
    });

    group('date formatting', () {
      test('should format date as date only string', () {
        final event = CalendarEvent(
          id: 'format',
          title: 'Test Event',
          date: DateTime(2024, 1, 15, 14, 30),
          trainingSplitId: 'split1',
        );

        expect(event.dateString, equals('2024-01-15'));
      });
    });
  });
}