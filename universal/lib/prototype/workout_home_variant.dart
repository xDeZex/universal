import 'package:flutter/material.dart';

// PROTOTYPE — throwaway. Answers wayfinder issue #214 (Workout home screen
// primary/secondary button hierarchy and spacing, replacing the unstyled
// TextButton row that overflows — tracked separately as issue #208). Never
// fold this file or its call sites into main; strip on capture once a
// direction wins.
enum WorkoutHomeVariant {
  current('Current', 'Unstyled TextButton row (overflows)'),
  tonalWrap('A', 'Filled primary + tonal wrap'),
  stackedOutline('B', 'Filled primary + stacked outline'),
  tonalGrid('C', 'Filled primary + tonal action grid');

  final String shortLabel;
  final String description;
  const WorkoutHomeVariant(this.shortLabel, this.description);
}

// Frozen to the direction #214 picked (see its resolution comment) — the
// last of this map's live prototype tickets, so no further switcher
// replaces this one on the floating bar. No longer switchable.
final ValueNotifier<WorkoutHomeVariant> workoutHomeVariant = ValueNotifier(
  WorkoutHomeVariant.tonalWrap,
);
