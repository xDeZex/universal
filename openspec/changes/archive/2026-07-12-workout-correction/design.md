## Context

`ActiveWorkoutScreen` currently gates every interactive element behind a single `_isReadOnly = !_workout.isInProgress` boolean (`universal/lib/screens/active_workout_screen.dart`). `PastWorkoutsScreen` opens this screen for a finished Workout with no-op callbacks (`onWorkoutChanged: (_) {}` etc.), so nothing it does can persist. Both were adequate while a finished Workout truly had nothing interactive on it — this change breaks that premise by construction, since a Locked Workout must support editing/deleting a Set or Exercise Entry while still hiding add-new and Discard/Finish. `ExerciseSet` and `ExerciseEntry` are already id-identified (ADR-0017), so mutation-by-id is already possible without new identity plumbing.

## Goals / Non-Goals

**Goals:**
- Replace the single read-only boolean with two independent, explicit gates.
- Add `Workout`-level operations to edit a Set, delete a Set, and delete an Exercise Entry, mirroring the existing `addSet` shape.
- Wire `PastWorkoutsScreen` to real persisting callbacks.
- One shared confirmation dialog widget for both delete call sites.

**Non-Goals:**
- Editing a Set's `loggedAt` or a Workout's `startTime` (out of scope per the proposal).
- Adding new Sets/Exercise Entries to a Locked Workout.
- Any change to `StorageService`'s persistence mechanism itself — it already autosaves the full Workout list on every mutation; this change only needs to make sure `onWorkoutChanged` is actually wired, not no-op.

## Decisions

**Two independent gates replace `_isReadOnly`.** `canAddNew` (`workout.isInProgress`) controls the add-Exercise-Entry field, add-Set row, and Discard/Finish row — unchanged from today's behavior, just renamed and narrowed. Correction actions (tap-to-edit a Set, delete icon on an Exercise Entry) are no longer gated on anything Workout-state-related; they're always rendered. This directly implements the `workout-correction` spec's "available regardless of Locked state" requirements without a second boolean to keep in sync — there's nothing to gate.

*Alternative considered*: keep `_isReadOnly` and add a second `_canCorrect` boolean that's always `true`. Rejected — a boolean that's always true isn't a gate, it's dead code; correction widgets should simply not be conditioned on Workout state at all.

**`Workout.editSet`, `Workout.deleteSet`, `Workout.deleteExerciseEntry` as new model methods**, alongside the existing `addSet`, each taking `entryId` (and `setId` where applicable) and returning a new `Workout` via `copyWith` — same immutable-update shape the model already uses. `deleteSet` looks up the Set's Entry by `entryId`, filters the Set out by `setId`, and does not touch the Entry itself even if that leaves zero Sets (per spec). `deleteExerciseEntry` filters the Entry out of `exerciseEntries` by `entryId` directly.

*Alternative considered*: mutate by list index instead of id. Rejected — that's exactly what ADR-0017 already ruled out for this reason (list order isn't a stable reference across edits).

**One shared `ConfirmDeleteDialog` widget**, parameterized by a message string, used by both the Set-delete flow (invoked from inside the Set edit dialog) and the Exercise-Entry-delete flow (invoked from the header's delete icon). Both call sites `await showDialog<bool>(...)` and only proceed on `true`.

**`PastWorkoutsScreen` gets real callbacks.** It already receives `workouts`/`exercises` as props from its parent (same as `ActiveWorkoutScreen` today); it needs the same `onWorkoutChanged`/`onExercisesChanged`/`onWorkoutDiscarded` plumbing `WorkoutHomeScreen` already has, passed down from wherever both screens' shared parent holds the persisted state. `onWorkoutDiscarded` specifically will never fire from here in practice (Discard is hidden on a Locked Workout), but the callback still needs to be real rather than no-op, since `ActiveWorkoutScreen`'s constructor requires all three.

## Risks / Trade-offs

- **[Risk]** Editing/deleting a Set or Exercise Entry from the Past Workouts detail view needs the same live-storage round-trip `WorkoutHomeScreen` already does, duplicated across two screens → **Mitigation**: both screens already take the same `Workout`/`Exercise` list + callback shape; wiring is mechanical, not a new pattern.
- **[Risk]** A shared confirmation dialog used for two structurally different actions (removing one Set vs. cascading through an entire Exercise Entry) could read as identical when the consequences differ → **Mitigation**: the dialog is parameterized by message text, so each call site states what's actually being deleted (e.g. "Delete this Set?" vs. "Delete this Exercise Entry and all N of its Sets?").

## Open Questions

None — all UX and boundary questions were resolved during the grilling and explore-mode sessions preceding this proposal (see ADR-0017, ADR-0018, CONTEXT.md's Locked/Set/Exercise Entry entries).
