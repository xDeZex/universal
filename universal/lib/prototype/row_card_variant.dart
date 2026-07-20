import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// PROTOTYPE — throwaway. Answers wayfinder issue #212 (row/card/divider/
// selection visual language across gym-tracking screens). Never fold this
// file or its call sites into main; strip on capture once a direction wins.
enum RowCardVariant {
  current('Current', "Today's app, unchanged"),
  gapList('A', 'Expressive gaps'),
  accentBar('B', 'Flat + accent bar'),
  coplanarCards('C', 'Coplanar cards');

  final String shortLabel;
  final String description;
  const RowCardVariant(this.shortLabel, this.description);
}

final ValueNotifier<RowCardVariant> rowCardVariant = ValueNotifier(
  RowCardVariant.current,
);

class RowCardVariantSwitcher extends StatelessWidget {
  const RowCardVariantSwitcher({super.key});

  void _cycle(int delta) {
    final values = RowCardVariant.values;
    final i = values.indexOf(rowCardVariant.value);
    rowCardVariant.value = values[(i + delta + values.length) % values.length];
  }

  @override
  Widget build(BuildContext context) {
    if (kReleaseMode) return const SizedBox.shrink();
    return ValueListenableBuilder<RowCardVariant>(
      valueListenable: rowCardVariant,
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
                  key: const ValueKey('row-card-variant-prev'),
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                  onPressed: () => _cycle(-1),
                ),
                Text(
                  '${variant.shortLabel} — ${variant.description}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                IconButton(
                  key: const ValueKey('row-card-variant-next'),
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
