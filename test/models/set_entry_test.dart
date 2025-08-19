import 'package:flutter_test/flutter_test.dart';
import 'package:universal/models/set_entry.dart';

void main() {
  group('SetEntry', () {
    const testReps = 10;
    const testWeight = '80kg';
    const testNotes = 'Good form';

    test('should create SetEntry with required fields', () {
      const entry = SetEntry(reps: testReps);

      expect(entry.reps, equals(testReps));
      expect(entry.weight, isNull);
      expect(entry.notes, isNull);
    });

    test('should create SetEntry with all fields', () {
      const entry = SetEntry(
        reps: testReps,
        weight: testWeight,
        notes: testNotes,
      );

      expect(entry.reps, equals(testReps));
      expect(entry.weight, equals(testWeight));
      expect(entry.notes, equals(testNotes));
    });

    test('should create copy with modified fields', () {
      const original = SetEntry(reps: testReps);
      final copy = original.copyWith(
        weight: testWeight,
        notes: testNotes,
      );

      expect(copy.reps, equals(testReps));
      expect(copy.weight, equals(testWeight));
      expect(copy.notes, equals(testNotes));
      expect(original.weight, isNull);
      expect(original.notes, isNull);
    });

    test('should serialize to JSON correctly', () {
      const entry = SetEntry(
        reps: testReps,
        weight: testWeight,
        notes: testNotes,
      );

      final json = entry.toJson();

      expect(json['reps'], equals(testReps));
      expect(json['weight'], equals(testWeight));
      expect(json['notes'], equals(testNotes));
    });

    test('should serialize to JSON with optional fields as null', () {
      const entry = SetEntry(reps: testReps);

      final json = entry.toJson();

      expect(json['reps'], equals(testReps));
      expect(json.containsKey('weight'), isFalse);
      expect(json.containsKey('notes'), isFalse);
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'reps': testReps,
        'weight': testWeight,
        'notes': testNotes,
      };

      final entry = SetEntry.fromJson(json);

      expect(entry.reps, equals(testReps));
      expect(entry.weight, equals(testWeight));
      expect(entry.notes, equals(testNotes));
    });

    test('should handle JSON serialization round trip', () {
      const original = SetEntry(
        reps: testReps,
        weight: testWeight,
        notes: testNotes,
      );

      final json = original.toJson();
      final restored = SetEntry.fromJson(json);

      expect(restored, equals(original));
    });

    test('should implement equality correctly', () {
      const entry1 = SetEntry(reps: testReps);
      const entry2 = SetEntry(reps: testReps);
      const entry3 = SetEntry(reps: 12);

      expect(entry1, equals(entry2));
      expect(entry1, isNot(equals(entry3)));
    });

    test('should have meaningful string representation', () {
      const entry = SetEntry(
        reps: testReps,
        weight: testWeight,
        notes: testNotes,
      );

      final stringRep = entry.toString();

      expect(stringRep, contains('$testReps'));
      expect(stringRep, contains(testWeight));
      expect(stringRep, contains(testNotes));
    });
  });
}