## Context

Four gym-tracking screens each render their own row/card container today, with no shared widget: `RoutineTile` and the Past Workouts row are bare `ListTile`s (no `Card` at all); `PlannedExerciseCard` wraps its content in a plain `Card`; `ExerciseEntryTile` roots itself in a `Material(color: tint)` where `tint` is `colorScheme.secondaryContainer` when selected, with a flat (non-card) row layout separated by `Divider`s.

The gym-tracking visual design spec (wayfinder #210, locked by #216 at `docs/design/gym-tracking-visual-design-spec.md`) specifies a single shared `CoplanarCard` for all four sites and a separate `SelectionAccentBorder` for selection-state indication, and its two locked coherence fixes: no outline/border on any coplanar card, and 8dp vertical / 12dp horizontal margin everywhere. `SelectionAccentBorder` is scoped to a later ticket (#221), but this change pulls forward the specific slice of it needed by `ExerciseEntryTile`, because that widget's container swap forces a rewrite of its selection mechanism regardless — see Decisions below.

The design's `CoplanarCard`/`SelectionAccentBorder` shapes were already validated in the throwaway prototype on branch `worktree-wayfinder-212-row-card-prototype` (`exercise_entry_tile_variants.dart`, `buildCoplanarCardEntryTile`), which this design follows directly rather than re-deriving from scratch.

## Goals / Non-Goals

**Goals:**
- One shared `CoplanarCard` widget, backed entirely by the app's global `CardThemeData`, used at all four call sites.
- `ExerciseEntryTile`'s selection indicator moves from a background tint to a left accent border, with zero behavioral change to selection semantics (which entry is selected, when, and how the add-Set bar targets it).
- No visual regression: card corners must not show square artifacts from inner decoration, and toggling selection must not shift row content horizontally.

**Non-Goals:**
- Zebra-row shading (any screen) — separate ticket (#221).
- `SelectionAccentBorder` applied to `PlannedExerciseCard`'s open row — separate ticket (#221); no existing selection visual there to restructure, so nothing forces it now.
- Any change to `WorkoutHomeActions`, `NumberStepper`, or `WeightInputControls` — unrelated components from the same design spec, different tickets.
- Any change to selection *behavior* (which Exercise Entry is selected, add-Set targeting, locked-Workout selection rules) — only its visual representation changes.

## Decisions

**`CoplanarCard` is a thin wrapper, not a themed component.**
`Card(margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8), clipBehavior: Clip.antiAlias, child: child)`. Color, elevation, and shape all come from `AppTheme`'s existing `CardThemeData` — deliberately no local overrides, per the locked spec, so every call site is guaranteed identical fill/elevation/radius/lack-of-border by construction rather than by convention.
- `clipBehavior: Clip.antiAlias` is set unconditionally, even though only `ExerciseEntryTile`'s content needs it (see next decision). `Card`'s default `clipBehavior` is `Clip.none`, and `AppTheme`'s `CardThemeData` doesn't set one either — confirmed in the prototype (`exercise_entry_tile_variants.dart:165` sets it explicitly; `planned_exercise_card.dart:221` in the same prototype omits it because its content has no full-bleed decoration). Setting it on `CoplanarCard` itself keeps the fix in one place rather than requiring every future consumer to remember it.

**Pull `SelectionAccentBorder` forward from #221, but only its `ExerciseEntryTile` slice.**
`ExerciseEntryTile`'s root widget is being rewritten in this change regardless (`Material` → `CoplanarCard`). Two options were considered for its selection indicator during that rewrite:
1. Preserve the current tint by nesting a nested `Material(color: tint)` inside `CoplanarCard`'s child, leaving the actual border swap for #221.
2. Build `SelectionAccentBorder` now and wire it in directly, retiring the tint entirely.

Option 2 was chosen: option 1 produces a shim that #221 immediately deletes a PR later — rework on the exact same lines for no lasting benefit — and it would also contradict the already-validated direction (the picked #212 prototype variant uses the border, not the tint, for this exact widget). `SelectionAccentBorder`'s application to `PlannedExerciseCard`'s open row is *not* pulled forward alongside it: that row has no existing selection visual to restructure, so building it now is net-new scope, not rework-avoidance, and stays with #221.

**`SelectionAccentBorder` shape**: wraps arbitrary child content, always rendering a 4dp left `BorderSide` — `colorScheme.primary` when selected, `Colors.transparent` when not. The border is never conditionally added/removed (only its color changes) because `BoxDecoration.border` contributes its own width to the child's effective padding; toggling the border's presence, rather than just its color, would shift all content horizontally by 4dp on every select/deselect.

**Structure inside `ExerciseEntryTile`**: `CoplanarCard(child: SelectionAccentBorder(selected: ..., child: Column(...)))` — matching the prototype's validated structure exactly (`Card → Container(decoration: border) → Column`).

**No outline on `CoplanarCard` itself, anywhere.** This is a property of the `Card`'s own shape (relying on `CardThemeData`'s borderless `RoundedRectangleBorder`) and is orthogonal to `SelectionAccentBorder`, which is a different widget layered inside the card's child — the card boundary and the selection accent are never the same visual element.

## Risks / Trade-offs

- **[Test rewrite risk]** `active_workout_screen_selection_test.dart` has 5 tests asserting directly on a `Material` widget's `.color` at key `entry-{id}`. These must be rewritten against `SelectionAccentBorder`'s border color instead, at the same keys, preserving the same observable behavior (which entry looks selected) while changing what implementation detail is asserted. → Mitigated by keeping the same `ValueKey`s on the outer widget so existing `find.byKey` lookups keep working; only the widget type and property under test changes.
- **[Corner-clip risk]** Without `clipBehavior: Clip.antiAlias`, `SelectionAccentBorder`'s rectangular decoration inside `ExerciseEntryTile` could show square corners poking past `CoplanarCard`'s rounded shape. → Mitigated by setting `clipBehavior: Clip.antiAlias` on `CoplanarCard` unconditionally (see Decisions); already validated as sufficient in the #212 prototype.
- **[Scope-creep risk]** Once inside `ExerciseEntryTile` and `PlannedExerciseCard` for the container swap, it's tempting to also land #221's zebra shading or the `PlannedExerciseCard` open-row border "since the file's already open." → Deliberately left out (see Non-Goals) to keep this change's diff reviewable and matched to #218's actual acceptance criteria; #221 remains a small, focused follow-up rather than dissolving into this change.

## Migration Plan

No data migration; this is a pure presentation-layer change to existing widgets already in production use. Suggested implementation order (matches dependency shape — build the shared widgets before consuming them):
1. `CoplanarCard` + widget test.
2. `SelectionAccentBorder` + widget test.
3. Swap `RoutineTile` and the Past Workouts row (independent, no selection concerns) — lowest-risk sites first.
4. Swap `PlannedExerciseCard`'s `Card` → `CoplanarCard` (straightforward, no selection concerns here either).
5. Restructure `ExerciseEntryTile` (`Material` → `CoplanarCard` + `SelectionAccentBorder`), then update `active_workout_screen_selection_test.dart`.
6. `flutter analyze` clean, `flutter test` passing, visual verification on the emulator across all four screens.

Rollback is a plain revert — no persisted state or external contracts are touched.

## Open Questions

None outstanding — scope, structure, and the one spec-level requirement change (`workout-logging-ui`) are settled. Once #221 is picked up, its author should link back here for the validated `SelectionAccentBorder` shape rather than re-deriving it.
