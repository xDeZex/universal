import 'package:flutter_test/flutter_test.dart';
import 'package:universal/models/training_split.dart';

void main() {
  setUpAll(() {
    WidgetController.hitTestWarningShouldBeFatal = true;
  });

  group('TrainingSplit Model', () {
    group('constructor', () {
      test('should create training split with required fields', () {
        final split = TrainingSplit(
          id: 'split1',
          name: 'Push Pull Legs',
          workouts: ['Push', 'Pull', 'Legs'],
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 1, 31),
        );

        expect(split.id, equals('split1'));
        expect(split.name, equals('Push Pull Legs'));
        expect(split.workouts, equals(['Push', 'Pull', 'Legs']));
        expect(split.startDate, equals(DateTime(2024, 1, 1)));
        expect(split.endDate, equals(DateTime(2024, 1, 31)));
        expect(split.isActive, isTrue);
      });

      test('should create training split with inactive status', () {
        final split = TrainingSplit(
          id: 'split2',
          name: 'Upper Lower',
          workouts: ['Upper', 'Lower'],
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 1, 14),
          isActive: false,
        );

        expect(split.isActive, isFalse);
      });

      test('should validate that end date is after start date', () {
        expect(
          () => TrainingSplit(
            id: 'invalid',
            name: 'Invalid Split',
            workouts: ['Workout'],
            startDate: DateTime(2024, 1, 15),
            endDate: DateTime(2024, 1, 10),
          ),
          throwsArgumentError,
        );
      });

      test('should validate that workouts list is not empty', () {
        expect(
          () => TrainingSplit(
            id: 'empty',
            name: 'Empty Split',
            workouts: [],
            startDate: DateTime(2024, 1, 1),
            endDate: DateTime(2024, 1, 31),
          ),
          throwsArgumentError,
        );
      });

      test('should validate that name is not empty', () {
        expect(
          () => TrainingSplit(
            id: 'noname',
            name: '',
            workouts: ['Workout'],
            startDate: DateTime(2024, 1, 1),
            endDate: DateTime(2024, 1, 31),
          ),
          throwsArgumentError,
        );
      });
    });

    group('JSON serialization', () {
      test('should serialize to JSON correctly', () {
        final split = TrainingSplit(
          id: 'split1',
          name: 'Push Pull Legs',
          workouts: ['Push', 'Pull', 'Legs'],
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 1, 31),
          isActive: true,
        );

        final json = split.toJson();

        expect(json['id'], equals('split1'));
        expect(json['name'], equals('Push Pull Legs'));
        expect(json['workouts'], equals(['Push', 'Pull', 'Legs']));
        expect(json['startDate'], equals('2024-01-01T00:00:00.000'));
        expect(json['endDate'], equals('2024-01-31T00:00:00.000'));
        expect(json['isActive'], equals(true));
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'id': 'split2',
          'name': 'Upper Lower',
          'workouts': ['Upper', 'Lower'],
          'startDate': '2024-01-01T00:00:00.000',
          'endDate': '2024-01-14T00:00:00.000',
          'isActive': false,
        };

        final split = TrainingSplit.fromJson(json);

        expect(split.id, equals('split2'));
        expect(split.name, equals('Upper Lower'));
        expect(split.workouts, equals(['Upper', 'Lower']));
        expect(split.startDate, equals(DateTime(2024, 1, 1)));
        expect(split.endDate, equals(DateTime(2024, 1, 14)));
        expect(split.isActive, isFalse);
      });

      test('should handle round-trip JSON serialization', () {
        final originalSplit = TrainingSplit(
          id: 'roundtrip',
          name: 'Full Body',
          workouts: ['Full Body A', 'Full Body B'],
          startDate: DateTime(2024, 6, 1),
          endDate: DateTime(2024, 8, 31),
        );

        final json = originalSplit.toJson();
        final deserializedSplit = TrainingSplit.fromJson(json);

        expect(deserializedSplit.id, equals(originalSplit.id));
        expect(deserializedSplit.name, equals(originalSplit.name));
        expect(deserializedSplit.workouts, equals(originalSplit.workouts));
        expect(deserializedSplit.startDate, equals(originalSplit.startDate));
        expect(deserializedSplit.endDate, equals(originalSplit.endDate));
        expect(deserializedSplit.isActive, equals(originalSplit.isActive));
      });
    });

    group('utility methods', () {
      test('should calculate duration in days correctly', () {
        final split = TrainingSplit(
          id: 'duration',
          name: 'Test Split',
          workouts: ['Workout A'],
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 1, 7),
        );

        expect(split.durationInDays, equals(7));
      });

      test('should identify if date is within split period', () {
        final split = TrainingSplit(
          id: 'datecheck',
          name: 'Test Split',
          workouts: ['Workout A'],
          startDate: DateTime(2024, 1, 5),
          endDate: DateTime(2024, 1, 15),
        );

        expect(split.containsDate(DateTime(2024, 1, 1)), isFalse);
        expect(split.containsDate(DateTime(2024, 1, 5)), isTrue);
        expect(split.containsDate(DateTime(2024, 1, 10)), isTrue);
        expect(split.containsDate(DateTime(2024, 1, 15)), isTrue);
        expect(split.containsDate(DateTime(2024, 1, 20)), isFalse);
      });

      test('should get workout for specific day index', () {
        final split = TrainingSplit(
          id: 'workout',
          name: 'PPL',
          workouts: ['Push', 'Pull', 'Legs'],
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 1, 10),
        );

        expect(split.getWorkoutForDay(0), equals('Push'));
        expect(split.getWorkoutForDay(1), equals('Pull'));
        expect(split.getWorkoutForDay(2), equals('Legs'));
        expect(split.getWorkoutForDay(3), equals('Push')); // Cycles back
        expect(split.getWorkoutForDay(4), equals('Pull'));
        expect(split.getWorkoutForDay(5), equals('Legs'));
      });

      test('should get workout for specific date', () {
        final split = TrainingSplit(
          id: 'dateWorkout',
          name: 'Upper Lower',
          workouts: ['Upper', 'Lower'],
          startDate: DateTime(2024, 1, 1), // Monday
          endDate: DateTime(2024, 1, 10),
        );

        expect(split.getWorkoutForDate(DateTime(2024, 1, 1)), equals('Upper'));
        expect(split.getWorkoutForDate(DateTime(2024, 1, 2)), equals('Lower'));
        expect(split.getWorkoutForDate(DateTime(2024, 1, 3)), equals('Upper'));
        expect(split.getWorkoutForDate(DateTime(2024, 1, 4)), equals('Lower'));
      });

      test('should return null for date outside split period', () {
        final split = TrainingSplit(
          id: 'outside',
          name: 'Test Split',
          workouts: ['Workout A'],
          startDate: DateTime(2024, 1, 5),
          endDate: DateTime(2024, 1, 15),
        );

        expect(split.getWorkoutForDate(DateTime(2024, 1, 1)), isNull);
        expect(split.getWorkoutForDate(DateTime(2024, 1, 20)), isNull);
      });
    });

    group('equality and hashCode', () {
      test('should be equal when all properties match', () {
        final split1 = TrainingSplit(
          id: 'same',
          name: 'Same Split',
          workouts: ['A', 'B'],
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 1, 10),
        );

        final split2 = TrainingSplit(
          id: 'same',
          name: 'Same Split',
          workouts: ['A', 'B'],
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 1, 10),
        );

        expect(split1, equals(split2));
        expect(split1.hashCode, equals(split2.hashCode));
      });

      test('should not be equal when properties differ', () {
        final split1 = TrainingSplit(
          id: 'different1',
          name: 'Split One',
          workouts: ['A'],
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 1, 10),
        );

        final split2 = TrainingSplit(
          id: 'different2',
          name: 'Split Two',
          workouts: ['B'],
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 1, 10),
        );

        expect(split1, isNot(equals(split2)));
      });
    });
  });
}