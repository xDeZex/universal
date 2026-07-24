## Context

`Workout.routineId` and the full `Routine`/`PlannedExercise`/`PlannedExerciseRow` model already exist (#182), and Planned Exercise rows can already be added/edited/deleted in place (#185). Neither of those changes touched `WorkoutRepository.startWorkout`, which accepts `routineId` but does nothing with it, or `ExerciseEntryTile`/`AddSetBar`, which only know how to render and log real Sets. This change wires the two sides together.

Two design questions came up while scoping this against the raw issue body (GitHub #186) and were resolved by conversation before writing this proposal — both reverse what the issue currently says, and both are recorded as an addendum on the issue itself:

1. **Row grouping** ("consecutive identical targets collapse into a range chip + `×N`") — the issue's text is stale. It was reversed on 2026-07-20 in addenda on both #176 and #177 (the issues #186 is handed off from), before #186 was filed, but never folded back into #186's body. #185 shipped with no grouping in `PlannedExerciseCard`, confirmed by reading current source. This change does not implement grouping.
2. **Tap-to-retarget** ("tapping any target row retargets the AddSetBar's prefill") — reconsidered and dropped in favor of strict count-order filling (see Decisions below).

## Goals / Non-Goals

**Goals:**
- Starting a Workout from a Routine pre-fills Exercise Entries with no placeholder Sets.
- Target rows render in the existing grid as dashed stand-ins, individually (no grouping).
- Logging always fills the next unfilled target in order; selecting an Entry auto-prefills from it.
- An archived Routine can't be used to start a Workout, defensively at the repository layer.
- Resolve the `workout.dart` / `routine.dart` import direction without a cycle.

**Non-Goals:**
- Row grouping / `×N` collapsing (explicitly out of scope, see Context).
- Any way to log against a target other than the next unfilled one (no per-row tap).
- Changing anything about `PlannedExercise`/`PlannedExerciseRow`/`Routine` themselves — only how their rows get snapshotted onto an `ExerciseEntry`.
- A separate Routine-picker flow off `WorkoutHomeScreen` (Manage Routines already provides that step).

## Decisions

### Targets are positional, not tagged — no `targetIndex` on `ExerciseSet`

**Decision:** `ExerciseEntry.targets` is a plain snapshot list (`List<PlannedExerciseRow>?`). A grid row's content is derived purely from position: row `i` is `sets[i]` if it exists, else `targets[i]`. `ExerciseSet` gains no new field.

**Why:** The alternative — a nullable `targetIndex` on `ExerciseSet` recording which target row a Set was logged against — was seriously considered, since it would support out-of-order logging (tap row 3, log against it while rows 1–2 stay dashed). That was rejected: logging out of order doesn't reflect how a Workout is actually performed (you don't do rep-set 3 before rep-set 1 of the same Exercise), and enforcing strict order removes an entire interaction and its matching logic for free — the next Set always lands at `sets.length`, the first still-dashed row. It also resolves the issue's own "left open" question (what happens to a target row that stays unfilled while a later one gets logged) without any special-casing: it simply can't happen, since only the very next target is ever fillable.

**Alternatives considered:**
- `targetIndex` on `ExerciseSet`, allowing arbitrary-order fills — rejected per above.
- A separate `targetFills: Map<int, String>` (target index → set id) on `ExerciseEntry` — same rejected rationale, plus an extra structure to keep in sync for no behavioral benefit once order is enforced.

### `WeightUnit` moves to its own file to avoid a model import cycle

**Decision:** Move the `WeightUnit` enum out of `lib/models/workout.dart` into a new `lib/models/weight_unit.dart`. `routine.dart` drops its `workout.dart` import (it only ever needed `WeightUnit`) and imports `weight_unit.dart` instead; `workout.dart` imports both `weight_unit.dart` and `routine.dart` (for `PlannedExerciseRow`, needed by the new `targets` field).

**Why:** `ExerciseEntry.targets: List<PlannedExerciseRow>?` requires `workout.dart` to depend on `routine.dart`. `routine.dart` already depends on `workout.dart` (for `WeightUnit` alone), which would create a cycle. Extracting the one enum both files actually need removes the existing edge entirely rather than papering over a new one, leaving a clean one-directional `workout.dart → routine.dart` dependency. This mirrors the codebase's existing answer to the same class of problem: `models/unique_name.dart` is a shared, dependency-free file imported by both `exercise.dart` and `routine.dart` for exactly this reason.

**Alternatives considered:**
- Allow the cycle (Dart compiles it fine) — rejected as inconsistent with the `unique_name.dart` precedent already established in this directory.
- Give `ExerciseEntry.targets` its own duplicate reps/weight shape instead of reusing `PlannedExerciseRow` — rejected, avoids the import question but creates two structurally identical types that must be kept in sync by hand.

### Archived-Routine guard lives in the repository, not only the UI

**Decision:** `WorkoutRepository.startWorkout({routineId})` refuses (no-op, no Workout created) if `routineId` resolves to an archived Routine, mirroring `_replacePlannedExercises`'s existing `isLocked` guard in `workout_repository_planned_exercises.dart`.

**Why:** The Start Workout bar is already hidden while a Routine is archived, so this path shouldn't be reachable from the UI — but every other lock-sensitive mutation in this repository (`addPlannedExercise`, `removePlannedExercise`, row mutations) enforces its own guard rather than trusting the caller, and `startWorkout` should follow the same convention rather than being the one exception.

## Risks / Trade-offs

- **[Risk]** Extracting `WeightUnit` touches two existing, already-shipped model files (`workout.dart`, `routine.dart`) as part of a change whose acceptance criteria are otherwise additive. → **Mitigation:** the move is mechanical (relocate one enum, update two import lines), covered by the existing model unit tests (`workout_test.dart`, `planned_exercise_row_test.dart` etc.) which exercise `WeightUnit` through its public usage and don't care which file declares it.
- **[Risk]** Rendering target rows positionally (`sets[i]` else `targets[i]`) means a Workout with more logged Sets than targets (user logs past the plan) needs to fall back to plain Set rendering for the excess — easy to get an off-by-one wrong. → **Mitigation:** cover this explicitly in `ExerciseEntryTile` widget tests (more Sets than targets, exactly equal, targets with no Sets yet).
- **[Trade-off]** Dropping tap-to-retarget is a real capability reduction versus the original issue text — a user who wants to log a heavier or lighter target row out of order can't jump ahead, only adjust the prefilled values before submitting (which still fills the next position, not the tapped one, since there is no tapped one). Accepted as the right trade for matching how a Workout is actually logged; recorded on #186's addendum for visibility.

## Migration Plan

No persisted-data migration needed: `ExerciseEntry.targets` is a new nullable field, defaulting to `null` on `fromJson` for every existing stored Workout (mirrors how `PlannedExerciseRow.weight` was migrated to a default in #185). No feature flag — this ships as soon as the code lands, same as every other change in this app.

## Open Questions

None — all design forks surfaced while scoping this were resolved in conversation before this document was written (see Decisions above and the addendum on #186).
