## 1. Model: shared `WeightUnit`, no import cycle

- [x] 1.1 New `lib/models/weight_unit.dart` declares the `WeightUnit` enum (`kg`, `lbs`), moved out of `lib/models/workout.dart`
- [x] 1.2 `lib/models/workout.dart` imports `WeightUnit` from `weight_unit.dart` instead of declaring it; existing `ExerciseSet`/`Workout` behavior is unchanged
- [x] 1.3 `lib/models/routine.dart` imports `WeightUnit` from `weight_unit.dart` instead of `workout.dart`, and drops its `workout.dart` import entirely
- [x] 1.4 Existing model unit tests (`workout_test.dart`, `planned_exercise_row_test.dart`, `planned_exercise_test.dart`, `routine_test.dart`) pass unmodified after the move

## 2. Model: `ExerciseEntry.targets`

- [x] 2.1 `ExerciseEntry` gains a nullable `targets: List<PlannedExerciseRow>?` field, `null` by default
- [x] 2.2 `ExerciseEntry.copyWith` supports overriding `targets`
- [x] 2.3 `ExerciseEntry.toJson`/`fromJson` round-trip `targets`, including `null`
- [x] 2.4 `fromJson` on a map with a missing `targets` key produces `null` rather than throwing (mirrors the existing `PlannedExerciseRow.weight` migration precedent from #185)
- [x] 2.5 `Workout.toJson`/`fromJson` round-trip an `ExerciseEntry` with a non-null `targets` list nested inside

## 3. Repository: pre-fill Exercise Entries when starting from a Routine

- [x] 3.1 `WorkoutRepository.startWorkout({routineId})`, when `routineId` is non-null and resolves to an active Routine, creates one `ExerciseEntry` per Planned Exercise (same order, same `exerciseId`, empty `sets`, `targets` copied from that Planned Exercise's `rows`)
- [x] 3.2 `startWorkout` with a `routineId` resolving to an archived Routine creates no Workout and leaves the stored Workout list unchanged
- [x] 3.3 `startWorkout` with no `routineId` behaves exactly as before (empty `exerciseEntries`, unaffected by this change)
- [x] 3.4 A Workout started from a Routine persists via `StorageService` and notifies listeners, same timing as existing `startWorkout` behavior
- [x] 3.5 Editing or deleting a Planned Exercise row on the Routine after a Workout has started from it does not change that Workout's already-copied `targets`

## 4. Rendering: dashed target rows in `ExerciseEntryTile`

- [x] 4.1 `ExerciseEntryTile` renders row `i` from `entry.sets[i]` when it exists, else from `entry.targets[i]` when that exists, else nothing
- [x] 4.2 An unfilled target row shows a dashed set-number badge and (on a Locked Workout only) a dashed time cell, using the target's own reps/weight formatting in the weight/reps columns
- [x] 4.3 Consecutive identical target rows render as separate rows, never grouped/collapsed
- [x] 4.4 An `ExerciseEntry` with `targets == null` renders identically to today (no dashed rows, no behavior change)
- [x] 4.5 An `ExerciseEntry` with more logged Sets than targets renders the excess Sets normally after the target-derived rows are exhausted
- [x] 4.6 A Locked Workout with unfilled trailing targets still shows them dashed (no special-casing needed beyond the existing `locked` rendering branch)

## 5. Logging: strict count-order fill and auto-prefill

- [x] 5.1 `ActiveWorkoutController`/`AddSetBar` prefill weight/reps from `entry.targets[entry.sets.length]` when selecting an Exercise Entry that has an unfilled target there
- [x] 5.2 Selecting an Exercise Entry with no unfilled target (targets `null`, or fully consumed) resets weight/reps to zero, unchanged from today
- [x] 5.3 A ranged target (`RangeReps`) prefills using its `min` value
- [x] 5.4 Logging a Set always appends to `entry.sets` via the existing `addSet` path — no new parameter, no way to target a specific row
- [x] 5.5 No per-target-row tap affordance exists anywhere in `ExerciseEntryTile` (confirm no tap handler is wired to individual target rows)

## 6. Routine screen: Start Workout / Continue Workout bar

- [x] 6.1 New widget (e.g. `StartWorkoutBar`) renders a full-width primary button in a padded, tinted container, pinned at the bottom of `RoutineScreen`'s body
- [x] 6.2 The bar reads "Start Workout" and calls `startWorkout(routineId: routine.id)` + navigates to the new Workout when no Workout is in progress
- [x] 6.3 The bar reads "Continue Workout" and navigates to the in-progress Workout (regardless of which Routine started it, or none) when one exists
- [x] 6.4 The bar is not rendered at all when `routine.isLocked`
- [x] 6.5 `RoutineScreen` wires the bar in without disturbing the existing add-field/card-list/archive-banner layout

## 7. Test coverage

- [x] 7.1 Unit tests cover the model changes in task groups 1–2 (import move, `targets` field, serialization, `null` migration)
- [x] 7.2 Repository unit tests cover every scenario in task group 3, including archived-Routine rejection and the no-`routineId` unaffected path
- [x] 7.3 Widget tests cover `ExerciseEntryTile` target-row rendering from task group 4 (dashed rows, no grouping, `null` targets, excess Sets, Locked Workout)
- [x] 7.4 Widget tests cover count-order fill and auto-prefill from task group 5, including the ranged-target `min` prefill and the absence of any per-row tap
- [x] 7.5 Widget tests cover the Start Workout bar from task group 6 end-to-end through `RoutineScreen`, including the archived-hidden and continue-regardless-of-routine cases
- [x] 7.6 `flutter test` and `flutter analyze` both pass
