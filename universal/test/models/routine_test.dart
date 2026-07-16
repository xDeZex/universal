import 'package:flutter_test/flutter_test.dart';
import 'package:universal/models/routine.dart';

void main() {
  group('Routine', () {
    test('a Routine with nested PlannedExercises round-trips through JSON', () {
      const routine = Routine(
        id: 'routine-1',
        name: 'Push Day',
        plannedExercises: [
          PlannedExercise(id: 'pe-1', exerciseId: 'ex-1'),
          PlannedExercise(id: 'pe-2', exerciseId: 'ex-2'),
        ],
      );

      final restored = Routine.fromJson(routine.toJson());

      expect(restored.id, 'routine-1');
      expect(restored.name, 'Push Day');
      expect(restored.plannedExercises.length, 2);
      expect(restored.plannedExercises[0].id, 'pe-1');
      expect(restored.plannedExercises[1].id, 'pe-2');
      expect(restored.archivedAt, isNull);
    });

    test('an archived Routine round-trips through JSON with archivedAt intact', () {
      final archivedAt = DateTime(2026, 7, 10);
      final routine = Routine(
        id: 'routine-1',
        name: 'Push Day',
        archivedAt: archivedAt,
      );

      final restored = Routine.fromJson(routine.toJson());

      expect(restored.archivedAt, archivedAt);
    });

    test('fromJson throws when id key is missing', () {
      final json = {'name': 'Push Day', 'plannedExercises': []};

      expect(() => Routine.fromJson(json), throwsA(anything));
    });

    test('fromJson throws when name key is missing', () {
      final json = {'id': 'routine-1', 'plannedExercises': []};

      expect(() => Routine.fromJson(json), throwsA(anything));
    });

    test('validateRename accepts a non-blank, non-colliding name', () {
      const routine = Routine(id: 'routine-1', name: 'Push Day');
      const existing = [routine, Routine(id: 'routine-2', name: 'Pull Day')];

      expect(routine.validateRename('Leg Day', existing), isNull);
    });

    test('validateRename rejects a blank name', () {
      const routine = Routine(id: 'routine-1', name: 'Push Day');
      const existing = [routine];

      expect(
        routine.validateRename('   ', existing),
        RoutineRenameError.blank,
      );
    });

    test(
      'validateRename rejects a name colliding case-insensitively with '
      'another Routine, but not with the Routine\'s own current name',
      () {
        const routine = Routine(id: 'routine-1', name: 'Push Day');
        const existing = [routine, Routine(id: 'routine-2', name: 'Pull Day')];

        expect(
          routine.validateRename('pull day', existing),
          RoutineRenameError.duplicate,
        );
        expect(routine.validateRename('Push Day', existing), isNull);
        expect(routine.validateRename('push day', existing), isNull);
      },
    );

    test('setting archivedAt via copyWith archives the Routine', () {
      const routine = Routine(id: 'routine-1', name: 'Push Day');
      final archivedAt = DateTime(2026, 7, 10);

      final archived = routine.copyWith(archivedAt: archivedAt);

      expect(archived.archivedAt, archivedAt);
    });

    test('clearing archivedAt via copyWith unarchives the Routine', () {
      final routine = Routine(
        id: 'routine-1',
        name: 'Push Day',
        archivedAt: DateTime(2026, 7, 10),
      );

      final unarchived = routine.copyWith(archivedAt: null);

      expect(unarchived.archivedAt, isNull);
    });

    test('copyWith with no archivedAt argument preserves the current value', () {
      final routine = Routine(
        id: 'routine-1',
        name: 'Push Day',
        archivedAt: DateTime(2026, 7, 10),
      );

      final copy = routine.copyWith(name: 'Push Day Updated');

      expect(copy.archivedAt, routine.archivedAt);
    });

    test('an active Routine (archivedAt == null) reports itself as not locked', () {
      const routine = Routine(id: 'routine-1', name: 'Push Day');

      expect(routine.isLocked, isFalse);
    });

    test('an archived Routine (non-null archivedAt) reports itself as locked', () {
      final routine = Routine(
        id: 'routine-1',
        name: 'Push Day',
        archivedAt: DateTime(2026, 7, 10),
      );

      expect(routine.isLocked, isTrue);
    });
  });
}
