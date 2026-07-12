## REMOVED Requirements

### Requirement: Active Workout screen renders read-only for a finished Workout
**Reason**: "Read-only" is no longer accurate — a finished (Locked) Workout now allows editing and deleting its Sets and Exercise Entries (see the `workout-correction` capability). Only the add-side controls and Discard/Finish stay hidden, which is now its own narrower requirement.
**Migration**: See "Active Workout screen hides add and Discard/Finish controls on a Locked Workout" in this capability, and the `workout-correction` capability for what remains available on a Locked Workout.

## ADDED Requirements

### Requirement: Active Workout screen hides add and Discard/Finish controls on a Locked Workout
The system SHALL hide the add-Exercise-Entry field, each Exercise Entry's add-Set controls, and the Discard/Finish buttons on the Active Workout screen whenever the given Workout is Locked, deriving this purely from the Workout's own `endTime` with no separate mode parameter. This is independent of whether the Workout's existing Sets and Exercise Entries can be edited or deleted (see `workout-correction`).

#### Scenario: Locked Workout hides add and action controls
- **WHEN** the Active Workout screen is opened for a Locked Workout (non-null `endTime`)
- **THEN** the add-Exercise-Entry field, add-Set controls, and Discard/Finish buttons SHALL NOT be shown

#### Scenario: In-progress Workout keeps add and action controls
- **WHEN** the Active Workout screen is opened for a Workout with a null `endTime`
- **THEN** the add-Exercise-Entry field, add-Set controls, and Discard/Finish buttons SHALL be shown as before

## MODIFIED Requirements

### Requirement: Finished Workout's Sets display their logged time
The system SHALL show each Set's `loggedAt` time alongside its reps and weight when the Active Workout screen is rendering a Locked Workout, while the in-progress display format remains "<reps> reps at <weight> <unit>" unchanged. This display rule is independent of the Set also being tappable to edit or delete on a Locked Workout.

#### Scenario: Set display includes logged time for a Locked Workout
- **WHEN** the Active Workout screen renders a Set belonging to a Locked Workout
- **THEN** the Set SHALL be displayed as "<reps> reps at <weight> <unit> — <loggedAt time>"

#### Scenario: In-progress Set display is unchanged
- **WHEN** the Active Workout screen renders a Set for an in-progress Workout
- **THEN** the Set SHALL be displayed as "<reps> reps at <weight> <unit>" with no timestamp
