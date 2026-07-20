## Why

Planned Exercise rows currently render as static, read-only text (`PlannedExerciseCard`'s `_formatRow`) — #184 shipped whole-card add/remove/reorder but explicitly left rows uneditable, "the next ticket." Without row-level editing there's no way to actually shape a Routine's rep/weight targets after creation, which defeats the point of a Routine.

## What Changes

- Add an inline "+ Add row" control to each Planned Exercise card that appends a new row — copying the last row's reps/weight, or defaulting to 1 rep / 0 kg if the card has no rows yet — and immediately opens its editor.
- Add in-place row editing: tapping a row expands an editor beneath it with a reps stepper (fixed) or two steppers joined by a range toggle (ranged), and a weight stepper with kg/lbs unit chips. Edits apply live to the repository on every stepper/toggle interaction — no save/cancel step.
- Add inline per-row delete (✕), no confirmation.
- **BREAKING**: `PlannedExerciseRow.weight` becomes a required `PlannedWeight` instead of a nullable `PlannedWeight?` — there is no longer a "no weight target" state. New rows default to `0 kg`. Already-persisted Routines with a null weight are migrated to `0 kg` on load.
- Exactly one row editor is open at a time across the whole Routine screen; opening a different row's editor collapses whichever was open.
- Row-editing controls (add row, per-row edit/delete) are hidden while the Routine is archived, consistent with the existing card-level and list-level locking.

## Capabilities

### New Capabilities
(none — this extends existing Routine-editing capabilities)

### Modified Capabilities
- `gym-routine-management`: Planned Exercise card rows become editable in place (add/edit/delete) instead of read-only; row editors are mutually exclusive (one open at a time, anywhere on the screen) and hidden while the Routine is archived.
- `routine-model`: `PlannedExerciseRow.weight` changes from optional/nullable to required.
- `routine-persistence`: new repository operations for adding, updating, and removing a Planned Exercise row, following the existing lock-check/persist/notify pattern already used by the whole-Planned-Exercise mutators.

## Impact

- `universal/lib/models/routine.dart` — `PlannedExerciseRow.weight` becomes non-nullable; `fromJson` defaults a missing/null weight to `0 kg` for backward compatibility with already-persisted data.
- `universal/lib/widgets/planned_exercise_card.dart` — rows become interactive (add/edit/delete), replacing the current `Text(_formatRow(row))` list.
- `universal/lib/widgets/set_input_row.dart` — refactored to extract a new shared `WeightInputControls` widget (weight stepper + kg/lbs chips); `SetInputRow`'s own external behavior/API is unchanged.
- New `PlannedExerciseRowEditor` widget under `universal/lib/widgets/`, composing `WeightInputControls` for weight and its own fixed/ranged reps section built on `NumberStepper`.
- `universal/lib/repositories/workout_repository_planned_exercises.dart` — new mutators for adding, updating, and removing a row within a Planned Exercise.
- `universal/lib/screens/routine_screen.dart` — owns which row's editor is currently open (single-open-editor state spanning all cards on the screen).
- Existing persisted Routine data (SharedPreferences) — any row with `weight: null` needs a load-time migration to `0 kg`.
