import 'package:flutter/material.dart';

import '../models/workout.dart';
import '../widgets/number_stepper.dart';
import 'input_control_variant.dart';

// PROTOTYPE — throwaway. Answers wayfinder issue #213. Three structurally
// different treatments for the numeric stepper and kg/lbs unit toggle,
// grounded in the M3 research from issue #211:
//
//   A, Tonal grouped pod: two IconButton.filledTonal flanking the value
//   inside one merged rounded container (the research's literal reading of
//   "pair filled/tonal icon buttons" + a fully-rounded SegmentedButton for
//   the toggle).
//   B, Outlined cluster + icon toggle: IconButton.outlined pair inside a
//   shared bordered cluster (lower emphasis than A), with the unit toggle
//   rendered as two selectable icon buttons (outlined when unselected,
//   filled when selected — the M3 "communicate selection via >1 property"
//   toggle-icon-button rule) instead of a labelled segmented bar.
//   C, Merged capsule: stepper and unit fused into a single continuous
//   pill — no separate toggle control at all, the unit is a tappable
//   suffix inside the value. Tests whether merging everything into one
//   row-length control eases the width pressure from issue #209 the most.
//
// Strip this file, its call sites, and input_control_variant.dart on
// capture once a direction wins.

class VariantStepper extends StatelessWidget {
  final InputControlVariant variant;
  final String keyPrefix;
  final num value;
  final num step;
  final bool allowNegative;
  final num? min;
  final num? max;
  final ValueChanged<num> onChanged;

  const VariantStepper({
    super.key,
    required this.variant,
    required this.keyPrefix,
    required this.value,
    required this.step,
    this.allowNegative = false,
    this.min,
    this.max,
    required this.onChanged,
  });

  bool get _canDecrement =>
      min != null ? value > min! : (allowNegative || value > 0);

  bool get _canIncrement => max == null || value < max!;

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case InputControlVariant.current:
        return NumberStepper(
          keyPrefix: keyPrefix,
          value: value,
          step: step,
          allowNegative: allowNegative,
          min: min,
          max: max,
          onChanged: onChanged,
        );
      case InputControlVariant.tonalPod:
        return _pod(context);
      case InputControlVariant.outlinedCluster:
        return _outlinedCluster(context);
      case InputControlVariant.mergedCapsule:
        return _capsuleStepper(context);
    }
  }

  Widget _pod(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton.filledTonal(
            key: ValueKey('$keyPrefix-decrement'),
            iconSize: 18,
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.remove),
            onPressed: _canDecrement
                ? () => onChanged(normalizeStepValue(value - step))
                : null,
          ),
          SizedBox(
            width: 36,
            child: Text(
              '${normalizeStepValue(value)}',
              key: ValueKey('$keyPrefix-value'),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall,
            ),
          ),
          IconButton.filledTonal(
            key: ValueKey('$keyPrefix-increment'),
            iconSize: 18,
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.add),
            onPressed: _canIncrement
                ? () => onChanged(normalizeStepValue(value + step))
                : null,
          ),
        ],
      ),
    );
  }

  Widget _outlinedCluster(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton.outlined(
            key: ValueKey('$keyPrefix-decrement'),
            iconSize: 16,
            visualDensity: VisualDensity.compact,
            style: const ButtonStyle(
              side: WidgetStatePropertyAll(BorderSide.none),
            ),
            icon: const Icon(Icons.remove),
            onPressed: _canDecrement
                ? () => onChanged(normalizeStepValue(value - step))
                : null,
          ),
          SizedBox(
            width: 36,
            child: Text(
              '${normalizeStepValue(value)}',
              key: ValueKey('$keyPrefix-value'),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall,
            ),
          ),
          IconButton.outlined(
            key: ValueKey('$keyPrefix-increment'),
            iconSize: 16,
            visualDensity: VisualDensity.compact,
            style: const ButtonStyle(
              side: WidgetStatePropertyAll(BorderSide.none),
            ),
            icon: const Icon(Icons.add),
            onPressed: _canIncrement
                ? () => onChanged(normalizeStepValue(value + step))
                : null,
          ),
        ],
      ),
    );
  }

  Widget _capsuleStepper(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(999),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            key: ValueKey('$keyPrefix-decrement'),
            iconSize: 16,
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.remove),
            onPressed: _canDecrement
                ? () => onChanged(normalizeStepValue(value - step))
                : null,
          ),
          Text(
            '${normalizeStepValue(value)}',
            key: ValueKey('$keyPrefix-value'),
            style: theme.textTheme.titleSmall,
          ),
          IconButton(
            key: ValueKey('$keyPrefix-increment'),
            iconSize: 16,
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.add),
            onPressed: _canIncrement
                ? () => onChanged(normalizeStepValue(value + step))
                : null,
          ),
        ],
      ),
    );
  }
}

/// The weight-stepper + kg/lbs unit toggle as one coherent cluster, styled
/// per [variant]. `current` reproduces today's `WeightInputControls`
/// (bare stepper + two `ChoiceChip`s) exactly.
class VariantWeightControls extends StatelessWidget {
  final InputControlVariant variant;
  final String weightStepperKey;
  final String unitKgKey;
  final String unitLbsKey;
  final num weight;
  final WeightUnit unit;
  final ValueChanged<num> onWeightChanged;
  final ValueChanged<WeightUnit> onUnitChanged;

  const VariantWeightControls({
    super.key,
    required this.variant,
    required this.weightStepperKey,
    required this.unitKgKey,
    required this.unitLbsKey,
    required this.weight,
    required this.unit,
    required this.onWeightChanged,
    required this.onUnitChanged,
  });

  num get _weightStep => unit == WeightUnit.kg ? 2.5 : 5;

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case InputControlVariant.current:
        return _currentChips(context);
      case InputControlVariant.tonalPod:
        return _withSegmentedToggle(context);
      case InputControlVariant.outlinedCluster:
        return _withIconToggle(context);
      case InputControlVariant.mergedCapsule:
        return _mergedCapsule(context);
    }
  }

  Widget _currentChips(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        VariantStepper(
          variant: variant,
          keyPrefix: weightStepperKey,
          value: weight,
          step: _weightStep,
          allowNegative: true,
          onChanged: onWeightChanged,
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          key: ValueKey(unitKgKey),
          label: const Text('kg'),
          showCheckmark: false,
          selected: unit == WeightUnit.kg,
          onSelected: (_) => onUnitChanged(WeightUnit.kg),
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          key: ValueKey(unitLbsKey),
          label: const Text('lbs'),
          showCheckmark: false,
          selected: unit == WeightUnit.lbs,
          onSelected: (_) => onUnitChanged(WeightUnit.lbs),
        ),
      ],
    );
  }

  Widget _withSegmentedToggle(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        VariantStepper(
          variant: variant,
          keyPrefix: weightStepperKey,
          value: weight,
          step: _weightStep,
          allowNegative: true,
          onChanged: onWeightChanged,
        ),
        const SizedBox(width: 8),
        SegmentedButton<WeightUnit>(
          style: SegmentedButton.styleFrom(
            visualDensity: VisualDensity.compact,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          showSelectedIcon: false,
          segments: [
            ButtonSegment(value: WeightUnit.kg, label: Text('kg', key: ValueKey(unitKgKey))),
            ButtonSegment(value: WeightUnit.lbs, label: Text('lbs', key: ValueKey(unitLbsKey))),
          ],
          selected: {unit},
          onSelectionChanged: (selection) => onUnitChanged(selection.first),
        ),
      ],
    );
  }

  Widget _withIconToggle(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        VariantStepper(
          variant: variant,
          keyPrefix: weightStepperKey,
          value: weight,
          step: _weightStep,
          allowNegative: true,
          onChanged: onWeightChanged,
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outline),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _unitToggleButton(
                context,
                key: unitKgKey,
                label: 'kg',
                selected: unit == WeightUnit.kg,
                onTap: () => onUnitChanged(WeightUnit.kg),
              ),
              _unitToggleButton(
                context,
                key: unitLbsKey,
                label: 'lb',
                selected: unit == WeightUnit.lbs,
                onTap: () => onUnitChanged(WeightUnit.lbs),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Selection communicated by both fill *and* label weight (M3: never by
  // color alone), matching the toggle-icon-button rule for outlined-vs-
  // filled from the #211 research.
  Widget _unitToggleButton(
    BuildContext context, {
    required String key,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      key: ValueKey(key),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        color: selected ? theme.colorScheme.secondaryContainer : null,
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: selected
                ? theme.colorScheme.onSecondaryContainer
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _mergedCapsule(BuildContext context) {
    final theme = Theme.of(context);
    final step = _weightStep;
    final canDecrement = weight > 0;
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(999),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            key: ValueKey('$weightStepperKey-decrement'),
            iconSize: 16,
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.remove),
            onPressed: canDecrement
                ? () => onWeightChanged(
                    normalizeStepValue(weight - step),
                  )
                : null,
          ),
          InkWell(
            // Tapping the value itself cycles the unit — no separate
            // toggle control in this variant. Keyed by whichever unit a
            // tap would switch *to*, matching the other variants' key
            // convention of "unit-{kg,lbs}" identifying that target unit.
            key: ValueKey(unit == WeightUnit.kg ? unitLbsKey : unitKgKey),
            borderRadius: BorderRadius.circular(999),
            onTap: () => onUnitChanged(
              unit == WeightUnit.kg ? WeightUnit.lbs : WeightUnit.kg,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 4,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${normalizeStepValue(weight)}',
                    key: ValueKey('$weightStepperKey-value'),
                    style: theme.textTheme.titleSmall,
                  ),
                  Text(
                    ' ${unit.name}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      decoration: TextDecoration.underline,
                      decorationColor: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            key: ValueKey('$weightStepperKey-increment'),
            iconSize: 16,
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.add),
            onPressed: () =>
                onWeightChanged(normalizeStepValue(weight + step)),
          ),
        ],
      ),
    );
  }
}
