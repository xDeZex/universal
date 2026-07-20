import 'package:flutter/material.dart';

import 'workout_home_variant.dart';

// PROTOTYPE — throwaway. Answers wayfinder issue #214. Three structurally
// different treatments for the Workout home screen's primary action
// (Start/Continue Workout) vs. secondary navigation (Past Workouts, Manage
// Exercises, Manage Routines), all replacing the unstyled `TextButton` row
// that overflows at real device width (issue #208):
//
//   A, Tonal wrap: primary stays a full-width FilledButton; secondary
//   actions become FilledButton.tonal chips in a Wrap, which flows onto a
//   second line instead of overflowing.
//   B, Stacked outline: primary as a full-width FilledButton.icon; each
//   secondary action gets its own full-width OutlinedButton.icon, stacked
//   vertically — the strongest hierarchy split (filled vs. outlined, hero
//   size vs. row size) but the tallest layout.
//   C, Tonal grid: primary as a full-width FilledButton; secondary actions
//   as equal-width FilledButton.tonal tiles (icon over label) in a single
//   Row of Expanded cells — never wraps or overflows by construction.
//
// Strip this file, its call sites, and workout_home_variant.dart on
// capture once a direction wins.

class WorkoutHomeAction {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const WorkoutHomeAction({
    required this.label,
    required this.icon,
    required this.onPressed,
  });
}

class WorkoutHomeActions extends StatelessWidget {
  final WorkoutHomeVariant variant;
  final String primaryLabel;
  final VoidCallback onPrimaryPressed;
  final List<WorkoutHomeAction> secondaryActions;

  const WorkoutHomeActions({
    super.key,
    required this.variant,
    required this.primaryLabel,
    required this.onPrimaryPressed,
    required this.secondaryActions,
  });

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case WorkoutHomeVariant.current:
        return _current();
      case WorkoutHomeVariant.tonalWrap:
        return _tonalWrap(context);
      case WorkoutHomeVariant.stackedOutline:
        return _stackedOutline();
      case WorkoutHomeVariant.tonalGrid:
        return _tonalGrid();
    }
  }

  // Reproduces today's app exactly, including the #208 overflow bug, so it
  // stays a live point of comparison against the redesigned variants.
  Widget _current() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: onPrimaryPressed,
          child: Text(primaryLabel),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final action in secondaryActions)
              TextButton(
                key: ValueKey('current-${action.label}'),
                onPressed: action.onPressed,
                child: Text(action.label),
              ),
          ],
        ),
      ],
    );
  }

  Widget _tonalWrap(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton(
          key: const ValueKey('tonal-wrap-primary'),
          onPressed: onPrimaryPressed,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(primaryLabel),
        ),
        const SizedBox(height: 20),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final action in secondaryActions)
              FilledButton.tonal(
                key: ValueKey('tonal-wrap-${action.label}'),
                onPressed: action.onPressed,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(action.icon, size: 18),
                    const SizedBox(width: 6),
                    Text(action.label),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _stackedOutline() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          key: const ValueKey('stacked-outline-primary'),
          onPressed: onPrimaryPressed,
          icon: const Icon(Icons.play_arrow),
          label: Text(primaryLabel),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        const SizedBox(height: 24),
        for (final action in secondaryActions)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: OutlinedButton.icon(
              key: ValueKey('stacked-outline-${action.label}'),
              onPressed: action.onPressed,
              icon: Icon(action.icon),
              label: Text(action.label),
            ),
          ),
      ],
    );
  }

  Widget _tonalGrid() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton(
          key: const ValueKey('tonal-grid-primary'),
          onPressed: onPrimaryPressed,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(primaryLabel),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            for (final action in secondaryActions)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilledButton.tonal(
                    key: ValueKey('tonal-grid-${action.label}'),
                    onPressed: action.onPressed,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(action.icon, size: 20),
                        const SizedBox(height: 4),
                        Text(
                          action.label,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12),
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
