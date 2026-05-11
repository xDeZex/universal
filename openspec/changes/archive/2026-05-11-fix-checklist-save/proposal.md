## Why

Checklist item changes (toggle, add, delete, reorder) are only persisted when the user navigates back from `ChecklistScreen` to `HomeScreen`. If the app is killed or crashes while a checklist is open, all unsaved changes are lost.

## What Changes

- `ChecklistScreen` receives an `onChanged` callback from `HomeScreen`
- Every item mutation in `ChecklistScreen` invokes the callback with the updated `Checklist`
- `HomeScreen` updates its list and saves to `SharedPreferences` on each callback

## Capabilities

### New Capabilities

- `checklist-persistence`: Checklist item changes are persisted immediately on every mutation, not only on screen pop

### Modified Capabilities

## Impact

- `lib/screens/checklist_screen.dart` — add `onChanged` parameter, call on every mutation
- `lib/screens/home_screen.dart` — pass callback to `ChecklistScreen`, save on each call
