## Context

Workout and Exercise state currently lives in `_WorkoutHomeScreenState`, threaded down to `ActiveWorkoutScreen`, `PastWorkoutsScreen`, and `ManageExercisesScreen` as constructor params plus three mutation callbacks (`onWorkoutChanged`, `onExercisesChanged`, `onWorkoutDiscarded`). Each callback does `setState` + fire-and-forget `StorageService.save*` in `WorkoutHomeScreen`; `PastWorkoutsScreen` forwards all three without calling any of them itself. `Checklist` state in `HomeScreen` follows the identical pattern independently and is out of scope for this change.

There's already one precedent in this codebase for centralized, `Provider`-based state: `UpdateService` (`lib/services/update_service.dart`), wired at the `MaterialApp` root in `main.dart` as a `ChangeNotifierProvider<UpdateService>`. This change extends that same pattern to Workouts and Exercises, rather than introducing a new one.

This is issue #158, filed from an architecture review. It blocks issue #159 (deduplicating `Workout`'s four near-identical entry/Set lookup-and-copy methods), which touches the same mutation surface `WorkoutRepository` will call into — #159 should land after this change. It's sequenced before the (not yet implemented) `unify-set-input-ui` change, so that change's rework of `ActiveWorkoutScreen`'s Set-input UI happens against an already-shrunk constructor.

## Goals / Non-Goals

**Goals:**
- One module (`WorkoutRepository`) owns load, save, and mutation for Workouts and Exercises.
- Screens read current state and issue mutations through `WorkoutRepository` instead of receiving objects + callbacks.
- Match the existing `UpdateService` pattern exactly (concrete `ChangeNotifier`, constructor-injected dependencies) so there's one established shape for "service with a test seam" in this codebase, not two.

**Non-Goals:**
- Checklist persistence — untouched, stays as-is in `HomeScreen`.
- Any change to `active_workout_screen.dart`'s Set-input UI (`_AddSetBar`/`_EditSetDialog`) — that's `unify-set-input-ui`, sequenced after this change.
- Deduplicating `Workout`'s entry/Set lookup methods — that's issue #159, sequenced after this change.
- An abstract `WorkoutRepository` interface with real + fake implementations. A second real adapter (syncing to a future Go Service) is on the roadmap but not yet scoped; introducing an interface now would mean guessing a contract shape (conflict resolution, offline queueing, retries) that will likely be wrong once that work is actually scoped. Revisit then.

## Decisions

### One repository for Workouts + Exercises, not two
Exercises and Workouts are transactionally linked in the UI: adding an Exercise Entry by typed name can create a new Exercise and add the Entry in the same user action (`ActiveWorkoutScreen._addExerciseEntry`), and both need to be saved together. A single `WorkoutRepository` owning both lists avoids splitting a single user action across two modules that would need to coordinate.

### Concrete `ChangeNotifier`, constructor-injected — not an abstract interface
Mirrors `UpdateService` exactly:

```dart
class WorkoutRepository extends ChangeNotifier {
  WorkoutRepository({
    StorageService? storage,
    List<Workout>? initialWorkouts,
    List<Exercise>? initialExercises,
  })  : _storage = storage ?? StorageService(),
        _workouts = initialWorkouts,
        _exercises = initialExercises;

  final StorageService _storage;
  List<Workout>? _workouts;
  List<Exercise>? _exercises;

  List<Workout> get workouts => _workouts ?? [];
  List<Exercise> get exercises => _exercises ?? [];

  Future<void> load() async {
    if (_workouts != null) return; // already seeded (real load, or test injection)
    _workouts = await _storage.loadWorkouts();
    _exercises = await _storage.loadExercises();
    notifyListeners();
  }

  // mutation methods: startWorkout, addExerciseEntry, addSet, editSet,
  // deleteSet, deleteExerciseEntry, discardWorkout, finishWorkout,
  // renameExercise — each updates in-memory state, calls notifyListeners(),
  // then fires StorageService.saveWorkouts/saveExercises.
}
```

`load()`'s `initialWorkouts ?? loadFromStorage` guard is `_WorkoutHomeScreenState._load()`'s existing logic, relocated. Widget tests seed `WorkoutRepository(initialWorkouts: [...], initialExercises: [...])` directly instead of via the `initialWorkouts`/`initialExercises` widget params `WorkoutHomeScreen` carries today — those params are removed from `WorkoutHomeScreen`, `PastWorkoutsScreen`, `ActiveWorkoutScreen`, and `ManageExercisesScreen` once the repository owns seeding.

**Alternative considered**: `abstract class WorkoutRepository` + `LocalWorkoutRepository implements WorkoutRepository`. Rejected for now — only one real adapter exists (`StorageService`/`SharedPreferences`); per this codebase's "one adapter = hypothetical seam" standard, the split would mean two declarations of the same surface kept in sync by hand, for zero extra implementers today.

### Provider placement: scoped to the Workout tab, not the `MaterialApp` root
```dart
// app_shell.dart
static final _tabs = [
  const HomeScreen(),
  ChangeNotifierProvider<WorkoutRepository>(
    create: (_) => WorkoutRepository()..load(),
    child: const WorkoutHomeScreen(),
  ),
];
```
Unlike `UpdateService` (needed app-wide for the update banner), `WorkoutRepository` is only ever read by Workout screens — Checklists never need it. Scoping keeps the dependency's reach matched to who actually uses it.

**Caveat, not a benefit to oversell**: `AppShell` builds both tabs eagerly via `IndexedStack` (`app_shell.dart:16`) — both are in the widget tree from launch, one just hidden. `WorkoutRepository.load()` therefore still fires at app launch, same as `WorkoutHomeScreen._load()` does today via `initState`. Scoping the provider buys locality (Workout state can't leak into Checklist code), not lazy loading — there is no behavior change in load timing, which is exactly why this change has no delta for it beyond the wording fix in `workout-persistence`.

### Screens take an id, read via `context.watch`/`context.read`
`ActiveWorkoutScreen` moves from `ActiveWorkoutScreen({required Workout workout, required List<Exercise> exercises, required onWorkoutChanged, required onExercisesChanged, required onWorkoutDiscarded})` to `ActiveWorkoutScreen({required String workoutId})`, reading `context.watch<WorkoutRepository>().workouts.firstWhere((w) => w.id == workoutId)` for display and calling `context.read<WorkoutRepository>().addSet(...)` etc. for mutations. Same shape applies to `PastWorkoutsScreen` (drops all three callback params entirely — it was a pure pass-through) and `ManageExercisesScreen` (drops `exercises`/`onExercisesChanged`, reads exercises directly).

**New structural possibility this introduces**: with an object handed down, the `Workout` a screen displays cannot disappear out from under it. With an id-based lookup, it structurally could, if some other path removed it from the repository while the screen holding its id was still mounted. Checked against the app's actual navigation model and found **not reachable today**: only one Workout can be in progress at a time, Discard is only available on an in-progress Workout from within its own `ActiveWorkoutScreen` instance (which pops itself immediately after discarding), finished Workouts can't be discarded (only Locked-but-correctable), and Exercises are never deleted. No path exists to reach `ActiveWorkoutScreen` for a `workoutId` and have it vanish while mounted. Handle it as a defensive guard (if the lookup ever fails, pop back to `WorkoutHomeScreen`) rather than a spec requirement — there's no reachable scenario to write a testable spec against, and inventing one would test code that can't run.

## Risks / Trade-offs

- **[Risk]** `context.watch<WorkoutRepository>()` in `ActiveWorkoutScreen`/`PastWorkoutsScreen` rebuilds on every repository change, including changes unrelated to the Workout currently being viewed (e.g. editing a different past Workout's Set while another is theoretically open — not reachable today per single-navigator-stack, but worth naming). → Mitigation: none needed now; `ChangeNotifier`'s single `notifyListeners()` granularity matches `UpdateService`'s existing usage in this codebase, and the app has no concurrent-Workout-viewing scenario to make this observable.
- **[Risk]** Removing `WorkoutHomeScreen`'s `initialWorkouts`/`initialExercises` widget params is a breaking change to every existing widget test that constructs these screens directly. → Mitigation: tracked as explicit test-update tasks in tasks.md; tests move to seeding `WorkoutRepository` via its own constructor params, wrapped in `ChangeNotifierProvider.value`.
- **[Trade-off]** No abstract interface means a future sync adapter will require introducing one retroactively (extract `abstract class WorkoutRepository`, rename this to `LocalWorkoutRepository`). Accepted — cheaper to defer than to guess the sync contract now.

## Migration Plan

No data migration — `StorageService`'s storage keys and JSON shapes are unchanged. Sequencing:
1. This change (`workout-repository`) lands first.
2. Issue #159 (`Workout` entry/Set lookup dedup) lands next, against the repository's call sites.
3. `unify-set-input-ui` lands last, reworking `ActiveWorkoutScreen`'s Set-input UI against the already-shrunk constructor.

No rollback complexity beyond normal git revert — no schema or on-disk format changes.
