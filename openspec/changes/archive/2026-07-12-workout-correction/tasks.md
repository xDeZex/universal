## 1. Workout model supports editing and deleting Sets and Exercise Entries

- [x] 1.1 `Workout.editSet(entryId, setId, weight, unit, reps)` returns a new Workout with that Set's weight/unit/reps updated, `loggedAt` unchanged
- [x] 1.2 `Workout.deleteSet(entryId, setId)` returns a new Workout with that Set removed from its Exercise Entry, leaving the Entry in place even at zero Sets
- [x] 1.3 `Workout.deleteExerciseEntry(entryId)` returns a new Workout with that Exercise Entry (and all its Sets) removed

## 2. Active Workout screen: editing a Set

- [x] 2.1 Tapping a logged Set opens a dialog pre-filled with its current weight, unit, and reps
- [x] 2.2 Submitting valid new values updates the Set and leaves `loggedAt` unchanged
- [x] 2.3 Submitting a non-numeric weight or a reps count that is not a positive whole number is rejected, leaving the Set unchanged
- [x] 2.4 Tapping a logged Set belonging to a Locked Workout opens the same edit dialog and behaves identically to an in-progress Workout

## 3. Active Workout screen: deleting a Set

- [x] 3.1 The Set edit dialog has a Delete action that opens a confirmation dialog
- [x] 3.2 Confirming removes the Set from its Exercise Entry
- [x] 3.3 Cancelling the confirmation leaves the Set unchanged
- [x] 3.4 Deleting the only remaining Set under an Exercise Entry leaves that Entry listed with zero Sets, not removed
- [x] 3.5 Deleting a Set belonging to a Locked Workout succeeds identically to an in-progress Workout

## 4. Active Workout screen: deleting an Exercise Entry

- [x] 4.1 Each Exercise Entry's name header has a delete icon that opens a confirmation dialog
- [x] 4.2 Confirming removes the Exercise Entry and every Set logged under it
- [x] 4.3 Cancelling the confirmation leaves the Exercise Entry and its Sets unchanged
- [x] 4.4 Deleting an Exercise Entry belonging to a Locked Workout succeeds identically to an in-progress Workout
- [x] 4.5 Deleting every Exercise Entry from a Locked Workout leaves it Locked with zero Exercise Entries, with no guard preventing it

## 5. Shared delete-confirmation dialog

- [x] 5.1 A single confirmation dialog widget is used by both the Set-delete and Exercise-Entry-delete flows, parameterized by a message describing what's being deleted

## 6. Active Workout screen: Locked-Workout gating replaces read-only

- [x] 6.1 Opening the Active Workout screen for a Locked Workout (non-null `endTime`) hides the add-Exercise-Entry field, add-Set controls, and Discard/Finish buttons
- [x] 6.2 Opening the Active Workout screen for an in-progress Workout (null `endTime`) still shows the add-Exercise-Entry field, add-Set controls, and Discard/Finish buttons
- [x] 6.3 A Set rendered on a Locked Workout still shows "<reps> reps at <weight> <unit> — <loggedAt time>"
- [x] 6.4 A Set rendered on an in-progress Workout still shows "<reps> reps at <weight> <unit>" with no timestamp

## 7. Past Workouts detail view persists corrections

- [x] 7.1 `PastWorkoutsScreen` passes real `onWorkoutChanged`/`onExercisesChanged`/`onWorkoutDiscarded` callbacks into `ActiveWorkoutScreen` instead of no-ops
- [x] 7.2 Editing or deleting a Set or Exercise Entry from a Past Workout's detail view is saved to storage
- [x] 7.3 Reopening that Workout's detail view after a correction reflects the saved change
