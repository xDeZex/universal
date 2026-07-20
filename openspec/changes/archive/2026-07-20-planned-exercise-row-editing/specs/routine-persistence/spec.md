## ADDED Requirements

### Requirement: Adding a Planned Exercise row validates the Routine's lock state and persists immediately
The system SHALL, when adding a row to a Planned Exercise, reject the operation if the Routine is archived, leaving the Planned Exercise unchanged; otherwise it SHALL append a new row — copying the last row's reps and weight if the Planned Exercise already has rows, or a default fixed 1 rep and `0 kg` otherwise — to the Planned Exercise's row list, persist the updated Routine list via `StorageService`, and notify listeners.

#### Scenario: Add a row to a Planned Exercise on an active Routine
- **WHEN** `WorkoutRepository.addPlannedExerciseRow` is called with the id of an active Routine and one of its Planned Exercise ids
- **THEN** a new row SHALL be appended to that Planned Exercise's row list

#### Scenario: Adding a row on an archived Routine is rejected
- **WHEN** `WorkoutRepository.addPlannedExerciseRow` is called with the id of an archived Routine
- **THEN** the Planned Exercise's row list SHALL remain unchanged and nothing SHALL be persisted

#### Scenario: Adding a row persists before the next frame
- **WHEN** `WorkoutRepository.addPlannedExerciseRow` successfully adds a row
- **THEN** the updated Routine list SHALL be written to `SharedPreferences` before the next frame

### Requirement: Updating a Planned Exercise row validates the Routine's lock state and persists immediately
The system SHALL, when updating a row's reps and/or weight, reject the operation if the Routine is archived, leaving the row unchanged; otherwise it SHALL replace that row's reps and/or weight in place, persist the updated Routine list via `StorageService`, and notify listeners.

#### Scenario: Update a row's reps or weight on an active Routine
- **WHEN** `WorkoutRepository.updatePlannedExerciseRow` is called with the id of an active Routine, one of its Planned Exercise ids, a row index, and a new reps and/or weight value
- **THEN** that row SHALL be replaced in place with the new value(s)

#### Scenario: Updating a row on an archived Routine is rejected
- **WHEN** `WorkoutRepository.updatePlannedExerciseRow` is called with the id of an archived Routine
- **THEN** the row SHALL remain unchanged and nothing SHALL be persisted

#### Scenario: Updating a row persists before the next frame
- **WHEN** `WorkoutRepository.updatePlannedExerciseRow` successfully updates a row
- **THEN** the updated Routine list SHALL be written to `SharedPreferences` before the next frame

### Requirement: Removing a Planned Exercise row validates the Routine's lock state and persists immediately
The system SHALL, when removing a row from a Planned Exercise, reject the operation if the Routine is archived, leaving the Planned Exercise unchanged; otherwise it SHALL remove that row from the Planned Exercise's row list, persist the updated Routine list via `StorageService`, and notify listeners.

#### Scenario: Remove a row from a Planned Exercise on an active Routine
- **WHEN** `WorkoutRepository.removePlannedExerciseRow` is called with the id of an active Routine, one of its Planned Exercise ids, and a row index
- **THEN** that row SHALL be removed from the Planned Exercise's row list

#### Scenario: Removing a row on an archived Routine is rejected
- **WHEN** `WorkoutRepository.removePlannedExerciseRow` is called with the id of an archived Routine
- **THEN** the Planned Exercise's row list SHALL remain unchanged and nothing SHALL be persisted

#### Scenario: Removing a row persists before the next frame
- **WHEN** `WorkoutRepository.removePlannedExerciseRow` successfully removes a row
- **THEN** the updated Routine list SHALL be written to `SharedPreferences` before the next frame
