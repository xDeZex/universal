## Purpose

Defines when Workout and Exercise data is loaded from and saved to persistent storage.
## Requirements
### Requirement: Workout changes persist immediately
The system SHALL save all Workout mutations (start, add Exercise Entry, add Set, finish, discard) to persistent storage at the time they occur, mirroring how Checklist mutations are saved.

#### Scenario: Start, log against, and finish a Workout
- **WHEN** the user starts a Workout, adds an Exercise Entry and a Set, and finishes it
- **THEN** the updated Workout list SHALL be written to `SharedPreferences` after each of those mutations, before the next frame

#### Scenario: App killed mid-Workout
- **WHEN** the app is force-closed while a Workout is in progress with logged Sets
- **THEN** the in-progress Workout and everything logged in it SHALL be present when the app is next launched

#### Scenario: Discard removes the Workout from storage
- **WHEN** the user discards an in-progress Workout
- **THEN** `SharedPreferences` SHALL no longer contain that Workout after the discard

#### Scenario: Workout list is written under its own storage key
- **WHEN** `StorageService` saves the Workout list
- **THEN** it SHALL write the JSON-encoded list to `SharedPreferences` under a dedicated key, separate from the Checklists key

### Requirement: New Exercises persist immediately when created via Exercise Entry reuse
The system SHALL save a newly created Exercise (created because a typed Exercise Entry name had no case-insensitive match) to persistent storage at the time it is created.

#### Scenario: Add an Exercise Entry with a new Exercise name
- **WHEN** the user adds an Exercise Entry whose typed name creates a new Exercise
- **THEN** the updated Exercise list SHALL be written to `SharedPreferences` before the next frame

#### Scenario: Reused Exercise does not duplicate storage
- **WHEN** the user adds an Exercise Entry whose typed name matches an existing Exercise
- **THEN** the stored Exercise list SHALL be unchanged, containing no duplicate Exercise

### Requirement: Workouts and Exercises load on app start
The system SHALL load the stored Workout list and Exercise list from `SharedPreferences` when `WorkoutRepository` is created, scoped to the Workout tab's subtree and independent of Checklist loading.

#### Scenario: Load with prior data
- **WHEN** the Workout tab's subtree initializes and `SharedPreferences` contains a previously saved Workout list and Exercise list
- **THEN** both lists SHALL be loaded and available via `WorkoutRepository` to the Workout home screen and its descendant screens

#### Scenario: Load with no prior data
- **WHEN** the Workout tab's subtree initializes and `SharedPreferences` has no stored Workout or Exercise data
- **THEN** the system SHALL default to empty lists rather than throwing

