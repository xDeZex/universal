## 1. Active Workout screen renders read-only for a finished Workout

- [x] 1.1 Opening the Active Workout screen for a Workout with a non-null `endTime` hides the add-Exercise-Entry field, every Exercise Entry's add-Set controls, and the Discard/Finish buttons
- [x] 1.2 Opening the Active Workout screen for a Workout with a null `endTime` still shows the add-Exercise-Entry field, add-Set controls, and Discard/Finish buttons (existing behavior unchanged)

## 2. Finished Workout's Sets display their logged time

- [x] 2.1 A Set rendered on the read-only (finished-Workout) screen shows as "<reps> reps at <weight> <unit> — <loggedAt time>"
- [x] 2.2 A Set rendered on the in-progress screen still shows as "<reps> reps at <weight> <unit>" with no timestamp

## 3. Past Workouts list screen

- [x] 3.1 The list shows only Workouts with a non-null `endTime`, excluding any in-progress Workout
- [x] 3.2 The list is ordered by `endTime` descending (most recent first)
- [x] 3.3 Each row shows the Workout's end date and a comma-joined list of its Exercise Entries' Exercise names, in Exercise Entry order, including entries with zero logged Sets
- [x] 3.4 A row's exercise summary is truncated with an ellipsis when it overflows the row's available width
- [x] 3.5 When there are no finished Workouts, the screen shows a centered "No past workouts yet" message instead of a list
- [x] 3.6 Tapping a row opens the Active Workout screen for that Workout in its read-only mode, showing its Exercise Entries and Sets (including any zero-Set entries) with no input or action controls

## 4. Workout home screen entry point

- [x] 4.1 The Workout home screen shows a "Past Workouts" action below Start/Continue Workout, regardless of whether any Workout has been finished
- [x] 4.2 Tapping the Past Workouts action navigates to the Past Workouts list screen
