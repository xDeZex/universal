# ExerciseEntry and Set are identified by id, not position

Both `ExerciseEntry` and `ExerciseSet` carry a stable `id`, minted at creation, rather than being addressed by their index within a Workout's list. The obvious shortcut would be to reference them by position (e.g. "the 2nd Set of the 3rd Entry") since they're always rendered as ordered lists — but list order shifts as Sets are added, and a future deletion feature (see #123) means an id minted once and never reused is the only reference that stays valid across edits. This mirrors Exercise's own id-based identity (ADR-0015).
