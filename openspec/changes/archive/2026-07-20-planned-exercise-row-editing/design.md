## Context

`PlannedExerciseCard` (`universal/lib/widgets/planned_exercise_card.dart`) is currently a `StatelessWidget` that renders rows as plain `Text(_formatRow(row))` — no interaction. `RoutineScreen` (`universal/lib/screens/routine_screen.dart`) is also `StatelessWidget`, watching `WorkoutRepository` via Provider and building one `PlannedExerciseCard` per Planned Exercise. `PlannedExerciseRow` (`universal/lib/models/routine.dart`) has no id of its own — it's identified only by its position within `PlannedExercise.rows`; "row count *is* the target-sets count" is an explicit model decision (#182), so rows are not going to gain a synthetic id as part of this change.

The existing `NumberStepper`/`SetInputRow` (`universal/lib/widgets/set_input_row.dart`) is the established precedent for stepper-based numeric input, used today for logged Sets via `AddSetBar` and `EditSetDialog`. Its weight-stepper-plus-unit-chips portion is now identical in shape to what a Planned Exercise row needs (weight became required for both this cycle), but its reps portion isn't — `SetInputRow` only ever renders a single reps stepper, with no concept of a ranged target.

## Goals / Non-Goals

**Goals:**
- Add, edit, and delete Planned Exercise rows in place, live-applying every change to `WorkoutRepository`.
- Make `PlannedExerciseRow.weight` required, migrating already-persisted null weights to `0 kg` on load.
- Keep exactly one row editor open at a time across the whole Routine screen.

**Non-Goals:**
- Row grouping / consecutive-row collapsing — explicitly dropped this cycle (see addenda on #176 and #177).
- Any change to #177 (Start Workout from Routine) — not yet implemented, out of scope here.
- Any change to drag-and-drop reordering or the Exercise autocomplete field — both already shipped by #184.

## Decisions

**Row identity for update/remove is positional (index within `PlannedExercise.rows`), not a synthetic id.** Rows have no id in the model and the model's own row-count-is-target-count design argues against adding one just for this. `updatePlannedExerciseRow`/`removePlannedExerciseRow` take `(routineId, plannedExerciseId, rowIndex)`.

**Single-open-editor state lives in `RoutineScreen` as local `setState`, not a Provider/ChangeNotifier controller.** `RoutineScreen` becomes `StatefulWidget` holding a nullable `({String plannedExerciseId, int rowIndex})? _openRow`, passed down to each `PlannedExerciseCard` (which stays otherwise similar) along with an `onRowTap` callback. This is pure ephemeral UI state — never persisted, never needed outside this screen's subtree — so a full controller class would be overkill; a `StatefulWidget` field is the simplest correct fit and matches ordinary Flutter idiom for this kind of local toggle state.

**Deleting any row from a Planned Exercise that currently has an open row editor closes that editor, not just when the deleted row is the open one.** Because rows are identified positionally, deleting a row *before* the currently-open row in the same Planned Exercise would silently shift the tracked index onto a different row's data after the rebuild. Rather than shift-tracking the open index on every delete (fragile, easy to get subtly wrong), any delete within the open row's Planned Exercise simply clears `_openRow`. Slightly more conservative than strictly necessary (deleting a row *after* the open one doesn't actually invalidate its index), but predictable and bug-free; deleting rows while another is mid-edit is not expected to be a common flow.

**`fromJson` migrates a missing/null `weight` to `PlannedWeight(value: 0, unit: WeightUnit.kg)`.** Applied lazily at load time in `PlannedExerciseRow.fromJson` — no separate migration script, no data rewrite required; every already-persisted Routine self-heals the first time it's loaded after this change ships.

**Extract the weight-stepper-plus-unit-chips portion of `SetInputRow` into a new shared widget, `WeightInputControls`.** `SetInputRow` is refactored to compose it internally (its own external behavior/API is unchanged — `AddSetBar` and `EditSetDialog` need no changes at all). The new `PlannedExerciseRowEditor` widget composes the same `WeightInputControls` for its weight section, plus its own fixed/ranged reps section built directly on `NumberStepper` and a new range-toggle icon button.

Considered instead: adding optional range-support params directly to `SetInputRow` (e.g. a nullable `rangeMax` + `onRangeToggle`/`onMaxChanged`) and reusing it wholesale for Planned rows too. Rejected — weight input is genuinely identical between the two contexts (same step sizes, same `allowNegative`, same shape), but reps is not (Sets are always single-value; Planned rows can range), so folding both into one widget would mean `SetInputRow.build()` permanently carries an `if (rangeMax != null)` branch for a case Set-editing can never hit, and its public contract gains params that are always null at its two existing call sites. Extracting only the genuinely-shared piece keeps `SetInputRow`'s contract exactly as simple as it is today.

Per-field floor/ceiling clamping (reps floor of 1; range steppers disabling the button that would cross `min`/`max`) lives in `PlannedExerciseRowEditor`'s own bounds logic, not in `NumberStepper` or `WeightInputControls`, so logged-Set behavior (reps floor of 0) is untouched.

**Repository mutator signatures**, following the existing `addPlannedExercise`/`removePlannedExercise`/`reorderPlannedExercises` pattern and its shared `_replacePlannedExercises` lock-check helper:
- `PlannedExerciseRow? addPlannedExerciseRow(String routineId, String plannedExerciseId)`
- `void updatePlannedExerciseRow(String routineId, String plannedExerciseId, int rowIndex, PlannedExerciseRow updatedRow)`
- `void removePlannedExerciseRow(String routineId, String plannedExerciseId, int rowIndex)`

## Risks / Trade-offs

- [Risk] Positional row identity means any index-shift bug in the editor's open-state tracking could silently edit or display the wrong row → Mitigation: closing the open editor on any delete within its own Planned Exercise (see Decision above) rather than attempting to shift-track the index.
- [Risk] `PlannedExerciseRow.weight` becoming non-nullable is a breaking model change touching already-persisted data → Mitigation: `fromJson` migrates missing/null weight to `0 kg` lazily on load; no explicit migration step or data rewrite needed, and no existing data becomes unreadable.
- [Risk] Reusing `NumberStepper`'s default floor of 0 for reps would allow constructing a meaningless "0 rep" target → Mitigation: floor of 1 is enforced in the new row editor widget's own logic, leaving `NumberStepper`'s shared default (and logged-Set behavior, which legitimately wants a 0 floor) unchanged.
