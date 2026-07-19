## Purpose

Defines when the Routine list is loaded from and saved to persistent storage, and how Routine creation is validated.
## Requirements
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

### Requirement: Renaming a Routine validates the name and persists immediately
The system SHALL, when renaming a Routine by id, reject a blank or case-insensitively duplicate name (against every other Routine) by leaving the Routine list unchanged; otherwise it SHALL update that Routine's name, persist the updated list via `StorageService`, and notify listeners.

#### Scenario: Rename to a unique name
- **WHEN** `WorkoutRepository.renameRoutine` is called with a non-blank name that does not match any other Routine's name case-insensitively
- **THEN** the target Routine's name SHALL be updated, the change SHALL be persisted, and listeners SHALL be notified

#### Scenario: Rename to a blank name is rejected
- **WHEN** `WorkoutRepository.renameRoutine` is called with a name that is empty or only whitespace
- **THEN** the Routine list SHALL be unchanged and nothing SHALL be persisted

#### Scenario: Rename to a colliding name is rejected
- **WHEN** `WorkoutRepository.renameRoutine` is called with a name matching another existing Routine's name case-insensitively
- **THEN** the Routine list SHALL be unchanged and nothing SHALL be persisted

#### Scenario: Rename persists before the next frame
- **WHEN** `WorkoutRepository.renameRoutine` successfully renames a Routine
- **THEN** the updated Routine list SHALL be written to `SharedPreferences` before the next frame

### Requirement: Archiving a Routine sets archivedAt and persists immediately
The system SHALL, when archiving a Routine by id, set its `archivedAt` to the current time, persist the updated list via `StorageService`, and notify listeners.

#### Scenario: Archive an active Routine
- **WHEN** `WorkoutRepository.archiveRoutine` is called with the id of an active Routine
- **THEN** that Routine's `archivedAt` SHALL become non-null, the change SHALL be persisted, and listeners SHALL be notified

#### Scenario: Archiving persists before the next frame
- **WHEN** `WorkoutRepository.archiveRoutine` successfully archives a Routine
- **THEN** the updated Routine list SHALL be written to `SharedPreferences` before the next frame

### Requirement: Unarchiving a Routine clears archivedAt and persists immediately
The system SHALL, when unarchiving a Routine by id, clear its `archivedAt` back to `null`, persist the updated list via `StorageService`, and notify listeners.

#### Scenario: Unarchive an archived Routine
- **WHEN** `WorkoutRepository.unarchiveRoutine` is called with the id of an archived Routine
- **THEN** that Routine's `archivedAt` SHALL become `null`, the change SHALL be persisted, and listeners SHALL be notified

#### Scenario: Unarchiving persists before the next frame
- **WHEN** `WorkoutRepository.unarchiveRoutine` successfully unarchives a Routine
- **THEN** the updated Routine list SHALL be written to `SharedPreferences` before the next frame

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

