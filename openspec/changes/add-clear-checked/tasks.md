## 1. Model

- [x] 1.1 Add `clearChecked()` method to `Checklist` in `lib/models/checklist.dart`
- [x] 1.2 Write unit tests for `clearChecked()` in `test/models/checklist_test.dart` (red)
- [x] 1.3 Verify unit tests pass (green)

## 2. UI

- [x] 2.1 Add "Clear checked" `IconButton` to `ChecklistScreen` app bar actions
- [x] 2.2 Guard visibility — show only when `checklist.checkedItems.isNotEmpty`
- [x] 2.3 Wire button to call `clearChecked()` and trigger auto-save via the existing provider pattern

## 3. Verification

- [x] 3.1 Run `flutter test` — all tests pass
- [x] 3.2 Run `flutter analyze` — no warnings
