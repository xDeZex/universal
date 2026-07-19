## ADDED Requirements

### Requirement: Adding a Planned Exercise validates the Routine's lock state and persists immediately
The system SHALL, when adding a Planned Exercise to a Routine by exercise name, reject the operation if the Routine is archived, leaving the Routine list unchanged; otherwise it SHALL resolve the Exercise (reusing an existing Exercise by case-insensitive name match, or creating a new one), append a new Planned Exercise referencing that Exercise's id to the Routine's Planned Exercise list, persist the updated Routine list via `StorageService`, and notify listeners.

#### Scenario: Add a Planned Exercise to an active Routine
- **WHEN** `WorkoutRepository.addPlannedExercise` is called with the id of an active Routine and a non-blank exercise name
- **THEN** a new Planned Exercise SHALL be appended to that Routine's list, referencing the resolved Exercise's id

#### Scenario: Adding to an archived Routine is rejected
- **WHEN** `WorkoutRepository.addPlannedExercise` is called with the id of an archived Routine
- **THEN** the Routine's Planned Exercise list SHALL remain unchanged and nothing SHALL be persisted

#### Scenario: Adding persists before the next frame
- **WHEN** `WorkoutRepository.addPlannedExercise` successfully adds a Planned Exercise
- **THEN** the updated Routine list SHALL be written to `SharedPreferences` before the next frame

### Requirement: Removing a Planned Exercise validates the Routine's lock state and persists immediately
The system SHALL, when removing a Planned Exercise from a Routine by id, reject the operation if the Routine is archived, leaving the Routine list unchanged; otherwise it SHALL remove that Planned Exercise from the Routine's list, persist the updated list via `StorageService`, and notify listeners.

#### Scenario: Remove a Planned Exercise from an active Routine
- **WHEN** `WorkoutRepository.removePlannedExercise` is called with the id of an active Routine and the id of one of its Planned Exercises
- **THEN** that Planned Exercise SHALL be removed from the Routine's list

#### Scenario: Removing from an archived Routine is rejected
- **WHEN** `WorkoutRepository.removePlannedExercise` is called with the id of an archived Routine
- **THEN** the Routine's Planned Exercise list SHALL remain unchanged and nothing SHALL be persisted

#### Scenario: Removing persists before the next frame
- **WHEN** `WorkoutRepository.removePlannedExercise` successfully removes a Planned Exercise
- **THEN** the updated Routine list SHALL be written to `SharedPreferences` before the next frame

### Requirement: Reordering Planned Exercises validates the Routine's lock state and persists immediately
The system SHALL, when reordering a Routine's Planned Exercises by old/new index, reject the operation if the Routine is archived, leaving the Routine list unchanged; otherwise it SHALL move the Planned Exercise at the old index to the new index, persist the updated list via `StorageService`, and notify listeners.

#### Scenario: Reorder Planned Exercises within an active Routine
- **WHEN** `WorkoutRepository.reorderPlannedExercises` is called with the id of an active Routine and a valid old/new index pair
- **THEN** the Routine's Planned Exercise list SHALL reflect the new order

#### Scenario: Reordering on an archived Routine is rejected
- **WHEN** `WorkoutRepository.reorderPlannedExercises` is called with the id of an archived Routine
- **THEN** the Routine's Planned Exercise list SHALL remain unchanged and nothing SHALL be persisted

#### Scenario: Reordering persists before the next frame
- **WHEN** `WorkoutRepository.reorderPlannedExercises` successfully reorders a Routine's Planned Exercises
- **THEN** the updated Routine list SHALL be written to `SharedPreferences` before the next frame
