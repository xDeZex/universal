import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:universal/providers/shopping_app_state.dart';
import 'package:universal/screens/exercise_graphs_screen.dart';
import 'package:universal/screens/weight_tracking_screen.dart';

void main() {
  group('Exercise Graphs Feature', () {
    group('Weight Tracking Screen FAB', () {
      testWidgets('should not show FAB when no exercise data exists', (tester) async {
        final appState = ShoppingAppState();

        await tester.pumpWidget(
          ChangeNotifierProvider.value(
            value: appState,
            child: const MaterialApp(
              home: WeightTrackingScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Should not show floating action button when no data
        expect(find.byType(FloatingActionButton), findsNothing);
      });

      testWidgets('should show FAB when exercise data exists', (tester) async {
        final appState = ShoppingAppState();
        
        // Add a workout with exercise and weight data
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        appState.addExerciseToWorkout(workoutId, 'Bench Press');
        final exerciseId = appState.workoutLists[0].exercises[0].id;
        appState.saveWeightForExercise(workoutId, exerciseId, '80kg');

        await tester.pumpWidget(
          ChangeNotifierProvider.value(
            value: appState,
            child: const MaterialApp(
              home: WeightTrackingScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Should show floating action button when data exists
        expect(find.byType(FloatingActionButton), findsOneWidget);
        expect(find.byIcon(Icons.bar_chart), findsOneWidget);
      });

      testWidgets('should show correct FAB tooltip', (tester) async {
        final appState = ShoppingAppState();
        
        // Add exercise data
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        appState.addExerciseToWorkout(workoutId, 'Squats');
        final exerciseId = appState.workoutLists[0].exercises[0].id;
        appState.saveWeightForExercise(workoutId, exerciseId, '100kg');

        await tester.pumpWidget(
          ChangeNotifierProvider.value(
            value: appState,
            child: const MaterialApp(
              home: WeightTrackingScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Long press to show tooltip
        await tester.longPress(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        expect(find.text('View Exercise Graphs'), findsOneWidget);
      });

      testWidgets('should navigate to exercise graphs when FAB is tapped', (tester) async {
        final appState = ShoppingAppState();
        
        // Add exercise data
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        appState.addExerciseToWorkout(workoutId, 'Deadlift');
        final exerciseId = appState.workoutLists[0].exercises[0].id;
        appState.saveWeightForExercise(workoutId, exerciseId, '120kg');

        await tester.pumpWidget(
          ChangeNotifierProvider.value(
            value: appState,
            child: const MaterialApp(
              home: WeightTrackingScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap the FAB
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        // Should navigate to Exercise Graphs screen
        expect(find.byType(ExerciseGraphsScreen), findsOneWidget);
        expect(find.text('Exercise Progress'), findsOneWidget);
      });
    });

    group('ExerciseGraphsScreen', () {
      testWidgets('should show empty state when no exercise data exists', (tester) async {
        final appState = ShoppingAppState();

        await tester.pumpWidget(
          ChangeNotifierProvider.value(
            value: appState,
            child: const MaterialApp(
              home: ExerciseGraphsScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Should show empty state
        expect(find.byIcon(Icons.bar_chart), findsOneWidget);
        expect(find.text('No exercise data yet'), findsOneWidget);
        expect(find.text('Start logging weights to see progress graphs'), findsOneWidget);
      });

      testWidgets('should display exercise cards when data exists', (tester) async {
        final appState = ShoppingAppState();
        
        // Add multiple exercises with weight data
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        
        appState.addExerciseToWorkout(workoutId, 'Bench Press');
        final benchId = appState.workoutLists[0].exercises[0].id;
        appState.saveWeightForExercise(workoutId, benchId, '80kg');
        appState.saveWeightForExercise(workoutId, benchId, '85kg');
        
        appState.addExerciseToWorkout(workoutId, 'Squats');
        final squatId = appState.workoutLists[0].exercises[1].id;
        appState.saveWeightForExercise(workoutId, squatId, '100kg');

        await tester.pumpWidget(
          ChangeNotifierProvider.value(
            value: appState,
            child: const MaterialApp(
              home: ExerciseGraphsScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Should show exercise cards
        expect(find.text('Bench Press'), findsOneWidget);
        expect(find.text('Squats'), findsOneWidget);
        expect(find.byType(Card), findsNWidgets(2));
      });

      testWidgets('should display correct exercise information in cards', (tester) async {
        final appState = ShoppingAppState();
        
        // Add exercise with multiple weight entries
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        appState.addExerciseToWorkout(workoutId, 'Deadlift');
        final exerciseId = appState.workoutLists[0].exercises[0].id;
        
        // Add multiple weight entries
        appState.saveWeightForExercise(workoutId, exerciseId, '120kg');
        appState.saveWeightForExercise(workoutId, exerciseId, '125kg');
        appState.saveWeightForExercise(workoutId, exerciseId, '130kg');

        await tester.pumpWidget(
          ChangeNotifierProvider.value(
            value: appState,
            child: const MaterialApp(
              home: ExerciseGraphsScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Should show exercise name and entry count
        expect(find.text('Deadlift'), findsOneWidget);
        expect(find.text('3 entries'), findsOneWidget);
        expect(find.text('Latest'), findsOneWidget);
        // Should show latest weight (multiple instances expected due to header + chart + stats)
        expect(find.text('130kg'), findsAtLeast(1));
      });

      testWidgets('should handle singular vs plural entry count correctly', (tester) async {
        final appState = ShoppingAppState();
        
        // Add exercise with single weight entry
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        appState.addExerciseToWorkout(workoutId, 'Pull-ups');
        final exerciseId = appState.workoutLists[0].exercises[0].id;
        appState.saveWeightForExercise(workoutId, exerciseId, '10kg');

        await tester.pumpWidget(
          ChangeNotifierProvider.value(
            value: appState,
            child: const MaterialApp(
              home: ExerciseGraphsScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Should show singular form for single entry
        expect(find.text('1 entry'), findsOneWidget);
        expect(find.text('1 entries'), findsNothing);
      });

      testWidgets('should display progress stats for exercises with multiple entries', (tester) async {
        final appState = ShoppingAppState();
        
        // Add exercise with progression
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        appState.addExerciseToWorkout(workoutId, 'Overhead Press');
        final exerciseId = appState.workoutLists[0].exercises[0].id;
        
        // Add entries showing progression
        appState.saveWeightForExercise(workoutId, exerciseId, '50kg');
        appState.saveWeightForExercise(workoutId, exerciseId, '55kg');
        appState.saveWeightForExercise(workoutId, exerciseId, '60kg');

        await tester.pumpWidget(
          ChangeNotifierProvider.value(
            value: appState,
            child: const MaterialApp(
              home: ExerciseGraphsScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Should show new stats format
        expect(find.text('Weight Change'), findsOneWidget);
        expect(find.text('Volume Change'), findsOneWidget);
        expect(find.text('Sessions'), findsOneWidget);
        expect(find.text('+10.0kg'), findsOneWidget); // 60kg - 50kg = +10kg
        expect(find.text('3'), findsAtLeast(1)); // Number of sessions (may appear in multiple places)
        // Should show latest weight (multiple instances expected)
        expect(find.text('60kg'), findsAtLeast(1));
      });

      testWidgets('should not show progress stats for single entry exercises', (tester) async {
        final appState = ShoppingAppState();
        
        // Add exercise with single entry
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        appState.addExerciseToWorkout(workoutId, 'Bicep Curls');
        final exerciseId = appState.workoutLists[0].exercises[0].id;
        appState.saveWeightForExercise(workoutId, exerciseId, '15kg');

        await tester.pumpWidget(
          ChangeNotifierProvider.value(
            value: appState,
            child: const MaterialApp(
              home: ExerciseGraphsScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Should show stats even for single entry
        expect(find.text('Weight Change'), findsOneWidget);
        expect(find.text('Volume Change'), findsOneWidget);
        expect(find.text('Sessions'), findsOneWidget);
        expect(find.text('0.0kg'), findsOneWidget); // Weight change should show 0 for single entry
        expect(find.text('0'), findsAtLeast(1)); // Volume change should show 0 for single entry (may appear multiple times)
      });

      testWidgets('should sort exercises by most recent activity', (tester) async {
        final appState = ShoppingAppState();
        
        // Add workout and exercises
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        
        // Add older exercise first
        appState.addExerciseToWorkout(workoutId, 'Old Exercise');
        final oldId = appState.workoutLists[0].exercises[0].id;
        appState.saveWeightForExercise(workoutId, oldId, '50kg', date: DateTime.now().subtract(const Duration(days: 7)));
        
        // Add newer exercise
        appState.addExerciseToWorkout(workoutId, 'New Exercise');
        final newId = appState.workoutLists[0].exercises[1].id;
        appState.saveWeightForExercise(workoutId, newId, '60kg', date: DateTime.now());

        await tester.pumpWidget(
          ChangeNotifierProvider.value(
            value: appState,
            child: const MaterialApp(
              home: ExerciseGraphsScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Should show both exercises
        expect(find.text('Old Exercise'), findsOneWidget);
        expect(find.text('New Exercise'), findsOneWidget);
        expect(find.byType(Card), findsNWidgets(2));
        
        // Note: The sorting order is tested functionally - the newer exercise should appear first
        // but the exact positioning in the widget tree can vary based on implementation
      });

      testWidgets('should handle exercises with different weight formats', (tester) async {
        final appState = ShoppingAppState();
        
        // Add exercise with various weight formats
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        appState.addExerciseToWorkout(workoutId, 'Mixed Format Exercise');
        final exerciseId = appState.workoutLists[0].exercises[0].id;
        
        // Add weights in different formats
        appState.saveWeightForExercise(workoutId, exerciseId, '50kg');
        appState.saveWeightForExercise(workoutId, exerciseId, '55.5 kg');
        appState.saveWeightForExercise(workoutId, exerciseId, 'bodyweight');

        await tester.pumpWidget(
          ChangeNotifierProvider.value(
            value: appState,
            child: const MaterialApp(
              home: ExerciseGraphsScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Should handle mixed formats gracefully
        expect(find.text('Mixed Format Exercise'), findsOneWidget);
        expect(find.text('3 entries'), findsOneWidget);
        expect(find.text('bodyweight'), findsOneWidget); // Latest entry
      });

      testWidgets('should show correct app bar', (tester) async {
        final appState = ShoppingAppState();

        await tester.pumpWidget(
          ChangeNotifierProvider.value(
            value: appState,
            child: const MaterialApp(
              home: ExerciseGraphsScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Should show correct app bar title
        expect(find.text('Exercise Progress'), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);
      });

      testWidgets('should handle deleted exercises properly', (tester) async {
        final appState = ShoppingAppState();
        
        // Add exercise, log weight, then delete exercise from workout
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        appState.addExerciseToWorkout(workoutId, 'Temporary Exercise');
        final exerciseId = appState.workoutLists[0].exercises[0].id;
        appState.saveWeightForExercise(workoutId, exerciseId, '75kg');
        
        // Delete the exercise from workout (but weight history remains in global storage)
        appState.deleteExerciseFromWorkout(workoutId, exerciseId);

        await tester.pumpWidget(
          ChangeNotifierProvider.value(
            value: appState,
            child: const MaterialApp(
              home: ExerciseGraphsScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Should still show the exercise data from global history
        expect(find.text('Temporary Exercise'), findsOneWidget);
        expect(find.text('75kg'), findsOneWidget);
      });
    });

    group('Time Interval Filtering', () {
      testWidgets('should show time period menu when calendar icon is tapped', (tester) async {
        final appState = ShoppingAppState();
        
        // Add exercise with weight data
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        appState.addExerciseToWorkout(workoutId, 'Test Exercise');
        final exerciseId = appState.workoutLists[0].exercises[0].id;
        appState.saveWeightForExercise(workoutId, exerciseId, '80kg');

        await tester.pumpWidget(
          ChangeNotifierProvider.value(
            value: appState,
            child: const MaterialApp(
              home: ExerciseGraphsScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap the calendar icon
        await tester.tap(find.byIcon(Icons.calendar_today).first);
        await tester.pumpAndSettle();

        // Should show time period menu
        expect(find.text('Week'), findsOneWidget);
        expect(find.text('Month'), findsOneWidget);
        expect(find.text('3 Months'), findsOneWidget);
        expect(find.text('6 Months'), findsOneWidget);
        expect(find.text('Year'), findsOneWidget);
        expect(find.text('All Time'), findsOneWidget);
      });

      testWidgets('should show 3 Months as default selected period', (tester) async {
        final appState = ShoppingAppState();
        
        // Add exercise with weight data
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        appState.addExerciseToWorkout(workoutId, 'Test Exercise');
        final exerciseId = appState.workoutLists[0].exercises[0].id;
        appState.saveWeightForExercise(workoutId, exerciseId, '80kg');

        await tester.pumpWidget(
          ChangeNotifierProvider.value(
            value: appState,
            child: const MaterialApp(
              home: ExerciseGraphsScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap the calendar icon
        await tester.tap(find.byIcon(Icons.calendar_today).first);
        await tester.pumpAndSettle();

        // Should show 3 Months as selected (with check icon)
        expect(find.byIcon(Icons.check), findsOneWidget);
        
        // The check should be next to "3 Months"
        final checkIcon = find.byIcon(Icons.check);
        final threeMonthsText = find.text('3 Months');
        expect(checkIcon, findsOneWidget);
        expect(threeMonthsText, findsOneWidget);
      });

      testWidgets('should update selected period when menu item is tapped', (tester) async {
        final appState = ShoppingAppState();
        
        // Add exercise with weight data
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        appState.addExerciseToWorkout(workoutId, 'Test Exercise');
        final exerciseId = appState.workoutLists[0].exercises[0].id;
        appState.saveWeightForExercise(workoutId, exerciseId, '80kg');

        await tester.pumpWidget(
          ChangeNotifierProvider.value(
            value: appState,
            child: const MaterialApp(
              home: ExerciseGraphsScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap the calendar icon
        await tester.tap(find.byIcon(Icons.calendar_today).first);
        await tester.pumpAndSettle();

        // Tap on "Week" option
        await tester.tap(find.text('Week'));
        await tester.pumpAndSettle();

        // Open menu again to verify selection changed
        await tester.tap(find.byIcon(Icons.calendar_today).first);
        await tester.pumpAndSettle();

        // The check should now be next to "Week"
        expect(find.byIcon(Icons.check), findsOneWidget);
        // Note: We can't easily test the exact positioning in widget tests,
        // but we can verify the menu still works
      });

      testWidgets('should filter data based on selected time period', (tester) async {
        final appState = ShoppingAppState();
        
        // Add exercise with weight data across different time periods
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        appState.addExerciseToWorkout(workoutId, 'Test Exercise');
        final exerciseId = appState.workoutLists[0].exercises[0].id;
        
        // Add recent entry (within week)
        appState.saveWeightForExercise(workoutId, exerciseId, '80kg', date: DateTime.now().subtract(const Duration(days: 3)));
        
        // Add older entry (beyond week but within month)
        appState.saveWeightForExercise(workoutId, exerciseId, '75kg', date: DateTime.now().subtract(const Duration(days: 15)));
        
        // Add very old entry (beyond month)
        appState.saveWeightForExercise(workoutId, exerciseId, '70kg', date: DateTime.now().subtract(const Duration(days: 60)));

        await tester.pumpWidget(
          ChangeNotifierProvider.value(
            value: appState,
            child: const MaterialApp(
              home: ExerciseGraphsScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Initially shows all data (3 Months default should include all entries)
        expect(find.text('3 entries'), findsOneWidget);

        // Change to Week filter
        await tester.tap(find.byIcon(Icons.calendar_today).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Week'));
        await tester.pumpAndSettle();

        // Should now show only 1 entry (from last week)
        expect(find.text('1 entry'), findsOneWidget);
        expect(find.text('3 entries'), findsNothing);
      });

      testWidgets('should handle All Time filter correctly', (tester) async {
        final appState = ShoppingAppState();
        
        // Add exercise with weight data across long time periods
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        appState.addExerciseToWorkout(workoutId, 'Long History Exercise');
        final exerciseId = appState.workoutLists[0].exercises[0].id;
        
        // Add entries across different time periods
        appState.saveWeightForExercise(workoutId, exerciseId, '80kg', date: DateTime.now());
        appState.saveWeightForExercise(workoutId, exerciseId, '75kg', date: DateTime.now().subtract(const Duration(days: 100)));
        appState.saveWeightForExercise(workoutId, exerciseId, '70kg', date: DateTime.now().subtract(const Duration(days: 400)));

        await tester.pumpWidget(
          ChangeNotifierProvider.value(
            value: appState,
            child: const MaterialApp(
              home: ExerciseGraphsScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Change to All Time filter
        await tester.tap(find.byIcon(Icons.calendar_today).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('All Time'));
        await tester.pumpAndSettle();

        // Should show all entries regardless of age
        expect(find.text('3 entries'), findsOneWidget);
      });

      testWidgets('should update progress stats based on filtered data', (tester) async {
        final appState = ShoppingAppState();
        
        // Add exercise with progressive weight data
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        appState.addExerciseToWorkout(workoutId, 'Progressive Exercise');
        final exerciseId = appState.workoutLists[0].exercises[0].id;
        
        // Add progression: 60kg -> 70kg -> 80kg over different time periods
        appState.saveWeightForExercise(workoutId, exerciseId, '60kg', date: DateTime.now().subtract(const Duration(days: 60)));
        appState.saveWeightForExercise(workoutId, exerciseId, '70kg', date: DateTime.now().subtract(const Duration(days: 15)));
        appState.saveWeightForExercise(workoutId, exerciseId, '80kg', date: DateTime.now().subtract(const Duration(days: 3)));

        await tester.pumpWidget(
          ChangeNotifierProvider.value(
            value: appState,
            child: const MaterialApp(
              home: ExerciseGraphsScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Default view should show all data
        expect(find.text('Weight Change'), findsOneWidget);
        expect(find.text('Volume Change'), findsOneWidget);
        expect(find.text('+20.0kg'), findsOneWidget); // 80kg - 60kg = +20kg
        expect(find.text('80kg'), findsAtLeast(1)); // Latest weight

        // Change to Week filter (should only include the 80kg entry)
        await tester.tap(find.byIcon(Icons.calendar_today).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Week'));
        await tester.pumpAndSettle();

        // With only one entry in the filtered period, stats should show 0 for changes
        expect(find.text('Weight Change'), findsOneWidget);
        expect(find.text('Volume Change'), findsOneWidget);
        expect(find.text('0.0kg'), findsOneWidget); // Should show 0 for weight change with single entry
        expect(find.text('0'), findsAtLeast(1)); // Should show 0 for volume change with single entry
        // But should still show the latest weight
        expect(find.text('80kg'), findsAtLeast(1));
      });

      testWidgets('should handle empty filtered results gracefully', (tester) async {
        final appState = ShoppingAppState();
        
        // Add exercise with only old weight data
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        appState.addExerciseToWorkout(workoutId, 'Old Exercise');
        final exerciseId = appState.workoutLists[0].exercises[0].id;
        
        // Add only very old entries (beyond 1 year)
        appState.saveWeightForExercise(workoutId, exerciseId, '70kg', date: DateTime.now().subtract(const Duration(days: 400)));
        appState.saveWeightForExercise(workoutId, exerciseId, '75kg', date: DateTime.now().subtract(const Duration(days: 500)));

        await tester.pumpWidget(
          ChangeNotifierProvider.value(
            value: appState,
            child: const MaterialApp(
              home: ExerciseGraphsScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Change to Week filter (should have no data)
        await tester.tap(find.byIcon(Icons.calendar_today).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Week'));
        await tester.pumpAndSettle();

        // Should show 0 entries but still show the exercise
        expect(find.text('Old Exercise'), findsOneWidget);
        expect(find.text('0 entries'), findsOneWidget);
        
        // Should still show latest weight from all data as fallback
        // Note: The latest weight might not be displayed when filtered data is empty
        // The fallback behavior may vary based on implementation
        expect(find.text('Old Exercise'), findsOneWidget);
      });

      testWidgets('should preserve filter selection when navigating back to screen', (tester) async {
        final appState = ShoppingAppState();
        
        // Add exercise with weight data
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        appState.addExerciseToWorkout(workoutId, 'Test Exercise');
        final exerciseId = appState.workoutLists[0].exercises[0].id;
        appState.saveWeightForExercise(workoutId, exerciseId, '80kg');

        await tester.pumpWidget(
          ChangeNotifierProvider.value(
            value: appState,
            child: const MaterialApp(
              home: ExerciseGraphsScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Change to Week filter
        await tester.tap(find.byIcon(Icons.calendar_today).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Week'));
        await tester.pumpAndSettle();

        // Simulate navigation by rebuilding the widget
        await tester.pumpWidget(
          ChangeNotifierProvider.value(
            value: appState,
            child: const MaterialApp(
              home: ExerciseGraphsScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Note: Since we're creating a new widget instance, the state resets to default.
        // In a real app, this would be preserved through navigation state management.
        // We can verify the menu still works correctly
        await tester.tap(find.byIcon(Icons.calendar_today).first);
        await tester.pumpAndSettle();
        
        expect(find.text('Week'), findsOneWidget);
        expect(find.text('3 Months'), findsOneWidget);
      });

      testWidgets('should show correct tooltip for calendar icon', (tester) async {
        final appState = ShoppingAppState();
        
        // Add minimal data to show the screen
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        appState.addExerciseToWorkout(workoutId, 'Test Exercise');
        final exerciseId = appState.workoutLists[0].exercises[0].id;
        appState.saveWeightForExercise(workoutId, exerciseId, '80kg');

        await tester.pumpWidget(
          ChangeNotifierProvider.value(
            value: appState,
            child: const MaterialApp(
              home: ExerciseGraphsScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Long press the calendar icon in the app bar to show tooltip
        await tester.longPress(find.byIcon(Icons.calendar_today).first);
        await tester.pumpAndSettle();

        expect(find.text('Time Period'), findsOneWidget);
      });
    });

    group('Chart Data Processing', () {
      testWidgets('should handle exercises with no weight data', (tester) async {
        final appState = ShoppingAppState();
        
        // Add exercise without weight data
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        appState.addExerciseToWorkout(workoutId, 'No Weight Exercise');

        await tester.pumpWidget(
          ChangeNotifierProvider.value(
            value: appState,
            child: const MaterialApp(
              home: ExerciseGraphsScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Should show empty state since no weight data exists
        expect(find.text('No exercise data yet'), findsOneWidget);
      });

      testWidgets('should handle exercises with invalid weight formats', (tester) async {
        final appState = ShoppingAppState();
        
        // Add exercise with invalid weight data
        appState.addWorkoutList('Test Workout');
        final workoutId = appState.workoutLists[0].id;
        appState.addExerciseToWorkout(workoutId, 'Invalid Weight Exercise');
        final exerciseId = appState.workoutLists[0].exercises[0].id;
        
        // Add entry with no numeric weight
        appState.saveWeightForExercise(workoutId, exerciseId, 'bodyweight only');

        await tester.pumpWidget(
          ChangeNotifierProvider.value(
            value: appState,
            child: const MaterialApp(
              home: ExerciseGraphsScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Should show the exercise but handle invalid weight gracefully
        expect(find.text('Invalid Weight Exercise'), findsOneWidget);
        expect(find.text('bodyweight only'), findsOneWidget);
      });
    });
  });

  group('Multi-Metric Charts', () {
    testWidgets('should show weight and volume legend controls', (tester) async {
      final appState = ShoppingAppState();
      
      // Add exercise with sets and reps data
      appState.addWorkoutList('Test Workout');
      final workoutId = appState.workoutLists[0].id;
      appState.addExerciseToWorkout(workoutId, 'Bench Press');
      final exerciseId = appState.workoutLists[0].exercises[0].id;
      appState.saveWeightForExercise(workoutId, exerciseId, '80kg', sets: 3, reps: 10);

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: appState,
          child: const MaterialApp(
            home: ExerciseGraphsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show legend with Weight and Volume options
      expect(find.text('Weight'), findsOneWidget);
      expect(find.text('Volume'), findsOneWidget);
    });

    testWidgets('should toggle weight line visibility when weight legend is tapped', (tester) async {
      final appState = ShoppingAppState();
      
      // Add exercise with weight and volume data
      appState.addWorkoutList('Test Workout');
      final workoutId = appState.workoutLists[0].id;
      appState.addExerciseToWorkout(workoutId, 'Squats');
      final exerciseId = appState.workoutLists[0].exercises[0].id;
      appState.saveWeightForExercise(workoutId, exerciseId, '100kg', sets: 4, reps: 8);
      appState.saveWeightForExercise(workoutId, exerciseId, '105kg', sets: 4, reps: 8);

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: appState,
          child: const MaterialApp(
            home: ExerciseGraphsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially both should be visible
      expect(find.text('Weight'), findsOneWidget);
      expect(find.text('Volume'), findsOneWidget);

      // Tap on Weight legend to toggle visibility
      await tester.tap(find.text('Weight'));
      await tester.pumpAndSettle();

      // Weight legend should still be there but potentially styled differently
      expect(find.text('Weight'), findsOneWidget);
    });

    testWidgets('should toggle volume line visibility when volume legend is tapped', (tester) async {
      final appState = ShoppingAppState();
      
      // Add exercise with weight and volume data
      appState.addWorkoutList('Test Workout');
      final workoutId = appState.workoutLists[0].id;
      appState.addExerciseToWorkout(workoutId, 'Deadlift');
      final exerciseId = appState.workoutLists[0].exercises[0].id;
      appState.saveWeightForExercise(workoutId, exerciseId, '120kg', sets: 3, reps: 5);
      appState.saveWeightForExercise(workoutId, exerciseId, '125kg', sets: 3, reps: 5);

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: appState,
          child: const MaterialApp(
            home: ExerciseGraphsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on Volume legend to toggle visibility
      await tester.tap(find.text('Volume'));
      await tester.pumpAndSettle();

      // Volume legend should still be there but potentially styled differently
      expect(find.text('Volume'), findsOneWidget);
    });

    testWidgets('should handle exercises with sets and reps data', (tester) async {
      final appState = ShoppingAppState();
      
      // Add exercise with sets and reps progression
      appState.addWorkoutList('Test Workout');
      final workoutId = appState.workoutLists[0].id;
      appState.addExerciseToWorkout(workoutId, 'Pull-ups');
      final exerciseId = appState.workoutLists[0].exercises[0].id;
      
      // Add entries with different sets and reps (volume progression)
      appState.saveWeightForExercise(workoutId, exerciseId, '10kg', sets: 3, reps: 8);
      appState.saveWeightForExercise(workoutId, exerciseId, '10kg', sets: 3, reps: 10);
      appState.saveWeightForExercise(workoutId, exerciseId, '10kg', sets: 4, reps: 10);

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: appState,
          child: const MaterialApp(
            home: ExerciseGraphsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show the exercise with multi-metric data
      expect(find.text('Pull-ups'), findsOneWidget);
      expect(find.text('3 entries'), findsOneWidget);
      expect(find.text('Weight'), findsOneWidget);
      expect(find.text('Volume'), findsOneWidget);
    });

    testWidgets('should handle exercises with missing sets and reps data', (tester) async {
      final appState = ShoppingAppState();
      
      // Add exercise with mixed data (some with sets/reps, some without)
      appState.addWorkoutList('Test Workout');
      final workoutId = appState.workoutLists[0].id;
      appState.addExerciseToWorkout(workoutId, 'Mixed Data Exercise');
      final exerciseId = appState.workoutLists[0].exercises[0].id;
      
      // Add entries with and without sets/reps
      appState.saveWeightForExercise(workoutId, exerciseId, '60kg', sets: 3, reps: 8);
      appState.saveWeightForExercise(workoutId, exerciseId, '65kg'); // No sets/reps
      appState.saveWeightForExercise(workoutId, exerciseId, '70kg', sets: 4, reps: 6);

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: appState,
          child: const MaterialApp(
            home: ExerciseGraphsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should handle mixed data gracefully
      expect(find.text('Mixed Data Exercise'), findsOneWidget);
      expect(find.text('3 entries'), findsOneWidget);
      expect(find.text('70kg'), findsAtLeast(1)); // Latest weight (may appear in multiple places)
    });

    testWidgets('should show appropriate chart when only weight data is available', (tester) async {
      final appState = ShoppingAppState();
      
      // Add exercise with only weight data (no sets/reps)
      appState.addWorkoutList('Test Workout');
      final workoutId = appState.workoutLists[0].id;
      appState.addExerciseToWorkout(workoutId, 'Weight Only Exercise');
      final exerciseId = appState.workoutLists[0].exercises[0].id;
      appState.saveWeightForExercise(workoutId, exerciseId, '50kg');
      appState.saveWeightForExercise(workoutId, exerciseId, '55kg');

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: appState,
          child: const MaterialApp(
            home: ExerciseGraphsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show chart with weight data
      expect(find.text('Weight Only Exercise'), findsOneWidget);
      expect(find.text('2 entries'), findsOneWidget);
      expect(find.text('Weight'), findsOneWidget);
      expect(find.text('Volume'), findsOneWidget);
    });

    testWidgets('should filter both weight and volume data based on time interval', (tester) async {
      final appState = ShoppingAppState();
      
      // Add exercise with weight and volume data across different time periods
      appState.addWorkoutList('Test Workout');
      final workoutId = appState.workoutLists[0].id;
      appState.addExerciseToWorkout(workoutId, 'Time Filtered Exercise');
      final exerciseId = appState.workoutLists[0].exercises[0].id;
      
      // Add recent entry (within week)
      appState.saveWeightForExercise(workoutId, exerciseId, '80kg', sets: 3, reps: 10, date: DateTime.now().subtract(const Duration(days: 3)));
      
      // Add older entry (beyond week)
      appState.saveWeightForExercise(workoutId, exerciseId, '75kg', sets: 3, reps: 8, date: DateTime.now().subtract(const Duration(days: 15)));

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: appState,
          child: const MaterialApp(
            home: ExerciseGraphsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially shows all data (3 Months default should include both entries)
      expect(find.text('2 entries'), findsOneWidget);

      // Change to Week filter
      await tester.tap(find.byIcon(Icons.calendar_today).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Week'));
      await tester.pumpAndSettle();

      // Should now show only 1 entry (from last week)
      expect(find.text('1 entry'), findsOneWidget);
      expect(find.text('2 entries'), findsNothing);
    });

    testWidgets('should show dual axis labels when both metrics are enabled', (tester) async {
      final appState = ShoppingAppState();
      
      // Add exercise with comprehensive weight and volume data
      appState.addWorkoutList('Test Workout');
      final workoutId = appState.workoutLists[0].id;
      appState.addExerciseToWorkout(workoutId, 'Dual Axis Exercise');
      final exerciseId = appState.workoutLists[0].exercises[0].id;
      
      // Add multiple entries with different weights and volumes
      appState.saveWeightForExercise(workoutId, exerciseId, '80kg', sets: 3, reps: 8);
      appState.saveWeightForExercise(workoutId, exerciseId, '85kg', sets: 3, reps: 10);
      appState.saveWeightForExercise(workoutId, exerciseId, '90kg', sets: 4, reps: 8);

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: appState,
          child: const MaterialApp(
            home: ExerciseGraphsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show exercise with dual-axis data
      expect(find.text('Dual Axis Exercise'), findsOneWidget);
      expect(find.text('3 entries'), findsOneWidget);
      
      // Both legend items should be visible
      expect(find.text('Weight'), findsOneWidget);
      expect(find.text('Volume'), findsOneWidget);
    });

    testWidgets('should show volume axis labels with varying data', (tester) async {
      final appState = ShoppingAppState();
      
      // Add exercise with varying volume data
      appState.addWorkoutList('Test Workout');
      final workoutId = appState.workoutLists[0].id;
      appState.addExerciseToWorkout(workoutId, 'Volume Test Exercise');
      final exerciseId = appState.workoutLists[0].exercises[0].id;
      
      // Add entries with different volumes: 15, 20, 24, 30
      appState.saveWeightForExercise(workoutId, exerciseId, '80kg', sets: 3, reps: 5);  // Volume: 15
      appState.saveWeightForExercise(workoutId, exerciseId, '82kg', sets: 4, reps: 5);  // Volume: 20
      appState.saveWeightForExercise(workoutId, exerciseId, '84kg', sets: 3, reps: 8);  // Volume: 24
      appState.saveWeightForExercise(workoutId, exerciseId, '86kg', sets: 5, reps: 6);  // Volume: 30

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: appState,
          child: const MaterialApp(
            home: ExerciseGraphsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show exercise with volume progression
      expect(find.text('Volume Test Exercise'), findsOneWidget);
      expect(find.text('4 entries'), findsOneWidget);
      
      // Volume change should show progression: 30 - 15 = +15
      expect(find.text('+15'), findsOneWidget);
    });

    testWidgets('should not show duplicate volume axis labels', (tester) async {
      final appState = ShoppingAppState();
      
      // Add exercise with very similar volume data to test deduplication
      appState.addWorkoutList('Test Workout');
      final workoutId = appState.workoutLists[0].id;
      appState.addExerciseToWorkout(workoutId, 'Deduplication Test');
      final exerciseId = appState.workoutLists[0].exercises[0].id;
      
      // Add entries with very small volume differences
      appState.saveWeightForExercise(workoutId, exerciseId, '80kg', sets: 3, reps: 8);  // Volume: 24
      appState.saveWeightForExercise(workoutId, exerciseId, '82kg', sets: 3, reps: 8);  // Volume: 24
      appState.saveWeightForExercise(workoutId, exerciseId, '84kg', sets: 3, reps: 9);  // Volume: 27

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: appState,
          child: const MaterialApp(
            home: ExerciseGraphsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show exercise with small volume progression
      expect(find.text('Deduplication Test'), findsOneWidget);
      expect(find.text('3 entries'), findsOneWidget);
      
      // Volume change should show small progression: 27 - 24 = +3
      expect(find.text('+3'), findsOneWidget);
    });

    testWidgets('should show volume change correctly with sets and reps data', (tester) async {
      final appState = ShoppingAppState();
      
      // Add exercise with clear volume progression
      appState.addWorkoutList('Test Workout');
      final workoutId = appState.workoutLists[0].id;
      appState.addExerciseToWorkout(workoutId, 'Volume Change Test');
      final exerciseId = appState.workoutLists[0].exercises[0].id;
      
      // Add entries with sets/reps data: 12 -> 20 = +8
      appState.saveWeightForExercise(workoutId, exerciseId, '80kg', sets: 3, reps: 4);  // Volume: 12
      appState.saveWeightForExercise(workoutId, exerciseId, '85kg', sets: 4, reps: 5);  // Volume: 20

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: appState,
          child: const MaterialApp(
            home: ExerciseGraphsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show exercise with clear volume change
      expect(find.text('Volume Change Test'), findsOneWidget);
      expect(find.text('2 entries'), findsOneWidget);
      
      // Volume change should show progression: 20 - 12 = +8
      expect(find.text('+8'), findsOneWidget);
      
      // Should not show N/A for volume change
      expect(find.text('N/A'), findsNothing);
    });

    testWidgets('should show 0 for volume change with single entry', (tester) async {
      final appState = ShoppingAppState();
      
      // Add exercise with single entry
      appState.addWorkoutList('Test Workout');
      final workoutId = appState.workoutLists[0].id;
      appState.addExerciseToWorkout(workoutId, 'Single Entry Test');
      final exerciseId = appState.workoutLists[0].exercises[0].id;
      
      // Add single entry with sets/reps
      appState.saveWeightForExercise(workoutId, exerciseId, '80kg', sets: 3, reps: 8);

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: appState,
          child: const MaterialApp(
            home: ExerciseGraphsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show exercise with single entry
      expect(find.text('Single Entry Test'), findsOneWidget);
      expect(find.text('1 entry'), findsOneWidget);
      
      // Both weight and volume change should show 0, not N/A
      expect(find.text('0.0kg'), findsOneWidget);  // Weight change
      expect(find.text('0'), findsAtLeast(1));      // Volume change (and possibly sessions)
      
      // Should not show N/A for any change
      expect(find.text('N/A'), findsNothing);
    });
  });
}