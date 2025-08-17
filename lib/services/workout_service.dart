import '../models/workout_list.dart';
import '../models/exercise.dart';
import '../models/weight_entry.dart';
import '../utils/id_generator.dart';
import 'list_manager.dart';

class WorkoutService {
  static WorkoutList createWorkoutList(String name) {
    return WorkoutList(
      id: IdGenerator.generateUniqueId(),
      name: name,
      exercises: [],
      createdAt: DateTime.now(),
    );
  }

  static WorkoutList addExerciseToWorkout(WorkoutList workout, String exerciseName, {
    String? sets,
    String? reps,
    String? weight,
    String? notes,
  }) {
    final newExercise = Exercise(
      id: IdGenerator.generateUniqueId(),
      name: exerciseName,
      sets: sets,
      reps: reps,
      weight: weight,
      notes: notes,
    );
    final updatedExercises = List<Exercise>.from(workout.exercises)..add(newExercise);
    return workout.copyWith(exercises: updatedExercises);
  }

  static WorkoutList updateExercise(WorkoutList workout, String exerciseId, Exercise updatedExercise) {
    final exercises = workout.exercises;
    final exerciseIndex = exercises.indexWhere((exercise) => exercise.id == exerciseId);
    if (exerciseIndex != -1) {
      final updatedExercises = List<Exercise>.from(exercises);
      updatedExercises[exerciseIndex] = updatedExercise;
      
      // Sort exercises: incomplete first, completed at bottom
      updatedExercises.sort((a, b) {
        if (a.isCompleted == b.isCompleted) return 0;
        return a.isCompleted ? 1 : -1;
      });
      
      return workout.copyWith(exercises: updatedExercises);
    }
    return workout;
  }

  static WorkoutList toggleExerciseCompletion(WorkoutList workout, String exerciseId) {
    final updatedExercises = ListManager.toggleItemCompletion(workout.exercises, exerciseId);
    return workout.copyWith(exercises: updatedExercises);
  }

  static WorkoutList deleteExerciseFromWorkout(WorkoutList workout, String exerciseId) {
    final updatedExercises = ListManager.deleteItem(workout.exercises, exerciseId);
    return workout.copyWith(exercises: updatedExercises);
  }

  static WorkoutList reorderExercises(WorkoutList workout, int oldIndex, int newIndex) {
    final updatedExercises = ListManager.reorderItems(workout.exercises, oldIndex, newIndex);
    return workout.copyWith(exercises: updatedExercises);
  }

  static WorkoutList saveWeightForExercise(WorkoutList workout, String exerciseId, String weight, {int? sets, int? reps, DateTime? date}) {
    final exercises = workout.exercises;
    final exerciseIndex = exercises.indexWhere((exercise) => exercise.id == exerciseId);
    if (exerciseIndex != -1) {
      final exercise = exercises[exerciseIndex];
      var entryDate = date ?? DateTime.now();
      
      // Ensure unique timestamp by adding microseconds if needed
      final existingTimes = exercise.weightHistory.map((e) => e.date.millisecondsSinceEpoch).toSet();
      while (existingTimes.contains(entryDate.millisecondsSinceEpoch)) {
        entryDate = entryDate.add(const Duration(microseconds: 1));
      }
      
      final newWeightEntry = WeightEntry(
        date: entryDate,
        weight: weight,
        sets: sets ?? (exercise.sets != null ? int.tryParse(exercise.sets!) : null),
        reps: reps ?? (exercise.reps != null ? int.tryParse(exercise.reps!) : null),
      );
      
      final updatedWeightHistory = List<WeightEntry>.from(exercise.weightHistory)
        ..add(newWeightEntry);
      
      final updatedExercise = exercise.copyWith(weightHistory: updatedWeightHistory);
      final updatedExercises = List<Exercise>.from(exercises);
      updatedExercises[exerciseIndex] = updatedExercise;
      
      return workout.copyWith(exercises: updatedExercises);
    }
    return workout;
  }

  static WorkoutList deleteWeightEntry(WorkoutList workout, String exerciseId, DateTime entryDate) {
    final exercises = workout.exercises;
    final exerciseIndex = exercises.indexWhere((exercise) => exercise.id == exerciseId);
    if (exerciseIndex != -1) {
      final exercise = exercises[exerciseIndex];
      
      final updatedWeightHistory = List<WeightEntry>.from(exercise.weightHistory);
      final entryIndex = updatedWeightHistory.indexWhere((entry) => 
          _isSameDateTime(entry.date, entryDate));
      
      if (entryIndex != -1) {
        updatedWeightHistory.removeAt(entryIndex);
        
        final updatedExercise = exercise.copyWith(weightHistory: updatedWeightHistory);
        final updatedExercises = List<Exercise>.from(exercises);
        updatedExercises[exerciseIndex] = updatedExercise;
        
        return workout.copyWith(exercises: updatedExercises);
      }
    }
    return workout;
  }

  static bool _isSameDateTime(DateTime date1, DateTime date2) {
    return date1.millisecondsSinceEpoch == date2.millisecondsSinceEpoch;
  }

  static WorkoutList deleteTodaysWeightForExercise(WorkoutList workout, String exerciseId) {
    final exercises = workout.exercises;
    final exerciseIndex = exercises.indexWhere((exercise) => exercise.id == exerciseId);
    if (exerciseIndex != -1) {
      final exercise = exercises[exerciseIndex];
      final todaysWeight = exercise.todaysWeight;
      
      if (todaysWeight != null) {
        return deleteWeightEntry(workout, exerciseId, todaysWeight.date);
      }
    }
    return workout;
  }

  static List<WorkoutList> addToCollection(List<WorkoutList> workoutLists, String name) {
    final newList = createWorkoutList(name);
    return List<WorkoutList>.from(workoutLists)..add(newList);
  }

  static List<WorkoutList> deleteFromCollection(List<WorkoutList> workoutLists, String id) {
    return workoutLists.where((list) => list.id != id).toList();
  }

  static List<WorkoutList> reorderCollection(List<WorkoutList> workoutLists, int oldIndex, int newIndex) {
    return ListManager.reorderLists(workoutLists, oldIndex, newIndex);
  }
}