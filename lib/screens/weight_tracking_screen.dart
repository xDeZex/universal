import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shopping_app_state.dart';
import '../models/weight_entry.dart';
import '../models/exercise.dart';
import '../models/exercise_history.dart';
import 'exercise_weight_history_screen.dart';

class WeightTrackingScreen extends StatelessWidget {
  const WeightTrackingScreen({super.key});

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
      title: const Text('Workout Logs'),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
    );
  }

  Widget _buildBody(BuildContext context, ShoppingAppState appState) {
    final exerciseSummaries = _getExerciseSummaries(appState);
    
    if (exerciseSummaries.isEmpty) {
      return _buildEmptyState();
    }

    return _buildExerciseList(context, exerciseSummaries);
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No workout logs yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Start logging by saving weights for your exercises',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseList(BuildContext context, List<ExerciseSummaryData> exerciseSummaries) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: exerciseSummaries.length,
      itemBuilder: (context, index) => _buildExerciseSummaryCard(context, exerciseSummaries[index]),
    );
  }

  List<ExerciseSummaryData> _getExerciseSummaries(ShoppingAppState appState) {
    final List<ExerciseSummaryData> summaries = [];
    
    // Get all exercise histories with weights from global storage only
    final exerciseHistories = appState.getAllExerciseHistoriesWithWeights();
    
    for (final exerciseHistory in exerciseHistories) {
      // Find the most recent workout that contains this exercise (for display purposes)
      String workoutName = 'Unknown Workout';
      Exercise? currentExercise;
      
      // Look for this exercise in current workouts
      for (final workout in appState.workoutLists) {
        for (final exercise in workout.exercises) {
          if (exercise.name.toLowerCase() == exerciseHistory.exerciseName.toLowerCase()) {
            workoutName = workout.name;
            currentExercise = exercise;
            break;
          }
        }
        if (currentExercise != null) break;
      }
      
      // If not found in any current workout, create a mock exercise for display
      if (currentExercise == null) {
        currentExercise = Exercise(
          id: 'deleted_${exerciseHistory.exerciseName.toLowerCase().replaceAll(' ', '_')}',
          name: exerciseHistory.exerciseName,
          isCompleted: false,
          weightHistory: [], // Don't use local history to avoid duplicates
        );
        workoutName = 'Deleted Exercise';
      } else {
        // For existing exercises, create a copy with empty local history to avoid duplicates
        currentExercise = currentExercise.copyWith(weightHistory: []);
      }
      
      // Create summary for this exercise
      if (exerciseHistory.weightHistory.isNotEmpty) {
        summaries.add(ExerciseSummaryData(
          exercise: currentExercise,
          workoutName: workoutName,
          exerciseHistory: exerciseHistory,
        ));
      }
    }
    
    // Sort by last used date (most recent first)
    summaries.sort((a, b) => b.exerciseHistory.lastUsed.compareTo(a.exerciseHistory.lastUsed));
    
    return summaries;
  }

  Widget _buildExerciseSummaryCard(BuildContext context, ExerciseSummaryData summaryData) {
    final cardData = _prepareCardData(summaryData);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _navigateToExerciseHistoryFromSummary(context, summaryData),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMainRow(context, summaryData, cardData),
              const SizedBox(height: 12),
              _buildMetricsRow(context, cardData),
            ],
          ),
        ),
      ),
    );
  }

  ExerciseCardData _prepareCardData(ExerciseSummaryData summaryData) {
    final exerciseHistory = summaryData.exerciseHistory;
    
    // Find the most recent entry by date
    WeightEntry? latestEntry;
    if (exerciseHistory.weightHistory.isNotEmpty) {
      latestEntry = exerciseHistory.weightHistory.reduce((a, b) => 
        a.date.isAfter(b.date) ? a : b);
    }
    
    // Calculate progression from the two most recent entries
    WeightProgression? progression;
    if (exerciseHistory.weightHistory.length >= 2) {
      final sortedEntries = List<WeightEntry>.from(exerciseHistory.weightHistory)
        ..sort((a, b) => b.date.compareTo(a.date));
      progression = _getProgressionFromEntries(sortedEntries[0], sortedEntries[1]);
    }
    
    return ExerciseCardData(
      latestEntry: latestEntry,
      hasToday: latestEntry != null && _isToday(latestEntry.date),
      totalEntries: exerciseHistory.weightHistory.length,
      progression: progression,
    );
  }

  Widget _buildMainRow(BuildContext context, ExerciseSummaryData summaryData, ExerciseCardData cardData) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildExerciseInfo(context, summaryData, cardData.hasToday)),
        _buildWeightInfo(context, cardData),
      ],
    );
  }

  Widget _buildExerciseInfo(BuildContext context, ExerciseSummaryData summaryData, bool hasToday) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildExerciseNameRow(context, summaryData.exercise.name, hasToday),
        const SizedBox(height: 4),
        _buildWorkoutName(summaryData.workoutName),
      ],
    );
  }

  Widget _buildExerciseNameRow(BuildContext context, String exerciseName, bool hasToday) {
    return Text(
      exerciseName,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: hasToday ? Theme.of(context).colorScheme.primary : null,
      ),
    );
  }

  Widget _buildWorkoutName(String workoutName) {
    return Text(
      workoutName,
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey[600],
      ),
    );
  }

  Widget _buildWeightInfo(BuildContext context, ExerciseCardData cardData) {
    if (cardData.latestEntry == null) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildLatestWeight(context, cardData),
        if (cardData.progression != null) ...[
          const SizedBox(height: 4),
          _buildProgressionBadge(cardData.progression!),
        ],
      ],
    );
  }

  Widget _buildLatestWeight(BuildContext context, ExerciseCardData cardData) {
    return Text(
      cardData.latestEntry!.weight,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: cardData.hasToday ? Theme.of(context).colorScheme.primary : null,
      ),
    );
  }

  Widget _buildProgressionBadge(WeightProgression progression) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: progression.isIncrease 
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: progression.isIncrease ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            progression.isIncrease ? Icons.trending_up : Icons.trending_down,
            size: 14,
            color: progression.isIncrease ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 4),
          Text(
            progression.text,
            style: TextStyle(
              color: progression.isIncrease ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsRow(BuildContext context, ExerciseCardData cardData) {
    return Row(
      children: [
        _buildEntryCount(cardData.totalEntries),
        const Spacer(),
        if (cardData.latestEntry != null) ...[
          _buildLastUpdated(cardData.latestEntry!),
          if (cardData.hasToday) ...[
            const SizedBox(width: 8),
            _buildTodayBadge(context),
          ],
        ],
      ],
    );
  }

  Widget _buildEntryCount(int totalEntries) {
    return Row(
      children: [
        Icon(
          Icons.history,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          '$totalEntries entr${totalEntries == 1 ? 'y' : 'ies'}',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildLastUpdated(WeightEntry latestEntry) {
    return Row(
      children: [
        Icon(
          Icons.access_time,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          _formatDate(latestEntry.date),
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildTodayBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 1,
        ),
      ),
      child: Text(
        'TODAY',
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  // ============================================================================
  // Helper Methods - Date & Time Formatting
  // ============================================================================

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entryDate = DateTime(date.year, date.month, date.day);
    final difference = today.difference(entryDate).inDays;
    
    if (difference == 0) {
      return 'Today at ${_formatTime(date)}';
    } else if (difference == 1) {
      return 'Yesterday at ${_formatTime(date)}';
    } else if (difference < 7) {
      return '$difference days ago at ${_formatTime(date)}';
    } else {
      return '${date.day}/${date.month}/${date.year} at ${_formatTime(date)}';
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // ============================================================================
  // Helper Methods - Weight Progression Calculation
  // ============================================================================

  WeightProgression? _getProgressionFromEntries(WeightEntry current, WeightEntry previous) {
    final currentWeight = _extractNumericWeight(current.weight);
    final previousWeight = _extractNumericWeight(previous.weight);
    
    if (currentWeight == null || previousWeight == null) return null;
    
    final difference = currentWeight - previousWeight;
    if (difference == 0) return null;
    
    return WeightProgression(
      isIncrease: difference > 0,
      text: '${difference > 0 ? '+' : ''}${difference.toStringAsFixed(1)}kg',
    );
  }

  double? _extractNumericWeight(String weight) {
    final regex = RegExp(r'(\d+(?:\.\d+)?)');
    final match = regex.firstMatch(weight);
    return match != null ? double.tryParse(match.group(1)!) : null;
  }

  // ============================================================================
  // Helper Methods - Navigation
  // ============================================================================

  void _navigateToExerciseHistoryFromSummary(BuildContext context, ExerciseSummaryData summaryData) {
    final appState = Provider.of<ShoppingAppState>(context, listen: false);
    String? workoutId;
    
    // Find the workout that contains this exercise (if it still exists in a workout)
    for (final workout in appState.workoutLists) {
      if (workout.exercises.any((ex) => ex.name.toLowerCase() == summaryData.exercise.name.toLowerCase())) {
        workoutId = workout.id;
        break;
      }
    }
    
    // For deleted exercises, use a placeholder workout ID
    workoutId ??= 'global_history';
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ExerciseWeightHistoryScreen(
          exercise: summaryData.exercise,
          workoutId: workoutId!,
          workoutName: summaryData.workoutName,
        ),
      ),
    );
  }
}

class ExerciseSummaryData {
  final Exercise exercise;
  final String workoutName;
  final ExerciseHistory exerciseHistory;

  const ExerciseSummaryData({
    required this.exercise,
    required this.workoutName,
    required this.exerciseHistory,
  });
}

class ExerciseCardData {
  final WeightEntry? latestEntry;
  final bool hasToday;
  final int totalEntries;
  final WeightProgression? progression;

  const ExerciseCardData({
    required this.latestEntry,
    required this.hasToday,
    required this.totalEntries,
    required this.progression,
  });
}

class WeightProgression {
  final bool isIncrease;
  final String text;

  const WeightProgression({
    required this.isIncrease,
    required this.text,
  });
}