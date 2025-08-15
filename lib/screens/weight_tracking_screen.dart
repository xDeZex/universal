import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/weight_entry.dart';
import '../models/exercise.dart';
import 'exercise_weight_history_screen.dart';

class WeightTrackingScreen extends StatelessWidget {
  const WeightTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weight Tracking'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<ShoppingAppState>(
        builder: (context, appState, child) {
          final allWeightEntries = _getAllWeightEntries(appState);
          
          if (allWeightEntries.isEmpty) {
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
                    'No weight tracking data yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Start tracking by saving weights for your exercises',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: allWeightEntries.length,
            itemBuilder: (context, index) {
              final entryData = allWeightEntries[index];
              final progression = index < allWeightEntries.length - 1
                  ? _getProgression(entryData, allWeightEntries[index + 1])
                  : null;
              
              return _buildWeightCard(context, entryData, progression);
            },
          );
        },
      ),
    );
  }

  List<WeightEntryData> _getAllWeightEntries(ShoppingAppState appState) {
    final List<WeightEntryData> allEntries = [];
    
    for (final workout in appState.workoutLists) {
      for (final exercise in workout.exercises) {
        for (final weightEntry in exercise.weightHistory) {
          allEntries.add(WeightEntryData(
            exercise: exercise,
            workoutName: workout.name,
            entry: weightEntry,
          ));
        }
      }
    }
    
    // Sort by date (newest first)
    allEntries.sort((a, b) => b.entry.date.compareTo(a.entry.date));
    
    return allEntries;
  }

  Widget _buildWeightCard(BuildContext context, WeightEntryData entryData, WeightProgression? progression) {
    final isToday = _isToday(entryData.entry.date);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _navigateToExerciseHistory(context, entryData),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                entryData.exercise.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isToday ? Theme.of(context).colorScheme.primary : null,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey[500],
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entryData.workoutName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          entryData.entry.weight,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isToday ? Theme.of(context).colorScheme.primary : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _showDeleteWeightDialog(context, entryData),
                          child: Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    if (progression != null) ...[
                      const SizedBox(height: 4),
                      Container(
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
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(entryData.entry.date),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                if (isToday) ...[
                  const SizedBox(width: 8),
                  Container(
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
                  ),
                ],
              ],
            ),
            if (entryData.exercise.sets != null || entryData.exercise.reps != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.fitness_center,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatSetsReps(entryData.exercise),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        ),
      ),
    );
  }

  String _formatSetsReps(Exercise exercise) {
    final details = <String>[];
    if (exercise.sets != null && exercise.reps != null) {
      details.add('${exercise.sets}s × ${exercise.reps}r');
    } else if (exercise.sets != null) {
      details.add('${exercise.sets}s');
    } else if (exercise.reps != null) {
      details.add('${exercise.reps}r');
    }
    return details.join(' • ');
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
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

  WeightProgression? _getProgression(WeightEntryData current, WeightEntryData previous) {
    // Only compare entries from the same exercise
    if (current.exercise.id != previous.exercise.id) return null;
    
    // Try to extract numeric values for comparison
    final currentWeight = _extractNumericWeight(current.entry.weight);
    final previousWeight = _extractNumericWeight(previous.entry.weight);
    
    if (currentWeight == null || previousWeight == null) return null;
    
    final difference = currentWeight - previousWeight;
    if (difference == 0) return null;
    
    return WeightProgression(
      isIncrease: difference > 0,
      text: '${difference > 0 ? '+' : ''}${difference.toStringAsFixed(1)}kg',
    );
  }

  double? _extractNumericWeight(String weight) {
    // Extract numeric value from weight string (e.g., "80kg" -> 80.0)
    final regex = RegExp(r'(\d+(?:\.\d+)?)');
    final match = regex.firstMatch(weight);
    return match != null ? double.tryParse(match.group(1)!) : null;
  }

  void _showDeleteWeightDialog(BuildContext context, WeightEntryData entryData) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete Weight Entry'),
        content: Text(
          'Are you sure you want to delete this weight entry?\n\n'
          '${entryData.exercise.name}: ${entryData.entry.weight}\n'
          '${_formatDate(entryData.entry.date)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Find the workout that contains this exercise
              final appState = Provider.of<ShoppingAppState>(context, listen: false);
              String? workoutId;
              
              for (final workout in appState.workoutLists) {
                if (workout.exercises.any((ex) => ex.id == entryData.exercise.id)) {
                  workoutId = workout.id;
                  break;
                }
              }
              
              if (workoutId != null) {
                appState.deleteWeightEntry(
                  workoutId,
                  entryData.exercise.id,
                  entryData.entry.date,
                );
              }
              
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _navigateToExerciseHistory(BuildContext context, WeightEntryData entryData) {
    final appState = Provider.of<ShoppingAppState>(context, listen: false);
    String? workoutId;
    
    // Find the workout that contains this exercise
    for (final workout in appState.workoutLists) {
      if (workout.exercises.any((ex) => ex.id == entryData.exercise.id)) {
        workoutId = workout.id;
        break;
      }
    }
    
    if (workoutId != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ExerciseWeightHistoryScreen(
            exercise: entryData.exercise,
            workoutId: workoutId!,
            workoutName: entryData.workoutName,
          ),
        ),
      );
    }
  }
}

class WeightEntryData {
  final Exercise exercise;
  final String workoutName;
  final WeightEntry entry;

  const WeightEntryData({
    required this.exercise,
    required this.workoutName,
    required this.entry,
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