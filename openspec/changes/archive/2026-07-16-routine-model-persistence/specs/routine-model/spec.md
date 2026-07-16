## ADDED Requirements

### Requirement: Routine construction and serialization
The system SHALL represent a Routine as an immutable value with a required `id` (String), `name` (String), an ordered list of PlannedExercises (which may be empty), and a nullable `archivedAt` (DateTime). It SHALL be serializable to and from JSON and expose `copyWith`.

#### Scenario: Construct and round-trip through JSON
- **WHEN** a Routine with a name, nested PlannedExercises, and no `archivedAt` is constructed, converted via `toJson`, and reconstructed via `fromJson`
- **THEN** the reconstructed Routine SHALL have the same id, name, PlannedExercises, and `archivedAt` as the original

#### Scenario: fromJson rejects a map missing required fields
- **WHEN** `Routine.fromJson` is called with a JSON map missing the `id` or `name` key
- **THEN** it SHALL throw rather than silently constructing a partial Routine

### Requirement: Routine name uniqueness is validated case-insensitively
The system SHALL reject a Routine rename to a blank name or to a name that collides case-insensitively with another Routine's name, mirroring Exercise's `validateRename` (ADR-0015). A Routine renamed to its own current name SHALL NOT be treated as a collision.

#### Scenario: Rename to an available name succeeds
- **WHEN** `validateRename` is called with a non-blank name that does not match any other Routine's name case-insensitively
- **THEN** it SHALL return no error

#### Scenario: Rename to a blank name is rejected
- **WHEN** `validateRename` is called with a name that is empty or only whitespace
- **THEN** it SHALL return a blank-name error

#### Scenario: Rename to a name colliding with another Routine is rejected
- **WHEN** `validateRename` is called with a name matching another Routine's name case-insensitively
- **THEN** it SHALL return a duplicate-name error

### Requirement: A Routine is archived via archivedAt and never hard-deleted
The system SHALL represent Routine archival as a nullable `archivedAt` timestamp: `null` means active, a non-null value means archived. Clearing `archivedAt` SHALL unarchive the Routine. No operation SHALL remove a Routine outright.

#### Scenario: Archiving sets archivedAt
- **WHEN** a Routine's `archivedAt` is set via `copyWith`
- **THEN** the Routine SHALL be considered archived

#### Scenario: Unarchiving clears archivedAt
- **WHEN** an archived Routine's `archivedAt` is cleared via `copyWith`
- **THEN** the Routine SHALL be considered active again

### Requirement: An archived Routine is locked
The system SHALL treat a Routine with a non-null `archivedAt` as locked: its Planned Exercises SHALL NOT be added, edited, or removed, and it SHALL NOT be used to start a new Workout, until it is unarchived.

#### Scenario: Active Routine is not locked
- **WHEN** a Routine has `archivedAt == null`
- **THEN** it SHALL report itself as not locked

#### Scenario: Archived Routine is locked
- **WHEN** a Routine has a non-null `archivedAt`
- **THEN** it SHALL report itself as locked

### Requirement: PlannedExercise construction and serialization
The system SHALL represent a PlannedExercise as an immutable value with a required `id` (String), `exerciseId` (String), and an ordered list of PlannedExerciseRows (which may be empty). It SHALL be serializable to and from JSON and expose `copyWith`. Row count IS the target-sets count — there is no separate count field.

#### Scenario: Construct and round-trip through JSON
- **WHEN** a PlannedExercise with an exerciseId and nested rows is constructed, converted via `toJson`, and reconstructed via `fromJson`
- **THEN** the reconstructed PlannedExercise SHALL have the same id, exerciseId, and rows as the original

#### Scenario: fromJson rejects a map missing required fields
- **WHEN** `PlannedExercise.fromJson` is called with a JSON map missing the `id` or `exerciseId` key
- **THEN** it SHALL throw rather than silently constructing a partial PlannedExercise

#### Scenario: A PlannedExercise with zero rows is a valid state
- **WHEN** a PlannedExercise is constructed with an empty row list and round-tripped through JSON
- **THEN** the reconstructed PlannedExercise SHALL have an empty row list, not an error

### Requirement: PlannedExerciseRow construction and serialization
The system SHALL represent a PlannedExerciseRow as an immutable value with a required `reps` (RepsTarget) and a nullable `weight` (PlannedWeight). It SHALL be serializable to and from JSON and expose `copyWith`.

#### Scenario: Construct a row with fixed reps and no weight, round-trip through JSON
- **WHEN** a PlannedExerciseRow with `FixedReps` and `weight: null` is constructed, converted via `toJson`, and reconstructed via `fromJson`
- **THEN** the reconstructed row SHALL have the same reps and a `null` weight

#### Scenario: Construct a row with ranged reps and a weight, round-trip through JSON
- **WHEN** a PlannedExerciseRow with `RangeReps` and a non-null `weight` is constructed, converted via `toJson`, and reconstructed via `fromJson`
- **THEN** the reconstructed row SHALL have the same reps range and the same weight value and unit

#### Scenario: fromJson rejects a map missing the reps field
- **WHEN** `PlannedExerciseRow.fromJson` is called with a JSON map missing the `reps` key
- **THEN** it SHALL throw rather than silently constructing a partial row

### Requirement: RepsTarget represents a fixed rep count or a min/max range
The system SHALL represent a Planned Exercise row's target reps as either a fixed integer (`FixedReps`) or a min/max range (`RangeReps`), serialized with a discriminator field so `fromJson` can reconstruct the correct variant.

#### Scenario: FixedReps round-trips through JSON
- **WHEN** a `FixedReps` is constructed, converted via `toJson`, and reconstructed via `fromJson`
- **THEN** the reconstructed value SHALL be a `FixedReps` with the same rep count

#### Scenario: RangeReps round-trips through JSON
- **WHEN** a `RangeReps` is constructed, converted via `toJson`, and reconstructed via `fromJson`
- **THEN** the reconstructed value SHALL be a `RangeReps` with the same min and max

#### Scenario: fromJson rejects an unrecognized discriminator
- **WHEN** `RepsTarget.fromJson` is called with a JSON map whose discriminator field matches neither `FixedReps` nor `RangeReps`
- **THEN** it SHALL throw rather than silently defaulting to either variant

### Requirement: RangeReps rejects an invalid min/max range
The system SHALL treat a range where `min >= max` as invalid, checked via a static validation before construction (mirroring `ExerciseRenameError`'s non-throwing-at-construction shape) rather than at construction time.

#### Scenario: A valid ascending range passes validation
- **WHEN** the range validation is checked with `min < max`
- **THEN** it SHALL return no error

#### Scenario: min equal to or greater than max is rejected
- **WHEN** the range validation is checked with `min >= max`
- **THEN** it SHALL return an invalid-range error

### Requirement: PlannedWeight bundles a value with its unit
The system SHALL represent a Planned Exercise row's target weight as a single value object holding both a numeric `value` and a `WeightUnit`, so the two travel together and a row can never carry one without the other.

#### Scenario: Construct and round-trip through JSON
- **WHEN** a PlannedWeight is constructed with a value and a unit, converted via `toJson`, and reconstructed via `fromJson`
- **THEN** the reconstructed PlannedWeight SHALL have the same value and unit as the original

#### Scenario: fromJson rejects a map missing the unit field
- **WHEN** `PlannedWeight.fromJson` is called with a JSON map missing the `unit` key
- **THEN** it SHALL throw rather than silently constructing a PlannedWeight with a default unit
