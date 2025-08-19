import 'package:flutter_test/flutter_test.dart';
import 'package:universal/models/weight_entry.dart';
import 'package:universal/models/set_entry.dart';

void main() {
  group('WeightEntry', () {
    final testDate = DateTime(2024, 1, 15, 10, 30);
    const testWeight = '80kg';

    test('should create WeightEntry with required fields', () {
      final entry = WeightEntry(
        date: testDate,
        weight: testWeight,
      );

      expect(entry.date, equals(testDate));
      expect(entry.weight, equals(testWeight));
    });

    test('should create copy with modified fields', () {
      final original = WeightEntry(
        date: testDate,
        weight: testWeight,
      );

      final newDate = DateTime(2024, 1, 16, 14, 0);
      const newWeight = '85kg';

      final copy = original.copyWith(
        date: newDate,
        weight: newWeight,
      );

      expect(copy.date, equals(newDate));
      expect(copy.weight, equals(newWeight));
      expect(original.date, equals(testDate)); // Original unchanged
      expect(original.weight, equals(testWeight)); // Original unchanged
    });

    test('should create copy with only some fields modified', () {
      final original = WeightEntry(
        date: testDate,
        weight: testWeight,
      );

      const newWeight = '85kg';
      final copy = original.copyWith(weight: newWeight);

      expect(copy.date, equals(testDate)); // Unchanged
      expect(copy.weight, equals(newWeight)); // Changed
    });

    test('should serialize to JSON correctly', () {
      final entry = WeightEntry(
        date: testDate,
        weight: testWeight,
      );

      final json = entry.toJson();

      expect(json['date'], equals(testDate.toIso8601String()));
      expect(json['weight'], equals(testWeight));
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'date': testDate.toIso8601String(),
        'weight': testWeight,
      };

      final entry = WeightEntry.fromJson(json);

      expect(entry.date, equals(testDate));
      expect(entry.weight, equals(testWeight));
    });

    test('should handle JSON serialization round trip', () {
      final original = WeightEntry(
        date: testDate,
        weight: testWeight,
      );

      final json = original.toJson();
      final restored = WeightEntry.fromJson(json);

      expect(restored.date, equals(original.date));
      expect(restored.weight, equals(original.weight));
      expect(restored, equals(original));
    });

    test('should implement equality correctly', () {
      final entry1 = WeightEntry(
        date: testDate,
        weight: testWeight,
      );

      final entry2 = WeightEntry(
        date: testDate,
        weight: testWeight,
      );

      final entry3 = WeightEntry(
        date: DateTime(2024, 1, 16),
        weight: testWeight,
      );

      expect(entry1, equals(entry2));
      expect(entry1, isNot(equals(entry3)));
      expect(entry1.hashCode, equals(entry2.hashCode));
    });

    test('should have meaningful string representation', () {
      final entry = WeightEntry(
        date: testDate,
        weight: testWeight,
      );

      final string = entry.toString();

      expect(string, contains('WeightEntry'));
      expect(string, contains(testDate.toString()));
      expect(string, contains(testWeight));
    });

    group('SetEntries functionality', () {
      test('should create WeightEntry with setEntries', () {
        const setEntries = <SetEntry>[
          SetEntry(reps: 10, weight: '80kg'),
          SetEntry(reps: 8, weight: '85kg'),
          SetEntry(reps: 6, weight: '90kg'),
        ];

        final entry = WeightEntry(
          date: testDate,
          weight: '85kg',
          setEntries: setEntries,
        );

        expect(entry.setEntries, equals(setEntries));
        expect(entry.hasDetailedSets, isTrue);
        expect(entry.totalSets, equals(3));
        expect(entry.totalReps, equals(24));
      });

      test('should handle entry without setEntries', () {
        final entry = WeightEntry(
          date: testDate,
          weight: '80kg',
        );

        expect(entry.hasDetailedSets, isFalse);
        expect(entry.totalSets, equals(0));
        expect(entry.totalReps, equals(0));
      });

      test('should format sets and reps display correctly', () {
        final detailedEntry = WeightEntry(
          date: testDate,
          weight: '80kg',
          setEntries: const [
            SetEntry(reps: 12),
            SetEntry(reps: 10),
            SetEntry(reps: 8),
          ],
        );

        expect(detailedEntry.setsRepsDisplay, equals('12, 10, 8'));

        final legacyEntry = WeightEntry(
          date: testDate,
          weight: '80kg',
          setEntries: const [
            SetEntry(reps: 10),
            SetEntry(reps: 10),
            SetEntry(reps: 10),
          ],
        );

        expect(legacyEntry.setsRepsDisplay, equals('10, 10, 10'));
      });

      test('should serialize setEntries to JSON correctly', () {
        final entry = WeightEntry(
          date: testDate,
          weight: '80kg',
          setEntries: const [
            SetEntry(reps: 10, weight: '80kg'),
            SetEntry(reps: 8, weight: '85kg'),
          ],
        );

        final json = entry.toJson();

        expect(json['setEntries'], isA<List>());
        expect((json['setEntries'] as List).length, equals(2));
        expect(json['setEntries'][0]['reps'], equals(10));
        expect(json['setEntries'][0]['weight'], equals('80kg'));
      });

      test('should deserialize setEntries from JSON correctly', () {
        final json = {
          'date': testDate.toIso8601String(),
          'weight': '80kg',
          'setEntries': [
            {'reps': 10, 'weight': '80kg'},
            {'reps': 8, 'weight': '85kg'},
          ],
        };

        final entry = WeightEntry.fromJson(json);

        expect(entry.setEntries.length, equals(2));
        expect(entry.setEntries[0].reps, equals(10));
        expect(entry.setEntries[0].weight, equals('80kg'));
        expect(entry.setEntries[1].reps, equals(8));
        expect(entry.setEntries[1].weight, equals('85kg'));
      });

      test('should handle JSON round trip with setEntries', () {
        final original = WeightEntry(
          date: testDate,
          weight: '80kg',
          setEntries: const [
            SetEntry(reps: 12, weight: '80kg', notes: 'Good'),
            SetEntry(reps: 10, weight: '85kg'),
          ],
        );

        final json = original.toJson();
        final restored = WeightEntry.fromJson(json);

        expect(restored, equals(original));
        expect(restored.setEntries.length, equals(2));
        expect(restored.setEntries[0].notes, equals('Good'));
      });
    });
  });
}