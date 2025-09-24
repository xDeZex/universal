import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/shopping_list.dart';
import '../models/workout_list.dart';
import '../models/exercise_history.dart';
import '../models/training_split.dart';
import '../models/calendar_event.dart';

class StorageService {
  static const String _shoppingStorageKey = 'shopping_lists';
  static const String _workoutStorageKey = 'workout_lists';
  static const String _exerciseHistoryStorageKey = 'exercise_history';
  static const String _trainingSplitsStorageKey = 'training_splits';
  static const String _calendarEventsStorageKey = 'calendar_events';

  static Future<List<ShoppingList>> loadShoppingLists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_shoppingStorageKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        return jsonList
            .map((jsonItem) => ShoppingList.fromJson(jsonItem as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<WorkoutList>> loadWorkoutLists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_workoutStorageKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        return jsonList
            .map((jsonItem) => WorkoutList.fromJson(jsonItem as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<ExerciseHistory>> loadExerciseHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_exerciseHistoryStorageKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        return jsonList
            .map((jsonItem) => ExerciseHistory.fromJson(jsonItem as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveShoppingLists(List<ShoppingList> shoppingLists) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonString = json.encode(
        shoppingLists.map((list) => list.toJson()).toList(),
      );
      await prefs.setString(_shoppingStorageKey, jsonString);
    } catch (e) {
      // Ignore saving errors - data will be retried on next save
    }
  }

  static Future<void> saveWorkoutLists(List<WorkoutList> workoutLists) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonString = json.encode(
        workoutLists.map((list) => list.toJson()).toList(),
      );
      await prefs.setString(_workoutStorageKey, jsonString);
    } catch (e) {
      // Ignore saving errors - data will be retried on next save
    }
  }

  static Future<void> saveExerciseHistory(List<ExerciseHistory> exerciseHistory) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonString = json.encode(
        exerciseHistory.map((history) => history.toJson()).toList(),
      );
      await prefs.setString(_exerciseHistoryStorageKey, jsonString);
    } catch (e) {
      // Ignore saving errors - data will be retried on next save
    }
  }

  static Future<List<TrainingSplit>> loadTrainingSplits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_trainingSplitsStorageKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        return jsonList
            .map((jsonItem) => TrainingSplit.fromJson(jsonItem as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveTrainingSplits(List<TrainingSplit> trainingSplits) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonString = json.encode(
        trainingSplits.map((split) => split.toJson()).toList(),
      );
      await prefs.setString(_trainingSplitsStorageKey, jsonString);
    } catch (e) {
      // Ignore saving errors - data will be retried on next save
    }
  }

  static Future<List<CalendarEvent>> loadCalendarEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_calendarEventsStorageKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        return jsonList
            .map((jsonItem) => CalendarEvent.fromJson(jsonItem as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveCalendarEvents(List<CalendarEvent> calendarEvents) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonString = json.encode(
        calendarEvents.map((event) => event.toJson()).toList(),
      );
      await prefs.setString(_calendarEventsStorageKey, jsonString);
    } catch (e) {
      // Ignore saving errors - data will be retried on next save
    }
  }
}