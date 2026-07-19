## ADDED Requirements

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
The system SHALL show a single-line "No Planned Exercises yet" message in the Routine screen's body, in both active and archived states, since Planned Exercise editing is not yet available.

#### Scenario: Empty state on an active Routine
- **WHEN** an active Routine's screen is displayed
- **THEN** the body SHALL show "No Planned Exercises yet" with no additional hint line

#### Scenario: Empty state on an archived Routine
- **WHEN** an archived Routine's screen is displayed
- **THEN** the body SHALL show "No Planned Exercises yet" with no additional hint line, alongside the locked banner
