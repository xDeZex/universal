### Requirement: Workout home screen exposes a Past Workouts entry point
The system SHALL provide a "Past Workouts" action on the Workout home screen, visible regardless of whether any Workout has been finished, that navigates to the Past Workouts list screen.

#### Scenario: Open Past Workouts from the Workout home screen
- **WHEN** the user taps the Past Workouts action
- **THEN** the app SHALL display the Past Workouts list screen

#### Scenario: Entry point is available with no finished Workouts
- **WHEN** no Workout has ever been finished
- **THEN** the Past Workouts action SHALL still be shown and SHALL open the (empty) Past Workouts list screen

### Requirement: Past Workouts list shows only finished Workouts, most recent first
The system SHALL list every Workout with a non-null `endTime`, sorted by `endTime` descending, and SHALL exclude any in-progress Workout.

#### Scenario: Multiple finished Workouts are ordered by recency
- **WHEN** two or more finished Workouts exist with different `endTime`s
- **THEN** the Past Workouts list SHALL display them ordered from most recent `endTime` to least recent

#### Scenario: An in-progress Workout is excluded
- **WHEN** a Workout is in progress (`endTime == null`) alongside any number of finished Workouts
- **THEN** the in-progress Workout SHALL NOT appear in the Past Workouts list

### Requirement: Past Workouts list row displays an absolute date and an exercise summary
Each row SHALL show the Workout's `endTime` as an absolute date and a comma-joined list of its Exercise Entries' Exercise names (in Exercise Entry order, including entries with zero logged Sets), truncated with an ellipsis if it would overflow the row.

#### Scenario: Row shows date and exercise names
- **WHEN** a finished Workout has Exercise Entries for "Bench Press" and "Squat"
- **THEN** its row SHALL show the Workout's end date and the text "Bench Press, Squat"

#### Scenario: Exercise Entry with zero Sets is still included
- **WHEN** a finished Workout has an Exercise Entry with no logged Sets
- **THEN** that Exercise Entry's name SHALL still appear in the row's exercise summary

#### Scenario: Long exercise summary is truncated
- **WHEN** a finished Workout's joined exercise names exceed the row's available width
- **THEN** the summary SHALL be truncated with an ellipsis rather than wrapping or overflowing the row

### Requirement: Past Workouts list shows an empty state with no finished Workouts
The system SHALL show a centered "No past workouts yet" message in place of the list when there are no finished Workouts.

#### Scenario: No finished Workouts
- **WHEN** no Workout has ever been finished
- **THEN** the Past Workouts list screen SHALL show a centered "No past workouts yet" message and no list rows

#### Scenario: At least one finished Workout
- **WHEN** at least one finished Workout exists
- **THEN** the empty-state message SHALL NOT be shown and the list SHALL show rows instead

### Requirement: Tapping a Past Workout opens its detail view
The system SHALL open the Active Workout screen for the tapped Workout when a row in the Past Workouts list is tapped. Because the Workout is Locked, its add-Exercise-Entry field, add-Set controls, and Discard/Finish buttons SHALL be hidden (per `workout-logging-ui`), but its Sets and Exercise Entries SHALL remain editable and deletable (per `workout-correction`), and any such changes SHALL be persisted, not discarded.

#### Scenario: Tap a row to view details
- **WHEN** the user taps a row in the Past Workouts list
- **THEN** the app SHALL open that Workout's detail view showing its Exercise Entries and Sets, with add and Discard/Finish controls hidden

#### Scenario: Detail view matches the Workout's Exercise Entries exactly
- **WHEN** a Workout has an Exercise Entry with zero logged Sets
- **THEN** the detail view SHALL show that Exercise Entry's name with no Sets listed under it, rather than omitting the entry

#### Scenario: Corrections made from the detail view are persisted
- **WHEN** the user edits or deletes a Set or Exercise Entry from a Past Workout's detail view
- **THEN** the change SHALL be saved to storage, and SHALL still be reflected the next time that Workout's detail view is opened
