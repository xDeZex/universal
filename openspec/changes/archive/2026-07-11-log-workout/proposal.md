## Why

Universal is checklist-only today. Gym tracking (Phase 3) needs its foundational vertical slice: a user must be able to start a Workout, log what they did against it, and finish or discard it. #119 and #120 resolved the domain decisions (Workout lifecycle, endTime derivation, Exercise reuse) this depends on; this change turns those decisions into the first working gym feature.

## What Changes

- Add `Workout`, `ExerciseEntry`, and `Set` data models (immutable, `copyWith`, `toJson`/`fromJson`), mirroring `models/checklist.dart` and `models/exercise.dart` in style.
- Extend `StorageService` to persist Workouts and Exercises (list, autosaved on every mutation, same SharedPreferences/JSON pattern as Checklists).
- Add a bottom navigation bar to the app shell with two tabs: Checklists (the existing `HomeScreen`) and Workout (new `WorkoutHomeScreen`).
- `WorkoutHomeScreen`: "Start Workout" button when no Workout is in progress; "Continue Workout" when one is (only one in-progress Workout at a time).
- Active Workout screen: add an Exercise Entry via a plain text field (type-to-create — case-insensitive exact match reuses an existing Exercise by id, otherwise creates a new one); add a Set (weight, reps) to an Entry.
- Finish action: disabled until the Workout has at least one logged Set; sets `endTime` to the last logged Set's timestamp (ADR-0016), not wall-clock time.
- Discard action: deletes an in-progress Workout and everything logged in it.

## Capabilities

### New Capabilities
- `workout-lifecycle`: Workout, ExerciseEntry, and Set data models, and the start/finish/discard state machine (in-progress vs. finished, endTime derivation, one-in-progress-at-a-time constraint).
- `workout-logging-ui`: Screens and interactions for starting/continuing a Workout, adding Exercise Entries (with Exercise reuse-by-name) and Sets, and finishing/discarding — including the bottom navigation entry point.
- `workout-persistence`: Autosave of Workouts and Exercises to SharedPreferences on every mutation, mirroring checklist-persistence.

### Modified Capabilities
(none — `gym-exercise-model`'s own requirements, construction/serialization/identity, are unchanged. `Exercise.resolve` implements the `workout-lifecycle` requirement "Adding an Exercise Entry resolves the Exercise by case-insensitive exact name match"; it's placed on the `Exercise` class as an implementation detail, not a new requirement on `gym-exercise-model` itself.)

## Impact

- New: `lib/models/workout.dart` (Workout, ExerciseEntry, Set), `lib/screens/workout_home_screen.dart`, `lib/screens/active_workout_screen.dart`, `lib/screens/app_shell.dart` (bottom nav shell wrapping `HomeScreen` and the new `WorkoutHomeScreen`).
- Modified: `lib/services/storage_service.dart` (Workout + Exercise persistence), `lib/main.dart` (swaps the app's `home` from `HomeScreen` to `AppShell`), `lib/models/exercise.dart` (adds `Exercise.resolve` for case-insensitive name reuse).
- No backend/API impact — local-only, same as Checklists today.
