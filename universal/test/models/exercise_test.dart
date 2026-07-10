import 'package:flutter_test/flutter_test.dart';
import 'package:universal/models/exercise.dart';

void main() {
  group('Exercise', () {
    test('creates with id and name', () {
      final exercise = Exercise(id: 'ex-1', name: 'Bench Press');

      expect(exercise.id, 'ex-1');
      expect(exercise.name, 'Bench Press');
    });

    test('toJson/fromJson round-trip preserves id and name', () {
      final exercise = Exercise(id: 'ex-1', name: 'Bench Press');

      final restored = Exercise.fromJson(exercise.toJson());

      expect(restored.id, 'ex-1');
      expect(restored.name, 'Bench Press');
    });

    test('fromJson throws when id key is missing', () {
      final json = {'name': 'Bench Press'};

      expect(() => Exercise.fromJson(json), throwsA(anything));
    });

    test('fromJson throws when name key is missing', () {
      final json = {'id': 'ex-1'};

      expect(() => Exercise.fromJson(json), throwsA(anything));
    });

    test('copyWith(name: ...) returns a new Exercise with the same id and updated name', () {
      final exercise = Exercise(id: 'ex-1', name: 'Bench Press');

      final renamed = exercise.copyWith(name: 'Incline Bench Press');

      expect(renamed.id, 'ex-1');
      expect(renamed.name, 'Incline Bench Press');
    });

    test('copyWith with no arguments returns an identical Exercise', () {
      final exercise = Exercise(id: 'ex-1', name: 'Bench Press');

      final copy = exercise.copyWith();

      expect(copy.id, 'ex-1');
      expect(copy.name, 'Bench Press');
    });
  });
}
