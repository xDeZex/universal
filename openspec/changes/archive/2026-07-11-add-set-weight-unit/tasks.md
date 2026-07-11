## 1. Set model gains a unit

- [x] 1.1 `WeightUnit` (kg, lbs) exists as a type usable on `ExerciseSet`
- [x] 1.2 `ExerciseSet` requires `unit` and round-trips it through `copyWith` and `toJson`/`fromJson`
- [x] 1.3 `ExerciseSet.fromJson` throws when `unit` is missing from the map
- [x] 1.4 `Workout.addSet` accepts a `unit` argument and forwards it to the newly created Set

## 2. Active Workout screen: unit selection

- [x] 2.1 Each Exercise Entry's Set-entry row shows a kg/lbs unit toggle alongside the weight and reps fields
- [x] 2.2 Submitting a Set uses the currently selected unit, included on the created Set
- [x] 2.3 A freshly added Exercise Entry's unit toggle defaults to kg before any Set has been logged against it
- [x] 2.4 After logging a Set with a given unit, that Exercise Entry's toggle defaults to the same unit for the next Set logged against it

## 3. Active Workout screen: display

- [x] 3.1 A logged Set is displayed as "<reps> reps at <weight> <unit>" (e.g. "8 reps at 135 lbs")

## 4. Verify

- [x] 4.1 `flutter test` passes
- [x] 4.2 `flutter analyze` reports no new warnings
