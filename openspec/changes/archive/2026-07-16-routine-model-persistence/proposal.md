## Why

The Routine design map (#172) is fully decided — a user should be able to define a reusable Routine of Planned Exercises and start a Workout from one. This change is the implementation handoff: the data model and persistence Routine needs before any screen can be built on top of it (#183-#186).

## What Changes

- Add `Routine` model: id-based identity, unique case-insensitive `name` (`validateRename`/`resolve`, mirroring `Exercise`/ADR-0015), ordered `List<PlannedExercise>`, `archivedAt` (nullable, reversible), locked-while-archived.
- Add `PlannedExercise` model: id-based identity, `exerciseId` reference, ordered `List<PlannedExerciseRow>`.
- Add `PlannedExerciseRow` model: `reps` (`RepsTarget`) and `weight` (`PlannedWeight?`).
- Add `RepsTarget` sealed class (`FixedReps`/`RangeReps`, with a validation error for an invalid range) — the first sealed class in this codebase.
- Add `PlannedWeight` value object bundling a weight value with its `WeightUnit` so the two can't go out of sync.
- Add nullable `routineId` field to `Workout`, set once at creation via `startWorkout`, immutable thereafter.
- Extend `StorageService` with a Routine storage key and `loadRoutines`/`saveRoutines`, mirroring the existing Checklist/Workout/Exercise key-per-model pattern.
- Extend `WorkoutRepository` (not a new sibling repository) with `List<Routine> routines` and a single mutation method, `addRoutine(name)`, rejecting blank/duplicate names.

## Capabilities

### New Capabilities
- `routine-model`: `Routine`, `PlannedExercise`, `PlannedExerciseRow`, `RepsTarget`, `PlannedWeight` — construction, serialization, identity/rename validation, and archive lifecycle.
- `routine-persistence`: Loading and saving Routines via `StorageService`/`WorkoutRepository`, and creating a new Routine.

### Modified Capabilities
- `workout-lifecycle`: Workout's construction/serialization requirement gains a nullable `routineId` field, set once at creation and immutable thereafter.

## Impact

- `lib/models/routine.dart` (new)
- `lib/models/workout.dart` (add `routineId`)
- `lib/services/storage_service.dart` (add Routine key/load/save)
- `lib/repositories/workout_repository.dart` (add `routines`, `addRoutine`)
- `test/models/routine_test.dart` (new), `test/models/workout_test.dart`, `test/repositories/workout_repository_test.dart`

No UI changes. Out of scope: rename/archive/unarchive, add/remove/reorder Planned Exercises, edit rows (#183-#185), pre-filling a Workout from a Routine (#186), Program/Schedule (#172).
