## 1. RepsTarget represents a fixed rep count or a min/max range

- [x] 1.1 `FixedReps` and `RangeReps` each round-trip through `toJson`/`fromJson`
- [x] 1.2 `RepsTarget.fromJson` throws on an unrecognized discriminator value
- [x] 1.3 Range validation returns no error for `min < max`
- [x] 1.4 Range validation returns an invalid-range error for `min >= max`

## 2. PlannedWeight bundles a value with its unit

- [x] 2.1 `PlannedWeight` round-trips through `toJson`/`fromJson`
- [x] 2.2 `PlannedWeight.fromJson` throws on a map missing the `unit` key

## 3. PlannedExerciseRow construction and serialization

- [x] 3.1 A row with `FixedReps` and `weight: null` round-trips through JSON
- [x] 3.2 A row with `RangeReps` and a non-null `weight` round-trips through JSON
- [x] 3.3 `PlannedExerciseRow.fromJson` throws on a map missing the `reps` key

## 4. PlannedExercise construction and serialization

- [x] 4.1 A PlannedExercise with nested rows round-trips through JSON
- [x] 4.2 `PlannedExercise.fromJson` throws on a map missing `id` or `exerciseId`
- [x] 4.3 A PlannedExercise with zero rows round-trips as a valid, non-error state

## 5. Routine construction, identity, and archive lifecycle

- [x] 5.1 A Routine with nested PlannedExercises round-trips through JSON
- [x] 5.2 `Routine.fromJson` throws on a map missing `id` or `name`
- [x] 5.3 `validateRename` accepts a non-blank, non-colliding name
- [x] 5.4 `validateRename` rejects a blank name
- [x] 5.5 `validateRename` rejects a name colliding case-insensitively with another Routine, but not with the Routine's own current name
- [x] 5.6 Setting `archivedAt` via `copyWith` archives the Routine; clearing it unarchives
- [x] 5.7 An active Routine reports itself as not locked; an archived Routine reports itself as locked

## 6. Workout gains a nullable, set-once routineId

- [x] 6.1 A Workout constructed with a `routineId` round-trips through JSON with that `routineId` intact
- [x] 6.2 A Workout constructed without a `routineId` has `routineId == null` and round-trips as `null`
- [x] 6.3 `Workout.copyWith` has no parameter that can change `routineId`
- [x] 6.4 `WorkoutRepository.startWorkout` accepts an optional `routineId` and sets it on the created Workout; omitting it defaults to `null`

## 7. Routines persist via StorageService under their own key

- [ ] 7.1 `StorageService.loadRoutines` returns a previously saved Routine list, reconstructed from JSON
- [ ] 7.2 `StorageService.loadRoutines` returns an empty list when nothing is stored
- [ ] 7.3 `StorageService.saveRoutines` writes to a key distinct from Checklists, Workouts, and Exercises

## 8. WorkoutRepository loads and creates Routines

- [ ] 8.1 `WorkoutRepository.load()` populates `routines` alongside `workouts` and `exercises`
- [ ] 8.2 `addRoutine` with a unique name creates and returns a new active Routine with no Planned Exercises
- [ ] 8.3 `addRoutine` with a blank name returns `null` and leaves the Routine list unchanged
- [ ] 8.4 `addRoutine` with a name colliding case-insensitively with an existing Routine returns `null` and creates no second Routine
- [ ] 8.5 A successful `addRoutine` call persists the updated Routine list via `StorageService` and calls `notifyListeners()`
