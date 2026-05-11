## ADDED Requirements

### Requirement: Item changes persist immediately
The app SHALL save all checklist item mutations to persistent storage at the time they occur, without requiring the user to navigate away from the checklist screen.

#### Scenario: Toggle item while checklist is open
- **WHEN** the user checks or unchecks an item in `ChecklistScreen`
- **THEN** the updated checklist SHALL be written to `SharedPreferences` before the next frame

#### Scenario: Add item while checklist is open
- **WHEN** the user adds a new item via the add dialog
- **THEN** the updated checklist SHALL be written to `SharedPreferences` before the next frame

#### Scenario: Delete item while checklist is open
- **WHEN** the user deletes an item from the checklist
- **THEN** the updated checklist SHALL be written to `SharedPreferences` before the next frame

#### Scenario: Reorder items while checklist is open
- **WHEN** the user drags an item to a new position
- **THEN** the updated checklist SHALL be written to `SharedPreferences` before the next frame

#### Scenario: App killed mid-session
- **WHEN** the app is force-closed while `ChecklistScreen` is visible
- **THEN** all item changes made prior to the kill SHALL be present when the app is next launched
