## 1. Branch is up to date with the merged Routine model

- [x] 1.1 Implementation branch is cut from (or rebased onto) an up-to-date `origin/main` so `universal/lib/models/routine.dart` and `WorkoutRepository.addRoutine`/`routines` are present

## 2. WorkoutRepository gains rename/archive/unarchive operations

- [x] 2.1 `renameRoutine(id, name)` renames on a valid, non-colliding name; persists via `StorageService`; notifies listeners
- [x] 2.2 `renameRoutine` rejects a blank name, leaving the Routine list and storage unchanged
- [x] 2.3 `renameRoutine` rejects a name colliding case-insensitively with another Routine, leaving the Routine list and storage unchanged
- [x] 2.4 `archiveRoutine(id)` sets `archivedAt` to now, persists, and notifies listeners
- [x] 2.5 `unarchiveRoutine(id)` clears `archivedAt`, persists, and notifies listeners
- [x] 2.6 Unit tests cover all five behaviors above (mirroring `workout_repository_routine_test.dart`'s coverage of `addRoutine`)

## 3. Manage Routines screen lists, sections, and empty state

- [x] 3.1 `RoutineTile` widget renders a Routine's name, tap-only, structurally identical to `ExerciseTile`
- [x] 3.2 `ManageRoutinesScreen` lists active Routines alphabetically (case-insensitive), followed by an "Archived" section (label shown only when non-empty) of archived Routines
- [x] 3.3 `ManageRoutinesScreen` shows an empty-state message when there are no Routines at all
- [x] 3.4 Tapping a Routine row (active or archived) navigates to that Routine's `RoutineScreen`
- [x] 3.5 "Manage Routines" entry point added to `WorkoutHomeScreen`'s button row, navigating to `ManageRoutinesScreen` via `pushWithRepository`
- [x] 3.6 Widget tests cover: alphabetical sort, active/archived sectioning (including archived-section absence when nothing is archived), empty-state, and navigation from `WorkoutHomeScreen`

## 4. Create Routine dialog

- [x] 4.1 FAB on `ManageRoutinesScreen` opens a Create Routine dialog (name-only field, Cancel/Create actions)
- [x] 4.2 Submitting a valid, non-colliding name closes the dialog, creates the Routine via `addRoutine`, and navigates directly into its `RoutineScreen`
- [x] 4.3 Submitting a blank name shows an inline error and keeps the dialog open, without creating a Routine
- [x] 4.4 Submitting a name colliding case-insensitively with an existing Routine shows an inline error and keeps the dialog open, without creating a second Routine
- [x] 4.5 Widget tests cover create-success-and-navigate, blank-name rejection, and duplicate-name rejection

## 5. Routine screen: view, rename, archive/unarchive, locked state

- [x] 5.1 `RoutineScreen` AppBar shows the Routine's name as its title
- [x] 5.2 Tapping the AppBar title opens a rename dialog pre-filled with the current name (no separate rename icon)
- [x] 5.3 Submitting a valid, non-colliding rename persists via `renameRoutine` and updates the title; cancelling leaves the name unchanged
- [x] 5.4 Submitting a blank or colliding rename shows an inline error and keeps the dialog open
- [x] 5.5 Rename remains available (title still tappable, dialog still works) while the Routine is archived
- [x] 5.6 One AppBar icon archives an active Routine or unarchives an archived one on a single tap, with no confirmation dialog, calling `archiveRoutine`/`unarchiveRoutine`
- [x] 5.7 Archived Routine screen shows a plain themed `Container` reading "Archived — unarchive to edit Planned Exercises"; the container is absent when active
- [x] 5.8 Routine screen body shows a single-line "No Planned Exercises yet" message (no second hint line) in both active and archived states
- [x] 5.9 Widget tests cover: rename success/cancel/validation-errors, archive/unarchive toggle (icon and effect), locked banner presence/absence, and the empty-state message in both active and archived states
