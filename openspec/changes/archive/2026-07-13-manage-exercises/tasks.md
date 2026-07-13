## 1. Manage Exercises screen displays the Exercise list

- [x] 1.1 Exercises are displayed sorted alphabetically by name, case-insensitively
- [x] 1.2 An empty Exercise list shows a "No Exercises yet" empty state with a hint to log a Workout, instead of a list
- [x] 1.3 No add/create control (e.g. a FloatingActionButton) is present on the screen, whether the list is empty or populated

## 2. Workout home screen entry point

- [x] 2.1 The Workout home screen shows a "Manage Exercises" action next to "Past Workouts"
- [x] 2.2 Tapping "Manage Exercises" opens the Manage Exercises screen showing every stored Exercise
- [x] 2.3 The entry point is available and unaffected by whether a Workout is in progress

## 3. Renaming an Exercise

- [x] 3.1 Tapping an Exercise row opens a rename dialog with a text field pre-filled with its current name
- [x] 3.2 Cancelling the dialog leaves the Exercise unchanged and closes it
- [x] 3.3 Submitting a valid new name renames the Exercise, persists the updated list, and closes the dialog
- [x] 3.4 Submitting the Exercise's own current name, or the same name with different casing, succeeds (excluded from its own collision check)
- [x] 3.5 Submitting an empty or whitespace-only name shows an inline validation error and keeps the dialog open, leaving the Exercise unchanged
- [x] 3.6 Submitting a name matching another existing Exercise case-insensitively shows an inline validation error and keeps the dialog open, leaving the Exercise unchanged
