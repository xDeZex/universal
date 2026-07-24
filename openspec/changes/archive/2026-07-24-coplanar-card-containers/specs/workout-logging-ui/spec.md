## MODIFIED Requirements

### Requirement: Exercise Entries render as a coplanar card with a selected-state accent border
The system SHALL render each Exercise Entry inside a coplanar card (an elevated, gapped, rounded container consistent with the other gym-tracking rows/cards) containing a bold header row, a column-header row labeling Set/Weight/Reps once Sets exist, then one numbered table row per Set — each preceded by a thin divider for readability. Each Set row SHALL show a small numbered badge (its position within the Exercise Entry), its weight (with unit) and reps in their own columns, with no other per-row status indicator (e.g. no checkmark). On a Locked Workout, an additional column SHALL show each Set's logged time. On an in-progress Workout, the selected Exercise Entry SHALL show a 4dp left accent border in `colorScheme.primary` that unselected Exercise Entries do not have — always rendered, transparent when unselected, so its layout footprint never changes on select/deselect — and tapping an Exercise Entry's rows SHALL be the mechanism for selecting it.

#### Scenario: Selected Exercise Entry shows an accent border
- **WHEN** an Exercise Entry is selected on an in-progress Workout
- **THEN** that Exercise Entry SHALL show a left accent border in `colorScheme.primary`, and no other Exercise Entry SHALL show the accent border

#### Scenario: Locked Workout rows are not selectable and show no accent border
- **WHEN** the user taps an Exercise Entry's rows on a Locked Workout
- **THEN** no Exercise Entry SHALL become selected and no Exercise Entry SHALL show the accent border

#### Scenario: Deselecting an Exercise Entry does not shift its content
- **WHEN** the currently selected Exercise Entry becomes deselected (e.g. by selecting a different Exercise Entry)
- **THEN** its accent border SHALL become transparent rather than being removed, so its content SHALL NOT shift horizontally
