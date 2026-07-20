## 1. PlannedExerciseRow.weight is required

- [x] 1.1 `PlannedExerciseRow.weight` is `PlannedWeight` (non-nullable), not `PlannedWeight?`
- [x] 1.2 Constructing/round-tripping a row with fixed reps and a weight through `toJson`/`fromJson` preserves reps and weight
- [x] 1.3 Constructing/round-tripping a row with ranged reps and a weight through `toJson`/`fromJson` preserves reps range and weight
- [x] 1.4 `fromJson` on a map with a `null` or missing `weight` key produces a row with weight `0 kg` instead of throwing or leaving weight null
- [x] 1.5 `fromJson` on a map missing the `reps` key still throws

## 2. Repository: add/update/remove a Planned Exercise row

- [x] 2.1 `WorkoutRepository.addPlannedExerciseRow(routineId, plannedExerciseId)` appends a row copying the last row's reps/weight when the Planned Exercise already has rows
- [x] 2.2 `addPlannedExerciseRow` appends a row defaulting to fixed 1 rep / `0 kg` when the Planned Exercise has no rows
- [x] 2.3 `addPlannedExerciseRow` on an archived Routine leaves the row list unchanged and persists nothing
- [x] 2.4 `addPlannedExerciseRow` persists the updated Routine list via `StorageService` and notifies listeners
- [x] 2.5 `WorkoutRepository.updatePlannedExerciseRow(routineId, plannedExerciseId, rowIndex, updatedRow)` replaces the row at that index in place
- [x] 2.6 `updatePlannedExerciseRow` on an archived Routine leaves the row unchanged and persists nothing
- [x] 2.7 `updatePlannedExerciseRow` persists the updated Routine list via `StorageService` and notifies listeners
- [x] 2.8 `WorkoutRepository.removePlannedExerciseRow(routineId, plannedExerciseId, rowIndex)` removes the row at that index
- [x] 2.9 `removePlannedExerciseRow` on an archived Routine leaves the row list unchanged and persists nothing
- [x] 2.10 `removePlannedExerciseRow` persists the updated Routine list via `StorageService` and notifies listeners

## 3. Row editor: reps (fixed / ranged)

- [x] 3.1 New `PlannedExerciseRowEditor` widget renders a single reps stepper when the row's reps is `FixedReps`
- [x] 3.2 Renders two reps steppers joined by a range toggle when the row's reps is `RangeReps`
- [x] 3.3 Adjusting the fixed-reps stepper calls the update callback immediately with the new `FixedReps` value
- [x] 3.4 Tapping the range toggle on a fixed row converts it to `RangeReps(min: <current>, max: <current> + 1)` immediately
- [x] 3.5 Tapping the range toggle on a ranged row converts it to `FixedReps(<min>)` immediately, dropping `max`
- [x] 3.6 The max stepper's decrement is disabled when `max == min + 1`; the min stepper's increment is disabled when `min == max - 1`
- [x] 3.7 Any reps stepper (fixed value, or either bound of a range) has its decrement disabled once its value is `1`

## 4. Row editor: weight

- [x] 4.1 Extract `WeightInputControls` (weight `NumberStepper` + kg/lbs `ChoiceChip`s) out of `SetInputRow`
- [x] 4.2 `SetInputRow` composes `WeightInputControls` internally; its own external API and rendered output are unchanged, and existing `SetInputRow`/`AddSetBar`/`EditSetDialog` tests pass unmodified
- [x] 4.3 `PlannedExerciseRowEditor` composes `WeightInputControls` for its weight section
- [x] 4.4 Adjusting the weight stepper calls the update callback immediately with the new `PlannedWeight.value`
- [x] 4.5 Tapping the kg/lbs chip calls the update callback immediately with the new `PlannedWeight.unit`

## 5. Card integration: add, edit, delete rows

- [x] 5.1 `PlannedExerciseCard` on an active Routine shows a "+ Add row" control that calls through to `addPlannedExerciseRow` and opens the new row's editor
- [x] 5.2 Each row on an active Routine shows its reps/weight and an inline delete icon
- [x] 5.3 Tapping a row opens its `PlannedExerciseRowEditor`; tapping the same row again collapses it
- [x] 5.4 Tapping the delete icon on a row removes it immediately with no confirmation
- [x] 5.5 Deleting a row that belongs to the Planned Exercise with a currently-open editor closes that editor
- [x] 5.6 `RoutineScreen` tracks at most one open row across all cards; opening a different row's editor (same or different card) collapses whichever was open
- [x] 5.7 An archived Routine hides the "+ Add row" control on every card
- [x] 5.8 An archived Routine's rows are not tappable (no editor opens) and show no delete icon

## 6. Test coverage

- [x] 6.1 Unit tests cover the `PlannedExerciseRow`/`PlannedWeight` model changes in task group 1
- [x] 6.2 Repository unit tests cover every scenario in task group 2, including archived-Routine rejection and persistence timing
- [x] 6.3 Widget tests cover row add/edit/delete end-to-end through `RoutineScreen`, including the single-open-editor exclusivity rule and archived-Routine control hiding
- [x] 6.4 `flutter test` and `flutter analyze` both pass
