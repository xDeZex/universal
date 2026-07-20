## MODIFIED Requirements

### Requirement: PlannedExerciseRow construction and serialization
The system SHALL represent a PlannedExerciseRow as an immutable value with a required `reps` (RepsTarget) and a required `weight` (PlannedWeight) — there is no "no weight target" state. It SHALL be serializable to and from JSON and expose `copyWith`. Loading a persisted row whose JSON `weight` is missing or `null` SHALL default it to `PlannedWeight(value: 0, unit: WeightUnit.kg)` rather than throwing or leaving weight null.

#### Scenario: Construct a row with fixed reps and a weight, round-trip through JSON
- **WHEN** a PlannedExerciseRow with `FixedReps` and a `PlannedWeight` is constructed, converted via `toJson`, and reconstructed via `fromJson`
- **THEN** the reconstructed row SHALL have the same reps and the same weight value and unit

#### Scenario: Construct a row with ranged reps and a weight, round-trip through JSON
- **WHEN** a PlannedExerciseRow with `RangeReps` and a `PlannedWeight` is constructed, converted via `toJson`, and reconstructed via `fromJson`
- **THEN** the reconstructed row SHALL have the same reps range and the same weight value and unit

#### Scenario: fromJson migrates a missing or null weight to 0 kg
- **WHEN** `PlannedExerciseRow.fromJson` is called with a JSON map whose `weight` key is `null` or absent (data persisted before weight became required)
- **THEN** the reconstructed row SHALL have a weight of `0 kg` rather than throwing or leaving weight null

#### Scenario: fromJson rejects a map missing the reps field
- **WHEN** `PlannedExerciseRow.fromJson` is called with a JSON map missing the `reps` key
- **THEN** it SHALL throw rather than silently constructing a partial row
