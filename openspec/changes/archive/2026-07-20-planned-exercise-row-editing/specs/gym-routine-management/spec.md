## MODIFIED Requirements

### Requirement: Routine screen renders Planned Exercises as a list of cards
The system SHALL render each Planned Exercise as a card in the Routine's stored order, with a header (drag handle, the referenced Exercise's current name, delete icon) and its rows displayed beneath, each row supporting in-place editing and deletion when the Routine is active.

#### Scenario: Planned Exercises render as cards in Routine order
- **WHEN** a Routine has multiple Planned Exercises
- **THEN** each SHALL render as a card, in the same order as the Routine's Planned Exercise list, showing its header and rows

#### Scenario: Card rows render as editable rows on an active Routine
- **WHEN** an active Planned Exercise card with one or more rows is displayed
- **THEN** each row SHALL show its reps and weight, be tappable to open its editor, and show an inline delete icon

#### Scenario: Card reflects the Exercise's current name after a rename elsewhere
- **WHEN** the Exercise referenced by a Planned Exercise has been renamed since the Planned Exercise was added
- **THEN** the card header SHALL display the Exercise's current name, not the name at the time it was added

### Requirement: Planned Exercise editing controls are hidden while a Routine is archived
The system SHALL hide the add field, the per-card delete icon, the per-row "Add row" control, and per-row edit/delete affordances, and SHALL NOT allow drag-to-reorder, whenever the displayed Routine is archived — consistent with the existing locked banner.

#### Scenario: Archived Routine hides the add field
- **WHEN** an archived Routine's screen is displayed
- **THEN** the add-Planned-Exercise field SHALL NOT be shown

#### Scenario: Archived Routine's cards hide the delete icon
- **WHEN** an archived Routine with one or more Planned Exercises is displayed
- **THEN** its cards SHALL NOT show a delete icon

#### Scenario: Archived Routine's cards are not draggable
- **WHEN** an archived Routine with two or more Planned Exercises is displayed
- **THEN** long-press-dragging a card SHALL have no reordering effect

#### Scenario: Archived Routine's cards hide the Add row control
- **WHEN** an archived Routine with one or more Planned Exercises is displayed
- **THEN** its cards SHALL NOT show a "+ Add row" control

#### Scenario: Archived Routine's rows are not editable or deletable
- **WHEN** an archived Routine's Planned Exercise card has one or more rows
- **THEN** tapping a row SHALL NOT open an editor and no per-row delete icon SHALL be shown

## ADDED Requirements

### Requirement: User can add a row to a Planned Exercise
The system SHALL, when "+ Add row" is tapped on an active Routine's Planned Exercise card, append a new row — copying the last row's reps and weight if the card already has rows, or defaulting to a fixed 1 rep and `0 kg` if it has none — and immediately open that new row's editor.

#### Scenario: Adding a row to a non-empty card copies the last row
- **WHEN** the user taps "+ Add row" on a Planned Exercise card whose last row is `8–12 reps @ 60 kg`
- **THEN** a new row SHALL be appended with the same reps target and weight, and its editor SHALL open immediately

#### Scenario: Adding a row to an empty card uses the default
- **WHEN** the user taps "+ Add row" on a Planned Exercise card with no rows
- **THEN** a new row SHALL be appended with a fixed 1 rep and `0 kg`, and its editor SHALL open immediately

### Requirement: User can edit a row's reps in place
The system SHALL, while a row's editor is open, show a single reps stepper for a fixed target or two steppers joined by a range toggle for a ranged target, applying each stepper/toggle interaction to the underlying row immediately.

#### Scenario: Adjusting a fixed row's reps stepper applies immediately
- **WHEN** the user taps the increment or decrement control on an open row's fixed-reps stepper
- **THEN** that row's `FixedReps` value SHALL update immediately to reflect the new count, with no separate save action

#### Scenario: Toggling a row from fixed to ranged reps
- **WHEN** the user taps the range toggle on an open row currently showing `FixedReps(8)`
- **THEN** the row SHALL become `RangeReps(min: 8, max: 9)` immediately, shown as two steppers

#### Scenario: Toggling a row from ranged back to fixed reps
- **WHEN** the user taps the range toggle on an open row currently showing `RangeReps(min: 8, max: 12)`
- **THEN** the row SHALL become `FixedReps(8)` immediately, shown as a single stepper

#### Scenario: Range steppers cannot cross into an invalid range
- **WHEN** an open row is ranged with `min` and `max` adjacent (e.g. `RangeReps(min: 8, max: 9)`)
- **THEN** the max stepper's decrement control SHALL be disabled and the min stepper's increment control SHALL be disabled, so `min` can never reach or exceed `max` through the steppers

#### Scenario: Reps steppers have a floor of 1
- **WHEN** an open row's reps value (fixed, or either bound of a range) is `1`
- **THEN** the corresponding stepper's decrement control SHALL be disabled

### Requirement: User can edit a row's weight in place
The system SHALL, while a row's editor is open, show a weight stepper with kg/lbs unit toggle chips mirroring `SetInputRow`'s weight controls, applying each interaction to the row's `PlannedWeight` immediately.

#### Scenario: Adjusting the weight stepper applies immediately
- **WHEN** the user taps the increment or decrement control on an open row's weight stepper
- **THEN** that row's `PlannedWeight.value` SHALL update immediately by the unit's step size, with no separate save action

#### Scenario: Switching the weight unit applies immediately
- **WHEN** the user taps the "lbs" chip on an open row currently in kg
- **THEN** that row's `PlannedWeight.unit` SHALL update immediately to `lbs`

### Requirement: User can delete a row inline
The system SHALL, when a row's inline delete icon is tapped on an active Routine, remove that row from its Planned Exercise immediately, with no confirmation dialog.

#### Scenario: Deleting a row removes it immediately
- **WHEN** the user taps a row's delete icon on an active Routine's Planned Exercise card
- **THEN** that row SHALL be removed from the Planned Exercise immediately, with no confirmation dialog shown

#### Scenario: Deleting the currently-open row also closes its editor
- **WHEN** the user taps the delete icon of a row whose editor is currently open
- **THEN** that row and its editor SHALL both disappear, with no other row's editor opening in its place

### Requirement: At most one row editor is open at a time
The system SHALL keep at most one Planned Exercise row's editor expanded at any time across the entire Routine screen; opening a different row's editor SHALL collapse whichever editor was already open, regardless of which card either row belongs to.

#### Scenario: Opening a new row's editor collapses the previous one
- **WHEN** a row's editor is already open and the user taps a different row, whether in the same card or a different card
- **THEN** the previously open editor SHALL collapse and the newly tapped row's editor SHALL open

#### Scenario: Tapping the open row again collapses it
- **WHEN** the user taps the row whose editor is currently open
- **THEN** that editor SHALL collapse, leaving no row editor open
