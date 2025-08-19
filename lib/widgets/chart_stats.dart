import 'package:flutter/material.dart';
import '../services/chart_service.dart';
import '../utils/chart_constants.dart';

class ChartStats extends StatelessWidget {
  final ChartData chartData;

  const ChartStats({
    super.key,
    required this.chartData,
  });

  @override
  Widget build(BuildContext context) {
    if (chartData.entries.isEmpty) {
      return const SizedBox.shrink();
    }

    final weightStats = _calculateWeightStats();
    final volumeStats = _calculateVolumeStats();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _StatItem(
          label: 'Weight Change',
          value: weightStats.value,
          color: weightStats.color,
          icon: weightStats.icon,
        ),
        _StatItem(
          label: 'Volume Change',
          value: volumeStats.value,
          color: volumeStats.color,
          icon: volumeStats.icon,
        ),
        _StatItem(
          label: 'Sessions',
          value: '${chartData.entries.length}',
          color: Colors.grey[600]!,
          icon: Icons.event_note,
        ),
      ],
    );
  }

  _StatData _calculateWeightStats() {
    final weightsOnly = chartData.entries.where((entry) => 
      _extractNumericWeight(entry.weight) != null).toList();
    
    if (weightsOnly.isEmpty) {
      return _StatData(
        value: 'N/A',
        color: Colors.grey[600]!,
        icon: Icons.trending_flat,
      );
    }

    if (weightsOnly.length == 1) {
      return _StatData(
        value: '0.0kg',
        color: Colors.grey[600]!,
        icon: Icons.trending_flat,
      );
    }

    final firstWeight = _extractNumericWeight(weightsOnly.first.weight) ?? 0;
    final lastWeight = _extractNumericWeight(weightsOnly.last.weight) ?? 0;
    final difference = lastWeight - firstWeight;
    
    if (difference > 0) {
      return _StatData(
        value: '+${difference.toStringAsFixed(1)}kg',
        color: Colors.green,
        icon: Icons.trending_up,
      );
    } else if (difference < 0) {
      return _StatData(
        value: '${difference.toStringAsFixed(1)}kg',
        color: Colors.red,
        icon: Icons.trending_down,
      );
    } else {
      return _StatData(
        value: '0.0kg',
        color: Colors.grey[600]!,
        icon: Icons.trending_flat,
      );
    }
  }

  _StatData _calculateVolumeStats() {
    if (chartData.entries.isEmpty) {
      return _StatData(
        value: 'N/A',
        color: Colors.grey[600]!,
        icon: Icons.trending_flat,
      );
    }

    final firstEntry = chartData.entries.first;
    final lastEntry = chartData.entries.last;
    
    final firstVolume = firstEntry.hasDetailedSets ? firstEntry.totalReps : 1;
    final lastVolume = lastEntry.hasDetailedSets ? lastEntry.totalReps : 1;
    
    if (chartData.entries.length == 1) {
      return _StatData(
        value: '0',
        color: Colors.grey[600]!,
        icon: Icons.trending_flat,
      );
    }

    final difference = lastVolume - firstVolume;
    
    if (difference > 0) {
      return _StatData(
        value: '+$difference',
        color: Colors.green,
        icon: Icons.trending_up,
      );
    } else if (difference < 0) {
      return _StatData(
        value: '$difference',
        color: Colors.red,
        icon: Icons.trending_down,
      );
    } else {
      return _StatData(
        value: '0',
        color: Colors.grey[600]!,
        icon: Icons.trending_flat,
      );
    }
  }

  double? _extractNumericWeight(String weight) {
    final regex = RegExp(r'(\d+(?:\.\d+)?)');
    final match = regex.firstMatch(weight);
    return match != null ? double.tryParse(match.group(1)!) : null;
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: ChartConstants.statIconSize,
        ),
        const SizedBox(height: ChartConstants.tinySpacing),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: ChartConstants.statValueFontSize,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: ChartConstants.statLabelFontSize,
          ),
        ),
      ],
    );
  }
}

class _StatData {
  final String value;
  final Color color;
  final IconData icon;

  _StatData({
    required this.value,
    required this.color,
    required this.icon,
  });
}