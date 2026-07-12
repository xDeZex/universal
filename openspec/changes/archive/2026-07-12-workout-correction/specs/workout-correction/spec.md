## ADDED Requirements

### Requirement: Active Workout screen allows editing a Set's weight, unit, and reps
The system SHALL open a dialog, pre-filled with the Set's current weight, unit, and reps, when the user taps a logged Set. Submitting valid values SHALL update the Set in place, leaving its `loggedAt` timestamp unchanged. The same weight/reps rules that apply when adding a Set apply here: weight is any decimal number including zero and negative, reps is a positive whole number.

#### Scenario: Edit a Set with valid values
- **WHEN** the user taps a logged Set, changes its weight and/or reps to valid values, and submits
- **THEN** the Set SHALL be updated with the new weight/unit/reps, and its `loggedAt` SHALL remain unchanged

#### Scenario: Submit invalid values while editing
- **WHEN** the user submits a non-numeric weight or a reps count that is not a positive whole number from the edit dialog
- **THEN** the system SHALL reject the submission and the Set SHALL remain unchanged

#### Scenario: Editing a Set is available on a Locked Workout
- **WHEN** the user taps a logged Set belonging to a Locked Workout
- **THEN** the edit dialog SHALL open and behave identically to editing a Set on an in-progress Workout

### Requirement: Deleting a Set requires confirmation
The system SHALL provide a Delete action inside the Set edit dialog. Choosing Delete SHALL show a confirmation dialog before removing the Set; declining the confirmation SHALL leave the Set unchanged. Deleting a Set SHALL NOT delete its Exercise Entry, even if it was the Entry's last remaining Set.

#### Scenario: Confirm deletion removes the Set
- **WHEN** the user chooses Delete on a Set's edit dialog and confirms the deletion
- **THEN** the Set SHALL be removed from its Exercise Entry

#### Scenario: Cancel confirmation leaves the Set unchanged
- **WHEN** the user chooses Delete on a Set's edit dialog and then cancels the confirmation
- **THEN** the Set SHALL remain unchanged and no deletion SHALL occur

#### Scenario: Deleting the last Set in an Exercise Entry leaves the Entry listed
- **WHEN** the user deletes the only remaining Set under an Exercise Entry
- **THEN** the Exercise Entry SHALL remain listed with zero Sets, rather than being removed automatically

#### Scenario: Deleting a Set is available on a Locked Workout
- **WHEN** the user deletes a Set belonging to a Locked Workout
- **THEN** the deletion SHALL succeed identically to deleting a Set on an in-progress Workout

### Requirement: Deleting an Exercise Entry requires confirmation and cascades to its Sets
The system SHALL provide a delete icon next to each Exercise Entry's name header. Tapping it SHALL show a confirmation dialog before removing the Exercise Entry; declining the confirmation SHALL leave the Exercise Entry and its Sets unchanged. Confirming SHALL remove the Exercise Entry and every Set logged under it.

#### Scenario: Confirm deletion removes the Exercise Entry and its Sets
- **WHEN** the user taps an Exercise Entry's delete icon and confirms the deletion
- **THEN** the Exercise Entry and all of its Sets SHALL be removed from the Workout

#### Scenario: Cancel confirmation leaves the Exercise Entry unchanged
- **WHEN** the user taps an Exercise Entry's delete icon and then cancels the confirmation
- **THEN** the Exercise Entry and its Sets SHALL remain unchanged and no deletion SHALL occur

#### Scenario: Deleting an Exercise Entry is available on a Locked Workout
- **WHEN** the user deletes an Exercise Entry belonging to a Locked Workout
- **THEN** the deletion SHALL succeed identically to deleting an Exercise Entry on an in-progress Workout

#### Scenario: A Locked Workout can be emptied entirely
- **WHEN** the user deletes every Exercise Entry (and therefore every Set) from a Locked Workout
- **THEN** the Workout SHALL remain Locked with zero Exercise Entries, with no guard preventing the deletion
