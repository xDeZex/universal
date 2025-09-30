import 'package:flutter/material.dart';
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
        expect(event.type, equals(CalendarEventType.general));
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

    group('time functionality', () {
      group('constructor with time fields', () {
        test('should create all-day event by default', () {
          final event = CalendarEvent(
            id: 'allday',
            title: 'All Day Event',
            date: DateTime(2024, 1, 15),
            trainingSplitId: 'split1',
          );

          expect(event.isAllDay, isTrue);
          expect(event.startTime, isNull);
          expect(event.duration, isNull);
        });

        test('should create timed event with start time', () {
          final startTime = const TimeOfDay(hour: 14, minute: 30);
          final event = CalendarEvent(
            id: 'timed',
            title: 'Timed Event',
            date: DateTime(2024, 1, 15),
            trainingSplitId: 'split1',
            startTime: startTime,
            isAllDay: false,
          );

          expect(event.isAllDay, isFalse);
          expect(event.startTime, equals(startTime));
          expect(event.duration, isNull);
        });

        test('should create timed event with start time and duration', () {
          final startTime = const TimeOfDay(hour: 9, minute: 0);
          final duration = const Duration(hours: 2);
          final event = CalendarEvent(
            id: 'duration',
            title: 'Event with Duration',
            date: DateTime(2024, 1, 15),
            trainingSplitId: 'split1',
            startTime: startTime,
            duration: duration,
            isAllDay: false,
          );

          expect(event.isAllDay, isFalse);
          expect(event.startTime, equals(startTime));
          expect(event.duration, equals(duration));
        });
      });

      group('endTime calculation', () {
        test('should return null for all-day events', () {
          final event = CalendarEvent(
            id: 'allday',
            title: 'All Day Event',
            date: DateTime(2024, 1, 15),
            trainingSplitId: 'split1',
            isAllDay: true,
          );

          expect(event.endTime, isNull);
        });

        test('should return null when no start time', () {
          final event = CalendarEvent(
            id: 'notime',
            title: 'No Time Event',
            date: DateTime(2024, 1, 15),
            trainingSplitId: 'split1',
            isAllDay: false,
          );

          expect(event.endTime, isNull);
        });

        test('should return null when no duration', () {
          final event = CalendarEvent(
            id: 'noduration',
            title: 'No Duration Event',
            date: DateTime(2024, 1, 15),
            trainingSplitId: 'split1',
            startTime: const TimeOfDay(hour: 14, minute: 30),
            isAllDay: false,
          );

          expect(event.endTime, isNull);
        });

        test('should calculate end time correctly', () {
          final event = CalendarEvent(
            id: 'endtime',
            title: 'End Time Event',
            date: DateTime(2024, 1, 15),
            trainingSplitId: 'split1',
            startTime: const TimeOfDay(hour: 14, minute: 30),
            duration: const Duration(hours: 1, minutes: 30),
            isAllDay: false,
          );

          final endTime = event.endTime!;
          expect(endTime.hour, equals(16));
          expect(endTime.minute, equals(0));
        });

        test('should handle end time crossing midnight', () {
          final event = CalendarEvent(
            id: 'midnight',
            title: 'Midnight Event',
            date: DateTime(2024, 1, 15),
            trainingSplitId: 'split1',
            startTime: const TimeOfDay(hour: 23, minute: 30),
            duration: const Duration(hours: 2),
            isAllDay: false,
          );

          final endTime = event.endTime!;
          expect(endTime.hour, equals(1));
          expect(endTime.minute, equals(30));
        });
      });

      group('timeDisplayString', () {
        test('should return "All day" for all-day events', () {
          final event = CalendarEvent(
            id: 'allday',
            title: 'All Day Event',
            date: DateTime(2024, 1, 15),
            trainingSplitId: 'split1',
            isAllDay: true,
          );

          expect(event.timeDisplayString, equals('All day'));
        });

        test('should return empty string when no time info', () {
          final event = CalendarEvent(
            id: 'notime',
            title: 'No Time Event',
            date: DateTime(2024, 1, 15),
            trainingSplitId: 'split1',
            isAllDay: false,
          );

          expect(event.timeDisplayString, equals(''));
        });

        test('should return start time only when no duration', () {
          final event = CalendarEvent(
            id: 'startonly',
            title: 'Start Only Event',
            date: DateTime(2024, 1, 15),
            trainingSplitId: 'split1',
            startTime: const TimeOfDay(hour: 14, minute: 30),
            isAllDay: false,
          );

          expect(event.timeDisplayString, equals('14:30'));
        });

        test('should return time range when duration is set', () {
          final event = CalendarEvent(
            id: 'timerange',
            title: 'Time Range Event',
            date: DateTime(2024, 1, 15),
            trainingSplitId: 'split1',
            startTime: const TimeOfDay(hour: 9, minute: 0),
            duration: const Duration(hours: 2, minutes: 30),
            isAllDay: false,
          );

          expect(event.timeDisplayString, equals('09:00 - 11:30'));
        });

        test('should handle legacy time field fallback', () {
          final event = CalendarEvent(
            id: 'legacy',
            title: 'Legacy Event',
            date: DateTime(2024, 1, 15),
            trainingSplitId: 'split1',
            time: '2:30 PM',
            isAllDay: false,
          );

          expect(event.timeDisplayString, equals('2:30 PM'));
        });

        test('should prefer new time fields over legacy time field', () {
          final event = CalendarEvent(
            id: 'mixed',
            title: 'Mixed Event',
            date: DateTime(2024, 1, 15),
            trainingSplitId: 'split1',
            time: '2:30 PM',
            startTime: const TimeOfDay(hour: 14, minute: 30),
            isAllDay: false,
          );

          expect(event.timeDisplayString, equals('14:30'));
        });
      });

      group('JSON serialization with time fields', () {
        test('should serialize time fields to JSON correctly', () {
          final event = CalendarEvent(
            id: 'timedjson',
            title: 'Timed Event',
            date: DateTime(2024, 1, 15),
            trainingSplitId: 'split1',
            startTime: const TimeOfDay(hour: 14, minute: 30),
            duration: const Duration(hours: 2),
            isAllDay: false,
          );

          final json = event.toJson();

          expect(json['startTime'], equals('14:30'));
          expect(json['duration'], equals(120)); // minutes
          expect(json['isAllDay'], isFalse);
        });

        test('should handle null time fields in JSON', () {
          final event = CalendarEvent(
            id: 'alldayjson',
            title: 'All Day Event',
            date: DateTime(2024, 1, 15),
            trainingSplitId: 'split1',
            isAllDay: true,
          );

          final json = event.toJson();

          expect(json['startTime'], isNull);
          expect(json['duration'], isNull);
          expect(json['isAllDay'], isTrue);
        });

        test('should deserialize time fields from JSON correctly', () {
          final json = {
            'id': 'timedfromjson',
            'title': 'Timed from JSON',
            'date': '2024-01-15T00:00:00.000',
            'trainingSplitId': 'split1',
            'type': 'general',
            'startTime': '09:15',
            'duration': 90,
            'isAllDay': false,
            'isCompleted': false,
          };

          final event = CalendarEvent.fromJson(json);

          expect(event.startTime!.hour, equals(9));
          expect(event.startTime!.minute, equals(15));
          expect(event.duration!.inMinutes, equals(90));
          expect(event.isAllDay, isFalse);
        });

        test('should handle legacy JSON without time fields', () {
          final json = {
            'id': 'legacy',
            'title': 'Legacy Event',
            'date': '2024-01-15T00:00:00.000',
            'trainingSplitId': 'split1',
            'type': 'general',
            'time': '2:30 PM',
            'isCompleted': false,
          };

          final event = CalendarEvent.fromJson(json);

          expect(event.startTime, isNull);
          expect(event.duration, isNull);
          expect(event.isAllDay, isFalse); // Should be false because time field exists
          expect(event.time, equals('2:30 PM'));
        });

        test('should default to all-day for completely legacy events', () {
          final json = {
            'id': 'oldlegacy',
            'title': 'Old Legacy Event',
            'date': '2024-01-15T00:00:00.000',
            'trainingSplitId': 'split1',
            'type': 'general',
            'isCompleted': false,
          };

          final event = CalendarEvent.fromJson(json);

          expect(event.startTime, isNull);
          expect(event.duration, isNull);
          expect(event.isAllDay, isTrue); // Should default to true
          expect(event.time, isNull);
        });

        test('should handle round-trip JSON with time fields', () {
          final originalEvent = CalendarEvent(
            id: 'roundtriptime',
            title: 'Round Trip Time Event',
            date: DateTime(2024, 1, 15),
            trainingSplitId: 'split1',
            startTime: const TimeOfDay(hour: 16, minute: 45),
            duration: const Duration(hours: 1, minutes: 15),
            isAllDay: false,
          );

          final json = originalEvent.toJson();
          final deserializedEvent = CalendarEvent.fromJson(json);

          expect(deserializedEvent.startTime, equals(originalEvent.startTime));
          expect(deserializedEvent.duration, equals(originalEvent.duration));
          expect(deserializedEvent.isAllDay, equals(originalEvent.isAllDay));
        });

        test('should handle corrupt time data gracefully', () {
          final json = {
            'id': 'corrupt',
            'title': 'Corrupt Time Event',
            'date': '2024-01-15T00:00:00.000',
            'trainingSplitId': 'split1',
            'type': 'general',
            'startTime': 'invalid:time',
            'duration': 'not_a_number',
            'isAllDay': null,
            'isCompleted': false,
          };

          final event = CalendarEvent.fromJson(json);

          expect(event.startTime, isNull);
          expect(event.duration, isNull);
          expect(event.isAllDay, isTrue); // Should default to true
        });
      });

      group('copyWith with time fields', () {
        test('should copy with modified time fields', () {
          final originalEvent = CalendarEvent(
            id: 'copytime',
            title: 'Copy Time Event',
            date: DateTime(2024, 1, 15),
            trainingSplitId: 'split1',
            startTime: const TimeOfDay(hour: 9, minute: 0),
            duration: const Duration(hours: 1),
            isAllDay: false,
          );

          final copiedEvent = originalEvent.copyWith(
            startTime: const TimeOfDay(hour: 10, minute: 30),
            duration: const Duration(hours: 2),
          );

          expect(copiedEvent.id, equals(originalEvent.id));
          expect(copiedEvent.title, equals(originalEvent.title));
          expect(copiedEvent.startTime!.hour, equals(10));
          expect(copiedEvent.startTime!.minute, equals(30));
          expect(copiedEvent.duration!.inHours, equals(2));
        });

        test('should copy from all-day to timed event', () {
          final originalEvent = CalendarEvent(
            id: 'alldaytotimed',
            title: 'All Day to Timed',
            date: DateTime(2024, 1, 15),
            trainingSplitId: 'split1',
            isAllDay: true,
          );

          final timedEvent = originalEvent.copyWith(
            startTime: const TimeOfDay(hour: 14, minute: 0),
            isAllDay: false,
          );

          expect(timedEvent.isAllDay, isFalse);
          expect(timedEvent.startTime!.hour, equals(14));
          expect(timedEvent.startTime!.minute, equals(0));
        });
      });

      group('equality with time fields', () {
        test('should be equal when time fields match', () {
          final event1 = CalendarEvent(
            id: 'timeequal1',
            title: 'Time Equal Event',
            date: DateTime(2024, 1, 15),
            trainingSplitId: 'split1',
            startTime: const TimeOfDay(hour: 14, minute: 30),
            duration: const Duration(hours: 2),
            isAllDay: false,
          );

          final event2 = CalendarEvent(
            id: 'timeequal1',
            title: 'Time Equal Event',
            date: DateTime(2024, 1, 15),
            trainingSplitId: 'split1',
            startTime: const TimeOfDay(hour: 14, minute: 30),
            duration: const Duration(hours: 2),
            isAllDay: false,
          );

          expect(event1, equals(event2));
          expect(event1.hashCode, equals(event2.hashCode));
        });

        test('should not be equal when time fields differ', () {
          final event1 = CalendarEvent(
            id: 'timenotequal',
            title: 'Time Not Equal Event',
            date: DateTime(2024, 1, 15),
            trainingSplitId: 'split1',
            startTime: const TimeOfDay(hour: 14, minute: 30),
            isAllDay: false,
          );

          final event2 = CalendarEvent(
            id: 'timenotequal',
            title: 'Time Not Equal Event',
            date: DateTime(2024, 1, 15),
            trainingSplitId: 'split1',
            startTime: const TimeOfDay(hour: 15, minute: 30),
            isAllDay: false,
          );

          expect(event1, isNot(equals(event2)));
        });
      });
    });
  });
}