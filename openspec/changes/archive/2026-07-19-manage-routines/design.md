## Context

#182 (merged to `origin/main` via PR #189, not yet present on this repo's local `main`/`test`) delivered the `Routine`/`Planned Exercise` model and `WorkoutRepository.addRoutine`, with no UI. #175's grilling session resolved the UX for this ticket and produced a mockup; three of its details were deliberately overridden during this change's exploration (see Decisions, and the note on #183). This design covers the Manage Routines list, Create Routine dialog, and the Routine view/edit screen — no Planned Exercise content (#176) or start-from-Routine flow (#177).

## Goals / Non-Goals

**Goals:**
- Manage Routines list (active + archived sections), Create Routine dialog, Routine screen with rename/archive/unarchive, reusing existing app patterns (`ExerciseTile`, `_RenameExerciseDialog`, `ChecklistScreen`'s conditional section headers, `pushWithRepository`) wherever they fit.
- Add the three repository operations (`renameRoutine`, `archiveRoutine`, `unarchiveRoutine`) this UI needs, in the same explicit-verb style as `renameExercise`/`addRoutine`.

**Non-Goals:**
- Planned Exercise display/editing (empty shell only).
- Starting a Workout from a Routine.
- Program/Schedule.

## Decisions

**Create-then-push is a new navigation precedent.** Every existing create-FAB (`HomeScreen`'s add-Checklist) stays on its list after creating. This ticket's Create Routine dialog instead pops the validated name to `ManageRoutinesScreen`, which calls `addRoutine(name)` and immediately `pushWithRepository`s into the new Routine's `RoutineScreen`. Alternative considered: have the dialog itself call `addRoutine` and return the created `Routine` — rejected to keep the dialog a pure input/validation component with no repository access, consistent with `_RenameExerciseDialog`'s existing shape (it returns a validated string, never touches the repository).

**Reuse `Routine.validateRename`'s candidate-construction approach for Create, not a new validation entry point.** `Routine.validateRename` checks a name against a list of existing Routines, excluding the Routine's own id from the collision check. A not-yet-created Routine has no id to exclude. `WorkoutRepository.addRoutine` already solves this internally by constructing a throwaway candidate `Routine` (with a fresh id) before calling `validateRename` on it — the Create Routine dialog's validation should call the same path (i.e., delegate to `addRoutine`'s existing validation, not reimplement duplicate-checking against bare names). Concretely: the dialog can construct the same kind of throwaway candidate to call `validateRename` for inline error display, but the actual creation (and its persistence) only happens once via `ManageRoutinesScreen`'s call to `addRoutine` after the dialog returns a valid name — avoiding two divergent validation paths that could disagree.

**Locked banner is a plain themed `Container`, not `MaterialBanner`.** Confirmed against the official Flutter API docs (`api.flutter.dev/flutter/material/MaterialBanner-class.html`): `MaterialBanner` requires a user-dismiss action, which doesn't fit a banner that clears automatically when the Routine is unarchived rather than via user interaction. Also confirmed Material 3's spec (`m3.material.io/components/banners*`) no longer includes a Banner component at all — it's Material 2 legacy. A `Container` styled with a neutral (non-error) `colorScheme` tone, per #175's mockup, is the idiomatic fit.

**Rename via title-tap, not a dedicated icon; validation is submit-time, not live; empty state is one line, no hint.** All three deliberately diverge from #175's mockup (which showed a pencil icon, live validation, and a two-line active-state empty message). Noted on #183 so the mismatch with the recorded UX decision isn't silently invisible. Rationale: keeps the AppBar to a single new icon (archive/unarchive) and reuses `_RenameExerciseDialog`'s exact validation timing rather than introducing a new as-you-type pattern with no existing precedent in the codebase.

**Repository methods are explicit verbs, not a toggle.** `archiveRoutine(id)` / `unarchiveRoutine(id)` mirror `renameExercise`'s and `addRoutine`'s existing naming style. A single `toggleArchiveRoutine(id)` was considered and rejected — it would require the caller to already know the current state to reason about the effect, whereas the existing codebase's mutation methods are all unambiguous about their effect from the name alone.

## Risks / Trade-offs

**Divergence from #175's mockup** → Documented on #183 and in this design; if a later ticket (#176/#177) assumes the mockup's rename-icon or live-validation behavior, that assumption will be wrong and needs re-checking against this change instead.

**Local branch is behind `origin/main`** → The implementation branch for this change must be cut from an up-to-date `origin/main` (`git fetch origin && git checkout -b <branch> origin/main`) to pick up #182's merged model/repository code; cutting from the current local `main`/`test` would be missing `Routine` entirely.
