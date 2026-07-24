## Why

Manage Routines, Past Workouts, the Routine screen's Planned Exercise cards, and Active Workout's Exercise Entries currently render their rows/cards inconsistently — two are bare `ListTile`s with no card at all, one is a plain `Card`, and one is a `Material`-tinted flat row group — a coherence gap the gym-tracking visual design spec work (#210, locked by #216 at `docs/design/gym-tracking-visual-design-spec.md`) identified and resolved on paper. This change builds the spec's `CoplanarCard` container and swaps it into all four call sites so they read as one consistent visual language, and — since it forces a rewrite of Active Workout's selection mechanism anyway — also builds `SelectionAccentBorder` (pulled forward from the otherwise-later #221) so that rewrite lands once, correctly, instead of as a throwaway shim.

## What Changes

- New `CoplanarCard` widget: `Card(margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8), clipBehavior: Clip.antiAlias, child: child)`, relying entirely on the app's existing global `CardThemeData` for fill/elevation/radius — no local color, elevation, or border override, and no outline on any coplanar card anywhere.
- `RoutineTile` (Manage Routines row) and the Past Workouts row, both currently bare `ListTile`s with no card, now render through `CoplanarCard`.
- `PlannedExerciseCard`'s existing plain `Card` is swapped for `CoplanarCard`.
- `ExerciseEntryTile` is restructured from a `Material(color: tint)` root (tint = `secondaryContainer` when selected) to `CoplanarCard` wrapping a new `SelectionAccentBorder`. The selected-state visual changes from a background tint to a 4dp left accent border in `colorScheme.primary`, always rendered (transparent when unselected) so its auto-padding never shifts content on select/deselect.
- New `SelectionAccentBorder` widget, built now but wired up only inside `ExerciseEntryTile` in this change. Its use inside `PlannedExerciseCard`'s open row, and zebra-row shading in either widget, stay scoped to the separate follow-up ticket (#221) since neither is forced by this change's container rewrite.

## Capabilities

### New Capabilities
_(none — `CoplanarCard` and `SelectionAccentBorder` are internal shared presentation widgets serving the requirement change below, not standalone user-facing capabilities)_

### Modified Capabilities
- `workout-logging-ui`: the requirement describing Exercise Entries as flat rows with a background-tint selected state changes — Exercise Entries now render inside an elevated, gapped card, and the selected-state indicator changes from a background tint to a left accent border. The row-internal structure (header, column headers, per-Set dividers) is unchanged in this change.

## Impact

- New: `universal/lib/widgets/coplanar_card.dart`, `universal/lib/widgets/selection_accent_border.dart`, plus their widget tests.
- Modified: `universal/lib/widgets/routine_tile.dart`, `universal/lib/widgets/planned_exercise_card.dart`, `universal/lib/widgets/exercise_entry_tile.dart`, `universal/lib/screens/past_workouts_screen.dart`.
- Test impact: `test/screens/active_workout_screen_selection_test.dart` currently asserts selection via a `Material` widget's `.color` property — these assertions move to `SelectionAccentBorder`'s border color. Screen-level tests for Manage Routines and Past Workouts (`manage_routines_screen_test.dart`, `past_workouts_screen_test.dart`) get checked for finder/widget-tree assumptions that the new `Card` wrapping could break.
- No change to persistence, models, or any behavioral (non-visual) requirement — selection semantics, add-Set behavior, and data flow are untouched.
