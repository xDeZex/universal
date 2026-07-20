# Gym-tracking visual design spec

Locked spec for the [Gym-tracking visual design spec](https://github.com/xDeZex/universal/issues/210) wayfinder map. Covers Workout home, Managed Routines, Routine (Planned Exercise cards/rows), Active Workout (Exercise Entries, set rows), and Past Workouts. Ready to hand off to an implementation effort — this doc is the destination, not the implementation.

Validated via:
- Research: [M3 + fitness-app patterns](https://github.com/xDeZex/universal/issues/211)
- Prototype: [row/card/divider/selection](https://github.com/xDeZex/universal/issues/212)
- Prototype: [input controls](https://github.com/xDeZex/universal/issues/213)
- Prototype: [home screen button hierarchy](https://github.com/xDeZex/universal/issues/214)
- Coherence pass + component boundaries: [this ticket, #216](https://github.com/xDeZex/universal/issues/216)

## Foundations (already in place, not changed by this spec)

- Dark palette seeded from a single orange/peach accent (`AppTheme.dark`, `universal/lib/theme/app_theme.dart`) — near-black surfaces, `surfaceContainerHigh`/`surfaceContainerHighest` for elevated content. Not up for redesign.
- `CardThemeData` already sets `color: surfaceContainerHigh`, `elevation: 0`, `shape: RoundedRectangleBorder(borderRadius: 16)` globally — the component library below relies on these defaults rather than re-declaring them per call site.
- Material 3, `useMaterial3: true`.

## Coherence decisions locked by this ticket

The three prototypes (#212, #213, #214) were validated independently; checking them together against the real code (not just the resolution comments) surfaced two inconsistencies, now resolved:

- **Card outline: none, anywhere.** The prototype code had `RoutineTile` and the Past Workouts row drawing an explicit `outlineVariant` border on their `Card`, while `PlannedExerciseCard` and the Active Workout `ExerciseEntryTile` did not. Resolved: **no border on any coplanar card** — `surfaceContainerHigh` fill alone (the existing `CardThemeData`) is the only container treatment. Drop the border from `RoutineTile`/`PastWorkoutsScreen`.
- **Card vertical margin: 8dp everywhere.** `PlannedExerciseCard`/`RoutineTile`/`PastWorkoutsScreen` used 8dp, the Active Workout `ExerciseEntryTile` used 6dp. Resolved: **8dp** vertical margin (12dp horizontal) on every coplanar card. Bump `ExerciseEntryTile` up to match.

With those two fixes, the tonal language (accent-bar selection in `colorScheme.primary`, zebra shading in `surfaceContainerHighest @ 0.5`, tonal-pod steppers, `FilledButton`/`FilledButton.tonal` hierarchy) is consistent across all four target screens — no other gaps found.

## Component library

Four shared widgets carry the new visual language. Two existing widgets are restyled in place rather than replaced. Zebra-row shading and the unit toggle are deliberately **not** separate components — see "Not promoted to components" below.

### 1. `CoplanarCard` (new widget)

The single container used everywhere a row/card needs to read as a distinct, gapped surface: `Card(margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8), child: ...)`, relying entirely on the global `CardThemeData` for fill/elevation/radius — no per-site color, elevation, or border overrides.

- **Used by**: `RoutineTile` (Manage Routines row), `PastWorkoutsScreen` row, `PlannedExerciseCard` (Routine screen), `ExerciseEntryTile` (Active Workout).
- **Replaces**: four separate hand-rolled `Card(...)` / `Padding(child: Card(...))` call sites, two of which currently duplicate theme defaults and disagree on margin/border.

### 2. `SelectionAccentBorder` (new widget)

Wraps arbitrary child content with a 4dp left border — `colorScheme.primary` when selected, **always rendered but `Colors.transparent` when not** (never conditionally added), so `BoxDecoration`'s auto-padding never shifts content on select/deselect. No tonal fill, no check icon — border only.

- **Used by**: the open (being-edited) row inside `PlannedExerciseCard`, the selected `ExerciseEntryTile` in Active Workout.
- **Not** applied to `RoutineTile`/`PastWorkoutsScreen` — neither has a selection state.

### 3. Tonal stepper pod (restyle of existing `NumberStepper`)

`universal/lib/widgets/number_stepper.dart` keeps its name and public API (`keyPrefix`, `value`, `step`, `min`/`max`, `allowNegative`, `onChanged`) but its body changes from bare `IconButton` +/- to: a pill container (`BorderRadius.circular(999)`, `surfaceContainerHighest` fill) housing `IconButton.filledTonal` decrement/increment (18dp icon, `VisualDensity.compact`) flanking a fixed-width (36dp) `titleSmall` value label.

- **Used by**: the reps stepper and reps-range steppers in `PlannedExerciseRowEditor`, the weight stepper in `WeightInputControls`, the reps stepper in `SetInputRow`.
- No new class — this is `NumberStepper`'s new implementation, not a fork.

### 4. `WorkoutHomeActions` (new widget)

Replaces the unstyled, overflowing `TextButton` row on `WorkoutHomeScreen` (issue #208, fixed by construction here): a full-width `FilledButton` primary action (Start/Continue Workout), followed by secondary actions (Past Workouts, Manage Exercises, Manage Routines) as `FilledButton.tonal` chips with a leading icon, laid out in a `Wrap` that flows to a second line instead of overflowing.

- **Used by**: `WorkoutHomeScreen` only.
- Takes a primary label/icon/callback plus a `List<WorkoutHomeAction>` (label, icon, callback) for the secondary row.

### Restyled in place: `WeightInputControls`

`universal/lib/widgets/weight_input_controls.dart` keeps its name and API. Internals change from a `NumberStepper` + two `ChoiceChip`s to: the tonal-pod `NumberStepper` (above) + a fully-rounded `SegmentedButton<WeightUnit>` (`showSelectedIcon: false`, `VisualDensity.compact`, `shape: RoundedRectangleBorder(borderRadius: 999)`) for the kg/lbs toggle. `SetInputRow` and `PlannedExerciseRowEditor` both consume this unchanged at the call-site level — they just render the new internals.

`SetInputRow` and `PlannedExerciseRowEditor` also retire the issue #209 horizontal-scroll workaround: both switch from a horizontally-scrolling `Row` to a `Wrap` (`SetInputRow`) / fixed two-line layout with the range-toggle icon pinned to the row's right edge via `Spacer` (`PlannedExerciseRowEditor`), so weight controls are always visible within the real screen width instead of scrolling off it.

### Not promoted to components

- **Zebra-row shading** (`index.isOdd ? surfaceContainerHighest.withValues(alpha: 0.5) : null` as a row `Container`'s `color`): used identically in `PlannedExerciseCard` rows and `ExerciseEntryTile` set rows, but stays an inline style rule in each — not worth a shared widget for a single `Container.color` line.
- **Unit toggle** (`SegmentedButton<WeightUnit>`): only ever appears inside `WeightInputControls`, so it's documented as part of that widget's restyle, not a standalone component.

## Screen-by-screen application

| Screen | Container | Selection | Input controls | Buttons |
|---|---|---|---|---|
| Workout home | — | — | — | `WorkoutHomeActions` |
| Manage Routines | `CoplanarCard` (`RoutineTile`) | — | — | — |
| Routine (Planned Exercise cards) | `CoplanarCard` (`PlannedExerciseCard`) | `SelectionAccentBorder` on open row | tonal-pod `NumberStepper` + `SegmentedButton` via `WeightInputControls`, `PlannedExerciseRowEditor` | — |
| Active Workout (Exercise Entries) | `CoplanarCard` (`ExerciseEntryTile`) | `SelectionAccentBorder` on selected entry | tonal-pod `NumberStepper` + `SegmentedButton` via `SetInputRow` (add-set bar, edit-Set dialog) | — |
| Past Workouts | `CoplanarCard` (row) | — | — | — |

## Out of scope (unchanged from the map)

- Building/wiring these widgets into the codebase — this spec is the handoff point; implementation is separate future work.
- Checklists tab / rest of the app.
- Issues #208 and #209 as standalone bugs — fixed by construction by `WorkoutHomeActions` and the `Wrap`/two-line layouts above, but tracked there, not here.
