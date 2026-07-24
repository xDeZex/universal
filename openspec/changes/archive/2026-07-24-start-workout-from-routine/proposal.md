## Why

A Routine's Planned Exercises are currently a static template with no way to act on them — `WorkoutRepository.startWorkout` already accepts a `routineId` but ignores it beyond storing it, and the Routine screen has no entry point to start a Workout at all. This change closes that gap ([#186](https://github.com/xDeZex/universal/issues/186)), completing the handoff started by the Routine data model (#182) and Planned Exercise row editing (#185): starting from a Routine pre-fills Exercise Entries from its Planned Exercises, renders their targets as dashed rows in the existing Set grid, and fills them in strict order as the user logs real Sets.

## What Changes

- Add a "Start Workout" / "Continue Workout" bar pinned to the bottom of the Routine screen, hidden entirely while the Routine is archived, reusing the existing one-in-progress rule and button-swap logic verbatim.
- `WorkoutRepository.startWorkout({routineId})` pre-fills one `ExerciseEntry` per Planned Exercise (same order, same `exerciseId`, no placeholder Sets) when given a `routineId`, and rejects the attempt if that Routine is archived.
- `ExerciseEntry` gains a new nullable `targets: List<PlannedExerciseRow>` field — a one-time snapshot of the source Planned Exercise's rows at Workout creation, `null` for entries not started from a Routine.
- `ExerciseEntryTile` renders target rows individually (no grouping/collapsing) in its existing SET/WEIGHT/REPS/TIME grid: row `i` shows a real Set if logged, otherwise a dashed target stand-in.
- Logging fills targets in strict count order — the next Set always lands at the first still-dashed row (`entry.sets.length`); there is no per-row tap-to-retarget. Selecting an Exercise Entry auto-prefills the `AddSetBar`'s weight/reps from the next unfilled target, if one exists.
- `WeightUnit` moves out of `lib/models/workout.dart` into a new `lib/models/weight_unit.dart`, so `workout.dart` can depend on `routine.dart` (for `PlannedExerciseRow`) without a circular import — `routine.dart` no longer needs to import `workout.dart` at all.

Supersedes the raw issue body on two points (see the addendum on #186 for full reasoning): target rows do **not** group into a range-chip/`×N` count (reversed upstream on #176/#177 before #186 was filed, never folded back in), and tapping an individual target row to retarget the prefill is dropped entirely in favor of strict count-order filling.

## Capabilities

### New Capabilities
(none — this change extends three existing capabilities)

### Modified Capabilities
- `gym-routine-management`: adds the Start Workout / Continue Workout bar on the Routine screen, including its archived-hidden and one-in-progress behavior.
- `workout-lifecycle`: extends `ExerciseEntry` construction/serialization with the new `targets` field, and extends "Start a Workout from a Routine" to pre-fill Exercise Entries and reject archived Routines.
- `workout-logging-ui`: extends Exercise Entry row rendering with dashed target rows, and extends Exercise Entry selection to auto-prefill the add-Set bar from the next unfilled target.

## Impact

- `lib/models/workout.dart`, new `lib/models/weight_unit.dart`, `lib/models/routine.dart` (import cleanup)
- `lib/repositories/workout_repository.dart` (`startWorkout` pre-fill + archived guard)
- `lib/widgets/exercise_entry_tile.dart` (dashed target-row rendering)
- `lib/widgets/add_set_bar.dart` / `lib/screens/active_workout_controller.dart` (auto-prefill from next target)
- `lib/screens/routine_screen.dart`, new Start Workout bar widget
- No changes to `PlannedExercise`/`PlannedExerciseRow`/`Routine` themselves — only how their rows are snapshotted and consumed
