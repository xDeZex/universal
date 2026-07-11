### Requirement: Workout, ExerciseEntry, and Set construction and serialization
The system SHALL represent a Workout as an immutable value with a required `id` (String), `startTime` (DateTime), nullable `endTime` (DateTime), and a list of ExerciseEntries; an ExerciseEntry as an immutable value with a required `id` (String), `exerciseId` (String), and a list of Sets; and a Set as an immutable value with a required `id` (String), `weight` (num), `unit` (kg or lbs), `reps` (int), and `loggedAt` (DateTime). All three SHALL be serializable to and from JSON and expose `copyWith`.

#### Scenario: Construct and round-trip a Workout through JSON
- **WHEN** a Workout with nested ExerciseEntries and Sets is constructed, converted via `toJson`, and reconstructed via `fromJson`
- **THEN** the reconstructed Workout SHALL have the same id, startTime, endTime, and nested ExerciseEntries/Sets — including each Set's `unit` — as the original

#### Scenario: fromJson rejects a map missing required fields
- **WHEN** `Workout.fromJson`, `ExerciseEntry.fromJson`, or `Set.fromJson` is called with a JSON map missing a required key, including `unit`
- **THEN** it SHALL throw rather than silently constructing a partial value

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
