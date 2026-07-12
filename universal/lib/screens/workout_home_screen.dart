import 'package:flutter/material.dart';

import '../models/exercise.dart';
import '../models/workout.dart';
import '../services/storage_service.dart';
import 'active_workout_screen.dart';
import 'past_workouts_screen.dart';

class WorkoutHomeScreen extends StatefulWidget {
  final List<Workout>? initialWorkouts;
  final List<Exercise>? initialExercises;

  const WorkoutHomeScreen({
    super.key,
    this.initialWorkouts,
    this.initialExercises,
  });

  @override
  State<WorkoutHomeScreen> createState() => _WorkoutHomeScreenState();
}

class _WorkoutHomeScreenState extends State<WorkoutHomeScreen> {
  final StorageService _storage = StorageService();
  List<Workout> _workouts = [];
  List<Exercise> _exercises = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.initialWorkouts != null || widget.initialExercises != null) {
      setState(() {
        _workouts = widget.initialWorkouts ?? [];
        _exercises = widget.initialExercises ?? [];
        _isLoading = false;
      });
      return;
    }

    final workouts = await _storage.loadWorkouts();
    final exercises = await _storage.loadExercises();
    setState(() {
      _workouts = workouts;
      _exercises = exercises;
      _isLoading = false;
    });
  }

  bool get _hasInProgress => _workouts.any((w) => w.isInProgress);

  Workout get _inProgressWorkout => _workouts.firstWhere((w) => w.isInProgress);

  void _startWorkout() {
    if (_hasInProgress) return;

    final workout = Workout(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      startTime: DateTime.now(),
    );

    setState(() {
      _workouts = [..._workouts, workout];
    });
    _storage.saveWorkouts(_workouts);
    _openActiveWorkout(workout);
  }

  void _continueWorkout() {
    _openActiveWorkout(_inProgressWorkout);
  }

  void _openPastWorkouts() {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => PastWorkoutsScreen(
          workouts: _workouts,
          exercises: _exercises,
          onWorkoutChanged: _onWorkoutChanged,
          onExercisesChanged: _onExercisesChanged,
          onWorkoutDiscarded: _onWorkoutDiscarded,
        ),
      ),
    );
  }

  void _openActiveWorkout(Workout workout) {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => ActiveWorkoutScreen(
          workout: workout,
          exercises: _exercises,
          onWorkoutChanged: _onWorkoutChanged,
          onExercisesChanged: _onExercisesChanged,
          onWorkoutDiscarded: _onWorkoutDiscarded,
        ),
      ),
    );
  }

  void _onWorkoutChanged(Workout updated) {
    setState(() {
      _workouts = _workouts
          .map((w) => w.id == updated.id ? updated : w)
          .toList();
    });
    _storage.saveWorkouts(_workouts);
  }

  void _onWorkoutDiscarded(String workoutId) {
    setState(() {
      _workouts = _workouts
          .where((w) => !(w.id == workoutId && w.isInProgress))
          .toList();
    });
    _storage.saveWorkouts(_workouts);
  }

  void _onExercisesChanged(List<Exercise> updated) {
    setState(() {
      _exercises = updated;
    });
    _storage.saveExercises(_exercises);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workout')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: _hasInProgress
                        ? _continueWorkout
                        : _startWorkout,
                    child: Text(
                      _hasInProgress ? 'Continue Workout' : 'Start Workout',
                    ),
                  ),
                  TextButton(
                    onPressed: _openPastWorkouts,
                    child: const Text('Past Workouts'),
                  ),
                ],
              ),
            ),
    );
  }
}
