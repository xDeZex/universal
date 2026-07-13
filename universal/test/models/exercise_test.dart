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

    test('resolve returns the existing Exercise on a case-insensitive exact match', () {
      final existing = [
        Exercise(id: 'ex-1', name: 'Bench Press'),
        Exercise(id: 'ex-2', name: 'Squat'),
      ];

      final resolved = Exercise.resolve('bench press', existing)!;

      expect(resolved.id, 'ex-1');
      expect(resolved.name, 'Bench Press');
    });

    test('resolve constructs a new Exercise when no match exists', () {
      final existing = [Exercise(id: 'ex-1', name: 'Bench Press')];

      final resolved = Exercise.resolve('Deadlift', existing)!;

      expect(resolved.name, 'Deadlift');
      expect(resolved.id, isNot(equals('ex-1')));
      expect(
        existing.any((e) => e.id == resolved.id),
        isFalse,
      );
    });

    test('resolve returns null and creates nothing for an empty name', () {
      final existing = [Exercise(id: 'ex-1', name: 'Bench Press')];

      final resolved = Exercise.resolve('', existing);

      expect(resolved, isNull);
    });

    test('resolve returns null and creates nothing for a whitespace-only name', () {
      final existing = [Exercise(id: 'ex-1', name: 'Bench Press')];

      final resolved = Exercise.resolve('   ', existing);

      expect(resolved, isNull);
    });

    test('nameFor returns the matching Exercise name', () {
      final existing = [
        Exercise(id: 'ex-1', name: 'Bench Press'),
        Exercise(id: 'ex-2', name: 'Squat'),
      ];

      expect(Exercise.nameFor('ex-2', existing), 'Squat');
    });

    test('nameFor falls back to "Unknown Exercise" when no id matches', () {
      final existing = [Exercise(id: 'ex-1', name: 'Bench Press')];

      expect(Exercise.nameFor('missing', existing), 'Unknown Exercise');
    });

    test(
      'validateRename returns null for a valid, non-colliding name',
      () {
        final exercise = Exercise(id: 'ex-1', name: 'Bench Press');
        final existing = [exercise, Exercise(id: 'ex-2', name: 'Squat')];

        expect(
          exercise.validateRename('Incline Bench Press', existing),
          isNull,
        );
      },
    );

    test(
      'validateRename returns blank for an empty or whitespace-only name',
      () {
        final exercise = Exercise(id: 'ex-1', name: 'Bench Press');
        final existing = [exercise];

        expect(
          exercise.validateRename('   ', existing),
          ExerciseRenameError.blank,
        );
      },
    );

    test(
      'validateRename returns null when renaming to its own current name '
      'or a case-only variant, since it is excluded from its own collision '
      'check',
      () {
        final exercise = Exercise(id: 'ex-1', name: 'Bench Press');
        final existing = [exercise, Exercise(id: 'ex-2', name: 'Squat')];

        expect(exercise.validateRename('Bench Press', existing), isNull);
        expect(exercise.validateRename('bench press', existing), isNull);
      },
    );

    test(
      'validateRename returns duplicate for a name colliding with another '
      'Exercise case-insensitively',
      () {
        final exercise = Exercise(id: 'ex-1', name: 'Bench Press');
        final existing = [exercise, Exercise(id: 'ex-2', name: 'Squat')];

        expect(
          exercise.validateRename('squat', existing),
          ExerciseRenameError.duplicate,
        );
      },
    );
  });
}
