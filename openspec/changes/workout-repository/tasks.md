## 1. WorkoutRepository owns load and save

- [x] 1.1 `WorkoutRepository()` with no seed data loads Workouts and Exercises from `StorageService` on `load()` and notifies listeners once both are available
- [x] 1.2 `WorkoutRepository(initialWorkouts: ..., initialExercises: ...)` skips the `StorageService` load entirely — `load()` is a no-op when seeded
- [x] 1.3 `WorkoutRepository(storage: fakeOrRealStorage)` uses the injected `StorageService` instance instead of constructing its own

## 2. WorkoutRepository exposes Workout mutations

- [x] 2.1 `startWorkout()` creates a new in-progress Workout, adds it to `workouts`, persists via `StorageService.saveWorkouts`, and notifies listeners
- [x] 2.2 `addExerciseEntry(workoutId, name)` resolves the Exercise by case-insensitive name (reusing or creating it per existing `Exercise.resolve` behavior), appends the Entry to the named Workout, persists both lists as needed, and notifies listeners
- [x] 2.3 `addSet(workoutId, entryId, weight, unit, reps)` delegates to `Workout.addSet`, replaces the Workout in `workouts`, persists via `StorageService.saveWorkouts`, and notifies listeners
- [x] 2.4 `editSet(workoutId, entryId, setId, weight, reps)` delegates to `Workout.editSet`, persists, and notifies listeners
- [x] 2.5 `deleteSet(workoutId, entryId, setId)` delegates to `Workout.deleteSet`, persists, and notifies listeners
- [x] 2.6 `deleteExerciseEntry(workoutId, entryId)` delegates to `Workout.deleteExerciseEntry`, persists, and notifies listeners
- [x] 2.7 `finishWorkout(workoutId)` delegates to `Workout.finish()`, persists, and notifies listeners; rejecting (no-op) when `Workout.finish()` returns null
- [x] 2.8 `discardWorkout(workoutId)` removes the Workout entirely from `workouts`, persists, and notifies listeners
- [x] 2.9 `renameExercise(exerciseId, newName)` delegates to `Exercise.copyWith(name:)` with the existing collision/blank-name validation, persists via `StorageService.saveExercises`, and notifies listeners

## 3. WorkoutRepository is wired into the widget tree

- [ ] 3.1 `AppShell` wraps the Workout tab's entry (`WorkoutHomeScreen`) in `ChangeNotifierProvider<WorkoutRepository>`, not the Checklists tab
- [ ] 3.2 `main.dart`'s existing `ChangeNotifierProvider<UpdateService>` at the `MaterialApp` root is unaffected

## 4. Screens read and write through WorkoutRepository instead of callbacks

- [ ] 4.1 `WorkoutHomeScreen` drops `initialWorkouts`/`initialExercises` constructor params and its own `_load`/`_onWorkoutChanged`/`_onWorkoutDiscarded`/`_onExercisesChanged` methods, reading in-progress state via `context.watch<WorkoutRepository>()`
- [ ] 4.2 `WorkoutHomeScreen`'s Start/Continue Workout button behavior is unchanged from the user's perspective (still shows "Start Workout" / "Continue Workout" per whether a Workout is in progress)
- [ ] 4.3 `PastWorkoutsScreen` drops `workouts`, `exercises`, `onWorkoutChanged`, `onExercisesChanged`, `onWorkoutDiscarded` constructor params entirely, reading the finished Workout list via `context.watch<WorkoutRepository>()`
- [ ] 4.4 `PastWorkoutsScreen` navigates to `ActiveWorkoutScreen(workoutId: ...)` instead of passing a `Workout` object and callbacks
- [ ] 4.5 `ActiveWorkoutScreen` takes `workoutId` instead of `workout`/`exercises`/the three callbacks, reading the current Workout and Exercise list via `context.watch<WorkoutRepository>()`
- [ ] 4.6 `ActiveWorkoutScreen`'s mutation call sites (add Exercise Entry, add/edit/delete Set, delete Entry, discard, finish) call `context.read<WorkoutRepository>()` methods instead of `widget.onWorkoutChanged`/etc.
- [ ] 4.7 `ActiveWorkoutScreen` defensively pops back to the previous screen if its `workoutId` is no longer found in `WorkoutRepository.workouts` (guards a structural possibility introduced by id-based lookup; not reachable via any current navigation path, so no dedicated spec scenario)
- [ ] 4.8 `ManageExercisesScreen` drops `exercises`/`onExercisesChanged` constructor params, reading the Exercise list via `context.watch<WorkoutRepository>()` and renaming via `context.read<WorkoutRepository>().renameExercise(...)`

## 5. Tests exercise the new repository-based seam

- [ ] 5.1 New `test/repositories/workout_repository_test.dart` covers load (seeded vs. `SharedPreferences`-backed), and each mutation method's persistence + `notifyListeners` behavior
- [ ] 5.2 `test/screens/workout_home_screen_test.dart`, `past_workouts_screen_test.dart`, `active_workout_screen_test.dart`, `manage_exercises_screen_test.dart` are updated to wrap the screen under test in `ChangeNotifierProvider<WorkoutRepository>.value(value: WorkoutRepository(initialWorkouts: ..., initialExercises: ...))` instead of passing `initialWorkouts`/objects/callbacks directly
- [ ] 5.3 `flutter test` passes for the full suite
- [ ] 5.4 `flutter analyze` reports no new warnings
