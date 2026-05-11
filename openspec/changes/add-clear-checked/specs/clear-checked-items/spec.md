## ADDED Requirements

### Requirement: Bulk remove checked items
The system SHALL provide a way to remove all checked items from the current checklist in a single action.

#### Scenario: Clear checked items
- **WHEN** the user taps the "Clear checked" button
- **THEN** all checked items are removed from the checklist and the change is persisted

#### Scenario: Button hidden when no checked items
- **WHEN** the checklist has no checked items
- **THEN** the "Clear checked" button is not visible

#### Scenario: Button visible when checked items exist
- **WHEN** at least one item is checked
- **THEN** the "Clear checked" button is visible in the toolbar

#### Scenario: Unchecked items preserved
- **WHEN** the user taps the "Clear checked" button
- **THEN** all unchecked items remain in the checklist unchanged
