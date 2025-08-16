import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopping_list_app/main.dart';
import 'package:shopping_list_app/models/exercise.dart';
import 'package:shopping_list_app/screens/exercise_weight_history_screen.dart';

void main() {
  group('ExerciseWeightHistoryScreen', () {
    late ShoppingAppState appState;
    late Exercise testExercise;
    late String workoutId;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      appState = ShoppingAppState();
      appState.addWorkoutList('Test Workout');
      workoutId = appState.workoutLists[0].id;
      appState.addExerciseToWorkout(workoutId, 'Bench Press', weight: '80kg', sets: '3', reps: '10');
      testExercise = appState.workoutLists[0].exercises[0];
    });

    Widget createTestWidget(Exercise exercise) {
      return ChangeNotifierProvider.value(
        value: appState,
        child: MaterialApp(
          home: ExerciseWeightHistoryScreen(
            exercise: exercise,
            workoutId: workoutId,
            workoutName: 'Test Workout',
          ),
        ),
      );
    }

    testWidgets('should show empty state when no weight history exists', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(testExercise));
      
      expect(find.text('No weight history yet'), findsOneWidget);
      expect(find.text('Start tracking by saving weights for this exercise'), findsOneWidget);
      expect(find.byIcon(Icons.timeline), findsOneWidget);
    });

    testWidgets('should display weight history entries correctly', (WidgetTester tester) async {
      // Add some weight entries
      appState.saveWeightForExercise(workoutId, testExercise.id, '80kg');
      appState.saveWeightForExercise(workoutId, testExercise.id, '85kg');
      appState.saveWeightForExercise(workoutId, testExercise.id, '90kg');
      
      await tester.pumpWidget(createTestWidget(testExercise));
      
      // Should show all weight entries
      expect(find.text('80kg'), findsOneWidget);
      expect(find.text('85kg'), findsOneWidget);
      expect(find.text('90kg'), findsOneWidget);
      
      // Should show exercise name in app bar
      expect(find.text('Bench Press'), findsOneWidget);
      
      // Should show LATEST badge on first entry
      expect(find.text('LATEST'), findsOneWidget);
    });

    testWidgets('should show progression indicators correctly', (WidgetTester tester) async {
      // Add weight entries with progression
      appState.saveWeightForExercise(workoutId, testExercise.id, '80kg');
      appState.saveWeightForExercise(workoutId, testExercise.id, '85kg');
      
      await tester.pumpWidget(createTestWidget(testExercise));
      
      // Should show progression indicator
      expect(find.byIcon(Icons.trending_up), findsOneWidget);
      expect(find.text('+5.0kg'), findsOneWidget);
    });

    testWidgets('should show exercise details (sets/reps) when available', (WidgetTester tester) async {
      appState.saveWeightForExercise(workoutId, testExercise.id, '80kg');
      
      await tester.pumpWidget(createTestWidget(testExercise));
      
      // Should show sets and reps
      expect(find.textContaining('3'), findsAtLeastNWidgets(1));
      expect(find.textContaining('sets'), findsOneWidget);
      expect(find.textContaining('10'), findsAtLeastNWidgets(1));
      expect(find.textContaining('reps'), findsOneWidget);
      expect(find.byIcon(Icons.fitness_center), findsOneWidget);
    });

    testWidgets('should show TODAY badge for today\'s entries', (WidgetTester tester) async {
      appState.saveWeightForExercise(workoutId, testExercise.id, '80kg');
      
      await tester.pumpWidget(createTestWidget(testExercise));
      
      // Should show TODAY badge
      expect(find.text('TODAY'), findsOneWidget);
    });

    testWidgets('should show delete confirmation dialog when delete button is tapped', (WidgetTester tester) async {
      appState.saveWeightForExercise(workoutId, testExercise.id, '80kg');
      
      await tester.pumpWidget(createTestWidget(testExercise));
      
      // Tap delete button
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      
      // Should show delete confirmation dialog
      expect(find.text('Delete Weight Entry'), findsOneWidget);
      expect(find.textContaining('Are you sure you want to delete this weight entry?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('should delete weight entry when confirmed', (WidgetTester tester) async {
      appState.saveWeightForExercise(workoutId, testExercise.id, '80kg');
      appState.saveWeightForExercise(workoutId, testExercise.id, '85kg');
      
      await tester.pumpWidget(createTestWidget(testExercise));
      
      // Verify initial state
      expect(find.text('80kg'), findsOneWidget);
      expect(find.text('85kg'), findsOneWidget);
      
      // Tap delete button on first entry (85kg - latest)
      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await tester.pumpAndSettle();
      
      // Confirm deletion
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      
      // Should only show one entry now
      expect(find.text('80kg'), findsOneWidget);
      expect(find.text('85kg'), findsNothing);
    });

    testWidgets('should handle cancel in delete dialog correctly', (WidgetTester tester) async {
      appState.saveWeightForExercise(workoutId, testExercise.id, '80kg');
      
      await tester.pumpWidget(createTestWidget(testExercise));
      
      // Tap delete button
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      
      // Cancel deletion
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      
      // Should still show the entry
      expect(find.text('80kg'), findsOneWidget);
    });
  });
}