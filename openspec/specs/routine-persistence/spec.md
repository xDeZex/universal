### Requirement: Routines load and save under their own storage key
The system SHALL load and save the Routine list via `StorageService` under a dedicated storage key, separate from the Checklist, Workout, and Exercise keys.

#### Scenario: Load with prior data
- **WHEN** `StorageService.loadRoutines` is called and `SharedPreferences` contains a previously saved Routine list
- **THEN** it SHALL return that list, reconstructed from JSON

#### Scenario: Load with no prior data
- **WHEN** `StorageService.loadRoutines` is called and `SharedPreferences` has no stored Routine data
- **THEN** it SHALL return an empty list rather than throwing

#### Scenario: Routine list is written under its own storage key
- **WHEN** `StorageService.saveRoutines` is called
- **THEN** it SHALL write the JSON-encoded Routine list to `SharedPreferences` under a key distinct from the Checklist, Workout, and Exercise keys

### Requirement: Routines load on WorkoutRepository creation
The system SHALL load the stored Routine list from `StorageService` when `WorkoutRepository.load()` runs, alongside Workouts and Exercises.

#### Scenario: Load populates routines alongside workouts and exercises
- **WHEN** `WorkoutRepository.load()` is called and `SharedPreferences` contains previously saved Routines, Workouts, and Exercises
- **THEN** all three SHALL be loaded and available via `WorkoutRepository`

### Requirement: Creating a Routine validates the name and persists immediately
The system SHALL, when creating a Routine by name, reject a blank or case-insensitively duplicate name by returning `null` without creating anything; otherwise it SHALL create a new active Routine (no Planned Exercises, `archivedAt: null`), add it to the Routine list, persist the updated list via `StorageService`, and notify listeners.

#### Scenario: Create a Routine with a unique name
- **WHEN** `WorkoutRepository.addRoutine` is called with a non-blank name that does not match any existing Routine's name case-insensitively
- **THEN** a new active Routine with that name and no Planned Exercises SHALL be created and returned

#### Scenario: Create a Routine with a blank name is rejected
- **WHEN** `WorkoutRepository.addRoutine` is called with a name that is empty or only whitespace
- **THEN** it SHALL return `null` and the Routine list SHALL be unchanged

#### Scenario: Create a Routine with a colliding name is rejected
- **WHEN** `WorkoutRepository.addRoutine` is called with a name matching an existing Routine's name case-insensitively
- **THEN** it SHALL return `null` and no second Routine with that name SHALL be created

#### Scenario: Creating a Routine persists it before the next frame
- **WHEN** `WorkoutRepository.addRoutine` successfully creates a Routine
- **THEN** the updated Routine list SHALL be written to `SharedPreferences` before the next frame
