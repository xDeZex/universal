import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/checklist.dart';
import '../models/exercise.dart';
import '../models/workout.dart';

class StorageService {
  static const String _checklistsKey = 'checklists';
  static const String _workoutsKey = 'workouts';
  static const String _exercisesKey = 'exercises';

  Future<List<T>> _loadList<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(key);

      if (jsonString == null) return [];

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _saveList<T>(
    String key,
    List<T> items,
    Map<String, dynamic> Function(T) toJson,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = items.map(toJson).toList();
    await prefs.setString(key, jsonEncode(jsonList));
  }

  Future<List<Checklist>> loadChecklists() =>
      _loadList(_checklistsKey, Checklist.fromJson);

  Future<void> saveChecklists(List<Checklist> checklists) =>
      _saveList(_checklistsKey, checklists, (c) => c.toJson());

  Future<List<Workout>> loadWorkouts() =>
      _loadList(_workoutsKey, Workout.fromJson);

  Future<void> saveWorkouts(List<Workout> workouts) =>
      _saveList(_workoutsKey, workouts, (w) => w.toJson());

  Future<List<Exercise>> loadExercises() =>
      _loadList(_exercisesKey, Exercise.fromJson);

  Future<void> saveExercises(List<Exercise> exercises) =>
      _saveList(_exercisesKey, exercises, (e) => e.toJson());
}
