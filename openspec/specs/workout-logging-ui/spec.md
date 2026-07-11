### Requirement: Bottom navigation exposes a Workout tab alongside Checklists
The system SHALL present a bottom navigation bar with a Checklists tab (the existing checklist home) and a Workout tab, allowing the user to switch between them without losing either screen's state.

#### Scenario: Switch to the Workout tab
- **WHEN** the user taps the Workout tab
- **THEN** the app SHALL display the Workout home screen

#### Scenario: Switch back to the Checklists tab preserves state
- **WHEN** the user switches to the Workout tab and back to the Checklists tab
- **THEN** the Checklists tab SHALL show the same checklist list state it had before switching away

### Requirement: Workout home screen reflects whether a Workout is in progress
The system SHALL show a "Start Workout" action when no Workout is in progress, and a "Continue Workout" action when one is.

#### Scenario: No Workout in progress
- **WHEN** the Workout tab is opened and no stored Workout is in progress
- **THEN** the screen SHALL show a "Start Workout" action

#### Scenario: A Workout is already in progress
- **WHEN** the Workout tab is opened and a stored Workout is in progress
- **THEN** the screen SHALL show a "Continue Workout" action that opens the active Workout screen for that Workout

### Requirement: Active Workout screen allows adding an Exercise Entry by typed name
The system SHALL provide a plain text field on the active Workout screen for adding an Exercise Entry by name (no autocomplete suggestions in this change).

#### Scenario: Add an Exercise Entry with a valid name
- **WHEN** the user types a non-empty name into the Exercise Entry field and submits it
- **THEN** a new ExerciseEntry SHALL appear on the active Workout screen, resolved to an existing or newly created Exercise per the Exercise reuse rule

#### Scenario: Submit an empty Exercise Entry name
- **WHEN** the user submits the Exercise Entry field while it is empty or whitespace-only
- **THEN** the system SHALL reject the submission and no ExerciseEntry SHALL be added

### Requirement: Active Workout screen allows adding a Set to an Exercise Entry
The system SHALL provide weight, unit (kg or lbs), and reps input fields on each Exercise Entry for logging a Set, stamped with the current time as `loggedAt` at the moment it is added. The unit input SHALL default to the unit most recently selected for that Exercise Entry in the current session, or to kg if no Set has yet been logged against that Exercise Entry. Each logged Set SHALL be displayed as "<reps> reps at <weight> <unit>" (e.g. "8 reps at 135 lbs").

#### Scenario: Add a Set with valid weight, unit, and reps
- **WHEN** the user enters a numeric weight, selects a unit, and enters a positive integer reps count and submits them against an Exercise Entry
- **THEN** a new Set SHALL be added to that Exercise Entry with `loggedAt` set to the current time, and SHALL be displayed as "<reps> reps at <weight> <unit>"

#### Scenario: Submit an invalid Set
- **WHEN** the user submits a non-numeric weight, or a reps count that is not a positive integer
- **THEN** the system SHALL reject the submission and no Set SHALL be added

#### Scenario: Unit selection defaults to kg on a freshly added Exercise Entry
- **WHEN** the user logs the first Set against an Exercise Entry that has no Sets yet
- **THEN** the unit input SHALL default to kg

#### Scenario: Unit selection is sticky within an Exercise Entry
- **WHEN** the user logs a Set against an Exercise Entry using lbs, then logs another Set against the same Exercise Entry
- **THEN** the unit input SHALL default to lbs for the second Set, without the user re-selecting it

### Requirement: Finish action is disabled until the Workout has a logged Set
The system SHALL disable the Finish action on the active Workout screen until at least one Set has been logged anywhere in the Workout, and SHALL return to the Workout home screen showing "Start Workout" after a successful finish.

#### Scenario: Finish disabled with zero Sets
- **WHEN** the active Workout has no logged Sets
- **THEN** the Finish action SHALL be disabled

#### Scenario: Finish enabled and completes the Workout
- **WHEN** the active Workout has at least one logged Set and the user taps Finish
- **THEN** the Workout SHALL be finished and the app SHALL return to the Workout home screen showing "Start Workout"

### Requirement: Discard action deletes the in-progress Workout from the active Workout screen
The system SHALL provide a Discard action on the active Workout screen, available whenever a Workout is in progress (including one with zero logged Sets), that deletes the Workout and returns to the Workout home screen.

#### Scenario: Discard an in-progress Workout
- **WHEN** the user taps Discard on the active Workout screen
- **THEN** the Workout and all of its logged Exercise Entries/Sets SHALL be deleted, and the app SHALL return to the Workout home screen showing "Start Workout"

#### Scenario: Discard is available with zero logged Sets
- **WHEN** the active Workout has no logged Sets and Finish is therefore disabled
- **THEN** the Discard action SHALL still be available so the empty Workout can be abandoned
