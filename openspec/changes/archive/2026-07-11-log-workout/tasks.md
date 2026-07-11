## 1. Workout, ExerciseEntry, and Set models

- [x] 1.1 `Workout`, `ExerciseEntry`, and `Set` construct, `copyWith`, and round-trip through `toJson`/`fromJson`
- [x] 1.2 `fromJson` throws on a map missing a required field, for all three types
- [x] 1.3 A `Workout` reports in-progress when `endTime` is null and finished when it is set
- [x] 1.4 `Workout.addSet` appends a Set (with `loggedAt` stamped at call time) to the given Exercise Entry
- [x] 1.5 `Workout.finish` sets `endTime` to the most recently logged Set's `loggedAt` and returns the finished Workout
- [x] 1.6 `Workout.finish` returns `null` and leaves the Workout unchanged when it has zero logged Sets
- [x] 1.7 `Exercise.resolve(name, existing)` returns the existing Exercise on a case-insensitive exact name match
- [x] 1.8 `Exercise.resolve(name, existing)` constructs a new Exercise when no match exists
- [x] 1.9 `Exercise.resolve` (or its caller) rejects an empty/whitespace-only name

## 2. Storage for Workouts and Exercises

- [x] 2.1 `StorageService.loadWorkouts`/`saveWorkouts` round-trip a Workout list through `SharedPreferences` under a dedicated key, defaulting to `[]` when unset or on decode failure
- [x] 2.2 `StorageService.loadExercises`/`saveExercises` round-trip an Exercise list through `SharedPreferences` under a dedicated key, defaulting to `[]` when unset or on decode failure

## 3. Bottom navigation shell

- [x] 3.1 App root shows a bottom navigation bar with Checklists and Workout tabs
- [x] 3.2 Switching tabs preserves each tab's screen state (no reload of `HomeScreen` on switching away and back)

## 4. Workout home screen

- [x] 4.1 Workout tab shows "Start Workout" when no stored Workout is in progress
- [x] 4.2 Workout tab shows "Continue Workout" and opens the active Workout screen when a stored Workout is in progress
- [x] 4.3 "Start Workout" creates a new in-progress Workout and opens the active Workout screen
- [x] 4.4 Starting a Workout while one is already in progress is prevented (guard before creating a second one)
- [x] 4.5 Workout and Exercise lists load from storage when the Workout tab initializes

## 5. Active Workout screen: logging

- [x] 5.1 Submitting a non-empty name in the Exercise Entry field adds an ExerciseEntry, resolved via `Exercise.resolve`, and persists both the Workout and (if a new Exercise was created) the Exercise list
- [x] 5.2 Submitting an empty/whitespace-only Exercise Entry name is rejected with no Entry added
- [x] 5.3 Submitting valid weight and reps on an Exercise Entry adds a Set and persists the Workout
- [x] 5.4 Submitting a non-numeric weight or non-positive-integer reps is rejected with no Set added

## 6. Active Workout screen: finish and discard

- [x] 6.1 Finish action is disabled while the Workout has zero logged Sets
- [x] 6.2 Finish action is enabled once at least one Set is logged, and finishing persists the Workout and returns to the Workout home screen showing "Start Workout"
- [x] 6.3 Discard action is available even with zero logged Sets
- [x] 6.4 Discard deletes the Workout (and its Entries/Sets) from storage and returns to the Workout home screen showing "Start Workout"

## 7. Verify

- [x] 7.1 `flutter test` passes
- [x] 7.2 `flutter analyze` reports no new warnings
