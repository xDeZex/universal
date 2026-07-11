## ADDED Requirements

### Requirement: Active Workout screen renders read-only for a finished Workout
The system SHALL hide the add-Exercise-Entry field, each Exercise Entry's add-Set controls, and the Discard/Finish buttons on the Active Workout screen whenever the given Workout is finished (`isInProgress == false`), deriving this purely from the Workout's own `endTime` with no separate mode parameter.

#### Scenario: Finished Workout hides input and action controls
- **WHEN** the Active Workout screen is opened for a Workout with a non-null `endTime`
- **THEN** the add-Exercise-Entry field, add-Set controls, and Discard/Finish buttons SHALL NOT be shown

#### Scenario: In-progress Workout keeps input and action controls
- **WHEN** the Active Workout screen is opened for a Workout with a null `endTime`
- **THEN** the add-Exercise-Entry field, add-Set controls, and Discard/Finish buttons SHALL be shown as before

### Requirement: Finished Workout's Sets display their logged time
The system SHALL show each Set's `loggedAt` time alongside its reps and weight when the Active Workout screen is rendering read-only for a finished Workout, while the in-progress display format remains "<reps> reps at <weight> <unit>" unchanged.

#### Scenario: Set display includes logged time for a finished Workout
- **WHEN** the Active Workout screen renders read-only for a finished Workout
- **THEN** each Set SHALL be displayed as "<reps> reps at <weight> <unit> — <loggedAt time>"

#### Scenario: In-progress Set display is unchanged
- **WHEN** the Active Workout screen renders a Set for an in-progress Workout
- **THEN** the Set SHALL be displayed as "<reps> reps at <weight> <unit>" with no timestamp
