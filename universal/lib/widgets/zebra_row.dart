import 'package:flutter/material.dart';

/// Alternating row-background shading used instead of dividers for
/// separation inside a [CoplanarCard] — odd rows get a faint
/// `surfaceContainerHighest` tint, even rows stay transparent.
class ZebraRow extends StatelessWidget {
  final int index;
  final Widget child;

  const ZebraRow({super.key, required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: index.isOdd
          ? Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
          : null,
      child: child,
    );
  }
}
