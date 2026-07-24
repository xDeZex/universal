## ADDED Requirements

### Requirement: Routine screen exposes a Start Workout / Continue Workout bar
The system SHALL show a bar pinned to the bottom of the Routine screen, structurally similar to the active Workout screen's add-Set bar (a full-width primary button in a padded, tinted container), labeled "Start Workout" when no Workout is in progress or "Continue Workout" when one is — mirroring the Workout home screen's existing button-swap rule exactly. Tapping "Start Workout" starts a new Workout from this Routine and navigates to it; tapping "Continue Workout" navigates to whichever Workout is currently in progress, regardless of which Routine (or none) started it. The bar SHALL NOT be shown at all while the Routine is archived.

#### Scenario: Start Workout from an active Routine with none in progress
- **WHEN** the Routine screen is opened for an active (non-archived) Routine and no Workout is in progress
- **THEN** the bar SHALL read "Start Workout", and tapping it SHALL start a new Workout from this Routine and navigate to the active Workout screen

#### Scenario: Continue Workout regardless of which Routine started it
- **WHEN** the Routine screen is opened for any active Routine while a Workout is already in progress
- **THEN** the bar SHALL read "Continue Workout", and tapping it SHALL navigate to the in-progress Workout even if it was started from a different Routine or from none at all

#### Scenario: Bar is hidden entirely on an archived Routine
- **WHEN** the Routine screen is opened for an archived Routine
- **THEN** the Start Workout / Continue Workout bar SHALL NOT be shown, regardless of whether a Workout is in progress
