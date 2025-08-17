import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:universal/providers/shopping_app_state.dart';
import 'package:universal/screens/workout_lists_screen.dart';

void main() {
  group('WorkoutListsScreen', () {
    testWidgets('should display exercise count with singular form for one exercise', (tester) async {
      final appState = ShoppingAppState();
      
      // Add a workout with one exercise
      appState.addWorkoutList('Test Workout');
      final workoutId = appState.workoutLists[0].id;
      appState.addExerciseToWorkout(workoutId, 'Push-ups');
      
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: appState,
          child: const MaterialApp(
            home: WorkoutListsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      // Should show "1 exercise" not "1 exercises"
      expect(find.text('1 exercise'), findsOneWidget);
      expect(find.text('1 exercises'), findsNothing);
      
      // Should not show completion ratio format
      expect(find.textContaining('0/1'), findsNothing);
      expect(find.textContaining('exercises completed'), findsNothing);
    });

    testWidgets('should display exercise count with plural form for multiple exercises', (tester) async {
      final appState = ShoppingAppState();
      
      // Add a workout with multiple exercises
      appState.addWorkoutList('Test Workout');
      final workoutId = appState.workoutLists[0].id;
      appState.addExerciseToWorkout(workoutId, 'Push-ups');
      appState.addExerciseToWorkout(workoutId, 'Squats');
      appState.addExerciseToWorkout(workoutId, 'Bench Press');
      
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: appState,
          child: const MaterialApp(
            home: WorkoutListsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      // Should show "3 exercises" in plural form
      expect(find.text('3 exercises'), findsOneWidget);
      expect(find.text('3 exercise'), findsNothing);
      
      // Should not show completion ratio format
      expect(find.textContaining('0/3'), findsNothing);
      expect(find.textContaining('3/3'), findsNothing);
      expect(find.textContaining('exercises completed'), findsNothing);
    });

    testWidgets('should display "0 exercises" for empty workout', (tester) async {
      final appState = ShoppingAppState();
      
      // Add a workout with no exercises
      appState.addWorkoutList('Empty Workout');
      
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: appState,
          child: const MaterialApp(
            home: WorkoutListsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      // Should show "0 exercises" 
      expect(find.text('0 exercises'), findsOneWidget);
      
      // Should not show completion ratio format
      expect(find.textContaining('0/0'), findsNothing);
      expect(find.textContaining('exercises completed'), findsNothing);
    });

    testWidgets('should display correct exercise count regardless of completion status', (tester) async {
      final appState = ShoppingAppState();
      
      // Add a workout with exercises, some completed
      appState.addWorkoutList('Mixed Workout');
      final workoutId = appState.workoutLists[0].id;
      appState.addExerciseToWorkout(workoutId, 'Push-ups');
      appState.addExerciseToWorkout(workoutId, 'Squats');
      
      // Mark one exercise as completed
      final exerciseId = appState.workoutLists[0].exercises[0].id;
      appState.toggleExerciseCompletion(workoutId, exerciseId);
      
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: appState,
          child: const MaterialApp(
            home: WorkoutListsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      // Should still show total count "2 exercises", not completion ratio
      expect(find.text('2 exercises'), findsOneWidget);
      
      // Should not show completion ratio format like "1/2 exercises completed"
      expect(find.textContaining('1/2'), findsNothing);
      expect(find.textContaining('exercises completed'), findsNothing);
    });

    testWidgets('should show workout list with correct exercise counts for multiple workouts', (tester) async {
      final appState = ShoppingAppState();
      
      // Add multiple workouts with different exercise counts
      appState.addWorkoutList('Workout A');
      final workoutAId = appState.workoutLists[0].id;
      appState.addExerciseToWorkout(workoutAId, 'Push-ups');
      
      appState.addWorkoutList('Workout B');
      final workoutBId = appState.workoutLists[1].id;
      appState.addExerciseToWorkout(workoutBId, 'Squats');
      appState.addExerciseToWorkout(workoutBId, 'Bench Press');
      appState.addExerciseToWorkout(workoutBId, 'Deadlifts');
      
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: appState,
          child: const MaterialApp(
            home: WorkoutListsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      // Should show correct counts for each workout
      expect(find.text('1 exercise'), findsOneWidget);   // Workout A
      expect(find.text('3 exercises'), findsOneWidget);  // Workout B
      
      // Should not show any completion ratios
      expect(find.textContaining('exercises completed'), findsNothing);
    });
  });
}