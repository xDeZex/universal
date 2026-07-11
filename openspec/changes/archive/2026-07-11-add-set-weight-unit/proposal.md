## Why

A logged Set's weight has no unit today, and the active Workout screen renders it as `'${weight} x ${reps}'` — a format that reads like the common "sets x reps" shorthand (e.g. "3 x 10"), not "weight for these reps". CONTEXT.md's own Set definition already writes the canonical form as "3 reps @ 50kg", so the domain vocabulary anticipated a unit the model never got. Users can't record whether a weight is in kg or lbs, and the display is ambiguous about what the two numbers even mean.

## What Changes

- Add a `unit` field (kg or lbs) to `ExerciseSet`, set per Set rather than globally or per Exercise — different Sets of the same Exercise Entry may legitimately use different equipment (e.g. dumbbells in lbs, a barbell in kg) within the same Workout.
- **BREAKING**: `ExerciseSet.fromJson` requires `unit` with no default for missing values — existing locally-persisted Workouts (SharedPreferences) predate this field and will fail to decode. No migration path; local storage is wiped instead (see design.md).
- Add a kg/lbs toggle next to the weight field in the Set-entry row on the active Workout screen. The toggle is sticky per Exercise Entry tile: it remembers the last unit chosen within that tile so successive Sets default to the previously used unit; a freshly created tile with no prior selection defaults to kg.
- Change the logged-Set display from `'${weight} x ${reps}'` to `'${reps} reps at ${weight} ${unit}'` (e.g. "8 reps at 135 lbs"), matching CONTEXT.md's existing Set phrasing.

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
- `workout-lifecycle`: the Set construction/serialization requirement gains a required `unit` field.
- `workout-logging-ui`: the "adding a Set" requirement gains a unit toggle input and a sticky-per-tile default; the logged-Set display format changes.

## Impact

- Modified: `lib/models/workout.dart` (`ExerciseSet.unit`, `Workout.addSet`, JSON (de)serialization), `lib/screens/active_workout_screen.dart` (unit toggle in `_ExerciseEntryTileState`, updated display string).
- Existing tests asserting on the old weight/reps model or the `'${weight} x ${reps}'` display string need updating.
- No backend/API impact — local-only, same as the rest of Workout data.
- No migration code for pre-existing local Workouts: `StorageService._loadList`'s existing catch-all already discards a collection that fails to decode and returns `[]` (see design.md) — old Sets missing `unit` will throw in `fromJson` and simply vanish on next load, with no crash and no manual step required.
