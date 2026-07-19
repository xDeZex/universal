import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal/models/routine.dart';
import 'package:universal/repositories/workout_repository.dart';
import 'package:universal/services/storage_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('WorkoutRepository.archiveRoutine', () {
    test('sets archivedAt on the target active Routine, persists the updated '
        'list, and notifies listeners', () async {
      final target = Routine(id: 'routine-1', name: 'Push Day');
      final repository = WorkoutRepository(
        initialWorkouts: const [],
        initialExercises: const [],
        initialRoutines: [target],
      );
      var notified = false;
      repository.addListener(() => notified = true);

      repository.archiveRoutine('routine-1');

      expect(
        repository.routines.firstWhere((r) => r.id == 'routine-1').archivedAt,
        isNotNull,
      );
      expect(notified, isTrue);

      await Future<void>.delayed(Duration.zero);
      final stored = await StorageService().loadRoutines();
      expect(
        stored.firstWhere((r) => r.id == 'routine-1').archivedAt,
        isNotNull,
      );
    });

    test('is a no-op for a routineId that matches no Routine', () {
      final target = Routine(id: 'routine-1', name: 'Push Day');
      final repository = WorkoutRepository(
        initialWorkouts: const [],
        initialExercises: const [],
        initialRoutines: [target],
      );
      var notified = false;
      repository.addListener(() => notified = true);

      repository.archiveRoutine('missing-routine');

      expect(repository.routines.single.archivedAt, isNull);
      expect(notified, isFalse);
    });
  });

  group('WorkoutRepository.unarchiveRoutine', () {
    test('clears archivedAt on the target archived Routine, persists the '
        'updated list, and notifies listeners', () async {
      final target = Routine(
        id: 'routine-1',
        name: 'Push Day',
        archivedAt: DateTime(2026, 7, 10),
      );
      final repository = WorkoutRepository(
        initialWorkouts: const [],
        initialExercises: const [],
        initialRoutines: [target],
      );
      var notified = false;
      repository.addListener(() => notified = true);

      repository.unarchiveRoutine('routine-1');

      expect(
        repository.routines.firstWhere((r) => r.id == 'routine-1').archivedAt,
        isNull,
      );
      expect(notified, isTrue);

      await Future<void>.delayed(Duration.zero);
      final stored = await StorageService().loadRoutines();
      expect(stored.firstWhere((r) => r.id == 'routine-1').archivedAt, isNull);
    });

    test('is a no-op for a routineId that matches no Routine', () {
      final target = Routine(
        id: 'routine-1',
        name: 'Push Day',
        archivedAt: DateTime(2026, 7, 10),
      );
      final repository = WorkoutRepository(
        initialWorkouts: const [],
        initialExercises: const [],
        initialRoutines: [target],
      );
      var notified = false;
      repository.addListener(() => notified = true);

      repository.unarchiveRoutine('missing-routine');

      expect(repository.routines.single.archivedAt, isNotNull);
      expect(notified, isFalse);
    });
  });
}
