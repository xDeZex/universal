import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/shopping_list.dart';
import 'models/shopping_item.dart';
import 'models/workout_list.dart';
import 'models/exercise.dart';
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
  static const String _shoppingStorageKey = 'shopping_lists';
  static const String _workoutStorageKey = 'workout_lists';
  static int _idCounter = 0;

  List<ShoppingList> get shoppingLists => _shoppingLists;
  List<WorkoutList> get workoutLists => _workoutLists;

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

  Future<void> _saveData() async {
    await _saveShoppingLists();
    await _saveWorkoutLists();
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

  void addExerciseToWorkout(String workoutId, String exerciseName) {
    final workoutIndex = _workoutLists.indexWhere((list) => list.id == workoutId);
    if (workoutIndex != -1) {
      final newExercise = Exercise(
        id: _generateUniqueId(),
        name: exerciseName,
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
}