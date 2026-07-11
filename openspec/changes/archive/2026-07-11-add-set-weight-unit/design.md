## Context

`ExerciseSet` (`lib/models/workout.dart`) currently holds `weight` (`num`) and `reps` (`int`) with no unit. The active Workout screen (`lib/screens/active_workout_screen.dart`, `_ExerciseEntryTileState`) renders each logged Set as `'${set.weight} x ${set.reps}'` and takes weight/reps input via two `TextField`s and an add button. CONTEXT.md's Set definition already phrases the concept as "3 reps @ 50kg" — the domain vocabulary anticipated a unit that never made it into the model.

This was explored (not just requested outright): the alternative of a global app-wide unit setting, or a per-Exercise default unit, were both considered and rejected in favor of a per-Set unit, because different Sets within the same Exercise Entry can legitimately use different equipment (dumbbells vs. barbell) within one Workout, and no aggregation/stats logic exists yet (stats-svc is out of scope per CONTEXT.md) that would need cross-unit conversion.

## Goals / Non-Goals

**Goals:**
- Give every logged Set an explicit, required weight unit (kg or lbs).
- Fix the ambiguous `weight x reps` display to read as `reps reps at weight unit`.
- Decide how the unit is chosen at entry time with minimal added friction (sticky default rather than re-selecting every Set).

**Non-Goals:**
- Global or per-Exercise default units — rejected during exploration; per-Set is the finer-grained and more accurate model of how equipment actually varies.
- Unit conversion, aggregation, or stats (1RM, volume, etc.) across mixed units — out of scope; stats-svc doesn't exist yet.
- Migrating existing persisted Sets to carry a unit — explicitly not attempted (see Decisions).

## Decisions

**`unit` is a required field on `ExerciseSet`, modeled as an enum.** Add `enum WeightUnit { kg, lbs }` (new, likely in `models/workout.dart` alongside `ExerciseSet`) and a required `unit` field on `ExerciseSet`, serialized via `.name`/`WeightUnit.values.byName(...)` in `toJson`/`fromJson`, matching the plain-JSON style already used for `DateTime.toIso8601String()`/`DateTime.parse()` elsewhere in the file. `Workout.addSet` gains a required `unit` parameter alongside `weight` and `reps`.

**No migration for pre-existing local Workouts — and no code needed to achieve that.** `StorageService._loadList` (`lib/services/storage_service.dart`) already wraps the entire decode-and-map in a try/catch that returns `[]` on any failure, including a `fromJson` throw partway through the list. Since `ExerciseSet.fromJson` will throw when `unit` is absent (per the "fromJson rejects a map missing required fields" requirement, unchanged in shape), old locally-persisted Workouts will simply fail to load and the app will behave as if the list were empty — no explicit wipe, storage-key bump, or backfill-default logic required. This is acceptable specifically because Workout data is local-only, single-device, and pre-real-usage; a networked or multi-device store would need an actual migration.

**The kg/lbs toggle is local widget state on `_ExerciseEntryTileState`, not persisted.** Add a `WeightUnit _selectedUnit` field (default `WeightUnit.kg`) next to the existing `_weightController`/`_repsController`. It's updated whenever the user flips the toggle and read when a Set is submitted, giving the "sticky within this Exercise Entry, resets to kg on a fresh tile" behavior for free — no new persistence, no cross-tile/cross-session state. If the app is closed and reopened mid-workout, the toggle reverts to kg (acceptable: it's a data-entry convenience, not a recorded fact — the fact is each already-logged Set's own stored `unit`).

**Display string moves from `'${set.weight} x ${set.reps}'` to `'${set.reps} reps at ${set.weight} ${unit label}'`.** The unit label is the lowercase enum name (`kg`/`lbs`), no pluralization handling for `reps` (matches the existing code's lack of pluralization elsewhere, e.g. no singular-vs-plural handling anywhere else in the screen).

## Risks / Trade-offs

- [`fromJson` now throws on any locally-persisted pre-change Workout] → Mitigated by the existing catch-all in `_loadList` (see Decisions); the failure mode is "old Workouts disappear," not a crash. Acceptable for a single-device personal app with no real usage yet on this data.
- [Mixed units within one Exercise Entry make any future per-Exercise stat (e.g. "heaviest set") ambiguous without a conversion step] → Explicitly deferred; stats aren't implemented yet, and the spec doesn't promise any cross-Set aggregation today.
- [Sticky toggle state resets on app restart, not just per-tile] → Acceptable: it's UI convenience, not a data-integrity concern — every already-logged Set keeps its own correct unit regardless.

## Migration Plan

None required — see the "no migration" decision above. Deploying this change is a plain code change; the first app launch afterward will find any existing local Workout data unreadable under the new `fromJson` and treat it as absent, which is the intended outcome.

## Open Questions

None outstanding — unit scope, display format, migration approach, and toggle default were all resolved during exploration before this proposal was written.
