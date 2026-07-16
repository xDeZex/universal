## MODIFIED Requirements

### Requirement: Workout, ExerciseEntry, and Set construction and serialization
The system SHALL represent a Workout as an immutable value with a required `id` (String), `startTime` (DateTime), nullable `endTime` (DateTime), nullable `routineId` (String), and a list of ExerciseEntries; an ExerciseEntry as an immutable value with a required `id` (String), `exerciseId` (String), and a list of Sets; and a Set as an immutable value with a required `id` (String), `weight` (num), `unit` (kg or lbs), `reps` (int), and `loggedAt` (DateTime). All three SHALL be serializable to and from JSON and expose `copyWith`.

#### Scenario: Construct and round-trip a Workout through JSON
- **WHEN** a Workout with a `routineId`, nested ExerciseEntries, and Sets is constructed, converted via `toJson`, and reconstructed via `fromJson`
- **THEN** the reconstructed Workout SHALL have the same id, startTime, endTime, routineId, and nested ExerciseEntries/Sets — including each Set's `unit` — as the original

#### Scenario: fromJson rejects a map missing required fields
- **WHEN** `Workout.fromJson`, `ExerciseEntry.fromJson`, or `Set.fromJson` is called with a JSON map missing a required key, including `unit`
- **THEN** it SHALL throw rather than silently constructing a partial value

#### Scenario: A Workout started without a Routine has a null routineId
- **WHEN** a Workout is constructed without specifying a `routineId`
- **THEN** its `routineId` SHALL be `null`, and it SHALL round-trip through JSON as `null` rather than an absent or default value

## ADDED Requirements

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
