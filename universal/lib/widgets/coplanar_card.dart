import 'package:flutter/material.dart';

/// Shared container for gym-tracking rows/cards: relies entirely on the
/// app's global [CardThemeData] for fill/elevation/radius, so every call
/// site is visually identical by construction rather than by convention.
class CoplanarCard extends StatelessWidget {
  final Widget child;

  const CoplanarCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}
