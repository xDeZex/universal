## 1. Red — write failing tests

- [x] 1.1 Update existing `checklist_screen_test.dart` constructions to pass `onChanged: (_) {}` so they compile once the parameter is added
- [x] 1.2 Add test: `onChanged` is called when an item is toggled
- [x] 1.3 Add test: `onChanged` is called when an item is added
- [x] 1.4 Add test: `onChanged` is called when an item is deleted
- [x] 1.5 Confirm tests fail (`flutter test` — expect compile errors or failures on the new tests)

## 2. Green — implement

- [x] 2.1 Add required `onChanged` parameter of type `void Function(Checklist)` to `ChecklistScreen`
- [x] 2.2 Call `onChanged(_checklist)` at the end of `_toggleItem`
- [x] 2.3 Call `onChanged(_checklist)` inside `_addItem` after a successful add or uncheck-duplicate
- [x] 2.4 Call `onChanged(_checklist)` at the end of `_deleteItem`
- [x] 2.5 Call `onChanged(_checklist)` at the end of `_reorderUnchecked`
- [x] 2.6 Call `onChanged(_checklist)` at the end of `_reorderChecked`
- [x] 2.7 In `HomeScreen`, extract `_onChecklistChanged(int index, Checklist updated)` that updates `_checklists[index]` and calls `_saveChecklists()`
- [x] 2.8 Pass the callback to `ChecklistScreen` in `_openChecklist`
- [x] 2.9 Confirm all tests pass (`flutter test`)

## 3. Refactor

- [x] 3.1 Run `flutter analyze` and fix any warnings
