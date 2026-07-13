## ADDED Requirements

### Requirement: Workout home screen exposes a Manage Exercises entry point
The system SHALL show a "Manage Exercises" action on the Workout home screen that navigates to the Manage Exercises screen, passing the current Exercise list.

#### Scenario: Open Manage Exercises from the Workout home screen
- **WHEN** the user taps "Manage Exercises" on the Workout home screen
- **THEN** the app SHALL display the Manage Exercises screen showing every stored Exercise

#### Scenario: Manage Exercises entry point available regardless of Workout state
- **WHEN** the Workout home screen is opened whether or not a Workout is in progress
- **THEN** the "Manage Exercises" action SHALL be available and unaffected by in-progress Workout state

### Requirement: Manage Exercises screen lists Exercises alphabetically, case-insensitively
The system SHALL display every stored Exercise sorted alphabetically by name, case-insensitively (e.g. "apple" before "Banana" before "cherry"), or an empty-state message when there are none.

#### Scenario: Exercises are sorted ignoring case
- **WHEN** the Manage Exercises screen is opened with Exercises named "Banana", "apple", "cherry"
- **THEN** they SHALL be displayed in the order "apple", "Banana", "cherry"

#### Scenario: No Exercises stored yet
- **WHEN** the Manage Exercises screen is opened with an empty Exercise list
- **THEN** the screen SHALL show an empty-state message ("No Exercises yet") with a hint to log a Workout to add one, instead of a list

### Requirement: Manage Exercises screen provides no Exercise-creation control
The system SHALL NOT provide any control for creating a new Exercise on the Manage Exercises screen; Exercise creation SHALL remain exclusive to the type-to-create flow during workout logging.

#### Scenario: No add control when the list is empty
- **WHEN** the Manage Exercises screen is rendered with no stored Exercises
- **THEN** no add/create control (e.g. a FloatingActionButton) SHALL be present, only the empty-state message

#### Scenario: No add control when Exercises are present
- **WHEN** the Manage Exercises screen is rendered with one or more stored Exercises
- **THEN** no add/create control SHALL be present anywhere on the screen

### Requirement: Tapping an Exercise opens a rename dialog
The system SHALL open a rename dialog, pre-filled with the Exercise's current name, when its row is tapped on the Manage Exercises screen.

#### Scenario: Tap opens a pre-filled rename dialog
- **WHEN** the user taps an Exercise row on the Manage Exercises screen
- **THEN** a dialog SHALL open with a text field pre-filled with that Exercise's current name

#### Scenario: Cancelling the dialog leaves the Exercise unchanged
- **WHEN** the user opens the rename dialog and cancels it
- **THEN** the Exercise's name SHALL remain unchanged and the dialog SHALL close

### Requirement: Renaming an Exercise validates and persists the new name
The system SHALL trim the submitted name, apply it via the Exercise's existing rename support if valid, persist the updated Exercise list, and close the dialog on success.

#### Scenario: Valid rename succeeds
- **WHEN** the user submits a non-empty name that does not collide with any other Exercise
- **THEN** the Exercise SHALL be renamed to the trimmed name, the change SHALL be persisted, and the dialog SHALL close

#### Scenario: Renaming to the Exercise's own current name (or a case-only variant) succeeds
- **WHEN** the user submits the Exercise's own current name unchanged, or the same name with different casing
- **THEN** the rename SHALL succeed since it does not collide with any *other* Exercise

### Requirement: Renaming an Exercise rejects invalid input inline
The system SHALL reject a blank/whitespace-only name or a name colliding case-insensitively with another existing Exercise, showing an inline error in the dialog and keeping the dialog open rather than closing it.

#### Scenario: Blank name is rejected
- **WHEN** the user submits an empty or whitespace-only name
- **THEN** the dialog SHALL show a validation error and remain open, and the Exercise SHALL remain unchanged

#### Scenario: Colliding name is rejected
- **WHEN** the user submits a name that matches another existing Exercise's name case-insensitively
- **THEN** the dialog SHALL show a validation error and remain open, and the Exercise SHALL remain unchanged
