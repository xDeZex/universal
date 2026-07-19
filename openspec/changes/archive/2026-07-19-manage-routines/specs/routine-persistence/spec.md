## ADDED Requirements

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
