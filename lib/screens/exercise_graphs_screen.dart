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
  bool _showWeight = true;
  bool _showVolume = true;

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
            _buildChartLegend(context),
            const SizedBox(height: 8),
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
    if (chartData.weightSpots.isEmpty && chartData.volumeSpots.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'No data to display',
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
            rightTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: _showVolume && chartData.volumeSpots.isNotEmpty,
                reservedSize: 50,
                interval: chartData.volumeInterval,
                getTitlesWidget: (value, meta) => _buildRightTitle(value, chartData),
              ),
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
                showTitles: _showWeight && chartData.weightSpots.isNotEmpty,
                interval: chartData.weightInterval,
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
          minY: chartData.minWeightY,
          maxY: chartData.maxWeightY,
          lineBarsData: _buildLineChartBars(context, chartData),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final entry = chartData.entries[spot.spotIndex];
                  final sets = entry.sets ?? 1;
                  final reps = entry.reps ?? 1;
                  final volume = sets * reps;
                  
                  String text = '';
                  if (spot.barIndex == 0 && _showWeight) {
                    text = 'Weight: ${entry.weight}';
                  } else if (spot.barIndex == 1 && _showVolume) {
                    text = 'Volume: ${volume} (${sets}×${reps})';
                  }
                  text += '\n${_formatTooltipDate(entry.date)}';
                  
                  return LineTooltipItem(
                    text,
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

  List<LineChartBarData> _buildLineChartBars(BuildContext context, ChartData chartData) {
    final bars = <LineChartBarData>[];
    
    // Weight line
    if (_showWeight && chartData.weightSpots.isNotEmpty) {
      bars.add(
        LineChartBarData(
          spots: chartData.weightSpots,
          isCurved: false,
          color: Theme.of(context).colorScheme.primary,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 5,
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
      );
    }
    
    // Volume line (scaled to weight axis range)
    if (_showVolume && chartData.volumeSpots.isNotEmpty) {
      final scaledVolumeSpots = chartData.volumeSpots.map((spot) {
        // Scale volume to weight axis range
        final volumeRatio = (spot.y - chartData.minVolumeY) / (chartData.maxVolumeY - chartData.minVolumeY);
        final scaledY = chartData.minWeightY + volumeRatio * (chartData.maxWeightY - chartData.minWeightY);
        return FlSpot(spot.x, scaledY);
      }).toList();
      
      bars.add(
        LineChartBarData(
          spots: scaledVolumeSpots,
          isCurved: false,
          color: Colors.orange,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 5,
                color: Colors.orange,
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
          ),
        ),
      );
    }
    
    return bars;
  }

  Widget _buildLeftTitle(double value, ChartData chartData) {
    // Only show labels that are nicely aligned with our interval and not too close to edges
    final roundedValue = (value / chartData.weightInterval).round() * chartData.weightInterval;
    
    // Don't show label if it's too close to the actual value (floating point precision issues)
    if ((value - roundedValue).abs() > chartData.weightInterval * 0.1) {
      return const SizedBox.shrink();
    }
    
    // Don't show labels too close to the chart edges
    if (value <= chartData.minWeightY + chartData.weightInterval * 0.1 || 
        value >= chartData.maxWeightY - chartData.weightInterval * 0.1) {
      return const SizedBox.shrink();
    }
    
    return Text(
      '${roundedValue.round()}kg',
      style: TextStyle(
        color: Theme.of(context).colorScheme.primary,
        fontSize: 10,
      ),
    );
  }

  Widget _buildRightTitle(double value, ChartData chartData) {
    // Convert from weight axis scale back to volume scale
    final weightRatio = (value - chartData.minWeightY) / (chartData.maxWeightY - chartData.minWeightY);
    final volumeValue = chartData.minVolumeY + weightRatio * (chartData.maxVolumeY - chartData.minVolumeY);
    
    // Use interval-based rounding to prevent duplicates
    final interval = chartData.volumeInterval;
    final roundedValue = (volumeValue / interval).round() * interval;
    
    // Don't show label if it's not close enough to the calculated position
    if ((volumeValue - roundedValue).abs() > interval * 0.3) {
      return const SizedBox.shrink();
    }
    
    // Filter out labels too close to edges
    final volumeRange = chartData.maxVolumeY - chartData.minVolumeY;
    if (volumeRange < 3) {
      // For very small ranges, only show min and max
      final minVal = chartData.minVolumeY.round();
      final maxVal = chartData.maxVolumeY.round();
      if (roundedValue.round() != minVal && roundedValue.round() != maxVal) {
        return const SizedBox.shrink();
      }
    } else {
      // For normal ranges, avoid edge labels
      if (roundedValue <= chartData.minVolumeY + volumeRange * 0.1 || 
          roundedValue >= chartData.maxVolumeY - volumeRange * 0.1) {
        return const SizedBox.shrink();
      }
    }
    
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Text(
        '${roundedValue.round()}',
        style: TextStyle(
          color: Colors.orange,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildChartLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _showWeight = !_showWeight;
            });
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 3,
                decoration: BoxDecoration(
                  color: _showWeight ? Theme.of(context).colorScheme.primary : Colors.grey,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Weight',
                style: TextStyle(
                  color: _showWeight ? Theme.of(context).colorScheme.primary : Colors.grey,
                  fontSize: 12,
                  fontWeight: _showWeight ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        GestureDetector(
          onTap: () {
            setState(() {
              _showVolume = !_showVolume;
            });
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 3,
                decoration: BoxDecoration(
                  color: _showVolume ? Colors.orange : Colors.grey,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Volume',
                style: TextStyle(
                  color: _showVolume ? Colors.orange : Colors.grey,
                  fontSize: 12,
                  fontWeight: _showVolume ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChartStats(BuildContext context, ChartData chartData) {
    if (chartData.entries.isEmpty) {
      return const SizedBox.shrink();
    }

    // Calculate weight change
    String weightChange = 'N/A';
    Color weightColor = Colors.grey[600]!;
    IconData weightIcon = Icons.trending_flat;
    
    final weightsOnly = chartData.entries.where((entry) => 
      _extractNumericWeight(entry.weight) != null).toList();
    
    if (weightsOnly.isNotEmpty) {
      if (weightsOnly.length == 1) {
        // Single entry should show 0, not N/A
        weightChange = '0.0kg';
        weightColor = Colors.grey[600]!;
        weightIcon = Icons.trending_flat;
      } else {
        // Multiple entries - calculate difference
        final firstWeight = _extractNumericWeight(weightsOnly.first.weight) ?? 0;
        final lastWeight = _extractNumericWeight(weightsOnly.last.weight) ?? 0;
        final difference = lastWeight - firstWeight;
        
        if (difference > 0) {
          weightChange = '+${difference.toStringAsFixed(1)}kg';
          weightColor = Colors.green;
          weightIcon = Icons.trending_up;
        } else if (difference < 0) {
          weightChange = '${difference.toStringAsFixed(1)}kg';
          weightColor = Colors.red;
          weightIcon = Icons.trending_down;
        } else {
          weightChange = '0.0kg';
          weightColor = Colors.grey[600]!;
          weightIcon = Icons.trending_flat;
        }
      }
    }

    // Calculate volume change
    String volumeChange = 'N/A';
    Color volumeColor = Colors.grey[600]!;
    IconData volumeIcon = Icons.trending_flat;
    
    // Check if we have any entries at all
    if (chartData.entries.isNotEmpty) {
      // Calculate volume for all entries (using defaults for missing sets/reps)
      final firstEntry = chartData.entries.first;
      final lastEntry = chartData.entries.last;
      
      final firstVolume = (firstEntry.sets ?? 1) * (firstEntry.reps ?? 1);
      final lastVolume = (lastEntry.sets ?? 1) * (lastEntry.reps ?? 1);
      
      if (chartData.entries.length == 1) {
        // Single entry should show 0, not N/A
        volumeChange = '0';
        volumeColor = Colors.grey[600]!;
        volumeIcon = Icons.trending_flat;
      } else {
        // Multiple entries - calculate difference
        final difference = lastVolume - firstVolume;
        
        if (difference > 0) {
          volumeChange = '+$difference';
          volumeColor = Colors.green;
          volumeIcon = Icons.trending_up;
        } else if (difference < 0) {
          volumeChange = '$difference';
          volumeColor = Colors.red;
          volumeIcon = Icons.trending_down;
        } else {
          volumeChange = '0';
          volumeColor = Colors.grey[600]!;
          volumeIcon = Icons.trending_flat;
        }
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          'Weight Change',
          weightChange,
          weightColor,
          weightIcon,
        ),
        _buildStatItem(
          'Volume Change',
          volumeChange,
          volumeColor,
          volumeIcon,
        ),
        _buildStatItem(
          'Sessions',
          '${chartData.entries.length}',
          Colors.grey[600]!,
          Icons.event_note,
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
        weightSpots: [],
        volumeSpots: [],
        entries: [],
        minX: 0,
        maxX: 1,
        minWeightY: 0,
        maxWeightY: 100,
        minVolumeY: 0,
        maxVolumeY: 50,
        weightInterval: 10,
        volumeInterval: 10,
        bottomInterval: 1,
      );
    }

    final weightSpots = <FlSpot>[];
    final volumeSpots = <FlSpot>[];
    final weights = <double>[];
    final volumes = <double>[];

    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final weight = _extractNumericWeight(entry.weight);
      
      if (weight != null) {
        weightSpots.add(FlSpot(i.toDouble(), weight));
        weights.add(weight);
      }
      
      // Calculate volume (sets × reps)
      final sets = entry.sets ?? 1;
      final reps = entry.reps ?? 1;
      final volume = (sets * reps).toDouble();
      
      // Only add volume data if we have meaningful sets/reps information
      if (entry.sets != null && entry.reps != null) {
        volumeSpots.add(FlSpot(i.toDouble(), volume));
        volumes.add(volume);
      } else {
        // Still add a spot for consistent indexing, but use default volume
        volumeSpots.add(FlSpot(i.toDouble(), 1.0));
        volumes.add(1.0);
      }
    }

    if (weights.isEmpty && volumes.isEmpty) {
      return ChartData(
        weightSpots: [],
        volumeSpots: [],
        entries: entries,
        minX: 0,
        maxX: entries.length.toDouble(),
        minWeightY: 0,
        maxWeightY: 100,
        minVolumeY: 0,
        maxVolumeY: 50,
        weightInterval: 10,
        volumeInterval: 10,
        bottomInterval: 1,
      );
    }

    // Calculate weight range and scaling
    double minWeightY = 0;
    double maxWeightY = 100;
    double weightInterval = 10;
    
    if (weights.isNotEmpty) {
      final minWeight = weights.reduce((a, b) => a < b ? a : b);
      final maxWeight = weights.reduce((a, b) => a > b ? a : b);
      final weightRange = maxWeight - minWeight;
      
      final paddingAmount = weightRange > 0 ? weightRange * 0.1 : 5.0;
      minWeightY = (minWeight - paddingAmount).clamp(0.0, double.infinity);
      maxWeightY = maxWeight + paddingAmount;
      
      final range = maxWeightY - minWeightY;
      weightInterval = _calculateOptimalInterval(range, minWeightY, maxWeightY);
    }
    
    // Calculate volume range and scaling
    double minVolumeY = 0;
    double maxVolumeY = 50;
    double volumeInterval = 10;
    
    if (volumes.isNotEmpty) {
      final minVolume = volumes.reduce((a, b) => a < b ? a : b);
      final maxVolume = volumes.reduce((a, b) => a > b ? a : b);
      final volumeRange = maxVolume - minVolume;
      
      // Use smaller padding for volumes to ensure better label visibility
      final paddingAmount = volumeRange > 0 ? volumeRange * 0.15 : 2.0;
      minVolumeY = (minVolume - paddingAmount).clamp(0.0, double.infinity);
      maxVolumeY = maxVolume + paddingAmount;
      
      final range = maxVolumeY - minVolumeY;
      
      // Ensure volume interval is appropriate for the range
      if (range <= 3) {
        volumeInterval = 1; // Use interval of 1 for very small ranges
      } else if (range <= 8) {
        volumeInterval = 2; // Use interval of 2 for small ranges
      } else if (range <= 15) {
        volumeInterval = 5; // Use interval of 5 for medium ranges
      } else {
        volumeInterval = _calculateOptimalInterval(range, minVolumeY, maxVolumeY);
        // Ensure volume interval is at least 2 to avoid too many labels
        volumeInterval = volumeInterval.clamp(2.0, double.infinity);
      }
    }

    final bottomInterval = entries.length > 10 ? (entries.length / 5).round().toDouble() : 1.0;

    return ChartData(
      weightSpots: weightSpots,
      volumeSpots: volumeSpots,
      entries: entries,
      minX: 0,
      maxX: entries.length > 1 ? (entries.length - 1).toDouble() : 1,
      minWeightY: minWeightY,
      maxWeightY: maxWeightY,
      minVolumeY: minVolumeY,
      maxVolumeY: maxVolumeY,
      weightInterval: weightInterval,
      volumeInterval: volumeInterval,
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
  final List<FlSpot> weightSpots;
  final List<FlSpot> volumeSpots;
  final List<WeightEntry> entries;
  final double minX;
  final double maxX;
  final double minWeightY;
  final double maxWeightY;
  final double minVolumeY;
  final double maxVolumeY;
  final double weightInterval;
  final double volumeInterval;
  final double bottomInterval;

  const ChartData({
    required this.weightSpots,
    required this.volumeSpots,
    required this.entries,
    required this.minX,
    required this.maxX,
    required this.minWeightY,
    required this.maxWeightY,
    required this.minVolumeY,
    required this.maxVolumeY,
    required this.weightInterval,
    required this.volumeInterval,
    required this.bottomInterval,
  });

  // Legacy getters for backward compatibility
  List<FlSpot> get spots => weightSpots;
  double get minY => minWeightY;
  double get maxY => maxWeightY;
  double get horizontalInterval => weightInterval;
}