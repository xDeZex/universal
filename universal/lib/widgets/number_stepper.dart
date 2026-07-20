import 'package:flutter/material.dart';

num normalizeStepValue(num value) {
  if (value is int) return value;
  final rounded = value.roundToDouble();
  return value == rounded ? value.toInt() : value;
}

class NumberStepper extends StatelessWidget {
  final String keyPrefix;
  final num value;
  final num step;
  final bool allowNegative;

  /// Floor below which decrementing is disabled. Defaults to `0` unless
  /// [allowNegative] is set, in which case decrementing is never disabled.
  /// Callers with a domain-specific floor (e.g. a reps floor of 1) pass it
  /// explicitly rather than this widget hard-coding it.
  final num? min;

  /// Ceiling above which incrementing is disabled. `null` (the default)
  /// means no ceiling.
  final num? max;

  final ValueChanged<num> onChanged;

  const NumberStepper({
    super.key,
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          key: ValueKey('$keyPrefix-decrement'),
          icon: const Icon(Icons.remove),
          onPressed: _canDecrement
              ? () => onChanged(normalizeStepValue(value - step))
              : null,
        ),
        SizedBox(
          width: 40,
          child: Text(
            '${normalizeStepValue(value)}',
            key: ValueKey('$keyPrefix-value'),
            textAlign: TextAlign.center,
          ),
        ),
        IconButton(
          key: ValueKey('$keyPrefix-increment'),
          icon: const Icon(Icons.add),
          onPressed: _canIncrement
              ? () => onChanged(normalizeStepValue(value + step))
              : null,
        ),
      ],
    );
  }
}
