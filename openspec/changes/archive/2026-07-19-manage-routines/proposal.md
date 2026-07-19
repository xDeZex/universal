## Why

#182 landed the `Routine`/`Planned Exercise` data model and persistence with no UI. #183 is the implementation handoff for the Routine's own list/create/rename/archive lifecycle — the foundation every later Routine screen (Planned Exercise editing in #176, start-from-Routine in #177) builds on top of.

## What Changes

- Add a "Manage Routines" entry point to `WorkoutHomeScreen`'s existing button row, alongside "Past Workouts" and "Manage Exercises".
- Add a `ManageRoutinesScreen`: flat, alphabetical (case-insensitive), name-only tiles via a new `RoutineTile` (structurally identical to `ExerciseTile`) — active Routines first, archived Routines below under an "Archived" section label (shown only when non-empty). A FAB opens a Create Routine dialog.
- Add a Create Routine dialog: name-only, submit-time validation via `Routine.validateRename` (same shape as `_RenameExerciseDialog`, not live/as-you-type). On success, `ManageRoutinesScreen` creates the Routine and navigates straight into its `RoutineScreen` — a new "create then push into the created item" precedent, distinct from `HomeScreen`'s add-Checklist FAB, which stays on the list.
- Add a `RoutineScreen` (one screen serves as both view and edit, no separate read-only mode, mirroring `ChecklistScreen`):
  - AppBar title shows the Routine's name; tapping the title opens the same submit-time-validated rename dialog (no separate rename icon).
  - One AppBar icon toggles archive/unarchive (single tap, no confirmation — archiving is reversible, unlike the app's hard-delete confirmations). Rename stays available while archived.
  - When archived, a plain themed `Container` (not `MaterialBanner` — its dismiss-action contract doesn't fit a state-derived, non-dismissible message, and Material 3 dropped the Banner component) shows "Archived — unarchive to edit Planned Exercises".
  - Body is an empty-state shell ("No Planned Exercises yet", one line, in both active and archived states) — Planned Exercise content is out of scope (#176).
- Add `WorkoutRepository.renameRoutine`, `archiveRoutine`, `unarchiveRoutine` — explicit verbs mirroring `renameExercise`/`addRoutine`'s existing style, no toggle method.

**Deviations from #175's resolved mockup** (noted on #183): validation is submit-time not live; rename has no dedicated icon (tap-title instead); the empty state drops the mockup's second hint line entirely.

## Capabilities

### New Capabilities
- `gym-routine-management`: Manage Routines list/create screen and the Routine view/edit screen — navigation entry point, list sorting/sectioning, create dialog, rename-via-title-tap, archive/unarchive, locked banner, empty states.

### Modified Capabilities
- `routine-persistence`: adds rename/archive/unarchive as first-class `WorkoutRepository` operations (validated persist-and-notify), alongside the existing create operation.

## Impact

- New files: `universal/lib/screens/manage_routines_screen.dart`, `universal/lib/screens/routine_screen.dart`, `universal/lib/widgets/routine_tile.dart`.
- Modified files: `universal/lib/screens/workout_home_screen.dart` (new button), `universal/lib/repositories/workout_repository.dart` (three new methods).
- Depends on #182's `Routine` model and `WorkoutRepository.addRoutine`, merged to `origin/main` via PR #189 but not yet present on this repo's local `main`/`test` branches — the implementation branch must be cut from an up-to-date `origin/main`.
- No changes to `Planned Exercise` content, Program/Schedule, or the start-from-Routine flow (#176/#177, out of scope).
