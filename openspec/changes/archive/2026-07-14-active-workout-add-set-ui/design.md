## Context

`ActiveWorkoutScreen` (`universal/lib/screens/active_workout_screen.dart`) currently renders each `ExerciseEntry` as its own `Card` (`_ExerciseEntryTile`) with a private inline add-Set row: two `TextField`s, two `ChoiceChip`s, and an `IconButton`. This change removes that per-entry input entirely and replaces it with one shared, selection-driven bottom bar. It's UI-only — no model or persistence changes (`Workout.addSet`/`editSet`/`deleteSet` in `universal/lib/models/workout.dart` are unaffected and keep being called the same way).

## Goals / Non-Goals

**Goals:**
- Single fixed add-Set bar, bound to a selected `ExerciseEntry`, stacked above Discard/Finish with a visible seam.
- Tap-to-select entries; default to most-recently-added; hide the bar when nothing is selected; clear (don't reassign) selection when the selected entry is deleted.
- Flat, `Card`-free entry rows with a selected-state background tint (not shown at all on Locked workouts).
- +/- steppers from zero for weight (2.5 kg / 5 lbs step) and reps (step 1), replacing free-text entry for the add-Set path.

**Non-Goals:**
- The Edit Set dialog (`_EditSetDialog`) — stays free-text, untouched.
- Any "programmed workout" / planned weight-reps concept.
- Switching the entry list from `ListView` to `ListView.builder` — out of scope; entry counts per workout are small and the existing `ListView(children: ...)` pattern is kept as-is to minimize the diff.

## Decisions

- **Selection state lives in `_ActiveWorkoutScreenState`, not per-tile.** `String? _selectedEntryId`. Tapping a tile's rows calls back up to set it (only when `_canAddNew`); tiles no longer own add-Set state themselves.
- **Sticky per-entry unit is tracked in the parent, not the bar.** A `Map<String, WeightUnit> _entryUnits` on `_ActiveWorkoutScreenState` (default `WeightUnit.kg` when absent) persists which unit was last used per entry — this is what makes stickiness survive switching selection away and back, which purely-local bar state couldn't do.
- **The bottom bar widget is keyed by the selected entry id** (`ValueKey(_selectedEntryId)` on the stepper bar widget). Switching selection therefore tears down and recreates the bar's `State`, which is exactly "reset weight/reps steppers to zero" for free — no manual reset logic needed. The bar reads its *initial* unit from `_entryUnits[entryId]` on construction; further unit toggles inside the bar call back up to update `_entryUnits` (for stickiness) and rebuild.
- **Selected-state tint uses `colorScheme.secondaryContainer`** (or equivalent M3 "container" token), matching how Material 3 already marks selection elsewhere (e.g. `ChoiceChip`, `NavigationBar` selected item) rather than inventing a new color.
- **Seam between the two fixed bars**: give the add-Set bar container a distinct surface tone (`colorScheme.surfaceContainerHighest`) plus a `Divider` between it and the Discard/Finish row, so two independently-purposed fixed bars don't read as one 6-control cluster.
- **Tap-to-select vs. the header row's delete `IconButton`**: no special gesture-arena handling needed. Wrapping the header row in `InkWell`/`GestureDetector` for selection and keeping the delete control as a nested `IconButton` works because Flutter hit-tests the topmost widget under the pointer — the `IconButton` consumes its own tap before it can reach the row's tap handler. This is standard behavior, not a new mechanism.
- **Locked-state non-interactivity**: reuse the existing `widget.locked` flag already threaded into `_ExerciseEntryTile`. When locked, rows render with no `InkWell`/tap handler and never read `_selectedEntryId` for tinting — this falls out of the existing prop rather than needing a new one.
- **Stepper is a small private reusable widget** (`_Stepper` or similar), parameterized by current value, step, an `allowNegative` flag (`false` by default, floors at 0), and an `onChanged`. Used twice in the bar with different step types and floor behavior: reps (`int` step 1, floored at 0 — can't have negative reps) and weight (`num` step 2.5/5, `allowNegative: true` — assisted exercises, e.g. an assisted pull-up machine, log a negative effective weight). Buttons sized to meet the ≥48dp Material touch target.
- **Set rows render as a numbered table, not sentence text.** Two rounds of user feedback after real-device testing (task 4.5) — first that a bare `Divider` between plain-text rows still wasn't enough separation, then that the header and Sets didn't read as a clear hierarchy at all — replaced the "<reps> reps at <weight> <unit>" sentence with a small table per Exercise Entry: a muted `SET / WEIGHT / REPS` column-header row (only shown once the entry has Sets), then one row per Set with a numbered circular badge, weight (with unit) and reps in their own columns (`font-variant: tabular-nums`-equivalent via `FontFeature.tabularFigures` is unnecessary in practice since values are short, so plain `Text` per cell is used), and a thin `Divider(height: 1, indent: 50)` above each row for separation. No per-row checkmark or other status glyph — explicitly rejected in favor of keeping the row uncluttered. On a Locked Workout the same row gains a fourth, right-aligned column showing the Set's logged time (reusing the slot a checkmark would otherwise occupy); that column is blank on in-progress Workouts. The Exercise name header uses `textTheme.titleMedium` (bold) against the Set rows' `bodyMedium`/`bodySmall` (muted `onSurfaceVariant`), so the header visibly outranks the data rows instead of matching their weight.
- **`_parseSetInput`/free-text parsing stays only for `_EditSetDialog`**, which is explicitly out of scope and keeps its `TextField`-based flow; the add-Set path no longer uses it.

## Risks / Trade-offs

- [Losing the "displayed weight = typed weight" precision users had with free text] → 2.5 kg / 5 lbs steps are a deliberate scope decision (plate-realistic increments), not a bug; no mitigation needed, it's the point.
- [Keyed-widget reset trick (`ValueKey(_selectedEntryId)`) is a bit implicit — a future reader might not realize selection switches double as a state-reset mechanism] → documented here in design.md; keep the bar's `State` class small enough that this stays obvious from reading it.
- [Existing tests reference the old per-entry `ValueKey`s (`weight-...`, `reps-...`, `unit-kg-...`, `add-set-...`)] → these are rewritten in this change (see tasks.md), not preserved; there's no dual-running old/new UI.

## Migration Plan

No data migration — this is a pure UI change over the existing `Workout`/`ExerciseEntry`/`ExerciseSet` models. Ship as a single change; no feature flag or staged rollout (personal app, single user, per project convention of not building backwards-compatibility shims for internal-only UI).
