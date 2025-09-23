import 'package:flutter/material.dart';
import '../models/shopping_list.dart';
import '../models/workout_list.dart';
import '../models/exercise.dart';
import '../models/weight_entry.dart';
import '../models/set_entry.dart';
import '../models/exercise_history.dart';
import '../services/list_manager.dart';
import '../services/storage_service.dart';
import '../services/shopping_service.dart';
import '../services/workout_service.dart';
import '../services/exercise_service.dart';

class ShoppingAppState extends ChangeNotifier {
  List<ShoppingList> _shoppingLists = [];
  List<WorkoutList> _workoutLists = [];
  List<ExerciseHistory> _exerciseHistory = [];

  List<ShoppingList> get shoppingLists => _shoppingLists;
  List<WorkoutList> get workoutLists => _workoutLists;
  List<ExerciseHistory> get exerciseHistory => _exerciseHistory;


  ShoppingAppState() {
    _loadData();
  }


  Future<void> _loadData() async {
    _shoppingLists = await StorageService.loadShoppingLists();
    _shoppingLists = _shoppingLists.map((list) => ListManager.sortListItems(list)).toList();
    _workoutLists = await StorageService.loadWorkoutLists();
    _workoutLists = _workoutLists.map((list) => ListManager.sortListItems(list)).toList();
    _exerciseHistory = await StorageService.loadExerciseHistory();
    notifyListeners();
  }


  Future<void> _saveData() async {
    await StorageService.saveShoppingLists(_shoppingLists);
    await StorageService.saveWorkoutLists(_workoutLists);
    await StorageService.saveExerciseHistory(_exerciseHistory);
  }

  void addShoppingList(String name) {
    _shoppingLists = ShoppingService.addToCollection(_shoppingLists, name);
    _saveData();
    notifyListeners();
  }

  void deleteShoppingList(String id) {
    _shoppingLists = ShoppingService.deleteFromCollection(_shoppingLists, id);
    _saveData();
    notifyListeners();
  }

  void reorderShoppingLists(int oldIndex, int newIndex) {
    _shoppingLists = ShoppingService.reorderCollection(_shoppingLists, oldIndex, newIndex);
    _saveData();
    notifyListeners();
  }

  void addItemToList(String listId, String itemName) {
    final listIndex = _shoppingLists.indexWhere((list) => list.id == listId);
    if (listIndex != -1) {
      _shoppingLists[listIndex] = ShoppingService.addItemToList(_shoppingLists[listIndex], itemName);
      _saveData();
      notifyListeners();
    }
  }

  void toggleItemCompletion(String listId, String itemId) {
    final listIndex = _shoppingLists.indexWhere((list) => list.id == listId);
    if (listIndex != -1) {
      _shoppingLists[listIndex] = ShoppingService.toggleItemCompletion(_shoppingLists[listIndex], itemId);
      _saveData();
      notifyListeners();
    }
  }

  void deleteItemFromList(String listId, String itemId) {
    final listIndex = _shoppingLists.indexWhere((list) => list.id == listId);
    if (listIndex != -1) {
      _shoppingLists[listIndex] = ShoppingService.deleteItemFromList(_shoppingLists[listIndex], itemId);
      _saveData();
      notifyListeners();
    }
  }

  void reorderItems(String listId, int oldIndex, int newIndex) {
    final listIndex = _shoppingLists.indexWhere((list) => list.id == listId);
    if (listIndex != -1) {
      _shoppingLists[listIndex] = ShoppingService.reorderItems(_shoppingLists[listIndex], oldIndex, newIndex);
      _saveData();
      notifyListeners();
    }
  }

  // Workout List Methods
  void addWorkoutList(String name) {
    _workoutLists = WorkoutService.addToCollection(_workoutLists, name);
    _saveData();
    notifyListeners();
  }

  void deleteWorkoutList(String id) {
    _workoutLists = WorkoutService.deleteFromCollection(_workoutLists, id);
    _saveData();
    notifyListeners();
  }

  void reorderWorkoutLists(int oldIndex, int newIndex) {
    _workoutLists = WorkoutService.reorderCollection(_workoutLists, oldIndex, newIndex);
    _saveData();
    notifyListeners();
  }

  void addExerciseToWorkout(String workoutId, String exerciseName, {
    String? sets,
    String? reps,
    String? weight,
    String? notes,
  }) {
    final workoutIndex = _workoutLists.indexWhere((list) => list.id == workoutId);
    if (workoutIndex != -1) {
      _workoutLists[workoutIndex] = WorkoutService.addExerciseToWorkout(
        _workoutLists[workoutIndex], 
        exerciseName, 
        sets: sets, 
        reps: reps, 
        weight: weight, 
        notes: notes
      );
      _saveData();
      notifyListeners();
    }
  }

  void updateExercise(String workoutId, String exerciseId, Exercise updatedExercise) {
    final workoutIndex = _workoutLists.indexWhere((list) => list.id == workoutId);
    if (workoutIndex != -1) {
      _workoutLists[workoutIndex] = WorkoutService.updateExercise(_workoutLists[workoutIndex], exerciseId, updatedExercise);
      _saveData();
      notifyListeners();
    }
  }

  void toggleExerciseCompletion(String workoutId, String exerciseId) {
    final workoutIndex = _workoutLists.indexWhere((list) => list.id == workoutId);
    if (workoutIndex != -1) {
      _workoutLists[workoutIndex] = WorkoutService.toggleExerciseCompletion(_workoutLists[workoutIndex], exerciseId);
      _saveData();
      notifyListeners();
    }
  }

  void deleteExerciseFromWorkout(String workoutId, String exerciseId) {
    final workoutIndex = _workoutLists.indexWhere((list) => list.id == workoutId);
    if (workoutIndex != -1) {
      _workoutLists[workoutIndex] = WorkoutService.deleteExerciseFromWorkout(_workoutLists[workoutIndex], exerciseId);
      _saveData();
      notifyListeners();
    }
  }

  void reorderExercises(String workoutId, int oldIndex, int newIndex) {
    final workoutIndex = _workoutLists.indexWhere((list) => list.id == workoutId);
    if (workoutIndex != -1) {
      _workoutLists[workoutIndex] = WorkoutService.reorderExercises(_workoutLists[workoutIndex], oldIndex, newIndex);
      _saveData();
      notifyListeners();
    }
  }

  void saveWeightForExercise(String workoutId, String exerciseId, String weight, {int? sets, int? reps, DateTime? date}) {
    final workoutIndex = _workoutLists.indexWhere((list) => list.id == workoutId);
    if (workoutIndex != -1) {
      final originalWorkout = _workoutLists[workoutIndex];
      final updatedWorkout = WorkoutService.saveWeightForExercise(originalWorkout, exerciseId, weight, sets: sets, reps: reps, date: date);
      _workoutLists[workoutIndex] = updatedWorkout;
      
      // Also save to global exercise history
      final exercises = updatedWorkout.exercises;
      final exerciseIndex = exercises.indexWhere((exercise) => exercise.id == exerciseId);
      if (exerciseIndex != -1) {
        final exercise = exercises[exerciseIndex];
        if (exercise.weightHistory.isNotEmpty) {
          final latestEntry = exercise.weightHistory.last;
          _addOrUpdateExerciseHistoryInternal(exercise.name, latestEntry);
        }
      }
      
      _saveData();
      notifyListeners();
    }
  }

  void saveDetailedWeightForExercise(String workoutId, String exerciseId, String baseWeight, List<SetEntry> setEntries, {DateTime? date}) {
    final workoutIndex = _workoutLists.indexWhere((list) => list.id == workoutId);
    if (workoutIndex != -1) {
      final originalWorkout = _workoutLists[workoutIndex];
      final updatedWorkout = WorkoutService.saveDetailedWeightForExercise(originalWorkout, exerciseId, baseWeight, setEntries, date: date);
      _workoutLists[workoutIndex] = updatedWorkout;
      
      // Also save to global exercise history
      final exercises = updatedWorkout.exercises;
      final exerciseIndex = exercises.indexWhere((exercise) => exercise.id == exerciseId);
      if (exerciseIndex != -1) {
        final exercise = exercises[exerciseIndex];
        if (exercise.weightHistory.isNotEmpty) {
          final latestEntry = exercise.weightHistory.last;
          _addOrUpdateExerciseHistoryInternal(exercise.name, latestEntry);
        }
      }
      
      _saveData();
      notifyListeners();
    }
  }

  void deleteWeightEntry(String workoutId, String exerciseId, DateTime entryDate) {
    final workoutIndex = _workoutLists.indexWhere((list) => list.id == workoutId);
    if (workoutIndex != -1) {
      final originalWorkout = _workoutLists[workoutIndex];
      final exercises = originalWorkout.exercises;
      final exerciseIndex = exercises.indexWhere((exercise) => exercise.id == exerciseId);
      if (exerciseIndex != -1) {
        final exercise = exercises[exerciseIndex];
        
        // Also delete from global exercise history
        _deleteWeightFromExerciseHistoryInternal(exercise.name, entryDate);
        
        _workoutLists[workoutIndex] = WorkoutService.deleteWeightEntry(originalWorkout, exerciseId, entryDate);
        _saveData();
        notifyListeners();
      }
    }
  }

  void deleteTodaysWeightForExercise(String workoutId, String exerciseId) {
    final workoutIndex = _workoutLists.indexWhere((list) => list.id == workoutId);
    if (workoutIndex != -1) {
      final originalWorkout = _workoutLists[workoutIndex];
      final exercises = originalWorkout.exercises;
      final exerciseIndex = exercises.indexWhere((exercise) => exercise.id == exerciseId);
      if (exerciseIndex != -1) {
        final exercise = exercises[exerciseIndex];
        final todaysWeight = exercise.todaysWeight;
        
        if (todaysWeight != null) {
          // Also delete from global exercise history
          _deleteWeightFromExerciseHistoryInternal(exercise.name, todaysWeight.date);
          
          _workoutLists[workoutIndex] = WorkoutService.deleteTodaysWeightForExercise(originalWorkout, exerciseId);
          _saveData();
          notifyListeners();
        }
      }
    }
  }

  // Global Exercise History Management
  ExerciseHistory? getExerciseHistory(String exerciseName) {
    return ExerciseService.getExerciseHistory(_exerciseHistory, exerciseName);
  }

  void addOrUpdateExerciseHistory(String exerciseName, WeightEntry weightEntry) {
    _exerciseHistory = ExerciseService.addOrUpdateExerciseHistory(_exerciseHistory, exerciseName, weightEntry);
    _saveData();
    notifyListeners();
  }

  void _addOrUpdateExerciseHistoryInternal(String exerciseName, WeightEntry weightEntry) {
    _exerciseHistory = ExerciseService.addOrUpdateExerciseHistory(_exerciseHistory, exerciseName, weightEntry);
  }

  void deleteWeightFromExerciseHistory(String exerciseName, DateTime entryDate) {
    _exerciseHistory = ExerciseService.deleteWeightFromExerciseHistory(_exerciseHistory, exerciseName, entryDate);
    _saveData();
    notifyListeners();
  }

  void _deleteWeightFromExerciseHistoryInternal(String exerciseName, DateTime entryDate) {
    _exerciseHistory = ExerciseService.deleteWeightFromExerciseHistory(_exerciseHistory, exerciseName, entryDate);
  }

  List<ExerciseHistory> getAllExerciseHistoriesWithWeights() {
    return ExerciseService.getAllExerciseHistoriesWithWeights(_exerciseHistory);
  }

  List<String> getExerciseNamesWithLogsNotInWorkout(String workoutId) {
    final currentWorkout = _workoutLists.firstWhere(
      (workout) => workout.id == workoutId,
      orElse: () => WorkoutList(id: '', name: '', exercises: [], createdAt: DateTime.now()),
    );
    
    return ExerciseService.getExerciseNamesWithLogsNotInWorkout(
      _exerciseHistory, 
      currentWorkout.exercises, 
      getExerciseHistory
    );
  }
}