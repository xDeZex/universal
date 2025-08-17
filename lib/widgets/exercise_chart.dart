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
    return FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: chartData.weightInterval,
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: Colors.grey.withValues(alpha: ChartConstants.gridAlpha),
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
          showTitles: showVolume && chartData.volumeSpots.isNotEmpty,
          reservedSize: ChartConstants.reservedSizeStandard,
          interval: chartData.volumeInterval,
          getTitlesWidget: (value, meta) => _RightTitle(value: value, chartData: chartData),
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
          showTitles: showWeight && chartData.weightSpots.isNotEmpty,
          interval: chartData.weightInterval,
          reservedSize: ChartConstants.reservedSizeStandard,
          getTitlesWidget: (value, meta) => _LeftTitle(value: value, chartData: chartData),
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
            final sets = entry.sets ?? 1;
            final reps = entry.reps ?? 1;
            final volume = sets * reps;
            
            String text = '';
            if (spot.barIndex == 0 && showWeight) {
              text = 'Weight: ${entry.weight}';
            } else if (spot.barIndex == 1 && showVolume) {
              text = 'Volume: $volume ($sets×$reps)';
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

  const _LeftTitle({
    required this.value,
    required this.chartData,
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
        color: Theme.of(context).colorScheme.primary,
        fontSize: ChartConstants.axisTitleFontSize,
      ),
    );
  }
}

class _RightTitle extends StatelessWidget {
  final double value;
  final ChartData chartData;

  const _RightTitle({
    required this.value,
    required this.chartData,
  });

  @override
  Widget build(BuildContext context) {
    final weightRatio = (value - chartData.minWeightY) / (chartData.maxWeightY - chartData.minWeightY);
    final volumeValue = chartData.minVolumeY + weightRatio * (chartData.maxVolumeY - chartData.minVolumeY);
    
    final interval = chartData.volumeInterval;
    final roundedValue = (volumeValue / interval).round() * interval;
    
    if ((volumeValue - roundedValue).abs() > interval * ChartConstants.volumeIntervalToleranceRatio) {
      return const SizedBox.shrink();
    }
    
    final volumeRange = chartData.maxVolumeY - chartData.minVolumeY;
    if (volumeRange < ChartConstants.volumeRangeSmall) {
      final minVal = chartData.minVolumeY.round();
      final maxVal = chartData.maxVolumeY.round();
      if (roundedValue.round() != minVal && roundedValue.round() != maxVal) {
        return const SizedBox.shrink();
      }
    } else {
      if (roundedValue <= chartData.minVolumeY + volumeRange * ChartConstants.edgeFilterRatio || 
          roundedValue >= chartData.maxVolumeY - volumeRange * ChartConstants.edgeFilterRatio) {
        return const SizedBox.shrink();
      }
    }
    
    return Padding(
      padding: const EdgeInsets.only(left: ChartConstants.rightTitleLeftPadding),
      child: Text(
        '${roundedValue.round()}',
        style: const TextStyle(
          color: Colors.orange,
          fontSize: ChartConstants.axisTitleFontSize,
        ),
      ),
    );
  }
}