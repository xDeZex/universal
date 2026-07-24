import 'package:flutter/material.dart';

/// Bar pinned to the bottom of [RoutineScreen]: a full-width primary button
/// in a padded, tinted container, mirroring [AddSetBar]'s structure and
/// [WorkoutHomeScreen]'s Start/Continue Workout button-swap rule.
class StartWorkoutBar extends StatelessWidget {
  final bool hasInProgress;
  final VoidCallback onPressed;

  const StartWorkoutBar({
    super.key,
    required this.hasInProgress,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('start-workout-bar'),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          key: const ValueKey('start-workout-button'),
          onPressed: onPressed,
          child: Text(hasInProgress ? 'Continue Workout' : 'Start Workout'),
        ),
      ),
    );
  }
}
