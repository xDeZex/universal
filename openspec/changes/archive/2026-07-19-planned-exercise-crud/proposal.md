## Why

Routine and Planned Exercise data model and persistence exist (#182), and Routines can be created, listed, renamed, and archived (#183), but a Routine's screen body is still a static "No Planned Exercises yet" placeholder — there's no way to actually build out a Routine's content yet. This ticket (#184) closes that gap for the add/remove/reorder half of Planned Exercise editing; editing an individual row's reps/weight target is out of scope, deferred to a later ticket.

## What Changes

- Routine screen body renders the Routine's Planned Exercises as a reorderable list of cards (header: drag handle, Exercise name, delete icon; rows render read-only beneath, no editing UI yet).
- A freeform text field + inline add button (mirroring the existing "Add Exercise Entry" field used during Workout logging) lets the user add a Planned Exercise by Exercise name, backed by a new autocomplete dropdown of matching existing Exercises.
  - Match is substring-anywhere, case-insensitive; results are plain (no usage counts), alphabetically ordered, unbounded (dropdown scrolls).
  - Tapping a suggestion fills the field with that Exercise's name (does not auto-submit); submitting (Enter or the add button) resolves the typed name to an existing Exercise by case-insensitive exact match or creates a new one, via the existing `Exercise.resolve` — unchanged, reused as-is.
  - No "add as new" row in the dropdown; unmatched-name-creates-new stays purely a submit-time behavior.
- Tapping a Planned Exercise card's header delete icon removes it (and its rows) immediately, no confirmation dialog.
- Long-press-dragging a card's header reorders it within the Routine's Planned Exercise list (list order is the Routine's implicit order, no separate position field); the new order persists.
- `WorkoutRepository` gains `addPlannedExercise`, `removePlannedExercise`, and `reorderPlannedExercises`, mirroring the existing Routine mutator pattern (validate/mutate/persist/notify).
- None of the above is available while a Routine is archived/locked (existing locked-banner behavior from #183 is unchanged and continues to block edits).

## Capabilities

### New Capabilities

_(none — this extends the two existing Routine capabilities below rather than introducing a new one)_

### Modified Capabilities

- `gym-routine-management`: Routine screen body gains the Planned Exercise list (add/remove/reorder UI, autocomplete dropdown), replacing the current static empty-state-only body. The empty-state requirement is superseded (still shown when the list is genuinely empty, but the body is no longer *only* that state).
- `routine-persistence`: `WorkoutRepository` gains `addPlannedExercise`/`removePlannedExercise`/`reorderPlannedExercises`, each validating against the Routine's locked state, persisting via `StorageService`, and notifying listeners — mirroring the existing add/rename/archive Routine requirements.

## Impact

- `universal/lib/screens/routine_screen.dart` — body rewritten from static placeholder to the live Planned Exercise list + add UI.
- `universal/lib/repositories/workout_repository.dart` — three new mutator methods, mirroring existing private mutate/replace helpers.
- New widget(s) under `universal/lib/widgets/` for the Planned Exercise card and the autocomplete-backed add field (new code, not extracted from or shared with the existing logging-flow "Add Exercise Entry" field or `ExerciseEntryTile` — those stay untouched).
- No changes to `universal/lib/models/routine.dart` (model already complete from #182) or to any logging-flow files (`active_workout_screen.dart`, `exercise_entry_tile.dart`).
- Blocked-by issues #182 (data model) and #183 (Manage Routines screen) are both already closed/merged — no outstanding blockers.
