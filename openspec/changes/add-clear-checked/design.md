## Context

The checklist screen currently has no bulk action for checked items. The `Checklist` model is immutable and uses `copyWith`/functional methods; all mutations go through `StorageService` auto-save.

## Goals / Non-Goals

**Goals:**
- Add `clearChecked()` to the `Checklist` model
- Surface a toolbar button that calls it and triggers auto-save
- Button visible only when checked items exist

**Non-Goals:**
- Undo/redo support
- Confirmation dialog (single-tap action is sufficient for this scope)
- Bulk-clear across multiple checklists

## Decisions

**Model method over screen-level filter**: `clearChecked()` lives on `Checklist`, consistent with how `removeItem`, `toggleItem`, etc. are modeled. Alternatives: filter in the screen's provider call — rejected because it leaks domain logic into UI.

**Toolbar placement**: An `IconButton` in the `AppBar` actions. Alternative: floating action button — rejected because FAB is already used/reserved for adding items.

**Visibility guard**: Show/hide via `AnimatedOpacity` or `Visibility` driven by `checkedItems.isNotEmpty`. This keeps the layout stable and avoids toolbar reflow.

## Risks / Trade-offs

- [Accidental tap] No undo → Mitigation: button is only shown when there are checked items, reducing accidental exposure. Undo is out of scope.

## Migration Plan

No data migration needed. Existing persisted checklists are unaffected.
