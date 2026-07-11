## Why

Once a Workout is finished, it currently disappears with no way to look back at it — the Workout tab only ever shows a Start/Continue action. Issue #122 (part of the Phase 3 gym-tracking epic, #16) calls for a reverse-chronological list of finished Workouts with a detail view per Workout, so a user can review what they actually did in past sessions.

## What Changes

- Add a "Past Workouts" entry point on the Workout home screen, below the Start/Continue action.
- Add a Past Workouts list screen: finished Workouts (`endTime != null`) sorted by `endTime` descending, each row showing an absolute date and a comma-joined, ellipsis-truncated list of exercise names (Exercise Entries with zero logged Sets included as-is). Shows a centered "No past workouts yet" message when the list is empty.
- Tapping a row opens `ActiveWorkoutScreen` for that Workout.
- `ActiveWorkoutScreen` now renders in a read-only mode whenever the given Workout is finished (`isInProgress == false`): the add-Exercise-Entry field, per-entry add-Set controls, and the Discard/Finish buttons are all hidden. No new parameter — this is derived from the Workout's own `endTime`.
- In read-only mode, each Set additionally displays its `loggedAt` time alongside weight/reps (e.g. "8 reps at 50 kg — 6:42 PM"); the in-progress Set format is unchanged.

## Capabilities

### New Capabilities
- `workout-history`: the Past Workouts list screen — entry point, sorting, row content, empty state, and navigation into the (read-only) detail view.

### Modified Capabilities
- `workout-logging-ui`: `ActiveWorkoutScreen` gains a read-only rendering mode for finished Workouts (hides all input/action controls) and shows each Set's `loggedAt` time in that mode.

## Impact

- `lib/screens/workout_home_screen.dart`: add navigation entry point to the new list screen.
- `lib/screens/active_workout_screen.dart`: branch rendering on `workout.isInProgress`.
- New screen file for the Past Workouts list (e.g. `lib/screens/past_workouts_screen.dart`).
- No model or storage changes — consumes existing `Workout`/`ExerciseEntry`/`ExerciseSet` fields as-is.
