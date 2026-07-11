## Context

Universal is Flutter-only, local storage only (SharedPreferences), no backend for app data. `Checklist`/`ChecklistItem` and `Exercise` establish the existing model style: plain immutable classes, `copyWith`, `toJson`/`fromJson`, no code-gen, no state-management framework beyond `provider` (used today only for `UpdateService`). `StorageService` is a single class with one load/save method pair per collection. This change adds the first screen(s) beyond checklists, so it also has to introduce the app's first multi-tab navigation shell.

Decisions #119/#120 already fixed the domain rules this design implements (Workout lifecycle, ADR-0016's endTime derivation, Exercise reuse-by-name); this document is about how those rules land in code, not whether they're correct.

## Goals / Non-Goals

**Goals:**
- Land `Workout`, `ExerciseEntry`, `Set` models and their persistence, matching existing model/service style closely enough that a reader of `checklist.dart`/`storage_service.dart` recognizes the pattern immediately.
- Decide where the "one Workout in progress," "finish requires ≥1 Set," and "resolve-or-create Exercise" rules live in code.
- Decide how the Workout tab is reached given the app has never had more than one screen at its root.

**Non-Goals:**
- Autocomplete suggestions, Exercise management screen, past-Workout browsing, editing/deleting a Set or Entry after logging, Routine/Program/Schedule — all explicitly deferred by the issue.
- Any backend/API sync for Workouts — stays local-only, same as Checklists.

## Decisions

**Bottom navigation shell replaces the bare `HomeScreen` root.** `MaterialApp.home` becomes a new `AppShell` (or similar) with a `Scaffold`/`BottomNavigationBar` holding two tabs: the existing `HomeScreen` (checklists) unchanged, and a new `WorkoutHomeScreen`. Alternative considered: a gym icon button in `HomeScreen`'s AppBar pushing to `WorkoutHomeScreen` (matches the Settings icon pattern already there, avoids restructuring `main.dart`). Rejected because Settings is a one-off destination, not a peer feature area — checklists and gym tracking are equal-weight parts of the app per the README's "checklist today, gym tracking planned" framing, and tab switching keeps both screens' state alive (no reload on switch), which a push/pop to Settings-style navigation doesn't give for free.

**Domain rules live on the models as methods, not a separate service class.** Mirrors `Checklist.addItem`/`removeItem`/`toggleItem`, which encode Checklist's rules (dedup, empty-name rejection) as instance methods returning a new value or `null`/unchanged on rejection, called directly from screen state (`HomeScreen._addChecklist` etc.) rather than through a service layer. So: `Workout` gets `addSet`, `finish` (returns `null` if zero Sets, mirroring `Checklist.addItem`'s null-on-rejection pattern), and the "one in progress" check is a plain list scan (`workouts.any((w) => w.endTime == null)`) done in `WorkoutHomeScreen` before constructing a new `Workout`, exactly where `HomeScreen._addChecklist` checks nothing today because Checklists have no such invariant — this is new territory but the shape (guard in screen state before `setState`) is the existing pattern for anything not already encoded on the model.

**Exercise resolve-or-create is a static factory, not a method on Workout.** `Workout`/`ExerciseEntry` don't hold the global Exercise list (it's a sibling top-level collection, like Checklists), so the reuse-by-name match can't live on them. Add `Exercise.resolve(String name, List<Exercise> existing)` — a pure static function returning either an existing `Exercise` (case-insensitive exact match) or a newly constructed one — called from `ActiveWorkoutScreen` when the user submits the Exercise Entry field, same layer that already owns both the Workout list and the Exercise list.

**IDs are timestamp strings, no new dependency.** `Workout`, `ExerciseEntry`, `Set`, and newly created `Exercise` all need a stable id distinct from any user-visible field (Set has no name at all; Workout/Entry need one for `copyWith`-based updates by id). Use `DateTime.now().microsecondsSinceEpoch.toString()` at construction time. Alternative considered: add the `uuid` package. Rejected — this is a single-user, local-only app where all id generation happens on one device in response to direct user action (never concurrent, never networked), so microsecond-timestamp collision risk is negligible, and it avoids a new dependency for a one-line problem.

**Storage keys: `workouts` and `exercises`, alongside the existing `checklists` key.** `StorageService` gains `loadWorkouts`/`saveWorkouts` and `loadExercises`/`saveExercises` pairs, each following `loadChecklists`/`saveChecklists`'s exact shape (try/catch defaulting to `[]` on load, `jsonEncode`/`jsonDecode` of a `List<Map>` on save). No new class — `StorageService` stays a single flat class, matching its current size and role.

## Risks / Trade-offs

- [Two independent top-level collections (`workouts`, `exercises`) loaded/saved separately] → each mutation that touches both (adding an Entry that creates a new Exercise) must save both lists; `ActiveWorkoutScreen` is responsible for calling both save paths in that case, same as `HomeScreen` already calls `_saveChecklists()` after every mutating `setState`. Covered by the workout-persistence spec's scenarios.
- [Timestamp-string ids] → theoretically collide if two entities are constructed within the same microsecond; not reachable from single-threaded, single-user UI interaction, so accepted rather than mitigated.
- [Bottom nav restructures `main.dart`, touching the app's root widget] → existing `HomeScreen` widget tests construct `HomeScreen` directly (see `initialChecklists` param used in tests); those tests are unaffected since `HomeScreen` itself doesn't change, only what wraps it.
- [Domain term "Set" vs. the Dart class name] → the domain vocabulary in `CONTEXT.md` calls this a "Set", but the Dart class is named `ExerciseSet` (`lib/models/workout.dart`) to avoid shadowing `dart:core`'s `Set<T>` collection type. Requirement text and UI copy still use "Set"; only the implementation type differs.

## Open Questions

None outstanding — navigation approach was the one ambiguous point and is resolved above.
