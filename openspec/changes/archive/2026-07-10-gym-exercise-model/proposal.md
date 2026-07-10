## Why

The Phase 3 gym epic (#16) needs a reusable `Exercise` concept before any Workout logging can exist. Issue #95 scopes out just the data model — no storage, UI, or backend sync — so the shape can be settled and tested in isolation, mirroring how `ChecklistItem` was introduced before `Checklist` persistence existed.

## What Changes

- Add an `Exercise` model to `universal/lib/models/exercise.dart`: immutable, with `id` (String, required constructor param, caller-supplied) and `name` (String, freeform), plus `copyWith`, `toJson`, `fromJson` — mirroring `universal/lib/models/checklist.dart`'s style.
- `Exercise` identity is `id`, not `name` (ADR-0015) — deliberately breaking from `ChecklistItem`'s name-as-identity pattern so a later rename doesn't orphan references from Exercise Entries.
- No `id` generation logic in the model itself — generation scheme (client UUID vs. server-assigned) is deferred to a future storage/catalog issue, pending the offline-vs-local-first decision still open on #16.
- No `==`/`hashCode` override — no dedup/Set usage exists in this issue's scope.
- Unit tests in `universal/test/models/exercise_test.dart`, mirroring `checklist_test.dart`'s coverage style (construction, `copyWith`, `toJson`/`fromJson`).

## Capabilities

### New Capabilities
- `gym-exercise-model`: The `Exercise` data model — its fields, identity semantics (id-based, not name-based), and serialization contract. Does not cover storage, uniqueness enforcement, reuse-by-name matching, or rename-collision handling — those are domain rules now recorded in CONTEXT.md but belong to a future storage/catalog change.

### Modified Capabilities
(none — no existing spec covers gym domain models yet)

## Impact

- New file: `universal/lib/models/exercise.dart`
- New file: `universal/test/models/exercise_test.dart`
- No changes to existing screens, services, or storage — `Exercise` is not yet referenced from anywhere else in the app.
