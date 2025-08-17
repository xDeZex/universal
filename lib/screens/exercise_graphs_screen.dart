import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/shopping_app_state.dart';
import '../models/weight_entry.dart';
import '../models/exercise_history.dart';

enum TimeInterval {
  week(7, 'Week'),
  month(30, 'Month'),
  threeMonths(90, '3 Months'),
  sixMonths(180, '6 Months'),
  year(365, 'Year'),
  all(0, 'All Time');

  const TimeInterval(this.days, this.label);
  final int days;
  final String label;
}

class ExerciseGraphsScreen extends StatefulWidget {
  const ExerciseGraphsScreen({super.key});

  @override
  State<ExerciseGraphsScreen> createState() => _ExerciseGraphsScreenState();
}

class _ExerciseGraphsScreenState extends State<ExerciseGraphsScreen> {
  TimeInterval _selectedInterval = TimeInterval.threeMonths;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Consumer<ShoppingAppState>(
        builder: (context, appState, child) => _buildBody(context, appState),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Exercise Progress'),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      actions: [
        PopupMenuButton<TimeInterval>(
          icon: const Icon(Icons.calendar_today),
          tooltip: 'Time Period',
          onSelected: (TimeInterval interval) {
            setState(() {
              _selectedInterval = interval;
            });
          },
          itemBuilder: (BuildContext context) {
            return TimeInterval.values.map((TimeInterval interval) {
              return PopupMenuItem<TimeInterval>(
                value: interval,
                child: Row(
                  children: [
                    Icon(
                      interval == _selectedInterval ? Icons.check : Icons.access_time,
                      size: 20,
                      color: interval == _selectedInterval 
                        ? Theme.of(context).colorScheme.primary 
                        : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      interval.label,
                      style: TextStyle(
                        color: interval == _selectedInterval 
                          ? Theme.of(context).colorScheme.primary 
                          : null,
                        fontWeight: interval == _selectedInterval 
                          ? FontWeight.bold 
                          : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }).toList();
          },
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, ShoppingAppState appState) {
    final exerciseHistories = appState.getAllExerciseHistoriesWithWeights();
    
    if (exerciseHistories.isEmpty) {
      return _buildEmptyState();
    }

    // Sort exercises by most recent activity
    final sortedExercises = List<ExerciseHistory>.from(exerciseHistories)
      ..sort((a, b) => b.lastUsed.compareTo(a.lastUsed));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedExercises.length,
      itemBuilder: (context, index) => _buildExerciseGraphCard(context, sortedExercises[index], _selectedInterval),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No exercise data yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Start logging weights to see progress graphs',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseGraphCard(BuildContext context, ExerciseHistory exerciseHistory, TimeInterval timeInterval) {
    final chartData = _prepareChartData(exerciseHistory, timeInterval);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader(context, exerciseHistory, chartData),
            const SizedBox(height: 16),
            _buildProgressChart(context, chartData),
            const SizedBox(height: 12),
            _buildChartStats(context, chartData),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader(BuildContext context, ExerciseHistory exerciseHistory, ChartData chartData) {
    // Use latest entry from filtered data, fall back to all data if no filtered entries
    final latestEntry = chartData.entries.isNotEmpty 
      ? chartData.entries.reduce((a, b) => a.date.isAfter(b.date) ? a : b)
      : exerciseHistory.weightHistory.reduce((a, b) => a.date.isAfter(b.date) ? a : b);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                exerciseHistory.exerciseName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${chartData.entries.length} entr${chartData.entries.length == 1 ? 'y' : 'ies'}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              latestEntry.weight,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Text(
              'Latest',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressChart(BuildContext context, ChartData chartData) {
    if (chartData.spots.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'No weight data to display',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: chartData.horizontalInterval,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withValues(alpha: 0.3),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: chartData.bottomInterval,
                getTitlesWidget: (value, meta) => _buildBottomTitle(value, chartData),
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: chartData.horizontalInterval,
                reservedSize: 50,
                getTitlesWidget: (value, meta) => _buildLeftTitle(value, chartData),
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
          ),
          minX: chartData.minX,
          maxX: chartData.maxX,
          minY: chartData.minY,
          maxY: chartData.maxY,
          lineBarsData: [
            LineChartBarData(
              spots: chartData.spots,
              isCurved: false, // Use straight lines for accurate representation
              color: Theme.of(context).colorScheme.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 5, // Slightly larger dots to emphasize actual data points
                    color: Theme.of(context).colorScheme.primary,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final entry = chartData.entries[spot.spotIndex];
                  return LineTooltipItem(
                    '${entry.weight}\n${_formatTooltipDate(entry.date)}',
                    TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomTitle(double value, ChartData chartData) {
    if (value < 0 || value.round() >= chartData.entries.length) {
      return const SizedBox.shrink();
    }
    
    final entry = chartData.entries[value.round()];
    final dateText = _formatBottomDate(entry.date);
    
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        dateText,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildLeftTitle(double value, ChartData chartData) {
    // Only show labels that are nicely aligned with our interval and not too close to edges
    final roundedValue = (value / chartData.horizontalInterval).round() * chartData.horizontalInterval;
    
    // Don't show label if it's too close to the actual value (floating point precision issues)
    if ((value - roundedValue).abs() > chartData.horizontalInterval * 0.1) {
      return const SizedBox.shrink();
    }
    
    // Don't show labels too close to the chart edges
    if (value <= chartData.minY + chartData.horizontalInterval * 0.1 || 
        value >= chartData.maxY - chartData.horizontalInterval * 0.1) {
      return const SizedBox.shrink();
    }
    
    return Text(
      '${roundedValue.round()}kg',
      style: TextStyle(
        color: Colors.grey[600],
        fontSize: 10,
      ),
    );
  }

  Widget _buildChartStats(BuildContext context, ChartData chartData) {
    if (chartData.entries.length < 2) {
      return const SizedBox.shrink();
    }

    final firstWeight = _extractNumericWeight(chartData.entries.first.weight) ?? 0;
    final lastWeight = _extractNumericWeight(chartData.entries.last.weight) ?? 0;
    final difference = lastWeight - firstWeight;
    final isIncrease = difference > 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          'Total Progress',
          '${difference > 0 ? '+' : ''}${difference.toStringAsFixed(1)}kg',
          isIncrease ? Colors.green : difference < 0 ? Colors.red : Colors.grey,
          isIncrease ? Icons.trending_up : difference < 0 ? Icons.trending_down : Icons.trending_flat,
        ),
        _buildStatItem(
          'Best Session',
          chartData.entries.reduce((a, b) {
            final aWeight = _extractNumericWeight(a.weight) ?? 0;
            final bWeight = _extractNumericWeight(b.weight) ?? 0;
            return aWeight > bWeight ? a : b;
          }).weight,
          Theme.of(context).colorScheme.primary,
          Icons.star,
        ),
        _buildStatItem(
          'Sessions',
          '${chartData.entries.length}',
          Colors.grey[600]!,
          Icons.fitness_center,
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 16,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  ChartData _prepareChartData(ExerciseHistory exerciseHistory, TimeInterval timeInterval) {
    // Filter entries based on time interval
    final now = DateTime.now();
    final cutoffDate = timeInterval == TimeInterval.all 
      ? DateTime(1970) // Very old date to include all entries
      : now.subtract(Duration(days: timeInterval.days));
    
    final filteredEntries = exerciseHistory.weightHistory
      .where((entry) => entry.date.isAfter(cutoffDate))
      .toList();
    
    final entries = List<WeightEntry>.from(filteredEntries)
      ..sort((a, b) => a.date.compareTo(b.date));

    if (entries.isEmpty) {
      return ChartData(
        spots: [],
        entries: [],
        minX: 0,
        maxX: 1,
        minY: 0,
        maxY: 100,
        horizontalInterval: 10,
        bottomInterval: 1,
      );
    }

    final spots = <FlSpot>[];
    final weights = <double>[];

    for (int i = 0; i < entries.length; i++) {
      final weight = _extractNumericWeight(entries[i].weight);
      if (weight != null) {
        spots.add(FlSpot(i.toDouble(), weight));
        weights.add(weight);
      }
    }

    if (weights.isEmpty) {
      return ChartData(
        spots: [],
        entries: entries,
        minX: 0,
        maxX: entries.length.toDouble(),
        minY: 0,
        maxY: 100,
        horizontalInterval: 10,
        bottomInterval: 1,
      );
    }

    final minWeight = weights.reduce((a, b) => a < b ? a : b);
    final maxWeight = weights.reduce((a, b) => a > b ? a : b);
    final weightRange = maxWeight - minWeight;
    
    // Add padding, but ensure we have a minimum range for better visualization
    final paddingAmount = weightRange > 0 ? weightRange * 0.1 : 5.0;
    final minY = (minWeight - paddingAmount).clamp(0.0, double.infinity);
    final maxY = maxWeight + paddingAmount;
    
    // Calculate interval that works well with the range and avoids overlapping labels
    final range = maxY - minY;
    final horizontalInterval = _calculateOptimalInterval(range, minY, maxY);

    final bottomInterval = entries.length > 10 ? (entries.length / 5).round().toDouble() : 1.0;

    return ChartData(
      spots: spots,
      entries: entries,
      minX: 0,
      maxX: entries.length > 1 ? (entries.length - 1).toDouble() : 1,
      minY: minY,
      maxY: maxY,
      horizontalInterval: horizontalInterval,
      bottomInterval: bottomInterval,
    );
  }

  double _calculateOptimalInterval(double range, double minY, double maxY) {
    if (range <= 0) return 5.0;
    
    // Target 4-6 intervals for good readability
    final targetIntervals = 5;
    final roughInterval = range / targetIntervals;
    
    // Find a nice round number for the interval
    final magnitude = _getMagnitude(roughInterval);
    final normalizedInterval = roughInterval / magnitude;
    
    double niceInterval;
    if (normalizedInterval <= 1) {
      niceInterval = magnitude;
    } else if (normalizedInterval <= 2) {
      niceInterval = magnitude * 2;
    } else if (normalizedInterval <= 5) {
      niceInterval = magnitude * 5;
    } else {
      niceInterval = magnitude * 10;
    }
    
    // Ensure the interval doesn't result in too many ticks
    final numberOfTicks = (range / niceInterval).ceil();
    if (numberOfTicks > 8) {
      niceInterval = niceInterval * 2;
    }
    
    return niceInterval;
  }
  
  double _getMagnitude(double value) {
    if (value <= 0) return 1.0;
    return math.pow(10, (math.log(value) / math.ln10).floor()).toDouble();
  }

  double? _extractNumericWeight(String weight) {
    final regex = RegExp(r'(\d+(?:\.\d+)?)');
    final match = regex.firstMatch(weight);
    return match != null ? double.tryParse(match.group(1)!) : null;
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

  String _formatTooltipDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class ChartData {
  final List<FlSpot> spots;
  final List<WeightEntry> entries;
  final double minX;
  final double maxX;
  final double minY;
  final double maxY;
  final double horizontalInterval;
  final double bottomInterval;

  const ChartData({
    required this.spots,
    required this.entries,
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
    required this.horizontalInterval,
    required this.bottomInterval,
  });
}