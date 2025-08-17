import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopping_list_app/providers/shopping_app_state.dart';
import 'package:shopping_list_app/models/weight_entry.dart';
import 'package:shopping_list_app/screens/workout_detail_screen.dart';

void main() {
  group('AddExerciseDialog', () {
    late ShoppingAppState appState;

    setUp(() async {
      // Reset SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
      appState = ShoppingAppState();
      
      // Wait for async initialization to complete
      await Future.delayed(const Duration(milliseconds: 10));
    });

    Widget createTestWidget(String workoutId) {
      return MaterialApp(
        home: ChangeNotifierProvider.value(
          value: appState,
          child: Scaffold(
            body: AddExerciseDialog(workoutId: workoutId),
          ),
        ),
      );
    }

    group('Recommendations Display', () {
      testWidgets('should show recommendations section when exercises with logs exist', (tester) async {
        // Create workout
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        
        // Add exercise history with logs
        appState.addOrUpdateExerciseHistory('Push Ups', WeightEntry(
          date: DateTime.now(),
          weight: '80kg',
          sets: 3,
          reps: 10,
        ));
        appState.addOrUpdateExerciseHistory('Pull Ups', WeightEntry(
          date: DateTime.now(),
          weight: '75kg',
          sets: 3,
          reps: 8,
        ));

        await tester.pumpWidget(createTestWidget(workoutId));
        await tester.pumpAndSettle();

        // Should show suggestions header
        expect(find.text('Suggestions (with previous logs):'), findsOneWidget);
        
        // Should show recommendation chips
        expect(find.text('Push Ups'), findsOneWidget);
        expect(find.text('Pull Ups'), findsOneWidget);
      });

      testWidgets('should not show recommendations section when no exercises with logs exist', (tester) async {
        // Create workout with no exercise history
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;

        await tester.pumpWidget(createTestWidget(workoutId));
        await tester.pumpAndSettle();

        // Should not show suggestions header
        expect(find.text('Suggestions (with previous logs):'), findsNothing);
      });

      testWidgets('should limit recommendations to 6 exercises', (tester) async {
        // Create workout
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        
        // Add 8 exercise histories with logs
        for (int i = 1; i <= 8; i++) {
          appState.addOrUpdateExerciseHistory('Exercise $i', WeightEntry(
            date: DateTime.now(),
            weight: '${70 + i}kg',
          ));
        }

        await tester.pumpWidget(createTestWidget(workoutId));
        await tester.pumpAndSettle();

        // Should show suggestions header
        expect(find.text('Suggestions (with previous logs):'), findsOneWidget);
        
        // Should only show 6 ActionChips (limited by take(6))
        expect(find.byType(ActionChip), findsNWidgets(6));
      });

      testWidgets('should exclude exercises already in current workout', (tester) async {
        // Create workout with one exercise
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        appState.addExerciseToWorkout(workoutId, 'Push Ups');
        
        // Add exercise histories with logs
        appState.addOrUpdateExerciseHistory('Push Ups', WeightEntry(
          date: DateTime.now(),
          weight: '80kg',
        ));
        appState.addOrUpdateExerciseHistory('Pull Ups', WeightEntry(
          date: DateTime.now(),
          weight: '75kg',
        ));

        await tester.pumpWidget(createTestWidget(workoutId));
        await tester.pumpAndSettle();

        // Should show suggestions header
        expect(find.text('Suggestions (with previous logs):'), findsOneWidget);
        
        // Should only show Pull Ups, not Push Ups (already in workout)
        expect(find.text('Pull Ups'), findsOneWidget);
        expect(find.text('Push Ups'), findsNothing);
      });
    });

    group('Auto-fill Functionality', () {
      testWidgets('should auto-fill form when recommendation chip is tapped', (tester) async {
        // Create workout
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        
        // Add exercise history with specific values
        appState.addOrUpdateExerciseHistory('Push Ups', WeightEntry(
          date: DateTime.now(),
          weight: '80kg',
          sets: 3,
          reps: 10,
        ));

        await tester.pumpWidget(createTestWidget(workoutId));
        await tester.pumpAndSettle();

        // Get the text field widgets to check their initial state
        final textFields = find.byType(TextField);
        expect(textFields, findsNWidgets(5)); // 5 text fields: name, sets, reps, weight, notes

        // Tap the recommendation chip
        await tester.tap(find.text('Push Ups'));
        await tester.pumpAndSettle();

        // Verify the values are in the text fields (find by the controller values)
        final nameFieldWidget = tester.widget<TextField>(textFields.at(0));
        final setsFieldWidget = tester.widget<TextField>(textFields.at(1));
        final repsFieldWidget = tester.widget<TextField>(textFields.at(2));
        final weightFieldWidget = tester.widget<TextField>(textFields.at(3));
        
        expect(nameFieldWidget.controller?.text, 'Push Ups');
        expect(setsFieldWidget.controller?.text, '3');
        expect(repsFieldWidget.controller?.text, '10');
        expect(weightFieldWidget.controller?.text, '80kg');
      });

      testWidgets('should auto-fill only available values from last exercise log', (tester) async {
        // Create workout
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        
        // Add exercise history with only weight (no sets/reps)
        appState.addOrUpdateExerciseHistory('Squats', WeightEntry(
          date: DateTime.now(),
          weight: '100kg',
          // sets and reps are null
        ));

        await tester.pumpWidget(createTestWidget(workoutId));
        await tester.pumpAndSettle();

        // Tap the recommendation chip
        await tester.tap(find.text('Squats'));
        await tester.pumpAndSettle();

        // Get the text field widgets to check their values
        final textFields = find.byType(TextField);
        final nameFieldWidget = tester.widget<TextField>(textFields.at(0));
        final setsFieldWidget = tester.widget<TextField>(textFields.at(1));
        final repsFieldWidget = tester.widget<TextField>(textFields.at(2));
        final weightFieldWidget = tester.widget<TextField>(textFields.at(3));
        
        // Verify only name and weight are filled
        expect(nameFieldWidget.controller?.text, 'Squats');
        expect(weightFieldWidget.controller?.text, '100kg');
        
        // Sets and reps should remain empty (not auto-filled)
        expect(setsFieldWidget.controller?.text, '');
        expect(repsFieldWidget.controller?.text, '');
      });

      testWidgets('should use most recent exercise log values for auto-fill', (tester) async {
        // Create workout
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        
        // Add older exercise history
        appState.addOrUpdateExerciseHistory('Bench Press', WeightEntry(
          date: DateTime.now().subtract(const Duration(days: 1)),
          weight: '80kg',
          sets: 3,
          reps: 8,
        ));
        
        // Add more recent exercise history
        appState.addOrUpdateExerciseHistory('Bench Press', WeightEntry(
          date: DateTime.now(),
          weight: '85kg',
          sets: 4,
          reps: 6,
        ));

        await tester.pumpWidget(createTestWidget(workoutId));
        await tester.pumpAndSettle();

        // Tap the recommendation chip
        await tester.tap(find.text('Bench Press'));
        await tester.pumpAndSettle();

        // Get the text field widgets to check their values
        final textFields = find.byType(TextField);
        final nameFieldWidget = tester.widget<TextField>(textFields.at(0));
        final setsFieldWidget = tester.widget<TextField>(textFields.at(1));
        final repsFieldWidget = tester.widget<TextField>(textFields.at(2));
        final weightFieldWidget = tester.widget<TextField>(textFields.at(3));
        
        // Should use values from most recent entry (85kg, 4 sets, 6 reps)
        expect(nameFieldWidget.controller?.text, 'Bench Press');
        expect(setsFieldWidget.controller?.text, '4');
        expect(repsFieldWidget.controller?.text, '6');
        expect(weightFieldWidget.controller?.text, '85kg');
      });
    });

    group('Dialog Functionality', () {
      testWidgets('should show standard form fields', (tester) async {
        // Create workout
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;

        await tester.pumpWidget(createTestWidget(workoutId));
        await tester.pumpAndSettle();

        // Check all form fields are present
        expect(find.widgetWithText(TextField, ''), findsNWidgets(5)); // 5 empty text fields
        expect(find.text('Exercise name'), findsOneWidget);
        expect(find.text('Sets'), findsOneWidget);
        expect(find.text('Reps'), findsOneWidget);
        expect(find.text('Weight'), findsOneWidget);
        expect(find.text('Notes'), findsOneWidget);
      });

      testWidgets('should show dialog title and action buttons', (tester) async {
        // Create workout
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;

        await tester.pumpWidget(createTestWidget(workoutId));
        await tester.pumpAndSettle();

        // Check dialog components
        expect(find.text('Add Exercise'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
        expect(find.text('Add'), findsOneWidget);
      });

      testWidgets('should create exercise when Add button is tapped with valid input', (tester) async {
        // Create workout
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;

        await tester.pumpWidget(createTestWidget(workoutId));
        await tester.pumpAndSettle();

        // Fill in exercise name
        await tester.enterText(
          find.widgetWithText(TextField, '').first,
          'Test Exercise'
        );
        await tester.pumpAndSettle();

        // Verify no exercises exist initially
        expect(appState.workoutLists[0].exercises.length, 0);

        // Tap Add button
        await tester.tap(find.text('Add'));
        await tester.pumpAndSettle();

        // Verify exercise was added
        expect(appState.workoutLists[0].exercises.length, 1);
        expect(appState.workoutLists[0].exercises[0].name, 'Test Exercise');
      });

      testWidgets('should not create exercise when Add button is tapped with empty name', (tester) async {
        // Create workout
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;

        await tester.pumpWidget(createTestWidget(workoutId));
        await tester.pumpAndSettle();

        // Leave exercise name empty and tap Add button
        await tester.tap(find.text('Add'));
        await tester.pumpAndSettle();

        // Verify no exercise was added
        expect(appState.workoutLists[0].exercises.length, 0);
      });
    });

    group('Edge Cases', () {
      testWidgets('should handle workout with no exercise history gracefully', (tester) async {
        // Create workout with no history
        appState.addWorkoutList('Empty Workout');
        final workoutId = appState.workoutLists[0].id;

        await tester.pumpWidget(createTestWidget(workoutId));
        await tester.pumpAndSettle();

        // Should show dialog without recommendations section
        expect(find.text('Add Exercise'), findsOneWidget);
        expect(find.text('Suggestions (with previous logs):'), findsNothing);
        expect(find.byType(ActionChip), findsNothing);
      });

      testWidgets('should handle exercise history without weight logs', (tester) async {
        // Create workout
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        
        // Add exercise history, then remove weight log to simulate empty history
        appState.addOrUpdateExerciseHistory('Test Exercise', WeightEntry(
          date: DateTime.now(),
          weight: '80kg',
        ));
        appState.deleteWeightFromExerciseHistory('Test Exercise', DateTime.now());

        await tester.pumpWidget(createTestWidget(workoutId));
        await tester.pumpAndSettle();

        // Should show dialog without recommendations
        expect(find.text('Add Exercise'), findsOneWidget);
        expect(find.text('Suggestions (with previous logs):'), findsNothing);
        expect(find.text('Test Exercise'), findsNothing);
      });
    });
  });
}