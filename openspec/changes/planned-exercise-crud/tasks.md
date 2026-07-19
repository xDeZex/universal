## 1. Repository gains Planned Exercise mutators

- [x] 1.1 `WorkoutRepository.addPlannedExercise(routineId, name)` resolves the name via `Exercise.resolve`, appends a new Planned Exercise referencing the resolved Exercise's id, persists, and notifies listeners on an active Routine
- [x] 1.2 `addPlannedExercise` on an archived Routine leaves the Routine list unchanged and persists nothing
- [x] 1.3 `addPlannedExercise` persists the updated Routine list before the next frame
- [x] 1.4 `WorkoutRepository.removePlannedExercise(routineId, plannedExerciseId)` removes the matching Planned Exercise, persists, and notifies listeners on an active Routine
- [x] 1.5 `removePlannedExercise` on an archived Routine leaves the Routine list unchanged and persists nothing
- [x] 1.6 `removePlannedExercise` persists the updated Routine list before the next frame
- [x] 1.7 `WorkoutRepository.reorderPlannedExercises(routineId, oldIndex, newIndex)` reorders the list, persists, and notifies listeners on an active Routine
- [x] 1.8 `reorderPlannedExercises` on an archived Routine leaves the Routine list unchanged and persists nothing
- [x] 1.9 `reorderPlannedExercises` persists the updated Routine list before the next frame

## 2. Routine screen renders Planned Exercises as cards

- [x] 2.1 A Routine with no Planned Exercises shows the "No Planned Exercises yet" empty state (active and archived)
- [x] 2.2 A Routine with Planned Exercises renders each as a card, in stored order, instead of the empty state
- [x] 2.3 Each card header shows the referenced Exercise's current name (reflecting renames, not a stale copy)
- [x] 2.4 Each card's rows render as a simple read-only line per row (no tap interaction, no grouping)

## 3. User can add a Planned Exercise via the freeform field

- [ ] 3.1 Submitting a name matching an existing Exercise case-insensitively adds a Planned Exercise referencing that Exercise's id
- [ ] 3.2 Submitting an unmatched name creates a new Exercise and adds a Planned Exercise referencing it
- [ ] 3.3 Submitting a blank/whitespace-only name adds nothing
- [ ] 3.4 New Planned Exercise appears at the end of the list, matching repository order

## 4. Add field shows an autocomplete dropdown

- [ ] 4.1 Typing text with a case-insensitive substring match against an existing Exercise name shows a dropdown of matches, alphabetically ordered
- [ ] 4.2 The dropdown never shows an "add as new" row
- [ ] 4.3 Typing text with no matches hides the dropdown
- [ ] 4.4 Tapping a suggestion fills the field with that Exercise's full name and does not submit
- [ ] 4.5 A long list of matches scrolls within the dropdown rather than being capped

## 5. User can remove a Planned Exercise

- [ ] 5.1 Tapping a card's delete icon removes that Planned Exercise and its rows immediately, no confirmation dialog
- [ ] 5.2 Deleting the only remaining Planned Exercise returns the screen to the empty state

## 6. User can reorder Planned Exercises

- [ ] 6.1 Long-press-dragging a card to a new position updates the Routine's Planned Exercise order and persists it
- [ ] 6.2 Dropping a card back in its original position leaves the order unchanged
- [ ] 6.3 Cards are keyed by Planned Exercise id (not list index) so reordering behaves correctly alongside add/remove

## 7. Planned Exercise editing is blocked while archived

- [ ] 7.1 An archived Routine's screen hides the add field
- [ ] 7.2 An archived Routine's cards hide the delete icon
- [ ] 7.3 An archived Routine's cards are not draggable / not wrapped in a reorderable list

## 8. Verify

- [ ] 8.1 `flutter test` passes for all new and existing tests
- [ ] 8.2 `flutter analyze` reports no new warnings
- [ ] 8.3 Manually verify add (both suggestion-reuse and create-new paths), remove, and reorder in the running app via the `run` skill
