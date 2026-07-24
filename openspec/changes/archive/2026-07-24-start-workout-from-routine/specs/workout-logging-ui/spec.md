## MODIFIED Requirements

### Requirement: Exercise Entries render as a coplanar card with a selected-state accent border
The system SHALL render each Exercise Entry inside a coplanar card (an elevated, gapped, rounded container consistent with the other gym-tracking rows/cards) containing a bold header row, a column-header row labeling Set/Weight/Reps once Sets or targets exist, then one numbered table row per Set or unfilled target — each preceded by a thin divider for readability. Rows are rendered positionally: row `i` SHALL show the logged Set at that position if `entry.sets` has one, otherwise the unfilled target at that position from `entry.targets` if one exists there, rendered individually with no grouping of consecutive identical targets. Each row SHALL show a small numbered badge (its position within the Exercise Entry), its weight (with unit) and reps in their own columns, with no other per-row status indicator (e.g. no checkmark). An unfilled target row SHALL show a dashed set-number badge and, on a Locked Workout, a dashed time column, in place of the real values a logged Set would show. On a Locked Workout, an additional column SHALL show each logged Set's time. On an in-progress Workout, the selected Exercise Entry SHALL show a 4dp left accent border in `colorScheme.primary` that unselected Exercise Entries do not have — always rendered, transparent when unselected, so its layout footprint never changes on select/deselect — and tapping an Exercise Entry's rows SHALL be the mechanism for selecting it.

#### Scenario: Selected Exercise Entry shows an accent border
- **WHEN** an Exercise Entry is selected on an in-progress Workout
- **THEN** that Exercise Entry SHALL show a left accent border in `colorScheme.primary`, and no other Exercise Entry SHALL show the accent border

#### Scenario: Locked Workout rows are not selectable and show no accent border
- **WHEN** the user taps an Exercise Entry's rows on a Locked Workout
- **THEN** no Exercise Entry SHALL become selected and no Exercise Entry SHALL show the accent border

#### Scenario: Deselecting an Exercise Entry does not shift its content
- **WHEN** the currently selected Exercise Entry becomes deselected (e.g. by selecting a different Exercise Entry)
- **THEN** its accent border SHALL become transparent rather than being removed, so its content SHALL NOT shift horizontally

#### Scenario: Unfilled target rows render with dashed stand-ins, individually
- **WHEN** an Exercise Entry has two logged Sets and three `targets`, and the first two targets are identical
- **THEN** the grid SHALL show two real Set rows followed by one dashed target row at position three (the two identical targets already consumed by the logged Sets are not shown as their own rows, and the remaining dashed row is never collapsed with another into a grouped `×N` count)

#### Scenario: An Exercise Entry with no targets renders exactly as before
- **WHEN** an Exercise Entry has a `null` `targets` field (not started from a Routine, or added manually)
- **THEN** the grid SHALL show only rows for its logged Sets, with no dashed rows

### Requirement: Exercise Entry selection targets the add-Set bar
The system SHALL let the user select an Exercise Entry as the target of the add-Set bottom bar by tapping it, defaulting to the most-recently-added Exercise Entry, and SHALL hide the bar entirely when no Exercise Entry is selected. Switching the selected Exercise Entry SHALL reset the weight and reps steppers to zero, unless the newly selected Exercise Entry has an unfilled target at position `entry.sets.length`, in which case the weight and reps steppers SHALL instead prefill from that target's weight and reps (the low end of the range, for a ranged target) rather than resetting to zero. Logging a Set always appends to `entry.sets`, landing at the first still-unfilled target position — there is no way to log against a target other than the next one.

#### Scenario: Default selection is the most-recently-added Exercise Entry
- **WHEN** a new Exercise Entry is added to the Workout
- **THEN** it SHALL become the selected Exercise Entry, and the add-Set bar SHALL target it

#### Scenario: Selecting a different Exercise Entry retargets the bar
- **WHEN** the user taps an unselected Exercise Entry that has no unfilled targets
- **THEN** that Exercise Entry SHALL become selected, the previously selected Exercise Entry SHALL become unselected, and the add-Set bar's weight and reps steppers SHALL reset to zero

#### Scenario: Add-Set bar hidden with no Exercise Entries
- **WHEN** the active Workout has zero Exercise Entries
- **THEN** no Exercise Entry SHALL be selected and the add-Set bar SHALL NOT be shown

#### Scenario: Selecting an Exercise Entry with an unfilled target auto-prefills the bar
- **WHEN** the user selects an Exercise Entry started from a Routine that has logged one Set against a three-row target snapshot
- **THEN** the add-Set bar's weight and reps steppers SHALL prefill from the second target row's weight and reps, rather than resetting to zero

#### Scenario: Logging fills the next target regardless of which values were shown
- **WHEN** the user selects an Exercise Entry with an unfilled target, adjusts the prefilled weight/reps to different values, and logs a Set
- **THEN** the new Set SHALL be appended to `entry.sets` and rendered at the position of the target that was prefilled (the first still-unfilled one), using the values actually submitted rather than the target's original values
