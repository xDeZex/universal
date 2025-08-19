import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shopping_app_state.dart';
import '../models/exercise_history.dart';
import '../services/chart_service.dart';
import '../widgets/chart_legend.dart';
import '../widgets/chart_stats.dart';
import '../widgets/exercise_chart.dart';
import '../utils/chart_constants.dart';
import '../utils/time_interval.dart';

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
      automaticallyImplyLeading: false,
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

    final sortedExercises = List<ExerciseHistory>.from(exerciseHistories)
      ..sort((a, b) => b.lastUsed.compareTo(a.lastUsed));

    return ListView.builder(
      padding: const EdgeInsets.all(ChartConstants.cardPadding),
      itemCount: sortedExercises.length,
      itemBuilder: (context, index) => _ExerciseGraphCard(
        exerciseHistory: sortedExercises[index],
        timeInterval: _selectedInterval,
      ),
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
          SizedBox(height: ChartConstants.sectionSpacing),
          Text(
            'No exercise data yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: ChartConstants.smallSpacing),
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
}

class _ExerciseGraphCard extends StatefulWidget {
  final ExerciseHistory exerciseHistory;
  final TimeInterval timeInterval;

  const _ExerciseGraphCard({
    required this.exerciseHistory,
    required this.timeInterval,
  });

  @override
  State<_ExerciseGraphCard> createState() => _ExerciseGraphCardState();
}

class _ExerciseGraphCardState extends State<_ExerciseGraphCard> {
  bool _showWeight = true;
  bool _showVolume = true;

  @override
  Widget build(BuildContext context) {
    final chartData = ChartService.prepareChartData(widget.exerciseHistory, widget.timeInterval);
    
    return Card(
      margin: const EdgeInsets.only(bottom: ChartConstants.cardBottomMargin),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(ChartConstants.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ExerciseCardHeader(
              exerciseHistory: widget.exerciseHistory,
              chartData: chartData,
            ),
            const SizedBox(height: ChartConstants.sectionSpacing),
            ChartLegend(
              showWeight: _showWeight,
              showVolume: _showVolume,
              onWeightToggle: () => setState(() => _showWeight = !_showWeight),
              onVolumeToggle: () => setState(() => _showVolume = !_showVolume),
            ),
            const SizedBox(height: ChartConstants.smallSpacing),
            ExerciseChart(
              chartData: chartData,
              showWeight: _showWeight,
              showVolume: _showVolume,
            ),
            const SizedBox(height: ChartConstants.mediumSpacing),
            ChartStats(chartData: chartData),
          ],
        ),
      ),
    );
  }
}

class _ExerciseCardHeader extends StatelessWidget {
  final ExerciseHistory exerciseHistory;
  final ChartData chartData;

  const _ExerciseCardHeader({
    required this.exerciseHistory,
    required this.chartData,
  });

  @override
  Widget build(BuildContext context) {
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
                  fontSize: ChartConstants.titleFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: ChartConstants.tinySpacing),
              Text(
                '${chartData.entries.length} entr${chartData.entries.length == 1 ? 'y' : 'ies'}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: ChartConstants.subtitleFontSize,
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
                fontSize: ChartConstants.latestWeightFontSize,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Text(
              'Latest',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: ChartConstants.latestLabelFontSize,
              ),
            ),
          ],
        ),
      ],
    );
  }
}