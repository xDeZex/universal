import 'package:flutter/material.dart';
import '../utils/chart_constants.dart';

class ChartLegend extends StatelessWidget {
  final bool showWeight;
  final bool showVolume;
  final VoidCallback onWeightToggle;
  final VoidCallback onVolumeToggle;

  const ChartLegend({
    super.key,
    required this.showWeight,
    required this.showVolume,
    required this.onWeightToggle,
    required this.onVolumeToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(
          label: 'Weight',
          color: showWeight ? Theme.of(context).colorScheme.primary : Colors.grey,
          isActive: showWeight,
          onTap: onWeightToggle,
        ),
        const SizedBox(width: ChartConstants.legendSpacing),
        _LegendItem(
          label: 'Volume',
          color: showVolume ? Colors.orange : Colors.grey,
          isActive: showVolume,
          onTap: onVolumeToggle,
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;

  const _LegendItem({
    required this.label,
    required this.color,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: ChartConstants.legendLineWidth,
            height: ChartConstants.legendLineHeight,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(ChartConstants.legendBorderRadius),
            ),
          ),
          const SizedBox(width: ChartConstants.legendItemSpacing),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: ChartConstants.legendFontSize,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}