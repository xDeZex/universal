import 'package:flutter/foundation.dart';
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

final ValueNotifier<InputControlVariant> inputControlVariant = ValueNotifier(
  InputControlVariant.current,
);

class InputControlVariantSwitcher extends StatelessWidget {
  const InputControlVariantSwitcher({super.key});

  void _cycle(int delta) {
    final values = InputControlVariant.values;
    final i = values.indexOf(inputControlVariant.value);
    inputControlVariant.value =
        values[(i + delta + values.length) % values.length];
  }

  @override
  Widget build(BuildContext context) {
    if (kReleaseMode) return const SizedBox.shrink();
    return ValueListenableBuilder<InputControlVariant>(
      valueListenable: inputControlVariant,
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
                  key: const ValueKey('input-control-variant-prev'),
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
                  key: const ValueKey('input-control-variant-next'),
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
