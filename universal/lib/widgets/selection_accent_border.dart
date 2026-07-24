import 'package:flutter/material.dart';

/// A 4dp left accent border indicating selection. The border is always
/// present — transparent when unselected — because [BoxDecoration.border]
/// contributes its own width to the child's effective padding; toggling
/// its presence (rather than just its color) would shift content
/// horizontally by 4dp on every select/deselect.
class SelectionAccentBorder extends StatelessWidget {
  final bool selected;
  final Widget child;

  const SelectionAccentBorder({
    super.key,
    required this.selected,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: selected ? theme.colorScheme.primary : Colors.transparent,
            width: 4,
          ),
        ),
      ),
      child: child,
    );
  }
}
