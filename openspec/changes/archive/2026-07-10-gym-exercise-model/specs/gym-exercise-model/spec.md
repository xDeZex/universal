## ADDED Requirements

### Requirement: Exercise construction and serialization
The system SHALL represent an Exercise as an immutable value with a required `id` (String) and `name` (String), serializable to and from JSON.

#### Scenario: Construct and round-trip through JSON
- **WHEN** an Exercise is constructed with an id and a name, converted via `toJson`, and reconstructed via `fromJson`
- **THEN** the reconstructed Exercise SHALL have the same id and name as the original

#### Scenario: fromJson rejects a map missing required fields
- **WHEN** `Exercise.fromJson` is called with a JSON map missing the `id` or `name` key
- **THEN** it SHALL throw rather than silently constructing a partial Exercise

### Requirement: Exercise id is stable identity, independent of name
The system SHALL keep an Exercise's `id` immutable after construction; only `name` SHALL be changeable via `copyWith`, and `copyWith` SHALL provide no way to alter `id`.

#### Scenario: copyWith changes name while preserving id
- **WHEN** `copyWith(name: <new name>)` is called on an Exercise
- **THEN** the returned Exercise SHALL retain the original `id` and reflect the updated `name`

#### Scenario: copyWith with no arguments returns an unchanged Exercise
- **WHEN** `copyWith` is called with no arguments
- **THEN** the returned Exercise SHALL have the same `id` and `name` as the original, leaving both fields unchanged
