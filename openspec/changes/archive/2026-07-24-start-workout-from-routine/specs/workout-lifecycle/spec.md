## MODIFIED Requirements

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

## ADDED Requirements

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
