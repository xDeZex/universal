## MODIFIED Requirements

### Requirement: Workouts and Exercises load on app start
The system SHALL load the stored Workout list and Exercise list from `SharedPreferences` when `WorkoutRepository` is created, scoped to the Workout tab's subtree and independent of Checklist loading.

#### Scenario: Load with prior data
- **WHEN** the Workout tab's subtree initializes and `SharedPreferences` contains a previously saved Workout list and Exercise list
- **THEN** both lists SHALL be loaded and available via `WorkoutRepository` to the Workout home screen and its descendant screens

#### Scenario: Load with no prior data
- **WHEN** the Workout tab's subtree initializes and `SharedPreferences` has no stored Workout or Exercise data
- **THEN** the system SHALL default to empty lists rather than throwing
