## 1. Flat Exercise Entry rows replace Cards

- [x] 1.1 Each Exercise Entry renders as a header row (bold exercise name + delete `IconButton`) followed by a numbered table of its Sets — a muted SET/WEIGHT/REPS column-header row once Sets exist, then one row per Set (numbered badge, weight, reps in their own columns, each row preceded by a thin `Divider`) — with a further `Divider` before the next Exercise Entry; no `Card` wrapper, no per-row checkmark
- [x] 1.2 The delete `IconButton` remains independently tappable (deletes the entry) without triggering entry selection

## 2. Exercise Entry selection

- [x] 2.1 Tapping an in-progress Workout's Exercise Entry rows selects it, and its rows show a `colorScheme.secondaryContainer` (or equivalent) background tint
- [x] 2.2 Only one Exercise Entry is tinted/selected at a time — selecting a new entry un-tints the previous one
- [x] 2.3 Adding a new Exercise Entry makes it the selected entry (most-recently-added default)
- [x] 2.4 A Workout with zero Exercise Entries has no selection
- [x] 2.5 Deleting the currently selected Exercise Entry clears the selection (does not fall back to another entry)
- [x] 2.6 Deleting a non-selected Exercise Entry leaves the current selection unchanged
- [x] 2.7 On a Locked Workout, Exercise Entry rows are not tappable for selection and never show the tint

## 3. Add-Set bottom bar

- [x] 3.1 The add-Set bar is a fixed bar anchored above the Discard/Finish row, visually seamed off from it (distinct surface tone and/or `Divider`)
- [x] 3.2 The bar is shown only when an Exercise Entry is selected on an in-progress Workout; hidden otherwise (including on Locked Workouts, per existing hide-on-Locked behavior)
- [x] 3.3 Weight, unit toggle, and reps controls are arranged in a single row above a full-width `FilledButton` labeled "Add Set"
- [x] 3.4 Weight and reps are +/- steppers starting from zero (no free-text fields); reps has a minimum of zero, weight has no minimum (allows negative values, for assisted exercise variations)
- [x] 3.5 The weight stepper steps by 2.5 when the unit is kg and by 5 when the unit is lbs
- [x] 3.6 The reps stepper steps by 1
- [x] 3.7 The Add Set button is disabled while reps is zero
- [x] 3.8 Tapping Add Set with reps > 0 adds a Set to the selected Exercise Entry with the current time as `loggedAt`, displayed as a numbered row with weight and reps in their own columns
- [x] 3.9 The unit defaults to kg for an Exercise Entry with no logged Sets yet, and to the last unit used for that entry once it has one (sticky per entry, independent of which entry is currently selected)
- [x] 3.10 Switching the selected Exercise Entry resets the weight and reps steppers to zero (the newly selected entry's sticky unit is still applied)

## 4. Tests and verification

- [x] 4.1 Rewrite `universal/test/screens/active_workout_screen_test.dart` coverage for the old inline add-Set row (`weight-...`, `reps-...`, `unit-kg-...`/`unit-lbs-...`, `add-set-...` keys) against the new bottom-bar and selection behavior
- [x] 4.2 Add test coverage for the new scenarios in section 2 and 3 above (selection default/clear-on-delete, stepper bounds/steps, disabled Add Set at zero reps, Locked non-interactivity)
- [x] 4.3 `flutter test` passes
- [x] 4.4 `flutter analyze` reports no new warnings
- [x] 4.5 Verify visually via the `/run-universal` skill: build, launch on emulator, drive an in-progress Workout (select entries, add Sets in both units, delete the selected entry) and a Locked Workout, screenshot both
