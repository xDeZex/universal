import 'package:flutter/material.dart';

import '../models/routine.dart';
import '../prototype/row_card_variant.dart';

class RoutineTile extends StatelessWidget {
  final Routine routine;
  final VoidCallback onTap;

  const RoutineTile({super.key, required this.routine, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<RowCardVariant>(
      valueListenable: rowCardVariant,
      builder: (context, variant, _) {
        final theme = Theme.of(context);
        return switch (variant) {
          RowCardVariant.current ||
          RowCardVariant.accentBar => ListTile(
            title: Text(routine.name),
            onTap: onTap,
          ),
          RowCardVariant.gapList => Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
            child: Material(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Text(routine.name),
                ),
              ),
            ),
          ),
          RowCardVariant.coplanarCards => Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
            child: Card(
              margin: EdgeInsets.zero,
              child: ListTile(title: Text(routine.name), onTap: onTap),
            ),
          ),
        };
      },
    );
  }
}
