import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shopping_app_state.dart';
import '../models/exercise.dart';
import '../models/weight_entry.dart';
import '../models/set_entry.dart';

class ExerciseWeightHistoryScreen extends StatelessWidget {
  final Exercise exercise;
  final String workoutId;
  final String workoutName;

  const ExerciseWeightHistoryScreen({
    super.key,
    required this.exercise,
    required this.workoutId,
    required this.workoutName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Consumer<ShoppingAppState>(
        builder: (context, appState, child) => _buildBody(context, appState),
      ),
      floatingActionButton: _buildFAB(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(exercise.name),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
    );
  }

  Widget _buildBody(BuildContext context, ShoppingAppState appState) {
    final exerciseHistory = appState.getExerciseHistory(exercise.name);
    
    if (exerciseHistory?.weightHistory.isEmpty ?? true) {
      return _buildEmptyState(context);
    }
    
    final sortedHistory = _getSortedWeightHistory(exerciseHistory!);
    return _buildWeightHistoryList(context, sortedHistory);
  }

  List<WeightEntry> _getSortedWeightHistory(dynamic exerciseHistory) {
    return List<WeightEntry>.from(exerciseHistory.weightHistory)
      ..sort((a, b) => b.date.compareTo(a.date)); // Newest first
  }

  Widget _buildWeightHistoryList(BuildContext context, List<WeightEntry> sortedHistory) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedHistory.length,
      itemBuilder: (context, index) => _buildListItem(context, sortedHistory, index),
    );
  }

  Widget _buildListItem(BuildContext context, List<WeightEntry> sortedHistory, int index) {
    final entry = sortedHistory[index];
    final progression = _calculateProgression(sortedHistory, index);
    final isLatest = index == 0;
    
    return _buildWeightEntryCard(context, entry, progression, isLatest);
  }

  ExerciseProgression? _calculateProgression(List<WeightEntry> sortedHistory, int index) {
    if (index >= sortedHistory.length - 1) return null;
    
    return _getProgression(sortedHistory[index], sortedHistory[index + 1]);
  }


  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timeline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No weight history yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking by saving weights for this exercise',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWeightEntryCard(BuildContext context, WeightEntry entry, ExerciseProgression? progression, bool isLatest) {
    final isToday = _isToday(entry.date);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isLatest ? 4 : 2,
      child: Container(
        decoration: _buildCardDecoration(context, isLatest),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildWeightInfo(context, entry, isToday, isLatest),
                  _buildActionButtons(context, entry, progression),
                ],
              ),
              _buildExerciseMetrics(context, entry, progression),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration? _buildCardDecoration(BuildContext context, bool isLatest) {
    if (!isLatest) return null;
    
    return BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        width: 2,
      ),
    );
  }

  Widget _buildWeightInfo(BuildContext context, WeightEntry entry, bool isToday, bool isLatest) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWeightRow(context, entry, isToday, isLatest),
        const SizedBox(height: 4),
        _buildDateRow(context, entry, isToday),
      ],
    );
  }

  Widget _buildWeightRow(BuildContext context, WeightEntry entry, bool isToday, bool isLatest) {
    return Row(
      children: [
        Text(
          entry.weight,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isToday 
                ? Theme.of(context).colorScheme.primary 
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
        if (isLatest) ...[
          const SizedBox(width: 8),
          _buildLatestBadge(context),
        ],
      ],
    );
  }

  Widget _buildLatestBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 1,
        ),
      ),
      child: Text(
        'LATEST',
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildDateRow(BuildContext context, WeightEntry entry, bool isToday) {
    return Row(
      children: [
        Icon(
          Icons.access_time,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          _formatDate(entry.date),
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        if (isToday) ...[
          const SizedBox(width: 8),
          _buildTodayBadge(context),
        ],
      ],
    );
  }

  Widget _buildTodayBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary,
          width: 1,
        ),
      ),
      child: Text(
        'TODAY',
        style: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
          fontWeight: FontWeight.bold,
          fontSize: 9,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WeightEntry entry, ExerciseProgression? progression) {
    return Row(
      children: [
        if (progression?.weightProgression != null) ...[
          _buildProgressionBadge(progression!.weightProgression!),
          const SizedBox(width: 8),
        ],
        _buildDeleteButton(context, entry),
      ],
    );
  }

  Widget _buildProgressionBadge(WeightProgression progression) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: progression.isIncrease 
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
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
            size: 16,
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

  Widget _buildDeleteButton(BuildContext context, WeightEntry entry) {
    return GestureDetector(
      onTap: () => _showDeleteWeightDialog(context, entry),
      child: Icon(
        Icons.delete_outline,
        size: 20,
        color: Colors.grey[600],
      ),
    );
  }

  Widget _buildExerciseMetrics(BuildContext context, WeightEntry entry, ExerciseProgression? progression) {
    if (!entry.hasDetailedSets) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          _buildSetsRepsRow(context, entry, progression),
          if (progression?.hasAnyProgression == true && 
              (progression!.setsProgression != null || progression.repsProgression != null))
            _buildProgressionRow(context, progression),
        ],
      ),
    );
  }

  Widget _buildSetsRepsRow(BuildContext context, WeightEntry entry, ExerciseProgression? progression) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.fitness_center,
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Text(
            '${entry.totalSets}',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            ' sets: ',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Text(
            entry.setsRepsDisplay,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            ' reps',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressionRow(BuildContext context, ExerciseProgression progression) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          if (progression.setsProgression != null) ...[
            _buildSmallProgressionBadge(progression.setsProgression!),
            const SizedBox(width: 8),
          ],
          if (progression.repsProgression != null) ...[
            _buildSmallProgressionBadge(progression.repsProgression!),
          ],
        ],
      ),
    );
  }

  Widget _buildSmallProgressionBadge(WeightProgression progression) {
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
            size: 12,
            color: progression.isIncrease ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 4),
          Text(
            progression.text,
            style: TextStyle(
              color: progression.isIncrease ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
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
  
  ExerciseProgression? _getProgression(WeightEntry current, WeightEntry previous) {
    final weightProgression = _getWeightProgression(current, previous);
    final setsProgression = _getSetsProgression(current, previous);
    final repsProgression = _getRepsProgression(current, previous);
    
    if (weightProgression == null && setsProgression == null && repsProgression == null) {
      return null;
    }
    
    return ExerciseProgression(
      weightProgression: weightProgression,
      setsProgression: setsProgression,
      repsProgression: repsProgression,
    );
  }

  WeightProgression? _getWeightProgression(WeightEntry current, WeightEntry previous) {
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

  WeightProgression? _getSetsProgression(WeightEntry current, WeightEntry previous) {
    if (!current.hasDetailedSets || !previous.hasDetailedSets) return null;
    
    final difference = current.totalSets - previous.totalSets;
    if (difference == 0) return null;
    
    return WeightProgression(
      isIncrease: difference > 0,
      text: '${difference > 0 ? '+' : ''}${difference.abs()} ${difference.abs() == 1 ? 'set' : 'sets'}',
    );
  }

  WeightProgression? _getRepsProgression(WeightEntry current, WeightEntry previous) {
    if (!current.hasDetailedSets || !previous.hasDetailedSets) return null;
    
    final difference = current.totalReps - previous.totalReps;
    if (difference == 0) return null;
    
    return WeightProgression(
      isIncrease: difference > 0,
      text: '${difference > 0 ? '+' : ''}${difference.abs()} ${difference.abs() == 1 ? 'rep' : 'reps'}',
    );
  }

  double? _extractNumericWeight(String weight) {
    final regex = RegExp(r'(\d+(?:\.\d+)?)');
    final match = regex.firstMatch(weight);
    return match != null ? double.tryParse(match.group(1)!) : null;
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showAddWeightEntryDialog(context),
      child: const Icon(Icons.add),
    );
  }

  void _showAddWeightEntryDialog(BuildContext context) {
    final weightController = TextEditingController(text: exercise.weight ?? '');
    final setsController = TextEditingController(text: exercise.sets ?? '');
    final repsController = TextEditingController(text: exercise.reps ?? '');
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Add Weight Entry for ${exercise.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Date selection
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Date'),
                    subtitle: Text(_formatDialogDate(selectedDate)),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Weight input
                TextField(
                  controller: weightController,
                  decoration: const InputDecoration(
                    labelText: 'Weight',
                    hintText: 'e.g., 80kg, bodyweight',
                  ),
                  textCapitalization: TextCapitalization.none,
                ),
                const SizedBox(height: 12),
                // Sets input
                TextField(
                  controller: setsController,
                  decoration: const InputDecoration(
                    labelText: 'Sets (optional)',
                    hintText: 'e.g., 3',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                // Reps input
                TextField(
                  controller: repsController,
                  decoration: const InputDecoration(
                    labelText: 'Reps (optional)',
                    hintText: 'e.g., 10',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (weightController.text.trim().isNotEmpty) {
                  final sets = setsController.text.trim().isNotEmpty 
                      ? int.tryParse(setsController.text.trim())
                      : null;
                  final reps = repsController.text.trim().isNotEmpty 
                      ? int.tryParse(repsController.text.trim())
                      : null;
                  
                  _saveWeightEntry(context, weightController.text.trim(), sets, reps, selectedDate);
                  Navigator.of(context).pop();
                }
              },
              child: Text(_isToday(selectedDate) ? 'Save' : 'Save for ${_formatDialogDate(selectedDate)}'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveWeightEntry(BuildContext context, String weight, int? sets, int? reps, DateTime date) {
    final appState = Provider.of<ShoppingAppState>(context, listen: false);
    
    if (workoutId != 'global_history') {
      // Save to workout if we have a valid workout ID
      appState.saveWeightForExercise(
        workoutId,
        exercise.id,
        weight,
        sets: sets,
        reps: reps,
        date: date,
      );
    } else {
      // Save only to global history for deleted exercises
      appState.addOrUpdateExerciseHistory(
        exercise.name,
        WeightEntry(
          date: date,
          weight: weight,
          setEntries: _createLegacySetEntries(sets, reps),
        ),
      );
    }
  }

  /// Helper method to create SetEntry objects from legacy sets/reps format
  List<SetEntry> _createLegacySetEntries(int? sets, int? reps) {
    if (sets == null && reps == null) {
      return [];
    }
    
    final actualSets = sets ?? 1;
    final actualReps = reps ?? 1;
    
    final setEntries = <SetEntry>[];
    for (int i = 0; i < actualSets; i++) {
      setEntries.add(SetEntry(reps: actualReps));
    }
    return setEntries;
  }

  String _formatDialogDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(date.year, date.month, date.day);
    final difference = today.difference(selectedDay).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showDeleteWeightDialog(BuildContext context, WeightEntry entry) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete Weight Entry'),
        content: Text(
          'Are you sure you want to delete this weight entry?\n\n'
          '${exercise.name}: ${entry.weight}\n'
          '${_formatDate(entry.date)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final appState = Provider.of<ShoppingAppState>(context, listen: false);
              // Delete from global exercise history
              appState.deleteWeightFromExerciseHistory(exercise.name, entry.date);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class WeightProgression {
  final bool isIncrease;
  final String text;

  const WeightProgression({
    required this.isIncrease,
    required this.text,
  });
}

class ExerciseProgression {
  final WeightProgression? weightProgression;
  final WeightProgression? setsProgression;
  final WeightProgression? repsProgression;

  const ExerciseProgression({
    this.weightProgression,
    this.setsProgression,
    this.repsProgression,
  });

  bool get hasAnyProgression => 
      weightProgression != null || 
      setsProgression != null || 
      repsProgression != null;
}