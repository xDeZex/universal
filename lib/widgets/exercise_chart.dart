import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/chart_service.dart';
import '../utils/chart_constants.dart';

class ExerciseChart extends StatelessWidget {
  final ChartData chartData;
  final bool showWeight;
  final bool showVolume;

  const ExerciseChart({
    super.key,
    required this.chartData,
    required this.showWeight,
    required this.showVolume,
  });

  @override
  Widget build(BuildContext context) {
    if (chartData.weightSpots.isEmpty && chartData.volumeSpots.isEmpty) {
      return const SizedBox(
        height: ChartConstants.chartHeight,
        child: Center(
          child: Text(
            'No data to display',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return SizedBox(
      height: ChartConstants.chartHeight,
      child: LineChart(
        LineChartData(
          gridData: _buildGridData(),
          titlesData: _buildTitlesData(context),
          borderData: _buildBorderData(),
          minX: chartData.minX,
          maxX: chartData.maxX,
          minY: chartData.minWeightY,
          maxY: chartData.maxWeightY,
          lineBarsData: _buildLineChartBars(context),
          lineTouchData: _buildLineTouchData(),
        ),
      ),
    );
  }

  FlGridData _buildGridData() {
    final gridAlpha = (showWeight || showVolume) ? ChartConstants.gridAlpha : ChartConstants.gridAlpha * 0.5;
    return FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: chartData.weightInterval,
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: Colors.grey.withValues(alpha: gridAlpha),
          strokeWidth: ChartConstants.gridLineStrokeWidth,
        );
      },
    );
  }

  FlTitlesData _buildTitlesData(BuildContext context) {
    return FlTitlesData(
      show: true,
      rightTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: chartData.volumeSpots.isNotEmpty,
          reservedSize: ChartConstants.reservedSizeStandard,
          interval: chartData.volumeInterval,
          getTitlesWidget: (value, meta) => _RightTitle(value: value, chartData: chartData, showVolume: showVolume),
        ),
      ),
      topTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: ChartConstants.reservedSizeBottom,
          interval: chartData.bottomInterval,
          getTitlesWidget: (value, meta) => _BottomTitle(value: value, chartData: chartData),
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: chartData.weightSpots.isNotEmpty,
          interval: chartData.weightInterval,
          reservedSize: ChartConstants.reservedSizeStandard,
          getTitlesWidget: (value, meta) => _LeftTitle(value: value, chartData: chartData, showWeight: showWeight),
        ),
      ),
    );
  }

  FlBorderData _buildBorderData() {
    return FlBorderData(
      show: true,
      border: Border.all(color: Colors.grey.withValues(alpha: ChartConstants.gridAlpha)),
    );
  }

  List<LineChartBarData> _buildLineChartBars(BuildContext context) {
    final bars = <LineChartBarData>[];
    
    if (showWeight && chartData.weightSpots.isNotEmpty) {
      bars.add(_createWeightLine(context));
    }
    
    if (showVolume && chartData.volumeSpots.isNotEmpty) {
      bars.add(_createVolumeLine());
    }
    
    return bars;
  }

  LineChartBarData _createWeightLine(BuildContext context) {
    return LineChartBarData(
      spots: chartData.weightSpots,
      isCurved: false,
      color: Theme.of(context).colorScheme.primary,
      barWidth: ChartConstants.lineWidth,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: ChartConstants.dotRadius,
            color: Theme.of(context).colorScheme.primary,
            strokeWidth: ChartConstants.dotStrokeWidth,
            strokeColor: Colors.white,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        color: Theme.of(context).colorScheme.primary.withValues(alpha: ChartConstants.belowBarAlpha),
      ),
    );
  }

  LineChartBarData _createVolumeLine() {
    final scaledVolumeSpots = chartData.volumeSpots.map((spot) {
      final volumeRatio = (spot.y - chartData.minVolumeY) / (chartData.maxVolumeY - chartData.minVolumeY);
      final scaledY = chartData.minWeightY + volumeRatio * (chartData.maxWeightY - chartData.minWeightY);
      return FlSpot(spot.x, scaledY);
    }).toList();
    
    return LineChartBarData(
      spots: scaledVolumeSpots,
      isCurved: false,
      color: Colors.orange,
      barWidth: ChartConstants.lineWidth,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: ChartConstants.dotRadius,
            color: Colors.orange,
            strokeWidth: ChartConstants.dotStrokeWidth,
            strokeColor: Colors.white,
          );
        },
      ),
    );
  }

  LineTouchData _buildLineTouchData() {
    return LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        getTooltipItems: (touchedSpots) {
          return touchedSpots.map((spot) {
            final entry = chartData.entries[spot.spotIndex];
            final volume = entry.hasDetailedSets ? entry.totalReps : 1;
            
            String text = '';
            if (spot.barIndex == 0 && showWeight) {
              text = 'Weight: ${entry.weight}';
            } else if (spot.barIndex == 1 && showVolume) {
              text = 'Volume: $volume';
            }
            text += '\n${_formatTooltipDate(entry.date)}';
            
            return LineTooltipItem(
              text,
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            );
          }).toList();
        },
      ),
    );
  }

  String _formatTooltipDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _BottomTitle extends StatelessWidget {
  final double value;
  final ChartData chartData;

  const _BottomTitle({
    required this.value,
    required this.chartData,
  });

  @override
  Widget build(BuildContext context) {
    if (value < 0 || value.round() >= chartData.entries.length) {
      return const SizedBox.shrink();
    }
    
    final entry = chartData.entries[value.round()];
    final dateText = _formatBottomDate(entry.date);
    
    return Padding(
      padding: const EdgeInsets.only(top: ChartConstants.bottomTitleTopPadding),
      child: Text(
        dateText,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: ChartConstants.axisTitleFontSize,
        ),
      ),
    );
  }

  String _formatBottomDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '${difference}d ago';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}

class _LeftTitle extends StatelessWidget {
  final double value;
  final ChartData chartData;
  final bool showWeight;

  const _LeftTitle({
    required this.value,
    required this.chartData,
    required this.showWeight,
  });

  @override
  Widget build(BuildContext context) {
    final roundedValue = (value / chartData.weightInterval).round() * chartData.weightInterval;
    
    if ((value - roundedValue).abs() > chartData.weightInterval * ChartConstants.intervalToleranceRatio) {
      return const SizedBox.shrink();
    }
    
    if (value <= chartData.minWeightY + chartData.weightInterval * ChartConstants.edgeFilterRatio || 
        value >= chartData.maxWeightY - chartData.weightInterval * ChartConstants.edgeFilterRatio) {
      return const SizedBox.shrink();
    }
    
    return Text(
      '${roundedValue.round()}kg',
      style: TextStyle(
        color: showWeight 
          ? Theme.of(context).colorScheme.primary 
          : Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        fontSize: ChartConstants.axisTitleFontSize,
      ),
    );
  }
}

class _RightTitle extends StatelessWidget {
  final double value;
  final ChartData chartData;
  final bool showVolume;

  const _RightTitle({
    required this.value,
    required this.chartData,
    required this.showVolume,
  });

  @override
  Widget build(BuildContext context) {
    // Convert from weight axis scale back to volume scale
    final weightRatio = (value - chartData.minWeightY) / (chartData.maxWeightY - chartData.minWeightY);
    final volumeValue = chartData.minVolumeY + weightRatio * (chartData.maxVolumeY - chartData.minVolumeY);
    
    // Use same simple logic as weight axis for consistency
    final interval = chartData.volumeInterval;
    final roundedValue = (volumeValue / interval).round() * interval;
    
    // Simple tolerance check like weight axis
    if ((volumeValue - roundedValue).abs() > interval * ChartConstants.intervalToleranceRatio) {
      return const SizedBox.shrink();
    }
    
    // Simple edge filtering like weight axis
    if (roundedValue <= chartData.minVolumeY + interval * ChartConstants.edgeFilterRatio || 
        roundedValue >= chartData.maxVolumeY - interval * ChartConstants.edgeFilterRatio) {
      return const SizedBox.shrink();
    }
    
    return Padding(
      padding: const EdgeInsets.only(left: ChartConstants.rightTitleLeftPadding),
      child: Text(
        '${roundedValue.round()}',
        style: TextStyle(
          color: showVolume 
            ? Colors.orange 
            : Colors.orange.withValues(alpha: 0.3),
          fontSize: ChartConstants.axisTitleFontSize,
        ),
      ),
    );
  }
}