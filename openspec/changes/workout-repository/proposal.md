## Why

Persistence policy for Workouts and Exercises — when to load, when to save, how to merge an edit — is reconstructed independently in five screens (`WorkoutHomeScreen`, `PastWorkoutsScreen`, `ActiveWorkoutScreen`, `ManageExercisesScreen`, and the callback wiring between them) instead of owned by one module. Three callbacks (`onWorkoutChanged`, `onExercisesChanged`, `onWorkoutDiscarded`) are threaded through 4 files as constructor params, with `PastWorkoutsScreen` forwarding callbacks it never calls itself. This is issue #158, filed from an architecture review. It blocks issue #159 (deduplicating `Workout`'s entry/Set lookup methods), which touches the same mutation surface this change consolidates.

## What Changes

- Introduce `WorkoutRepository`, a `ChangeNotifier` (mirroring the existing `UpdateService` pattern in `lib/services/update_service.dart`) that owns the in-memory Workout and Exercise lists and wraps `StorageService` for load/save.
- `WorkoutRepository` is constructor-injected (`StorageService`, optional `initialWorkouts`/`initialExercises` for seeding in tests), matching `UpdateService`'s existing test-seam shape — no abstract interface, since only one real storage adapter exists today.
- Provide `WorkoutRepository` via `ChangeNotifierProvider` scoped to `WorkoutHomeScreen`'s subtree inside `AppShell._tabs`, not at the `MaterialApp` root — Checklists never need to see it.
- `WorkoutHomeScreen`, `PastWorkoutsScreen`, `ActiveWorkoutScreen`, and `ManageExercisesScreen` stop receiving `Workout`/`Exercise` objects and the three mutation callbacks as constructor params. **BREAKING** (internal API only, no persisted-data format change): they instead take an id (e.g. `workoutId`) where relevant and read current state via `context.watch<WorkoutRepository>()`, writing via `context.read<WorkoutRepository>()` method calls.
- `StorageService` is unchanged — `WorkoutRepository` wraps it, doesn't replace it.
- No change to `Checklist` persistence, `HomeScreen`, or `active_workout_screen.dart`'s Set-input UI (that's the separate, still-unimplemented `unify-set-input-ui` change, sequenced after this one).

## Capabilities

### New Capabilities
- (none — this change restructures how existing Workout/Exercise state is owned and passed between screens; no new user-facing behavior)

### Modified Capabilities
- (none — `workout-persistence` and `workout-logging-ui`'s requirements describe load/save timing and screen behavior, both of which are preserved as-is; only the internal implementation moves)

## Impact

- New file: `universal/lib/repositories/workout_repository.dart`.
- Modified: `universal/lib/main.dart` (no change — Provider added in `app_shell.dart`, not here), `universal/lib/screens/app_shell.dart`, `universal/lib/screens/workout_home_screen.dart`, `universal/lib/screens/past_workouts_screen.dart`, `universal/lib/screens/active_workout_screen.dart` (constructor/state-reading only, not its Set-input UI), `universal/lib/screens/manage_exercises_screen.dart`.
- Unchanged: `universal/lib/services/storage_service.dart`, `universal/lib/models/workout.dart`, `universal/lib/models/exercise.dart`, `universal/lib/services/update_service.dart`, `universal/lib/screens/home_screen.dart`.
- Test files under `universal/test/screens/` and a new `universal/test/repositories/` need updating to seed `WorkoutRepository` directly instead of via widget-level `initialWorkouts`/`initialExercises` params.
