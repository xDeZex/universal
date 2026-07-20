import 'package:flutter/material.dart';

/// A secondary action rendered as a tonal chip by [WorkoutHomeActions].
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

/// Primary/secondary action row for [WorkoutHomeScreen]: a full-width
/// [FilledButton] primary action followed by [FilledButton.tonalIcon] chips
/// for the secondary actions, laid out in a [Wrap] so they flow to a second
/// line instead of overflowing.
class WorkoutHomeActions extends StatelessWidget {
  final String primaryLabel;
  final IconData primaryIcon;
  final VoidCallback onPrimaryPressed;
  final List<WorkoutHomeAction> secondaryActions;

  const WorkoutHomeActions({
    super.key,
    required this.primaryLabel,
    required this.primaryIcon,
    required this.onPrimaryPressed,
    required this.secondaryActions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: onPrimaryPressed,
          icon: Icon(primaryIcon),
          label: Text(primaryLabel),
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final action in secondaryActions)
              FilledButton.tonalIcon(
                onPressed: action.onPressed,
                icon: Icon(action.icon, size: 18),
                label: Text(action.label),
              ),
          ],
        ),
      ],
    );
  }
}
