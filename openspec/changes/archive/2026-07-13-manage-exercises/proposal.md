## Why

Users can only correct a mistyped Exercise name today by discarding history-losing workarounds — there's no dedicated place to view the full Exercise list or rename an entry. The Exercise model already supports renaming (`copyWith`, case-insensitive uniqueness), so the UI just needs to expose it (issue #125, part of the Phase 3 gym-tracking epic #16).

## What Changes

- Add a "Manage Exercises" screen: a case-insensitive alphabetically sorted list of every Exercise, reachable via a new `TextButton` on the Workout home screen (next to "Past Workouts").
- Tapping an Exercise row opens a rename dialog pre-filled with its current name.
- Rename validation, surfaced as an inline dialog error (dialog stays open on failure):
  - Empty/whitespace-only name is rejected.
  - A name colliding case-insensitively with any *other* Exercise is rejected (not merged) — the Exercise being renamed is excluded from its own collision check.
- Empty state ("No Exercises yet" + a hint to log a Workout) when there are no Exercises.
- No add/create affordance on this screen — Exercise creation remains exclusive to the type-to-create flow during workout logging.

## Capabilities

### New Capabilities
- `gym-exercise-management`: Manage Exercises screen — browse all Exercises and rename one, with validation for blank and colliding names.

### Modified Capabilities
- (none — `gym-exercise-model`'s rename/uniqueness behavior is unchanged; this change only exposes it via UI)

## Impact

- New screen: `universal/lib/screens/manage_exercises_screen.dart`, new tile widget `universal/lib/widgets/exercise_tile.dart`.
- `universal/lib/screens/workout_home_screen.dart`: new `TextButton` entry point, threading `_exercises` / `_onExercisesChanged` the same way `PastWorkoutsScreen` already does.
- No changes to `Exercise` model or `StorageService` — both already support what's needed.
