part of 'workout_repository.dart';

/// Planned Exercise mutators for [WorkoutRepository], split into a part file
/// to keep `workout_repository.dart` under the repo's line-count limit while
/// retaining access to its private fields.
extension WorkoutRepositoryPlannedExercises on WorkoutRepository {
  PlannedExercise? addPlannedExercise(String routineId, String name) {
    final exercise = Exercise.resolve(name, exercises);
    if (exercise == null) return null;

    final isNewExercise = !exercises.any((e) => e.id == exercise.id);
    final plannedExercise = PlannedExercise(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      exerciseId: exercise.id,
    );

    final applied = _replacePlannedExercises(
      routineId,
      (r) => r.copyWith(
        plannedExercises: [...r.plannedExercises, plannedExercise],
      ),
    );
    if (!applied) return null;

    if (isNewExercise) {
      _exercises = [...exercises, exercise];
      _storage.saveExercises(exercises);
    }
    _notifyPlannedExercisesChanged();
    return plannedExercise;
  }

  void removePlannedExercise(String routineId, String plannedExerciseId) {
    final routineIndex = routines.indexWhere((r) => r.id == routineId);
    if (routineIndex == -1) return;
    if (!routines[routineIndex].plannedExercises.any(
      (pe) => pe.id == plannedExerciseId,
    )) {
      return;
    }

    final applied = _replacePlannedExercises(
      routineId,
      (r) => r.copyWith(
        plannedExercises: r.plannedExercises
            .where((pe) => pe.id != plannedExerciseId)
            .toList(),
      ),
    );
    if (applied) _notifyPlannedExercisesChanged();
  }

  void reorderPlannedExercises(String routineId, int oldIndex, int newIndex) {
    final routineIndex = routines.indexWhere((r) => r.id == routineId);
    if (routineIndex == -1) return;
    final length = routines[routineIndex].plannedExercises.length;
    if (oldIndex < 0 ||
        oldIndex >= length ||
        newIndex < 0 ||
        newIndex >= length) {
      return;
    }

    final applied = _replacePlannedExercises(routineId, (r) {
      final reordered = r.plannedExercises.toList();
      final plannedExercise = reordered.removeAt(oldIndex);
      reordered.insert(newIndex, plannedExercise);
      return r.copyWith(plannedExercises: reordered);
    });
    if (applied) _notifyPlannedExercisesChanged();
  }

  PlannedExerciseRow? addPlannedExerciseRow(
    String routineId,
    String plannedExerciseId,
  ) {
    final plannedExercise = _findPlannedExercise(routineId, plannedExerciseId);
    if (plannedExercise == null) return null;

    final newRow = plannedExercise.rows.isEmpty
        ? const PlannedExerciseRow(
            reps: FixedReps(1),
            weight: PlannedExerciseRow.defaultWeight,
          )
        : plannedExercise.rows.last;

    final applied = _updatePlannedExerciseRows(
      routineId,
      plannedExerciseId,
      (rows) => [...rows, newRow],
    );
    if (!applied) return null;

    _notifyPlannedExercisesChanged();
    return newRow;
  }

  void updatePlannedExerciseRow(
    String routineId,
    String plannedExerciseId,
    int rowIndex,
    PlannedExerciseRow updatedRow,
  ) {
    final plannedExercise = _findPlannedExercise(routineId, plannedExerciseId);
    if (plannedExercise == null) return;
    if (rowIndex < 0 || rowIndex >= plannedExercise.rows.length) return;

    final applied = _updatePlannedExerciseRows(
      routineId,
      plannedExerciseId,
      (rows) => rows.toList()..[rowIndex] = updatedRow,
    );
    if (applied) _notifyPlannedExercisesChanged();
  }

  void removePlannedExerciseRow(
    String routineId,
    String plannedExerciseId,
    int rowIndex,
  ) {
    final plannedExercise = _findPlannedExercise(routineId, plannedExerciseId);
    if (plannedExercise == null) return;
    if (rowIndex < 0 || rowIndex >= plannedExercise.rows.length) return;

    final applied = _updatePlannedExerciseRows(
      routineId,
      plannedExerciseId,
      (rows) => rows.toList()..removeAt(rowIndex),
    );
    if (applied) _notifyPlannedExercisesChanged();
  }

  PlannedExercise? _findPlannedExercise(
    String routineId,
    String plannedExerciseId,
  ) {
    final routineIndex = routines.indexWhere((r) => r.id == routineId);
    if (routineIndex == -1) return null;
    final plannedExercises = routines[routineIndex].plannedExercises;
    for (final pe in plannedExercises) {
      if (pe.id == plannedExerciseId) return pe;
    }
    return null;
  }

  /// Replaces the Planned Exercise matching [plannedExerciseId] within the
  /// Routine matching [routineId] by applying [update] to its row list,
  /// via [_replacePlannedExercises]'s lock-check/persist behavior.
  bool _updatePlannedExerciseRows(
    String routineId,
    String plannedExerciseId,
    List<PlannedExerciseRow> Function(List<PlannedExerciseRow>) update,
  ) {
    return _replacePlannedExercises(
      routineId,
      (r) => r.copyWith(
        plannedExercises: r.plannedExercises
            .map(
              (pe) => pe.id == plannedExerciseId
                  ? pe.copyWith(rows: update(pe.rows))
                  : pe,
            )
            .toList(),
      ),
    );
  }

  /// Replaces the Routine matching [routineId] via [update], persisting and
  /// returning `true` only if a match was found and it isn't archived — a
  /// no-op otherwise, so archived Routines reject Planned Exercise edits.
  bool _replacePlannedExercises(
    String routineId,
    Routine Function(Routine) update,
  ) {
    final index = routines.indexWhere((r) => r.id == routineId);
    if (index == -1 || routines[index].isLocked) return false;

    _routines = routines.map((r) => r.id == routineId ? update(r) : r).toList();
    _storage.saveRoutines(routines);
    return true;
  }
}
