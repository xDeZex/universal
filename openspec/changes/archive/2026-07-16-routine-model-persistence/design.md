## Context

The Routine design map (#172) settled every product decision for Routines and Planned Exercises; #173's resolution comment fixed the field-level shape. This change is the implementation handoff (#182): build the model and persistence only, with no UI. The design questions below are the ones #173 left open for implementation time, worked through against the existing codebase (`Exercise`, `Workout`/`ExerciseEntry`/`ExerciseSet`, `WorkoutRepository`, `StorageService`) in an `openspec-explore` session.

## Goals / Non-Goals

**Goals:**
- `Routine`, `PlannedExercise`, `PlannedExerciseRow` model classes with the identity/validation/archive rules from #173.
- `Workout.routineId` (nullable, set-once).
- Persistence via `StorageService` + `WorkoutRepository`, proven with a round-trip and a single creation path (`addRoutine`).

**Non-Goals:**
- Any UI.
- Rename, archive/unarchive, add/remove/reorder Planned Exercises, edit rows — repository methods for these are added by #183 (list/create/rename/archive), #184 (add/remove/reorder), #185 (edit rows) when each needs them, not here.
- Pre-filling a Workout's Exercise Entries from a Routine (#186).
- Program/Schedule (out of scope per #172).

## Decisions

### RepsTarget as a sealed class, not flat nullable fields

A Planned Exercise row's reps target is either a fixed integer or a min/max range. Considered:
- **Flat fields**: `{ int reps, int? repsMax }`, `repsMax == null` meaning fixed. Consistent with this codebase's existing style (everything today is flat nullable fields, no sum types) but lets a `reps`/`repsMax` pair exist in a state neither variant intends (e.g. `repsMax` set below `reps`, or set without a clear meaning), and callers must remember the null-check convention rather than the type system enforcing it.
- **Sealed class** (`sealed class RepsTarget` with `FixedReps(int reps)` / `RangeReps(int min, int max)`): each variant only carries the fields that make sense for it, and Dart 3's exhaustive `switch` means adding a third variant later is a compile error everywhere it isn't handled.

Chosen: sealed class. This is the first sealed class in the codebase — accepted as a deliberate, minimal introduction of a pattern better suited to a genuine either/or than the flat-nullable-field convention used elsewhere. `toJson`/`fromJson` need an explicit discriminator field (Dart has no built-in tagged serialization); `fromJson` throws on an unrecognized tag rather than defaulting to a variant.

### PlannedWeight bundles value + unit, rather than two nullable fields

`ExerciseSet.weight` and `.unit` are always both present (a logged Set always has a unit). A Planned Exercise row's weight is optional, so a naive port would be `num? weight, WeightUnit? unit` — but that lets weight be set with no unit or vice versa, a state with no sensible interpretation. `PlannedWeight? weight` (a small value object holding both) is nullable as a whole and makes the invalid split state unconstructable.

### Routine gets `validateRename`, not `resolve`

#173 called for "the same enforcement pattern as Exercise (ADR-0015-style `validateRename`/`resolve`)". `Exercise.resolve` is find-or-create: typing a name during Workout logging silently reuses a case-insensitive match, which suits freeform text entry mid-workout. Routine creation (`addRoutine`, #183's create dialog) is an explicit "create a new Routine" action — a name collision there is a mistake to reject, not something to dedupe transparently. So Routine gets `validateRename` (blank/duplicate check) but no `resolve`; `addRoutine` validates and rejects (returns `null`) rather than returning an existing Routine on collision.

### Routine folds onto the existing WorkoutRepository, not a sibling repository

Considered a standalone `RoutineRepository` (mirroring how `WorkoutRepository` itself is a sibling to whatever manages Checklists) versus adding Routine to `WorkoutRepository` alongside Workout and Exercise. Nothing today needs to read Workout and Routine data from two different repositories at once, but #186 ("Start Workout from Routine") will need both in the same place to pre-fill Exercise Entries — that future need, not this ticket, is the actual tie-breaker, and it favors one repository over coordinating two. Chosen: fold onto `WorkoutRepository`, gaining a `routines` getter loaded in `load()` alongside `workouts`/`exercises`, following the same `ChangeNotifier` shape.

### StorageService gets its own Routine key, mirroring the existing per-model key convention

`StorageService` already gives Checklist, Workout, and Exercise each their own `SharedPreferences` key and `_loadList`/`_saveList` pair. Routine follows the same convention (`_routinesKey`, `loadRoutines`, `saveRoutines`) rather than nesting Routines inside the Workout key — consistent with every existing model in this file.

### Only `addRoutine` is added to the repository now

The acceptance criteria for #182 ask for models, `routineId`, and proven persistence — not full CRUD. Adding rename/archive/planned-exercise methods now would be dead code with no caller until #183-#185 land, and risks guessing at a shape those tickets should decide when they're actually worked. `addRoutine` is the one exception: without it, there's no way to exercise the persistence path (create → save → reload) in a repository-level test, so it earns its place as the minimal method needed to prove the plumbing works.

## Risks / Trade-offs

- **First sealed class in the codebase** → mitigated by keeping `RepsTarget` minimal (two variants, no shared mutable state) so it reads as an obviously-correct fit rather than an unfamiliar pattern to reverse-engineer later.
- **`WorkoutRepository` grows another responsibility** (Workout + Exercise + now Routine) → accepted for now since #186 will need Workout and Routine together; if the class becomes unwieldy once #183-#186 add their methods, splitting it is a future refactor, not blocked by this decision.
- **`addRoutine` exists with no UI caller yet** → acceptable short-term dead code; it's covered by repository-level tests and is the specific method #183's create dialog will call.
