import 'package:flutter/material.dart';

// PROTOTYPE — throwaway. Answers wayfinder issue #213 (numeric stepper /
// unit-toggle control redesign for the Planned Exercise row editor and
// Active Workout set-entry controls). Never fold this file or its call
// sites into main; strip on capture once a direction wins.
enum InputControlVariant {
  current('Current', 'Bare +/- and chips'),
  tonalPod('A', 'Tonal pod'),
  outlinedCluster('B', 'Outlined + icon toggle'),
  mergedCapsule('C', 'Merged capsule');

  final String shortLabel;
  final String description;
  const InputControlVariant(this.shortLabel, this.description);
}

// Frozen to the direction #213 picked (see its resolution comment) so #214's
// home-screen mockups are judged inside the styling they'll actually ship
// alongside, not today's app. No longer switchable — see #214 for the
// WorkoutHomeVariant switcher that replaced this one on the floating bar.
final ValueNotifier<InputControlVariant> inputControlVariant = ValueNotifier(
  InputControlVariant.tonalPod,
);
