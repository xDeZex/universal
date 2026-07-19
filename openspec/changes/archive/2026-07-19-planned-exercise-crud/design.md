## Context

The Routine and Planned Exercise data model (`Routine`, `PlannedExercise`, `PlannedExerciseRow`, `RepsTarget`, `PlannedWeight`) already exists in `universal/lib/models/routine.dart` (#182), and `RoutineScreen` already handles rename/archive/locked-banner (#183) but renders a static empty-state-only body. This change fills in that body with add/remove/reorder for whole Planned Exercises.

Two existing precedents anchor the approach:
- **Reorder**: `home_screen.dart` (checklists) and `checklist_screen.dart` both use `ReorderableListView.builder` with `onReorderItem` (old/new index already correct, no manual adjustment) calling a pure `reorderX(oldIndex, newIndex)` method on the model, then persisting via the repository/`onChanged`. No explicit drag-handle listener is used anywhere in the app — the whole row is draggable by default, with `Icons.drag_handle` as a purely decorative leading icon.
- **Exercise resolution**: `Exercise.resolve(name, existing)` (`lib/models/exercise.dart`) already implements case-insensitive-match-or-create; it's used as-is by `ActiveWorkoutController`/`WorkoutRepository.addExerciseEntry` today and will be reused unchanged here.

The one genuinely new surface is the autocomplete dropdown: confirmed via codebase search that no `Autocomplete` widget or suggestion UI exists anywhere in `lib/` today. Issue #124 (the logging-flow ticket that originally proposed this pattern) is still open and unbuilt. The exact dropdown behavior (substring-anywhere match, no usage counts, alphabetical order, tap-fills-not-submits, no "add as new" row, unbounded/scrolling) was pinned down during exploration and recorded on #184 (https://github.com/xDeZex/universal/issues/184#issuecomment-5016818652) specifically so #124 follows the same spec later, even though the widget itself is not shared code yet.

## Goals / Non-Goals

**Goals:**
- Add, remove, and reorder whole Planned Exercises within an active Routine, persisted via `WorkoutRepository`.
- A working autocomplete-backed add field, matching the spec recorded on #184.
- Respect the existing archived/locked rule: none of add/remove/reorder is available on an archived Routine.

**Non-Goals:**
- Editing a Planned Exercise row's reps/weight target (in-place stepper editing, range toggle) — separate, later ticket. Rows render as a simple read-only line for now.
- The grouped `×N` collapsing display for consecutive identical rows shown in #176's mockup — that's part of row editing/display polish, deferred with it.
- Extracting a widget shared with #124's future logging-flow implementation. This ticket builds its own copy per #184's stated scope; the *design* is shared (via the recorded spec), the *code* is not, yet.
- Any change to `ExerciseEntryTile`, `active_workout_screen.dart`, or `ActiveWorkoutController` — the logging flow is untouched.

## Decisions

**Reorder mechanism**: `ReorderableListView.builder` with `onReorderItem`, mirroring `checklist_screen.dart` exactly, over inventing a custom drag implementation or the mockup's dedicated-handle-only drag. A `Routine.reorderPlannedExercises(oldIndex, newIndex)` (or equivalent list-splice logic reused by the repository) mirrors `Checklist.reorderUnchecked`/`reorderChecked` (`checklist.dart:89-107`). The drag handle icon in each card header is decorative, consistent with `item_tile.dart` — the whole card is draggable, not just the handle. Rationale: zero new interaction pattern to build or test; the app already has two working examples of this exact shape.

**Repository shape**: `addPlannedExercise`, `removePlannedExercise`, `reorderPlannedExercises` on `WorkoutRepository`, each following the existing private mutate/replace helper pattern already used for Workouts and the existing Routine mutators (validate → mutate → `StorageService.saveRoutines` → `notifyListeners()`). Each checks `routine.isLocked` first and no-ops (no persistence, no notify) if archived — same rejection shape as the existing archive/unarchive guard implied by #182's "Locked while archived" rule, now enforced explicitly rather than left to callers.

**Card widget**: new widget, not a reuse of `ExerciseEntryTile` (which lives in the logging flow, isn't reorderable, and has a different tap-to-select responsibility). Visually mirrors its header-plus-rows shape (drag handle, name, delete icon; rows below) but is its own class since the underlying data (`PlannedExercise` vs `ExerciseEntry`) and interactions (reorder here, none there) differ.

**Add field + autocomplete**: new self-contained widget for this screen. Owns the `TextField`, the inline add `IconButton`, and the dropdown. On submit, resolves the name via `Exercise.resolve` and calls `WorkoutRepository.addPlannedExercise`. The dropdown filters the repository's `Exercise` list by case-insensitive substring match against the current field text, sorted alphabetically, with no count cap (wrapped in a scrollable container, e.g. a bounded-height `ListView` inside an `Overlay`/inline expansion below the field — exact widget mechanics are an implementation detail, not a design fork). Tapping a suggestion sets the field's text to the full Exercise name and does not call `addPlannedExercise` itself — the user still submits.

**Row display (placeholder)**: since row editing is out of scope, rows render as a single plain `Text` per row (e.g. "8–12 reps @ 60 kg" / "6 reps · no weight"), no grouping, no tap interaction. This keeps the card's shape (header + rows) visible without building UI that the next ticket will replace anyway.

**Locked-state gating in the UI**: mirrors the existing archived-banner pattern — the add field and per-card delete icons are hidden (not just disabled) when `routine.isLocked`, and the list is wrapped in a plain (non-reorderable) `ListView` instead of `ReorderableListView` in that case, rather than trying to intercept/reject drags on a reorderable list. Simpler than disabling drag gesture recognition on a widget designed to always be draggable.

## Risks / Trade-offs

- **[Risk]** Building the autocomplete widget as a one-off for this ticket means #124, whenever picked up, either duplicates this code or triggers a refactor to share it. → **Mitigation**: the behavior spec is already recorded on #184's thread precisely so the eventual #124 implementation (or a follow-up extraction) matches this one exactly; duplication cost is bounded to UI glue, not design rework.
- **[Risk]** `ReorderableListView` requires each item to carry a stable `Key`; Planned Exercise cards must key off `PlannedExercise.id`, not list index, or reordering will misbehave when combined with concurrent add/remove. → **Mitigation**: use `ValueKey(plannedExercise.id)` per card, consistent with how `ChecklistTile` keys off name+index today (Planned Exercises already have stable ids, so this is more robust than that precedent, not less).
- **[Trade-off]** Hiding (not disabling) controls when archived means the list widget type itself changes (`ReorderableListView` ↔ plain `ListView`) based on lock state, slightly more branching in the screen than a single always-reorderable list with drag rejection. Accepted since it avoids fighting the reorder gesture recognizer and matches the "hide" language already used for other archived-state UI.

## Migration Plan

No data migration — `Routine`/`PlannedExercise` already persist via the existing `routines` storage key (#182). This change only adds repository methods and UI; no schema change, no backfill.
