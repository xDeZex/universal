## Why

A user can log a Workout but has no way to fix a mistake afterward — a wrong weight, an extra Set, an Exercise Entry added by accident. Once a Workout is Locked (finished), the Active Workout screen hides every interactive control, including ones that only ever needed to be gone for *new* logging, not for correcting what's already there. This blocks a core part of the local-first gym-tracking MVP (issue #16): editing or deleting any Set or Exercise Entry.

## What Changes

- Add editing a Set's weight/unit/reps via a dialog opened by tapping its row, pre-filled with the current values.
- Add deleting a Set, via a Delete action inside that same edit dialog.
- Add deleting an Exercise Entry (and all its Sets) via a delete icon next to its name header.
- Add a single shared confirmation dialog, required before any delete (Set or Exercise Entry), regardless of whether the Workout is Locked.
- **BREAKING**: Replace `ActiveWorkoutScreen`'s single read-only mode with two independent gates — adding new Sets/Exercise Entries and Discard/Finish stay exclusive to an in-progress Workout, while editing/deleting is available regardless of Locked state.
- Wire `PastWorkoutsScreen`'s currently no-op `onWorkoutChanged`/`onExercisesChanged`/`onWorkoutDiscarded` callbacks into real persisting callbacks, since a Locked Workout opened from Past Workouts now needs somewhere to save corrections to.

## Capabilities

### New Capabilities
- `workout-correction`: editing and deleting a Set or Exercise Entry on the Active Workout screen, the Locked-vs-correctable distinction, and the shared delete-confirmation dialog.

### Modified Capabilities
- `workout-logging-ui`: the "Active Workout screen renders read-only for a finished Workout" and "Finished Workout's Sets display their logged time" requirements are replaced — this capability keeps only the Locked-gating of add-controls (add-Entry field, add-Set controls, Discard/Finish hidden when Locked); correction behavior itself moves to `workout-correction`.
- `workout-history`: the "Tapping a Past Workout opens its read-only detail view" requirement is reworded — the detail view is no longer read-only, and `PastWorkoutsScreen` must wire real persisting callbacks instead of no-ops.

## Impact

- `universal/lib/screens/active_workout_screen.dart` — edit dialog, delete affordances, shared confirmation dialog, replacing `_isReadOnly` with two independent gates.
- `universal/lib/screens/past_workouts_screen.dart` — real callbacks instead of no-ops.
- `universal/lib/models/workout.dart` — likely needs `editSet`/`deleteSet`/`deleteExerciseEntry` operations alongside the existing `addSet`.
- `openspec/specs/workout-logging-ui/spec.md`, `openspec/specs/workout-history/spec.md` — delta specs for the requirement changes above.
- `CONTEXT.md` (Locked, Set, Exercise Entry, Workout) and `docs/adr/0017-*.md`, `docs/adr/0018-*.md` — already updated on this branch during exploration; no further changes expected.
