## MODIFIED Requirements

### Requirement: Tapping a Past Workout opens its detail view
The system SHALL open the Active Workout screen for the tapped Workout when a row in the Past Workouts list is tapped. Because the Workout is Locked, its add-Exercise-Entry field, add-Set controls, and Discard/Finish buttons SHALL be hidden (per `workout-logging-ui`), but its Sets and Exercise Entries SHALL remain editable and deletable (per `workout-correction`), and any such changes SHALL be persisted, not discarded.

#### Scenario: Tap a row to view details
- **WHEN** the user taps a row in the Past Workouts list
- **THEN** the app SHALL open that Workout's detail view showing its Exercise Entries and Sets, with add and Discard/Finish controls hidden

#### Scenario: Detail view matches the Workout's Exercise Entries exactly
- **WHEN** a Workout has an Exercise Entry with zero logged Sets
- **THEN** the detail view SHALL show that Exercise Entry's name with no Sets listed under it, rather than omitting the entry

#### Scenario: Corrections made from the detail view are persisted
- **WHEN** the user edits or deletes a Set or Exercise Entry from a Past Workout's detail view
- **THEN** the change SHALL be saved to storage, and SHALL still be reflected the next time that Workout's detail view is opened
