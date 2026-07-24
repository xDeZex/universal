# workout-lifecycle Specification

## Purpose
TBD - created by archiving change start-workout-from-routine. Update Purpose after archive.
## Requirements
### Requirement: Workout, ExerciseEntry, and Set construction and serialization
The system SHALL represent a Workout as an immutable value with a required `id` (String), `startTime` (DateTime), nullable `endTime` (DateTime), nullable `routineId` (String), and a list of ExerciseEntries; an ExerciseEntry as an immutable value with a required `id` (String), `exerciseId` (String), a list of Sets, and a nullable `targets` field (a list of `PlannedExerciseRow`, the type already used by a Routine's Planned Exercise rows) recording the target rows this entry started with, `null` when the entry was not pre-filled from a Routine; and a Set as an immutable value with a required `id` (String), `weight` (num), `unit` (kg or lbs), `reps` (int), and `loggedAt` (DateTime). All three SHALL be serializable to and from JSON and expose `copyWith`.

#### Scenario: Construct and round-trip a Workout through JSON
- **WHEN** a Workout with a `routineId`, nested ExerciseEntries (including one with a non-null `targets` list), and Sets is constructed, converted via `toJson`, and reconstructed via `fromJson`
- **THEN** the reconstructed Workout SHALL have the same id, startTime, endTime, routineId, and nested ExerciseEntries/Sets — including each Set's `unit` and each ExerciseEntry's `targets` — as the original

#### Scenario: fromJson rejects a map missing required fields
- **WHEN** `Workout.fromJson`, `ExerciseEntry.fromJson`, or `Set.fromJson` is called with a JSON map missing a required key, including `unit`
- **THEN** it SHALL throw rather than silently constructing a partial value

#### Scenario: A Workout started without a Routine has a null routineId
- **WHEN** a Workout is constructed without specifying a `routineId`
- **THEN** its `routineId` SHALL be `null`, and it SHALL round-trip through JSON as `null` rather than an absent or default value

#### Scenario: An ExerciseEntry not pre-filled from a Routine has null targets
- **WHEN** an ExerciseEntry is constructed without specifying `targets` (e.g. added manually via the active Workout screen's Exercise Entry field)
- **THEN** its `targets` SHALL be `null`, and it SHALL round-trip through JSON as `null` rather than an absent or default value

### Requirement: A Workout's routineId is set once at creation and immutable thereafter
The system SHALL allow `routineId` to be provided only when a Workout is started (via `startWorkout`), and SHALL provide no way to change it afterward.

#### Scenario: Start a Workout from a Routine
- **WHEN** the user starts a Workout specifying a `routineId`
- **THEN** the created Workout SHALL carry that `routineId`

#### Scenario: Start a Workout without a Routine
- **WHEN** the user starts a Workout without specifying a `routineId`
- **THEN** the created Workout's `routineId` SHALL be `null`

#### Scenario: copyWith provides no way to alter routineId
- **WHEN** `copyWith` is called on an existing Workout
- **THEN** the returned Workout SHALL retain the original `routineId` unchanged, with no parameter available to override it

### Requirement: A Workout is in progress until endTime is set
The system SHALL treat a Workout as in progress from construction until `endTime` is non-null, with no separate status field.

#### Scenario: Newly started Workout is in progress
- **WHEN** a Workout is constructed with a `startTime` and no `endTime`
- **THEN** it SHALL be considered in progress

#### Scenario: Workout with endTime is not in progress
- **WHEN** a Workout has a non-null `endTime`
- **THEN** it SHALL be considered finished, not in progress

### Requirement: Only one Workout may be in progress at a time
The system SHALL prevent starting a new Workout while another Workout is already in progress.

#### Scenario: Start a Workout with none in progress
- **WHEN** the user starts a new Workout and no Workout in the stored list is in progress
- **THEN** a new in-progress Workout SHALL be created and added to the list

#### Scenario: Start a Workout while one is already in progress
- **WHEN** the user attempts to start a new Workout while an in-progress Workout already exists
- **THEN** the system SHALL reject the attempt and SHALL NOT create a second Workout

### Requirement: Finishing a Workout requires at least one logged Set and derives endTime from it
The system SHALL only allow finishing a Workout that has at least one logged Set across its ExerciseEntries, and SHALL set `endTime` to the `loggedAt` timestamp of the most recently logged Set — not the current time when Finish is invoked.

#### Scenario: Finish a Workout with logged Sets
- **WHEN** the user finishes a Workout that has one or more logged Sets
- **THEN** the Workout's `endTime` SHALL be set to the `loggedAt` value of its most recently logged Set, and the Workout SHALL become finished

#### Scenario: Finish a Workout with zero logged Sets is rejected
- **WHEN** the user attempts to finish an in-progress Workout that has no logged Sets
- **THEN** the system SHALL reject the attempt and the Workout SHALL remain in progress with `endTime` unset

### Requirement: Discarding a Workout deletes it and everything logged within it
The system SHALL allow discarding an in-progress Workout, removing it and all of its ExerciseEntries and Sets entirely.

#### Scenario: Discard an in-progress Workout
- **WHEN** the user discards an in-progress Workout
- **THEN** the Workout SHALL be removed from the stored list along with all of its ExerciseEntries and Sets

#### Scenario: Discard is unavailable on a finished Workout
- **WHEN** the user attempts to discard a Workout whose `endTime` is already set
- **THEN** the system SHALL reject the attempt and leave the finished Workout unchanged

### Requirement: Adding an Exercise Entry resolves the Exercise by case-insensitive exact name match
The system SHALL, when adding an Exercise Entry by typed name, reuse an existing Exercise whose name matches case-insensitively and exactly, or create a new Exercise with that name if no match exists.

#### Scenario: Typed name matches an existing Exercise
- **WHEN** the user adds an Exercise Entry by typing a name that matches an existing Exercise's name case-insensitively (e.g. "bench press" matching "Bench Press")
- **THEN** the new ExerciseEntry SHALL reference the existing Exercise's id, and no new Exercise SHALL be created

#### Scenario: Typed name has no match
- **WHEN** the user adds an Exercise Entry by typing a name with no case-insensitive exact match among existing Exercises
- **THEN** a new Exercise SHALL be created with that name, and the new ExerciseEntry SHALL reference its id

#### Scenario: Typed name is empty
- **WHEN** the user attempts to add an Exercise Entry with an empty or whitespace-only name
- **THEN** the system SHALL reject the attempt and SHALL NOT create an Exercise or ExerciseEntry

### Requirement: Starting a Workout from a Routine pre-fills Exercise Entries from its Planned Exercises
The system SHALL, when `startWorkout` is called with a `routineId`, create one `ExerciseEntry` per Planned Exercise on that Routine, in the same order, referencing the same `exerciseId`, with an empty `sets` list (no placeholder Sets) and a `targets` list that is a one-time copy of that Planned Exercise's rows at the moment the Workout is created — not a live reference, so later edits to the Routine's Planned Exercises SHALL NOT affect an already-started Workout's targets. The system SHALL reject the attempt (create no Workout) if the given `routineId` refers to an archived Routine.

#### Scenario: Start a Workout from a Routine with Planned Exercises
- **WHEN** the user starts a Workout from an active Routine with two Planned Exercises, the first having two rows and the second having one row
- **THEN** the created Workout SHALL have two ExerciseEntries in the same order, referencing the same Exercises, each with an empty `sets` list and a `targets` list matching its source Planned Exercise's rows

#### Scenario: Editing the Routine afterward does not affect an already-started Workout
- **WHEN** a Workout has been started from a Routine, and a Planned Exercise row it copied into a `targets` snapshot is subsequently edited or deleted on the Routine
- **THEN** the already-started Workout's ExerciseEntry `targets` SHALL remain unchanged, reflecting the Planned Exercise's rows as they were at the moment the Workout was created

#### Scenario: Starting a Workout from an archived Routine is rejected
- **WHEN** the user attempts to start a Workout specifying the `routineId` of an archived Routine
- **THEN** the system SHALL reject the attempt and SHALL NOT create a new Workout

