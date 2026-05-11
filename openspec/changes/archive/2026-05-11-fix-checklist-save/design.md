## Context

`ChecklistScreen` is a stateful widget that holds a local `_checklist` copy. Mutations (toggle, add, delete, reorder) update only that local copy. The save path back to `SharedPreferences` relies entirely on `HomeScreen._openChecklist` receiving the result of `Navigator.pop`. If the app is killed while `ChecklistScreen` is on screen, that pop never fires.

## Goals / Non-Goals

**Goals:**
- Persist checklist item changes immediately on each mutation
- No user-visible behavior change (no extra taps, no loading states)

**Non-Goals:**
- Debouncing or batching saves (latency is negligible for SharedPreferences at this scale)
- Moving to a different storage backend
- Changing state management architecture (no Provider)

## Decisions

**Pass an `onChanged` callback rather than injecting `StorageService` into `ChecklistScreen`**

`ChecklistScreen` only holds one `Checklist`. `StorageService.saveChecklists` requires the full list. Injecting storage would force `ChecklistScreen` to also receive the full list or load it — coupling it to global state it doesn't otherwise need. A callback keeps `ChecklistScreen` a simple leaf widget: it reports mutations upward, and `HomeScreen` handles persistence as it already does.

Alternative considered: lift state with Provider. Correct long-term if the app grows, but disproportionate scope for a two-file bug fix.

## Risks / Trade-offs

- Each mutation triggers a full serialise-and-write to SharedPreferences. For typical checklist sizes this is imperceptible, but it is more writes than before. → Acceptable given the data scale; can debounce later if needed.
- The pop-with-result path in `ChecklistScreen` still exists. After this fix it becomes redundant but harmless. → Leave it; removing it is a separate cleanup.
