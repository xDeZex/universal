## 1. `CoplanarCard` exists and is theme-only

- [ ] 1.1 `CoplanarCard` renders its child inside a `Card` with 12dp horizontal / 8dp vertical margin
- [ ] 1.2 `CoplanarCard` sets no local color, elevation, or shape/border override — it renders identically to the app's global `CardThemeData` defaults
- [ ] 1.3 `CoplanarCard` sets `clipBehavior: Clip.antiAlias`

## 2. `SelectionAccentBorder` exists and never shifts layout

- [ ] 2.1 `SelectionAccentBorder` renders its child with a 4dp left border in `colorScheme.primary` when `selected` is true
- [ ] 2.2 `SelectionAccentBorder` renders the same 4dp left border in `Colors.transparent` (not omitted) when `selected` is false
- [ ] 2.3 Toggling `selected` does not change the widget's rendered size or the child's horizontal offset

## 3. Manage Routines row and Past Workouts row render through `CoplanarCard`

- [ ] 3.1 `RoutineTile` renders its `ListTile` inside a `CoplanarCard`
- [ ] 3.2 Each row in the Past Workouts list renders inside a `CoplanarCard`
- [ ] 3.3 `manage_routines_screen_test.dart` and `past_workouts_screen_test.dart` pass against the new structure

## 4. `PlannedExerciseCard` renders through `CoplanarCard`

- [ ] 4.1 `PlannedExerciseCard`'s outer `Card` is replaced with `CoplanarCard`, with no other change to its header/row/add-row content
- [ ] 4.2 Existing `PlannedExerciseCard`-related tests (Routine screen, reorder, row editing) pass unchanged

## 5. `ExerciseEntryTile` renders through `CoplanarCard` + `SelectionAccentBorder`

- [ ] 5.1 `ExerciseEntryTile`'s root becomes `CoplanarCard(child: SelectionAccentBorder(child: ...))`, removing the `Material(color: tint)` root and the `tint` variable entirely
- [ ] 5.2 The entry's header row, column-header row, and per-Set rows (with their existing dividers) render unchanged inside the new structure
- [ ] 5.3 On an in-progress Workout, selecting an Exercise Entry shows the left accent border in `colorScheme.primary`; no other entry shows it
- [ ] 5.4 On a Locked Workout, tapping an Exercise Entry's rows does not select it and shows no accent border
- [ ] 5.5 Deselecting a previously-selected Exercise Entry turns its border transparent without shifting its content
- [ ] 5.6 `active_workout_screen_selection_test.dart`'s 5 selection tests are rewritten to assert `SelectionAccentBorder`'s border color at the existing `entry-{id}` keys instead of `Material.color`, and pass

## 6. No outline on any coplanar card, anywhere

- [ ] 6.1 None of `RoutineTile`, the Past Workouts row, `PlannedExerciseCard`, or `ExerciseEntryTile` draws a border/outline on its `CoplanarCard` shape

## 7. Final verification

- [ ] 7.1 `flutter analyze` is clean
- [ ] 7.2 `flutter test` passes in full
- [ ] 7.3 Visually verified on the emulator across Manage Routines, Routine, Active Workout, and Past Workouts (including selecting/deselecting an Exercise Entry and confirming no layout shift)
