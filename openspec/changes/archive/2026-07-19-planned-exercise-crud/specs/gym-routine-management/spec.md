## MODIFIED Requirements

### Requirement: Routine screen shows an empty Planned Exercises state
The system SHALL show a single-line "No Planned Exercises yet" message in the Routine screen's body only when the Routine's Planned Exercise list is empty, in both active and archived states. When the list is non-empty, the body SHALL render the Planned Exercise list instead.

#### Scenario: Empty state on an active Routine with no Planned Exercises
- **WHEN** an active Routine with no Planned Exercises is displayed
- **THEN** the body SHALL show "No Planned Exercises yet" with no additional hint line

#### Scenario: Empty state on an archived Routine with no Planned Exercises
- **WHEN** an archived Routine with no Planned Exercises is displayed
- **THEN** the body SHALL show "No Planned Exercises yet" with no additional hint line, alongside the locked banner

#### Scenario: Non-empty Routine does not show the empty state
- **WHEN** a Routine with one or more Planned Exercises is displayed
- **THEN** the body SHALL render the Planned Exercise list instead of the empty-state message

## ADDED Requirements

### Requirement: Routine screen renders Planned Exercises as a list of cards
The system SHALL render each Planned Exercise as a card in the Routine's stored order, with a header (drag handle, the referenced Exercise's current name, delete icon) and its rows displayed read-only beneath.

#### Scenario: Planned Exercises render as cards in Routine order
- **WHEN** a Routine has multiple Planned Exercises
- **THEN** each SHALL render as a card, in the same order as the Routine's Planned Exercise list, showing its header and rows

#### Scenario: Card rows render read-only
- **WHEN** a Planned Exercise card with one or more rows is displayed
- **THEN** the rows SHALL be visible but SHALL NOT offer any editing interaction (row editing is not yet available)

#### Scenario: Card reflects the Exercise's current name after a rename elsewhere
- **WHEN** the Exercise referenced by a Planned Exercise has been renamed since the Planned Exercise was added
- **THEN** the card header SHALL display the Exercise's current name, not the name at the time it was added

### Requirement: Adding a Planned Exercise resolves the typed name to an existing or new Exercise
The system SHALL, on submitting the add field (via Enter or the inline add button) with a non-blank name, add a new Planned Exercise to the end of the Routine's list, referencing an existing Exercise reused by case-insensitive exact name match, or a newly created Exercise if no match exists.

#### Scenario: Submitting a name matching an existing Exercise reuses it
- **WHEN** the user submits a name that case-insensitively matches an existing Exercise's name
- **THEN** a new Planned Exercise SHALL be added referencing that existing Exercise's id

#### Scenario: Submitting an unmatched name creates a new Exercise
- **WHEN** the user submits a name that does not case-insensitively match any existing Exercise's name
- **THEN** a new Exercise SHALL be created with that name, and a new Planned Exercise SHALL be added referencing its id

#### Scenario: Submitting a blank name is rejected
- **WHEN** the user submits an empty or whitespace-only name
- **THEN** no Planned Exercise SHALL be added and the Planned Exercise list SHALL remain unchanged

### Requirement: Add field shows an autocomplete dropdown of matching Exercises while typing
The system SHALL, as the user types in the add field, show a dropdown listing existing Exercises whose name contains the typed text anywhere (case-insensitive), in alphabetical order, with no limit on the number shown (the dropdown scrolls if long). Tapping a suggestion SHALL fill the field with that Exercise's full name without submitting it.

#### Scenario: Typed text with matches shows the dropdown
- **WHEN** the user types text that is a case-insensitive substring of one or more existing Exercise names
- **THEN** a dropdown SHALL appear listing those Exercise names in alphabetical order, with no "add as new" option among them

#### Scenario: Typed text with no matches hides the dropdown
- **WHEN** the user types text that is not a case-insensitive substring of any existing Exercise name
- **THEN** no dropdown SHALL be shown

#### Scenario: Tapping a suggestion fills the field without submitting
- **WHEN** the user taps a suggestion in the dropdown
- **THEN** the add field SHALL be filled with that Exercise's full name and no Planned Exercise SHALL be added until the user separately submits

### Requirement: User can remove a Planned Exercise via its card header delete icon
The system SHALL, when the delete icon on an active Routine's Planned Exercise card is tapped, remove that Planned Exercise and its rows immediately, with no confirmation dialog.

#### Scenario: Deleting a Planned Exercise removes it immediately
- **WHEN** the user taps the delete icon on a Planned Exercise card in an active Routine
- **THEN** that Planned Exercise and its rows SHALL be removed immediately, with no confirmation dialog shown

#### Scenario: Deleting the last Planned Exercise shows the empty state
- **WHEN** the user deletes the only remaining Planned Exercise in a Routine
- **THEN** the Routine screen SHALL show the "No Planned Exercises yet" empty state

### Requirement: User can reorder Planned Exercises via drag-and-drop on a card header
The system SHALL, when a Planned Exercise card is long-press-dragged to a new position within an active Routine's list, update the Routine's stored order to match and persist it.

#### Scenario: Dragging a card to a new position reorders the list
- **WHEN** the user long-press-drags a Planned Exercise card to a different position in an active Routine's list
- **THEN** the Routine's Planned Exercise order SHALL be updated to match the drop position, and the new order SHALL persist across a rebuild

#### Scenario: Dropping a card in its original position is a no-op
- **WHEN** the user long-press-drags a card and drops it back in its original position
- **THEN** the Routine's Planned Exercise order SHALL remain unchanged

### Requirement: Planned Exercise editing controls are hidden while a Routine is archived
The system SHALL hide the add field and the per-card delete icon, and SHALL NOT allow drag-to-reorder, whenever the displayed Routine is archived — consistent with the existing locked banner.

#### Scenario: Archived Routine hides the add field
- **WHEN** an archived Routine's screen is displayed
- **THEN** the add-Planned-Exercise field SHALL NOT be shown

#### Scenario: Archived Routine's cards hide the delete icon
- **WHEN** an archived Routine with one or more Planned Exercises is displayed
- **THEN** its cards SHALL NOT show a delete icon

#### Scenario: Archived Routine's cards are not draggable
- **WHEN** an archived Routine with two or more Planned Exercises is displayed
- **THEN** long-press-dragging a card SHALL have no reordering effect
