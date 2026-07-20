import 'package:flutter/material.dart';

import 'row_card_variant.dart';

// PROTOTYPE — throwaway. Renders the *open* (being-edited) Planned
// Exercise row's selection treatment per RowCardVariant, split out of
// widgets/planned_exercise_card.dart to stay under the repo's 300-line
// file limit. Answers wayfinder issue #212.
Widget buildOpenPlannedExerciseRow(
  BuildContext context,
  RowCardVariant variant,
  ThemeData theme, {
  required Widget rowLine,
  required Widget editor,
}) {
  switch (variant) {
    case RowCardVariant.current:
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: rowLine,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: editor,
          ),
        ],
      );
    case RowCardVariant.gapList:
      // Selection = solid container-color swap on the row's own rounded
      // container (M3 "expressive list" selected state).
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        child: Material(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(14),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: DefaultTextStyle.merge(
                    style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
                    child: IconTheme.merge(
                      data: IconThemeData(color: theme.colorScheme.onPrimaryContainer),
                      child: rowLine,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
                  child: editor,
                ),
              ],
            ),
          ),
        ),
      );
    case RowCardVariant.accentBar:
      // Selection = a left accent bar. `BoxDecoration.border` auto-adds
      // padding equal to its own width, so margin alone (12 + the 4 the
      // border contributes = 16) lands content at the same x as the
      // closed row — no extra manual padding, or it'd double up.
      return Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 16, 8),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: theme.colorScheme.primary, width: 4),
          ),
        ),
        child: Column(
          children: [
            Padding(padding: const EdgeInsets.only(bottom: 8), child: rowLine),
            editor,
          ],
        ),
      );
    case RowCardVariant.coplanarCards:
      // Selection = a left accent bar (matches the B variant's treatment,
      // not a tonal fill + check icon). Same auto-padding math as above.
      return Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 16, 8),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: theme.colorScheme.primary, width: 4),
          ),
        ),
        child: Column(
          children: [
            Padding(padding: const EdgeInsets.only(bottom: 4), child: rowLine),
            editor,
          ],
        ),
      );
  }
}
