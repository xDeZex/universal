import 'package:flutter/foundation.dart';
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

final ValueNotifier<WorkoutHomeVariant> workoutHomeVariant = ValueNotifier(
  WorkoutHomeVariant.current,
);

class WorkoutHomeVariantSwitcher extends StatelessWidget {
  const WorkoutHomeVariantSwitcher({super.key});

  void _cycle(int delta) {
    final values = WorkoutHomeVariant.values;
    final i = values.indexOf(workoutHomeVariant.value);
    workoutHomeVariant.value =
        values[(i + delta + values.length) % values.length];
  }

  @override
  Widget build(BuildContext context) {
    if (kReleaseMode) return const SizedBox.shrink();
    return ValueListenableBuilder<WorkoutHomeVariant>(
      valueListenable: workoutHomeVariant,
      builder: (context, variant, _) => Align(
        alignment: Alignment.bottomCenter,
        child: SafeArea(
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: const Color(0xE6000000),
              borderRadius: BorderRadius.circular(999),
              boxShadow: const [
                BoxShadow(color: Colors.black54, blurRadius: 10),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  key: const ValueKey('workout-home-variant-prev'),
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                  onPressed: () => _cycle(-1),
                ),
                Flexible(
                  child: Text(
                    '${variant.shortLabel} — ${variant.description}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                IconButton(
                  key: const ValueKey('workout-home-variant-next'),
                  icon: const Icon(Icons.chevron_right, color: Colors.white),
                  onPressed: () => _cycle(1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
