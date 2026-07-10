## 1. Exercise model exists with required fields

- [x] 1.1 Exercise can be constructed with an id and a name, exposing both via fields
- [x] 1.2 Exercise's toJson/fromJson round-trip preserves id and name
- [x] 1.3 Exercise.fromJson throws when the id or name key is missing

## 2. Exercise id is stable identity, independent of name

- [x] 2.1 copyWith(name: ...) returns a new Exercise with the same id and the updated name
- [x] 2.2 copyWith with no arguments returns an Exercise identical to the original
- [x] 2.3 copyWith's signature exposes no id parameter, so identity cannot be reassigned through it

## 3. Verification

- [x] 3.1 `flutter test` passes for `universal/test/models/exercise_test.dart`
- [x] 3.2 `flutter analyze` reports no new warnings for `universal/lib/models/exercise.dart`
