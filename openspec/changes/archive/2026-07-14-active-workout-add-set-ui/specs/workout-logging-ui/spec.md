## MODIFIED Requirements

### Requirement: Active Workout screen allows adding a Set to the selected Exercise Entry
The system SHALL provide a single fixed bottom bar containing weight, unit (kg or lbs), and reps controls for logging a Set against whichever Exercise Entry is currently selected, stamped with the current time as `loggedAt` at the moment it is added. Weight and reps SHALL be entered via +/- steppers starting from zero (no free-text entry): the weight stepper SHALL step by 2.5 when the unit is kg and by 5 when the unit is lbs and MAY go negative (to log assisted variations, e.g. an assisted pull-up machine); the reps stepper SHALL step by 1 and SHALL NOT go below zero. The unit input SHALL default to the unit most recently selected for the selected Exercise Entry in the current session, or to kg if no Set has yet been logged against it. Each logged Set SHALL be displayed as a numbered table row showing its weight (with unit) and reps in separate columns (e.g. set "1", weight "135 lbs", reps "8").

#### Scenario: Add a Set with valid stepper values
- **WHEN** an Exercise Entry is selected, the user adjusts the weight and reps steppers to positive values, and taps Add Set
- **THEN** a new Set SHALL be added to the selected Exercise Entry with `loggedAt` set to the current time, and SHALL be displayed as a numbered row with its weight and reps in separate columns

#### Scenario: Add Set is disabled at zero reps
- **WHEN** the reps stepper for the selected Exercise Entry is at zero
- **THEN** the Add Set button SHALL be disabled and no Set SHALL be added

#### Scenario: Unit selection defaults to kg on a freshly added Exercise Entry
- **WHEN** the user logs the first Set against an Exercise Entry that has no Sets yet
- **THEN** the unit input SHALL default to kg and the weight stepper SHALL step by 2.5

#### Scenario: Unit selection is sticky within an Exercise Entry
- **WHEN** the user logs a Set against an Exercise Entry using lbs, then selects that same Exercise Entry again and logs another Set
- **THEN** the unit input SHALL default to lbs and the weight stepper SHALL step by 5, without the user re-selecting the unit

#### Scenario: Weight stepper allows negative values for assisted exercises
- **WHEN** the user decrements the weight stepper below zero
- **THEN** the weight stepper SHALL show a negative value and Add Set SHALL remain usable (subject to reps being greater than zero)

### Requirement: Finished Workout's Sets display their logged time
The system SHALL show each Set's `loggedAt` time in its own column when the Active Workout screen is rendering a Locked Workout, alongside the Set-number badge, weight, and reps columns present for every Workout. This display rule is independent of the Set also being tappable to edit or delete on a Locked Workout.

#### Scenario: Set display includes a time column for a Locked Workout
- **WHEN** the Active Workout screen renders a Set belonging to a Locked Workout
- **THEN** the Set's row SHALL include its logged time in a dedicated column

#### Scenario: In-progress Set display has no time column
- **WHEN** the Active Workout screen renders a Set for an in-progress Workout
- **THEN** the Set's row SHALL NOT show a logged-time column

### Requirement: Active Workout screen hides add and Discard/Finish controls on a Locked Workout
The system SHALL hide the add-Exercise-Entry field, the add-Set bottom bar, and the Discard/Finish buttons on the Active Workout screen whenever the given Workout is Locked, deriving this purely from the Workout's own `endTime` with no separate mode parameter. This is independent of whether the Workout's existing Sets and Exercise Entries can be edited or deleted (see `workout-correction`).

#### Scenario: Locked Workout hides add and action controls
- **WHEN** the Active Workout screen is opened for a Locked Workout (non-null `endTime`)
- **THEN** the add-Exercise-Entry field, the add-Set bottom bar, and the Discard/Finish buttons SHALL NOT be shown

#### Scenario: In-progress Workout keeps add and action controls
- **WHEN** the Active Workout screen is opened for a Workout with a null `endTime`
- **THEN** the add-Exercise-Entry field, the add-Set bottom bar, and the Discard/Finish buttons SHALL be shown as before

## ADDED Requirements

### Requirement: Exercise Entry selection targets the add-Set bar
The system SHALL let the user select an Exercise Entry as the target of the add-Set bottom bar by tapping it, defaulting to the most-recently-added Exercise Entry, and SHALL hide the bar entirely when no Exercise Entry is selected. Switching the selected Exercise Entry SHALL reset the weight and reps steppers to zero.

#### Scenario: Default selection is the most-recently-added Exercise Entry
- **WHEN** a new Exercise Entry is added to the Workout
- **THEN** it SHALL become the selected Exercise Entry, and the add-Set bar SHALL target it

#### Scenario: Selecting a different Exercise Entry retargets the bar
- **WHEN** the user taps an unselected Exercise Entry
- **THEN** that Exercise Entry SHALL become selected, the previously selected Exercise Entry SHALL become unselected, and the add-Set bar's weight and reps steppers SHALL reset to zero

#### Scenario: Add-Set bar hidden with no Exercise Entries
- **WHEN** the active Workout has zero Exercise Entries
- **THEN** no Exercise Entry SHALL be selected and the add-Set bar SHALL NOT be shown

### Requirement: Deleting the selected Exercise Entry clears the selection
The system SHALL clear the current selection when the selected Exercise Entry is deleted, hiding the add-Set bar, rather than selecting a different remaining Exercise Entry.

#### Scenario: Deleting the selected Exercise Entry hides the bar
- **WHEN** the user deletes the currently selected Exercise Entry
- **THEN** no Exercise Entry SHALL be selected afterward, and the add-Set bar SHALL NOT be shown, even if other Exercise Entries remain

#### Scenario: Deleting an unselected Exercise Entry leaves the selection unchanged
- **WHEN** the user deletes an Exercise Entry other than the currently selected one
- **THEN** the currently selected Exercise Entry SHALL remain selected, and the add-Set bar SHALL continue to target it

### Requirement: Exercise Entries render as flat rows with a selected-state tint
The system SHALL render each Exercise Entry as a flat row group (a bold header row, a column-header row labeling Set/Weight/Reps once Sets exist, then one numbered table row per Set — each preceded by a thin divider for readability — with a further divider before the next Exercise Entry) rather than as an elevated Card. Each Set row SHALL show a small numbered badge (its position within the Exercise Entry), its weight (with unit) and reps in their own columns, with no other per-row status indicator (e.g. no checkmark). On a Locked Workout, an additional column SHALL show each Set's logged time. On an in-progress Workout, the selected Exercise Entry's rows SHALL show a background tint that unselected Exercise Entries' rows do not have, and tapping an Exercise Entry's rows SHALL be the mechanism for selecting it.

#### Scenario: Selected Exercise Entry is visually tinted
- **WHEN** an Exercise Entry is selected on an in-progress Workout
- **THEN** that Exercise Entry's header row and Set rows SHALL show a background tint, and no other Exercise Entry's rows SHALL be tinted

#### Scenario: Locked Workout rows are not selectable or tintable
- **WHEN** the user taps an Exercise Entry's rows on a Locked Workout
- **THEN** no Exercise Entry SHALL become selected and no row SHALL show the selected-state tint
