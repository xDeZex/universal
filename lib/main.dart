import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/shopping_list.dart';
import 'models/shopping_item.dart';
import 'models/workout_list.dart';
import 'models/exercise.dart';
import 'models/weight_entry.dart';
import 'models/exercise_history.dart';
import 'screens/main_screen.dart';
import 'services/list_manager.dart';

void main() {
  runApp(MyApp());
}

ThemeData _createDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF6366F1), // Indigo
      primaryContainer: Color(0xFF4338CA),
      secondary: Color(0xFF8B5CF6), // Purple
      secondaryContainer: Color(0xFF7C3AED),
      surface: Color(0xFF121212), // Dark background
      surfaceContainerHighest: Color(0xFF1F1F1F), // Card background
      surfaceContainer: Color(0xFF1A1A1A), // Container background
      onSurface: Color(0xFFE5E5E5), // Primary text color
      onSurfaceVariant: Color(0xFFB0B0B0), // Secondary text color
      outline: Color(0xFF404040), // Border color
      error: Color(0xFFEF4444), // Error red
      onError: Color(0xFFFFFFFF),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1F1F1F),
      foregroundColor: Color(0xFFE5E5E5),
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: const CardThemeData(
      color: Color(0xFF1F1F1F),
      elevation: 2,
      shadowColor: Color(0x40000000),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    ),
    listTileTheme: const ListTileThemeData(
      textColor: Color(0xFFE5E5E5),
      iconColor: Color(0xFFB0B0B0),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF6366F1),
      foregroundColor: Color(0xFFFFFFFF),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: const Color(0xFFFFFFFF),
        elevation: 2,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF6366F1),
      ),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: Color(0xFF1F1F1F),
      titleTextStyle: TextStyle(
        color: Color(0xFFE5E5E5),
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: TextStyle(
        color: Color(0xFFB0B0B0),
        fontSize: 16,
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF2A2A2A),
      labelStyle: TextStyle(color: Color(0xFFB0B0B0)),
      hintStyle: TextStyle(color: Color(0xFF808080)),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF404040)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF6366F1), width: 2),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.selected)) {
          return const Color(0xFF6366F1);
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(const Color(0xFFFFFFFF)),
      side: const BorderSide(color: Color(0xFF6366F1), width: 2),
    ),
    iconTheme: const IconThemeData(
      color: Color(0xFFB0B0B0),
      size: 24,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF404040),
      thickness: 1,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1F1F1F),
      selectedItemColor: Color(0xFF6366F1),
      unselectedItemColor: Color(0xFFB0B0B0),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: Color(0xFFE5E5E5)),
      displayMedium: TextStyle(color: Color(0xFFE5E5E5)),
      displaySmall: TextStyle(color: Color(0xFFE5E5E5)),
      headlineLarge: TextStyle(color: Color(0xFFE5E5E5)),
      headlineMedium: TextStyle(color: Color(0xFFE5E5E5)),
      headlineSmall: TextStyle(color: Color(0xFFE5E5E5)),
      titleLarge: TextStyle(color: Color(0xFFE5E5E5)),
      titleMedium: TextStyle(color: Color(0xFFE5E5E5)),
      titleSmall: TextStyle(color: Color(0xFFE5E5E5)),
      labelLarge: TextStyle(color: Color(0xFFE5E5E5)),
      labelMedium: TextStyle(color: Color(0xFFB0B0B0)),
      labelSmall: TextStyle(color: Color(0xFFB0B0B0)),
      bodyLarge: TextStyle(color: Color(0xFFE5E5E5)),
      bodyMedium: TextStyle(color: Color(0xFFE5E5E5)),
      bodySmall: TextStyle(color: Color(0xFFB0B0B0)),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ShoppingAppState(),
      child: MaterialApp(
        title: 'Shopping Lists',
        theme: _createDarkTheme(),
        darkTheme: _createDarkTheme(),
        themeMode: ThemeMode.dark,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''),
          Locale('sv', ''),
        ],
        home: const MainScreen(),
      ),
    );
  }
}

class ShoppingAppState extends ChangeNotifier {
  List<ShoppingList> _shoppingLists = [];
  List<WorkoutList> _workoutLists = [];
  List<ExerciseHistory> _exerciseHistory = [];
  static const String _shoppingStorageKey = 'shopping_lists';
  static const String _workoutStorageKey = 'workout_lists';
  static const String _exerciseHistoryStorageKey = 'exercise_history';
  static int _idCounter = 0;

  List<ShoppingList> get shoppingLists => _shoppingLists;
  List<WorkoutList> get workoutLists => _workoutLists;
  List<ExerciseHistory> get exerciseHistory => _exerciseHistory;

  String _generateUniqueId() {
    _idCounter++;
    return '${DateTime.now().millisecondsSinceEpoch}_$_idCounter';
  }

  ShoppingAppState() {
    _loadData();
  }

  ShoppingList _sortListItems(ShoppingList list) {
    final sortedItems = List<ShoppingItem>.from(list.items);
    sortedItems.sort((a, b) {
      if (a.isCompleted == b.isCompleted) return 0;
      return a.isCompleted ? 1 : -1;
    });
    return list.copyWith(items: sortedItems);
  }

  WorkoutList _sortWorkoutExercises(WorkoutList list) {
    final sortedExercises = List<Exercise>.from(list.exercises);
    sortedExercises.sort((a, b) {
      if (a.isCompleted == b.isCompleted) return 0;
      return a.isCompleted ? 1 : -1;
    });
    return list.copyWith(exercises: sortedExercises);
  }

  Future<void> _loadData() async {
    await _loadShoppingLists();
    await _loadWorkoutLists();
    await _loadExerciseHistory();
  }

  Future<void> _loadShoppingLists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_shoppingStorageKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        _shoppingLists = jsonList
            .map((jsonItem) => ShoppingList.fromJson(jsonItem as Map<String, dynamic>))
            .map((list) => _sortListItems(list))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      // Ignore loading errors - app continues with empty state
    }
  }

  Future<void> _loadWorkoutLists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_workoutStorageKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        _workoutLists = jsonList
            .map((jsonItem) => WorkoutList.fromJson(jsonItem as Map<String, dynamic>))
            .map((list) => _sortWorkoutExercises(list))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      // Ignore loading errors - app continues with empty state
    }
  }

  Future<void> _loadExerciseHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_exerciseHistoryStorageKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        _exerciseHistory = jsonList
            .map((jsonItem) => ExerciseHistory.fromJson(jsonItem as Map<String, dynamic>))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      // Ignore loading errors - app continues with empty state
    }
  }

  Future<void> _saveData() async {
    await _saveShoppingLists();
    await _saveWorkoutLists();
    await _saveExerciseHistory();
  }

  Future<void> _saveShoppingLists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonString = json.encode(
        _shoppingLists.map((list) => list.toJson()).toList(),
      );
      await prefs.setString(_shoppingStorageKey, jsonString);
    } catch (e) {
      // Ignore saving errors - data will be retried on next save
    }
  }

  Future<void> _saveWorkoutLists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonString = json.encode(
        _workoutLists.map((list) => list.toJson()).toList(),
      );
      await prefs.setString(_workoutStorageKey, jsonString);
    } catch (e) {
      // Ignore saving errors - data will be retried on next save
    }
  }

  Future<void> _saveExerciseHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonString = json.encode(
        _exerciseHistory.map((history) => history.toJson()).toList(),
      );
      await prefs.setString(_exerciseHistoryStorageKey, jsonString);
    } catch (e) {
      // Ignore saving errors - data will be retried on next save
    }
  }

  void addShoppingList(String name) {
    final newList = ShoppingList(
      id: _generateUniqueId(),
      name: name,
      items: [],
      createdAt: DateTime.now(),
    );
    _shoppingLists.add(newList);
    _saveData();
    notifyListeners();
  }

  void deleteShoppingList(String id) {
    _shoppingLists.removeWhere((list) => list.id == id);
    _saveData();
    notifyListeners();
  }

  void reorderShoppingLists(int oldIndex, int newIndex) {
    _shoppingLists = ListManager.reorderLists(_shoppingLists, oldIndex, newIndex);
    _saveData();
    notifyListeners();
  }

  void addItemToList(String listId, String itemName) {
    final listIndex = _shoppingLists.indexWhere((list) => list.id == listId);
    if (listIndex != -1) {
      final newItem = ShoppingItem(
        id: _generateUniqueId(),
        name: itemName,
      );
      final updatedItems = List<ShoppingItem>.from(_shoppingLists[listIndex].items)..add(newItem);
      _shoppingLists[listIndex] = _shoppingLists[listIndex].copyWith(items: updatedItems);
      _saveData();
      notifyListeners();
    }
  }

  void toggleItemCompletion(String listId, String itemId) {
    final listIndex = _shoppingLists.indexWhere((list) => list.id == listId);
    if (listIndex != -1) {
      final updatedItems = ListManager.toggleItemCompletion(_shoppingLists[listIndex].items, itemId);
      _shoppingLists[listIndex] = _shoppingLists[listIndex].copyWith(items: updatedItems);
      _saveData();
      notifyListeners();
    }
  }

  void deleteItemFromList(String listId, String itemId) {
    final listIndex = _shoppingLists.indexWhere((list) => list.id == listId);
    if (listIndex != -1) {
      final updatedItems = ListManager.deleteItem(_shoppingLists[listIndex].items, itemId);
      _shoppingLists[listIndex] = _shoppingLists[listIndex].copyWith(items: updatedItems);
      _saveData();
      notifyListeners();
    }
  }

  void reorderItems(String listId, int oldIndex, int newIndex) {
    final listIndex = _shoppingLists.indexWhere((list) => list.id == listId);
    if (listIndex != -1) {
      final updatedItems = ListManager.reorderItems(_shoppingLists[listIndex].items, oldIndex, newIndex);
      _shoppingLists[listIndex] = _shoppingLists[listIndex].copyWith(items: updatedItems);
      _saveData();
      notifyListeners();
    }
  }

  // Workout List Methods
  void addWorkoutList(String name) {
    final newList = WorkoutList(
      id: _generateUniqueId(),
      name: name,
      exercises: [],
      createdAt: DateTime.now(),
    );
    _workoutLists.add(newList);
    _saveData();
    notifyListeners();
  }

  void deleteWorkoutList(String id) {
    _workoutLists.removeWhere((list) => list.id == id);
    _saveData();
    notifyListeners();
  }

  void reorderWorkoutLists(int oldIndex, int newIndex) {
    _workoutLists = ListManager.reorderLists(_workoutLists, oldIndex, newIndex);
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
      final newExercise = Exercise(
        id: _generateUniqueId(),
        name: exerciseName,
        sets: sets,
        reps: reps,
        weight: weight,
        notes: notes,
      );
      final updatedExercises = List<Exercise>.from(_workoutLists[workoutIndex].exercises)..add(newExercise);
      _workoutLists[workoutIndex] = _workoutLists[workoutIndex].copyWith(exercises: updatedExercises);
      _saveData();
      notifyListeners();
    }
  }

  void updateExercise(String workoutId, String exerciseId, Exercise updatedExercise) {
    final workoutIndex = _workoutLists.indexWhere((list) => list.id == workoutId);
    if (workoutIndex != -1) {
      final exercises = _workoutLists[workoutIndex].exercises;
      final exerciseIndex = exercises.indexWhere((exercise) => exercise.id == exerciseId);
      if (exerciseIndex != -1) {
        final updatedExercises = List<Exercise>.from(exercises);
        updatedExercises[exerciseIndex] = updatedExercise;
        
        // Sort exercises: incomplete first, completed at bottom
        updatedExercises.sort((a, b) {
          if (a.isCompleted == b.isCompleted) return 0;
          return a.isCompleted ? 1 : -1;
        });
        
        _workoutLists[workoutIndex] = _workoutLists[workoutIndex].copyWith(exercises: updatedExercises);
        _saveData();
        notifyListeners();
      }
    }
  }

  void toggleExerciseCompletion(String workoutId, String exerciseId) {
    final workoutIndex = _workoutLists.indexWhere((list) => list.id == workoutId);
    if (workoutIndex != -1) {
      final updatedExercises = ListManager.toggleItemCompletion(_workoutLists[workoutIndex].exercises, exerciseId);
      _workoutLists[workoutIndex] = _workoutLists[workoutIndex].copyWith(exercises: updatedExercises);
      _saveData();
      notifyListeners();
    }
  }

  void deleteExerciseFromWorkout(String workoutId, String exerciseId) {
    final workoutIndex = _workoutLists.indexWhere((list) => list.id == workoutId);
    if (workoutIndex != -1) {
      final updatedExercises = ListManager.deleteItem(_workoutLists[workoutIndex].exercises, exerciseId);
      _workoutLists[workoutIndex] = _workoutLists[workoutIndex].copyWith(exercises: updatedExercises);
      _saveData();
      notifyListeners();
    }
  }

  void reorderExercises(String workoutId, int oldIndex, int newIndex) {
    final workoutIndex = _workoutLists.indexWhere((list) => list.id == workoutId);
    if (workoutIndex != -1) {
      final updatedExercises = ListManager.reorderItems(_workoutLists[workoutIndex].exercises, oldIndex, newIndex);
      _workoutLists[workoutIndex] = _workoutLists[workoutIndex].copyWith(exercises: updatedExercises);
      _saveData();
      notifyListeners();
    }
  }

  void saveWeightForExercise(String workoutId, String exerciseId, String weight, {int? sets, int? reps}) {
    final workoutIndex = _workoutLists.indexWhere((list) => list.id == workoutId);
    if (workoutIndex != -1) {
      final exercises = _workoutLists[workoutIndex].exercises;
      final exerciseIndex = exercises.indexWhere((exercise) => exercise.id == exerciseId);
      if (exerciseIndex != -1) {
        final exercise = exercises[exerciseIndex];
        var entryDate = DateTime.now();
        
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
        
        // Save to local exercise history (for backward compatibility)
        final updatedWeightHistory = List<WeightEntry>.from(exercise.weightHistory)
          ..add(newWeightEntry);
        
        final updatedExercise = exercise.copyWith(weightHistory: updatedWeightHistory);
        final updatedExercises = List<Exercise>.from(exercises);
        updatedExercises[exerciseIndex] = updatedExercise;
        
        _workoutLists[workoutIndex] = _workoutLists[workoutIndex].copyWith(exercises: updatedExercises);
        
        // Also save to global exercise history (without calling _saveData to avoid recursion)
        _addOrUpdateExerciseHistoryInternal(exercise.name, newWeightEntry);
        
        _saveData();
        notifyListeners();
      }
    }
  }

  void deleteWeightEntry(String workoutId, String exerciseId, DateTime entryDate) {
    final workoutIndex = _workoutLists.indexWhere((list) => list.id == workoutId);
    if (workoutIndex != -1) {
      final exercises = _workoutLists[workoutIndex].exercises;
      final exerciseIndex = exercises.indexWhere((exercise) => exercise.id == exerciseId);
      if (exerciseIndex != -1) {
        final exercise = exercises[exerciseIndex];
        
        // Find the first matching entry and remove only that one
        final updatedWeightHistory = List<WeightEntry>.from(exercise.weightHistory);
        final entryIndex = updatedWeightHistory.indexWhere((entry) => 
            _isSameDateTime(entry.date, entryDate));
        
        if (entryIndex != -1) {
          updatedWeightHistory.removeAt(entryIndex);
          
          // Also delete from global exercise history (without calling _saveData to avoid recursion)
          _deleteWeightFromExerciseHistoryInternal(exercise.name, entryDate);
        }
        
        final updatedExercise = exercise.copyWith(weightHistory: updatedWeightHistory);
        final updatedExercises = List<Exercise>.from(exercises);
        updatedExercises[exerciseIndex] = updatedExercise;
        
        _workoutLists[workoutIndex] = _workoutLists[workoutIndex].copyWith(exercises: updatedExercises);
        _saveData();
        notifyListeners();
      }
    }
  }

  bool _isSameDateTime(DateTime date1, DateTime date2) {
    return date1.millisecondsSinceEpoch == date2.millisecondsSinceEpoch;
  }

  void deleteTodaysWeightForExercise(String workoutId, String exerciseId) {
    final workoutIndex = _workoutLists.indexWhere((list) => list.id == workoutId);
    if (workoutIndex != -1) {
      final exercises = _workoutLists[workoutIndex].exercises;
      final exerciseIndex = exercises.indexWhere((exercise) => exercise.id == exerciseId);
      if (exerciseIndex != -1) {
        final exercise = exercises[exerciseIndex];
        final todaysWeight = exercise.todaysWeight;
        
        if (todaysWeight != null) {
          deleteWeightEntry(workoutId, exerciseId, todaysWeight.date);
        }
      }
    }
  }

  // Global Exercise History Management
  ExerciseHistory? getExerciseHistory(String exerciseName) {
    return _exerciseHistory.cast<ExerciseHistory?>().firstWhere(
      (history) => history?.exerciseName.toLowerCase() == exerciseName.toLowerCase(),
      orElse: () => null,
    );
  }

  void addOrUpdateExerciseHistory(String exerciseName, WeightEntry weightEntry) {
    _addOrUpdateExerciseHistoryInternal(exerciseName, weightEntry);
    _saveData();
    notifyListeners();
  }

  void _addOrUpdateExerciseHistoryInternal(String exerciseName, WeightEntry weightEntry) {
    final existingIndex = _exerciseHistory.indexWhere(
      (history) => history.exerciseName.toLowerCase() == exerciseName.toLowerCase(),
    );

    if (existingIndex != -1) {
      // Update existing exercise history
      final existing = _exerciseHistory[existingIndex];
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
      final updatedHistory = List<WeightEntry>.from(existing.weightHistory)..add(updatedEntry);
      
      _exerciseHistory[existingIndex] = existing.copyWith(
        weightHistory: updatedHistory,
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
      _exerciseHistory.add(newHistory);
    }
  }

  void deleteWeightFromExerciseHistory(String exerciseName, DateTime entryDate) {
    _deleteWeightFromExerciseHistoryInternal(exerciseName, entryDate);
    _saveData();
    notifyListeners();
  }

  void _deleteWeightFromExerciseHistoryInternal(String exerciseName, DateTime entryDate) {
    final historyIndex = _exerciseHistory.indexWhere(
      (history) => history.exerciseName.toLowerCase() == exerciseName.toLowerCase(),
    );

    if (historyIndex != -1) {
      final history = _exerciseHistory[historyIndex];
      final updatedWeightHistory = List<WeightEntry>.from(history.weightHistory);
      final entryIndex = updatedWeightHistory.indexWhere((entry) => 
          _isSameDateTime(entry.date, entryDate));
      
      if (entryIndex != -1) {
        updatedWeightHistory.removeAt(entryIndex);
        
        // Keep the history even if no weight entries - just update lastUsed
        _exerciseHistory[historyIndex] = history.copyWith(
          weightHistory: updatedWeightHistory,
          lastUsed: DateTime.now(),
        );
      }
    }
  }

  List<ExerciseHistory> getAllExerciseHistoriesWithWeights() {
    return _exerciseHistory.where((history) => history.weightHistory.isNotEmpty).toList()
      ..sort((a, b) => b.lastUsed.compareTo(a.lastUsed)); // Most recently used first
  }
}