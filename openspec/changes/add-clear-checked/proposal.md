## Why

Users accumulate many checked items over time with no way to remove them all at once. A single "Clear checked" action removes the friction of deleting items one by one.

## What Changes

- Add a "Clear checked" button to the checklist screen toolbar
- Tapping it removes all checked items from the current checklist and persists the change
- Button is only visible when at least one item is checked

## Capabilities

### New Capabilities
- `clear-checked-items`: Bulk-remove all checked items from a checklist in one tap

### Modified Capabilities

## Impact

- `lib/models/checklist.dart` — new `clearChecked()` method on `Checklist`
- `lib/screens/checklist_screen.dart` — toolbar button wired to `clearChecked()`
- `lib/services/storage_service.dart` — no changes (auto-save already handles persistence)
- `test/` — new unit tests for `clearChecked()` and widget test for the button
