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

// Frozen to the direction #212 picked (see its resolution comment) so #213's
// input-control mockups are judged inside the styling they'll actually ship
// alongside, not today's app. No longer switchable — see #213 for the
// InputControlVariant switcher that replaced this one on the floating bar.
final ValueNotifier<RowCardVariant> rowCardVariant = ValueNotifier(
  RowCardVariant.coplanarCards,
);
