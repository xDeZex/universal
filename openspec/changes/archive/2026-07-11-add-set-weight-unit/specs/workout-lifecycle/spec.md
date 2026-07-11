## MODIFIED Requirements

### Requirement: Workout, ExerciseEntry, and Set construction and serialization
The system SHALL represent a Workout as an immutable value with a required `id` (String), `startTime` (DateTime), nullable `endTime` (DateTime), and a list of ExerciseEntries; an ExerciseEntry as an immutable value with a required `id` (String), `exerciseId` (String), and a list of Sets; and a Set as an immutable value with a required `id` (String), `weight` (num), `unit` (kg or lbs), `reps` (int), and `loggedAt` (DateTime). All three SHALL be serializable to and from JSON and expose `copyWith`.

#### Scenario: Construct and round-trip a Workout through JSON
- **WHEN** a Workout with nested ExerciseEntries and Sets is constructed, converted via `toJson`, and reconstructed via `fromJson`
- **THEN** the reconstructed Workout SHALL have the same id, startTime, endTime, and nested ExerciseEntries/Sets — including each Set's `unit` — as the original

#### Scenario: fromJson rejects a map missing required fields
- **WHEN** `Workout.fromJson`, `ExerciseEntry.fromJson`, or `Set.fromJson` is called with a JSON map missing a required key, including `unit`
- **THEN** it SHALL throw rather than silently constructing a partial value
