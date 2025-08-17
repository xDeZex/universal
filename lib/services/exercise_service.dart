import '../models/exercise_history.dart';
import '../models/weight_entry.dart';

class ExerciseService {
  static ExerciseHistory? getExerciseHistory(List<ExerciseHistory> exerciseHistory, String exerciseName) {
    return exerciseHistory.cast<ExerciseHistory?>().firstWhere(
      (history) => history?.exerciseName.toLowerCase() == exerciseName.toLowerCase(),
      orElse: () => null,
    );
  }

  static List<ExerciseHistory> addOrUpdateExerciseHistory(
    List<ExerciseHistory> exerciseHistory, 
    String exerciseName, 
    WeightEntry weightEntry
  ) {
    final updatedHistory = List<ExerciseHistory>.from(exerciseHistory);
    final existingIndex = updatedHistory.indexWhere(
      (history) => history.exerciseName.toLowerCase() == exerciseName.toLowerCase(),
    );

    if (existingIndex != -1) {
      // Update existing exercise history
      final existing = updatedHistory[existingIndex];
      var entryDate = weightEntry.date;
      
      // Ensure unique timestamp by adding microseconds if needed
      final existingTimes = existing.weightHistory.map((e) => e.date.millisecondsSinceEpoch).toSet();
      while (existingTimes.contains(entryDate.millisecondsSinceEpoch)) {
        entryDate = entryDate.add(const Duration(microseconds: 1));
      }
      
      final updatedEntry = WeightEntry(
        date: entryDate, 
        weight: weightEntry.weight,
        sets: weightEntry.sets,
        reps: weightEntry.reps,
      );
      final updatedWeightHistory = List<WeightEntry>.from(existing.weightHistory)..add(updatedEntry);
      
      updatedHistory[existingIndex] = existing.copyWith(
        weightHistory: updatedWeightHistory,
        lastUsed: DateTime.now(),
      );
    } else {
      // Create new exercise history
      final newHistory = ExerciseHistory(
        exerciseName: exerciseName,
        weightHistory: [weightEntry],
        createdAt: DateTime.now(),
        lastUsed: DateTime.now(),
      );
      updatedHistory.add(newHistory);
    }

    return updatedHistory;
  }

  static List<ExerciseHistory> deleteWeightFromExerciseHistory(
    List<ExerciseHistory> exerciseHistory,
    String exerciseName, 
    DateTime entryDate
  ) {
    final updatedHistory = List<ExerciseHistory>.from(exerciseHistory);
    final historyIndex = updatedHistory.indexWhere(
      (history) => history.exerciseName.toLowerCase() == exerciseName.toLowerCase(),
    );

    if (historyIndex != -1) {
      final history = updatedHistory[historyIndex];
      final updatedWeightHistory = List<WeightEntry>.from(history.weightHistory);
      final entryIndex = updatedWeightHistory.indexWhere((entry) => 
          _isSameDateTime(entry.date, entryDate));
      
      if (entryIndex != -1) {
        updatedWeightHistory.removeAt(entryIndex);
        
        // Keep the history even if no weight entries - just update lastUsed
        updatedHistory[historyIndex] = history.copyWith(
          weightHistory: updatedWeightHistory,
          lastUsed: DateTime.now(),
        );
      }
    }

    return updatedHistory;
  }

  static List<ExerciseHistory> getAllExerciseHistoriesWithWeights(List<ExerciseHistory> exerciseHistory) {
    return exerciseHistory.where((history) => history.weightHistory.isNotEmpty).toList()
      ..sort((a, b) => b.lastUsed.compareTo(a.lastUsed)); // Most recently used first
  }

  static List<String> getExerciseNamesWithLogsNotInWorkout(
    List<ExerciseHistory> exerciseHistory,
    List<dynamic> currentExercises,
    Function(String) getExerciseHistoryFunction
  ) {
    final currentExerciseNames = currentExercises
        .map((exercise) => exercise.name.toLowerCase())
        .toSet();
    
    return exerciseHistory
        .where((history) => history.weightHistory.isNotEmpty)
        .map((history) => history.exerciseName)
        .where((name) => !currentExerciseNames.contains(name.toLowerCase()))
        .toList()
        ..sort((a, b) {
          final historyA = getExerciseHistoryFunction(a);
          final historyB = getExerciseHistoryFunction(b);
          return historyB?.lastUsed.compareTo(historyA?.lastUsed ?? DateTime(0)) ?? 0;
        });
  }

  static bool _isSameDateTime(DateTime date1, DateTime date2) {
    return date1.millisecondsSinceEpoch == date2.millisecondsSinceEpoch;
  }
}