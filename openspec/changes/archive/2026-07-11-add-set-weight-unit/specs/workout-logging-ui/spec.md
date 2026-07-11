## MODIFIED Requirements

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
