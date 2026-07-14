## Why

The Active Workout screen's add-Set control is currently squeezed into an inline row inside each Exercise Entry's `Card` — a free-text weight field, two `ChoiceChip`s, a free-text reps field, and a bare `IconButton`, all in one cramped row that scrolls away with the entry. Grilling and prototyping this against the real screen (issue #145) confirmed the concrete problems (hard to find/reach one-handed, visually disorganized, mis-tappable button) and validated a replacement: a single fixed bar anchored above Discard/Finish, targeting whichever Exercise Entry the user has selected, with +/- steppers instead of free text. This change implements that validated redesign (issue #149).

## What Changes

- Replace each Exercise Entry's inline add-Set row with one fixed bottom bar, anchored above the Discard/Finish row, visually seamed off from it (Divider or surface-tint step) so the two fixed bars don't read as one control cluster.
- Add exercise-entry selection: tapping an entry selects it as the bottom bar's target. Default selection is the most-recently-added entry. The bar is hidden entirely when no entry is selected (e.g. workout has zero entries).
- Deleting the selected Exercise Entry clears the selection (bar hides); selection does not fall back to another entry.
- Re-render Exercise Entries as flat rows (header row + one row per Set + a `Divider` before the next entry) instead of floating `Card`s. Selected state is shown via a background tint on the entry's own rows.
- On a Locked Workout (view-only, past workout), entries are not selectable or tintable — there is no bar to target there, so the tap affordance is removed rather than left dead.
- The header row's delete `IconButton` remains a distinct hit target, unaffected by the row's new tap-to-select gesture.
- Change weight/reps input from free-text fields to +/- steppers starting from zero. Step size is 2.5 when the unit is kg, 5 when the unit is lbs (plate-realistic increments); reps step is 1. Reps floors at zero; weight can go negative, to log assisted exercise variations (e.g. an assisted pull-up machine).
- Replace each Set's "<reps> reps at <weight> <unit>" sentence with a numbered table row (set-number badge, weight, reps in their own columns, plus a logged-time column on Locked Workouts only), and give the Exercise name header a visibly heavier type style than the Set rows beneath it — so entries read as a clear header-then-data hierarchy instead of blending into one block of text now that the `Card` boundary is gone.
- Add Set becomes a full-width labeled `FilledButton` ("Add Set") instead of a bare `IconButton`.
- **BREAKING** (UI only, no persisted-data impact): free-text weight/reps entry is removed in favor of steppers; a workout can no longer be logged with weights/reps typed directly.

Out of scope: the Edit Set dialog (unchanged), any "programmed workout" / planned-weight-reps concept.

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `workout-logging-ui`: the "Active Workout screen allows adding a Set to an Exercise Entry" requirement changes from per-entry inline free-text fields to a single selection-driven bottom bar with steppers; new requirements cover Exercise Entry selection (default, clearing on delete, hidden bar), flat-row rendering with selected-state tint, and locked-state non-interactivity of that tint/selection.

## Impact

- `universal/lib/screens/active_workout_screen.dart`: `_ActiveWorkoutScreenState` gains selection state and the fixed bottom bar; `_ExerciseEntryTile`/`_ExerciseEntryTileState` are restructured from a `Card`-based widget with its own inline add-Set row into a flat, selectable row group with no add-Set UI of its own. `_EditSetDialog` and `_parseSetInput` free-text parsing helper are otherwise unaffected (Edit Set stays free-text per issue scope), though `_parseSetInput` may no longer be needed for the add-Set path once it's stepper-driven.
- `universal/test/screens/active_workout_screen_test.dart`: tests covering the inline add-Set row (`ValueKey('weight-...')`, `ValueKey('reps-...')`, `ValueKey('unit-kg-...')`, `ValueKey('add-set-...')`) need rewriting against the new bottom-bar keys and selection behavior.
- No changes to `universal/lib/models/workout.dart` — `ExerciseEntry`, `ExerciseSet`, `WeightUnit` are unaffected; this is UI-only.
