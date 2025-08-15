import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_list_app/models/exercise.dart';
import 'package:shopping_list_app/models/weight_entry.dart';

void main() {
  group('Exercise', () {
    test('should create Exercise with required fields', () {
      const exercise = Exercise(
        id: 'test-id',
        name: 'Push ups',
      );

      expect(exercise.id, equals('test-id'));
      expect(exercise.name, equals('Push ups'));
      expect(exercise.sets, isNull);
      expect(exercise.reps, isNull);
      expect(exercise.weight, isNull);
      expect(exercise.notes, isNull);
      expect(exercise.weightHistory, isEmpty);
      expect(exercise.isCompleted, isFalse);
    });

    test('should create Exercise with all fields', () {
      final weightHistory = [
        WeightEntry(date: DateTime(2024, 1, 15), weight: '80kg'),
        WeightEntry(date: DateTime(2024, 1, 16), weight: '82kg'),
      ];

      final exercise = Exercise(
        id: 'test-id',
        name: 'Bench press',
        sets: '3',
        reps: '10',
        weight: '80kg',
        notes: 'Good form',
        weightHistory: weightHistory,
        isCompleted: true,
      );

      expect(exercise.id, equals('test-id'));
      expect(exercise.name, equals('Bench press'));
      expect(exercise.sets, equals('3'));
      expect(exercise.reps, equals('10'));
      expect(exercise.weight, equals('80kg'));
      expect(exercise.notes, equals('Good form'));
      expect(exercise.weightHistory, equals(weightHistory));
      expect(exercise.isCompleted, isTrue);
    });

    test('should create copy with modified fields', () {
      const original = Exercise(
        id: 'test-id',
        name: 'Push ups',
        sets: '3',
        reps: '10',
      );

      final newWeightHistory = [
        WeightEntry(date: DateTime(2024, 1, 15), weight: 'bodyweight'),
      ];

      final copy = original.copyWith(
        name: 'Diamond push ups',
        weight: 'bodyweight',
        weightHistory: newWeightHistory,
        isCompleted: true,
      );

      expect(copy.id, equals('test-id')); // Unchanged
      expect(copy.name, equals('Diamond push ups')); // Changed
      expect(copy.sets, equals('3')); // Unchanged
      expect(copy.reps, equals('10')); // Unchanged
      expect(copy.weight, equals('bodyweight')); // Changed
      expect(copy.weightHistory, equals(newWeightHistory)); // Changed
      expect(copy.isCompleted, isTrue); // Changed
    });

    test('should serialize to JSON correctly', () {
      final weightHistory = [
        WeightEntry(date: DateTime(2024, 1, 15, 10, 30), weight: '80kg'),
        WeightEntry(date: DateTime(2024, 1, 16, 11, 0), weight: '82kg'),
      ];

      final exercise = Exercise(
        id: 'test-id',
        name: 'Bench press',
        sets: '3',
        reps: '10',
        weight: '80kg',
        notes: 'Good form',
        weightHistory: weightHistory,
        isCompleted: true,
      );

      final json = exercise.toJson();

      expect(json['id'], equals('test-id'));
      expect(json['name'], equals('Bench press'));
      expect(json['sets'], equals('3'));
      expect(json['reps'], equals('10'));
      expect(json['weight'], equals('80kg'));
      expect(json['notes'], equals('Good form'));
      expect(json['weightHistory'], isA<List>());
      expect(json['weightHistory'].length, equals(2));
      expect(json['isCompleted'], isTrue);
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'id': 'test-id',
        'name': 'Bench press',
        'sets': '3',
        'reps': '10',
        'weight': '80kg',
        'notes': 'Good form',
        'weightHistory': [
          {
            'date': DateTime(2024, 1, 15, 10, 30).toIso8601String(),
            'weight': '80kg',
          },
          {
            'date': DateTime(2024, 1, 16, 11, 0).toIso8601String(),
            'weight': '82kg',
          },
        ],
        'isCompleted': true,
      };

      final exercise = Exercise.fromJson(json);

      expect(exercise.id, equals('test-id'));
      expect(exercise.name, equals('Bench press'));
      expect(exercise.sets, equals('3'));
      expect(exercise.reps, equals('10'));
      expect(exercise.weight, equals('80kg'));
      expect(exercise.notes, equals('Good form'));
      expect(exercise.weightHistory.length, equals(2));
      expect(exercise.weightHistory[0].weight, equals('80kg'));
      expect(exercise.weightHistory[1].weight, equals('82kg'));
      expect(exercise.isCompleted, isTrue);
    });

    test('should deserialize from JSON without weightHistory field', () {
      final json = {
        'id': 'test-id',
        'name': 'Push ups',
        'sets': '3',
        'reps': '10',
        'weight': null,
        'notes': null,
        'isCompleted': false,
      };

      final exercise = Exercise.fromJson(json);

      expect(exercise.id, equals('test-id'));
      expect(exercise.name, equals('Push ups'));
      expect(exercise.weightHistory, isEmpty);
      expect(exercise.isCompleted, isFalse);
    });

    test('should deserialize from JSON with null weightHistory', () {
      final json = {
        'id': 'test-id',
        'name': 'Push ups',
        'sets': '3',
        'reps': '10',
        'weight': null,
        'notes': null,
        'weightHistory': null,
        'isCompleted': false,
      };

      final exercise = Exercise.fromJson(json);

      expect(exercise.id, equals('test-id'));
      expect(exercise.name, equals('Push ups'));
      expect(exercise.weightHistory, isEmpty);
      expect(exercise.isCompleted, isFalse);
    });

    test('should handle JSON serialization round trip', () {
      final weightHistory = [
        WeightEntry(date: DateTime(2024, 1, 15), weight: '80kg'),
      ];

      final original = Exercise(
        id: 'test-id',
        name: 'Bench press',
        sets: '3',
        reps: '10',
        weight: '80kg',
        notes: 'Good form',
        weightHistory: weightHistory,
        isCompleted: true,
      );

      final json = original.toJson();
      final restored = Exercise.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.name, equals(original.name));
      expect(restored.sets, equals(original.sets));
      expect(restored.reps, equals(original.reps));
      expect(restored.weight, equals(original.weight));
      expect(restored.notes, equals(original.notes));
      expect(restored.isCompleted, equals(original.isCompleted));
      expect(restored.weightHistory.length, equals(original.weightHistory.length));
      expect(restored.weightHistory[0].date, equals(original.weightHistory[0].date));
      expect(restored.weightHistory[0].weight, equals(original.weightHistory[0].weight));
    });

    group('todaysWeight getter', () {
      test('should return null when no weight history', () {
        const exercise = Exercise(
          id: 'test-id',
          name: 'Push ups',
        );

        expect(exercise.todaysWeight, isNull);
      });

      test('should return null when no weight for today', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final weightHistory = [
          WeightEntry(date: yesterday, weight: '80kg'),
        ];

        final exercise = Exercise(
          id: 'test-id',
          name: 'Bench press',
          weightHistory: weightHistory,
        );

        expect(exercise.todaysWeight, isNull);
      });

      test('should return weight entry for today', () {
        final today = DateTime.now();
        final todayEntry = WeightEntry(date: today, weight: '80kg');
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        
        final weightHistory = [
          WeightEntry(date: yesterday, weight: '75kg'),
          todayEntry,
        ];

        final exercise = Exercise(
          id: 'test-id',
          name: 'Bench press',
          weightHistory: weightHistory,
        );

        expect(exercise.todaysWeight, equals(todayEntry));
      });

      test('should return latest weight entry for today when multiple exist', () {
        final today = DateTime.now();
        final morningEntry = WeightEntry(
          date: DateTime(today.year, today.month, today.day, 8, 0),
          weight: '80kg',
        );
        final afternoonEntry = WeightEntry(
          date: DateTime(today.year, today.month, today.day, 15, 0),
          weight: '82kg',
        );
        
        final weightHistory = [morningEntry, afternoonEntry];

        final exercise = Exercise(
          id: 'test-id',
          name: 'Bench press',
          weightHistory: weightHistory,
        );

        expect(exercise.todaysWeight, equals(afternoonEntry));
      });
    });

    test('should implement copyWithCompletion correctly', () {
      const exercise = Exercise(
        id: 'test-id',
        name: 'Push ups',
        isCompleted: false,
      );

      final completed = exercise.copyWithCompletion(isCompleted: true);

      expect(completed.isCompleted, isTrue);
      expect(completed.id, equals(exercise.id));
      expect(completed.name, equals(exercise.name));
    });

    test('should implement equality correctly', () {
      final weightHistory = [
        WeightEntry(date: DateTime(2024, 1, 15), weight: '80kg'),
      ];

      final exercise1 = Exercise(
        id: 'test-id',
        name: 'Bench press',
        sets: '3',
        reps: '10',
        weight: '80kg',
        notes: 'Good form',
        weightHistory: weightHistory,
        isCompleted: true,
      );

      final exercise2 = Exercise(
        id: 'test-id',
        name: 'Bench press',
        sets: '3',
        reps: '10',
        weight: '80kg',
        notes: 'Good form',
        weightHistory: weightHistory,
        isCompleted: true,
      );

      final exercise3 = Exercise(
        id: 'test-id',
        name: 'Push ups', // Different name
        sets: '3',
        reps: '10',
        weight: '80kg',
        notes: 'Good form',
        weightHistory: weightHistory,
        isCompleted: true,
      );

      expect(exercise1, equals(exercise2));
      expect(exercise1, isNot(equals(exercise3)));
      expect(exercise1.hashCode, equals(exercise2.hashCode));
    });
  });
}