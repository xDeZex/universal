# gym-routine-management Specification

## Purpose
TBD - created by archiving change manage-routines. Update Purpose after archive.
## Requirements
### Requirement: Workout home screen exposes a Manage Routines entry point
The system SHALL show a "Manage Routines" action on the Workout home screen, alongside "Past Workouts" and "Manage Exercises", that navigates to the Manage Routines screen.

#### Scenario: Open Manage Routines from the Workout home screen
- **WHEN** the user taps "Manage Routines" on the Workout home screen
- **THEN** the app SHALL display the Manage Routines screen showing every stored Routine

#### Scenario: Manage Routines entry point available regardless of Workout state
- **WHEN** the Workout home screen is opened whether or not a Workout is in progress
- **THEN** the "Manage Routines" action SHALL be available and unaffected by in-progress Workout state

### Requirement: Manage Routines screen lists active Routines first, then archived Routines in their own section
The system SHALL display active Routines (flat, alphabetical by name, case-insensitive) followed by archived Routines under a separate "Archived" section label, which SHALL only appear when at least one archived Routine exists. An entirely empty Routine list SHALL show an empty-state message instead.

#### Scenario: Active and archived Routines are sectioned and sorted
- **WHEN** the Manage Routines screen is opened with active Routines "Pull Day" and "Push Day", and an archived Routine "Full Body A"
- **THEN** "Pull Day" and "Push Day" SHALL be listed first in alphabetical order, followed by an "Archived" section label and "Full Body A" below it

#### Scenario: No Archived section when nothing is archived
- **WHEN** the Manage Routines screen is opened with only active Routines
- **THEN** no "Archived" section label SHALL be rendered

#### Scenario: No Routines stored yet
- **WHEN** the Manage Routines screen is opened with an empty Routine list
- **THEN** the screen SHALL show an empty-state message instead of a list

### Requirement: Manage Routines screen provides a Create Routine control
The system SHALL show a FloatingActionButton on the Manage Routines screen that opens a Create Routine dialog, regardless of whether any Routines exist yet.

#### Scenario: Create control available with no Routines
- **WHEN** the Manage Routines screen is rendered with no stored Routines
- **THEN** a FloatingActionButton SHALL be present that opens the Create Routine dialog when tapped

#### Scenario: Create control available with existing Routines
- **WHEN** the Manage Routines screen is rendered with one or more stored Routines
- **THEN** the FloatingActionButton SHALL still be present and open the Create Routine dialog when tapped

### Requirement: Creating a Routine validates the name and navigates into the new Routine
The system SHALL, on Create Routine dialog submission, validate the name (rejecting blank or case-insensitively duplicate names with an inline error, keeping the dialog open) and, on success, create the Routine and navigate directly into its Routine screen rather than back to the list.

#### Scenario: Valid name creates the Routine and opens it
- **WHEN** the user submits a non-blank name that does not collide with any existing Routine's name
- **THEN** a new Routine SHALL be created with that name and the app SHALL navigate directly to that Routine's screen

#### Scenario: Blank name is rejected
- **WHEN** the user submits an empty or whitespace-only name
- **THEN** the dialog SHALL show a validation error and remain open, and no Routine SHALL be created

#### Scenario: Colliding name is rejected
- **WHEN** the user submits a name matching an existing Routine's name case-insensitively
- **THEN** the dialog SHALL show a validation error and remain open, and no Routine SHALL be created

### Requirement: Tapping a Routine row opens its Routine screen
The system SHALL navigate to the tapped Routine's Routine screen when its row is tapped on the Manage Routines screen, whether the Routine is active or archived.

#### Scenario: Tap an active Routine
- **WHEN** the user taps an active Routine's row on the Manage Routines screen
- **THEN** the app SHALL display that Routine's Routine screen

#### Scenario: Tap an archived Routine
- **WHEN** the user taps an archived Routine's row on the Manage Routines screen
- **THEN** the app SHALL display that Routine's Routine screen, showing its archived/locked state

### Requirement: Tapping the Routine screen's title opens a rename dialog
The system SHALL open a rename dialog, pre-filled with the Routine's current name, when the Routine's name in the AppBar title is tapped. No separate rename icon SHALL be present.

#### Scenario: Tap opens a pre-filled rename dialog
- **WHEN** the user taps the Routine name in the Routine screen's AppBar
- **THEN** a dialog SHALL open with a text field pre-filled with that Routine's current name

#### Scenario: Cancelling the dialog leaves the Routine unchanged
- **WHEN** the user opens the rename dialog and cancels it
- **THEN** the Routine's name SHALL remain unchanged and the dialog SHALL close

### Requirement: Renaming a Routine validates and persists the new name
The system SHALL trim the submitted name, apply it via the Routine's existing rename support if valid, persist the updated Routine, and close the dialog on success. Renaming SHALL remain available while the Routine is archived.

#### Scenario: Valid rename succeeds
- **WHEN** the user submits a non-empty name that does not collide with any other Routine
- **THEN** the Routine SHALL be renamed to the trimmed name, the change SHALL be persisted, and the dialog SHALL close

#### Scenario: Renaming an archived Routine succeeds
- **WHEN** an archived Routine's rename dialog is submitted with a valid new name
- **THEN** the rename SHALL succeed despite the Routine being locked for Planned Exercise edits

#### Scenario: Blank or colliding name is rejected inline
- **WHEN** the user submits an empty/whitespace-only name, or a name colliding case-insensitively with another existing Routine
- **THEN** the dialog SHALL show a validation error and remain open, and the Routine SHALL remain unchanged

### Requirement: Archive/unarchive is a single-tap AppBar action with no confirmation
The system SHALL show one AppBar icon on the Routine screen that archives an active Routine or unarchives an archived one, applying the change immediately on tap with no confirmation dialog.

#### Scenario: Archiving an active Routine
- **WHEN** the user taps the archive icon on an active Routine's screen
- **THEN** the Routine SHALL become archived immediately, with no confirmation dialog shown

#### Scenario: Unarchiving an archived Routine
- **WHEN** the user taps the unarchive icon on an archived Routine's screen
- **THEN** the Routine SHALL become active immediately, with no confirmation dialog shown

### Requirement: An archived Routine's screen shows a locked banner
The system SHALL show a persistent, non-dismissible banner on an archived Routine's screen reading "Archived — unarchive to edit Planned Exercises", styled as a neutral (non-error-colored) container rather than a dismissible Material banner component.

#### Scenario: Banner shown while archived
- **WHEN** an archived Routine's screen is displayed
- **THEN** a banner reading "Archived — unarchive to edit Planned Exercises" SHALL be visible

#### Scenario: Banner absent while active
- **WHEN** an active Routine's screen is displayed
- **THEN** no locked banner SHALL be shown

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

