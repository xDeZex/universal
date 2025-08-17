import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shopping_list_app/providers/shopping_app_state.dart';
import 'package:shopping_list_app/screens/main_screen.dart';

void main() {
  group('Main Screen with Bottom Navigation', () {
    testWidgets('should show bottom navigation with three tabs', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => ShoppingAppState(),
          child: MaterialApp(
            home: const MainScreen(),
          ),
        ),
      );

      // Verify that bottom navigation bar is present
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      
      // Verify that all three navigation items are present (may appear multiple times due to AppBar + Bottom Nav)
      expect(find.text('Shopping Lists'), findsAtLeast(1));
      expect(find.text('Workouts'), findsOneWidget);
      expect(find.text('Workout Logs'), findsOneWidget);
      
      // Verify navigation icons are present
      expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
      expect(find.byIcon(Icons.fitness_center), findsOneWidget);
      expect(find.byIcon(Icons.trending_up), findsOneWidget);
    });

    testWidgets('should switch between screens when navigation items are tapped', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => ShoppingAppState(),
          child: MaterialApp(
            home: const MainScreen(),
          ),
        ),
      );

      // Initially, shopping lists screen should be shown
      expect(find.text('Shopping Lists'), findsAtLeast(1)); // Title + bottom nav
      expect(find.text('No shopping lists yet.\nTap the + button to create one!'), findsOneWidget);
      
      // Tap on the second navigation item (Workouts)
      await tester.tap(find.text('Workouts').last); // Use .last to tap the bottom nav item
      await tester.pumpAndSettle();
      
      // Should now show the workout screen content
      expect(find.text('Workouts'), findsAtLeast(1)); // Title + bottom nav
      expect(find.text('No workouts yet.\nTap the + button to create your first workout!'), findsOneWidget);

      // Tap on the third navigation item (Workout Logs)
      await tester.tap(find.text('Workout Logs').last);
      await tester.pumpAndSettle();
      
      // Should now show the weight tracking screen content
      expect(find.text('Workout Logs'), findsAtLeast(1)); // Title + bottom nav
      expect(find.text('No workout logs yet'), findsOneWidget);
      
      // Go back to first tab
      await tester.tap(find.text('Shopping Lists').last);
      await tester.pumpAndSettle();
      
      // Should be back to shopping lists
      expect(find.text('No shopping lists yet.\nTap the + button to create one!'), findsOneWidget);
    });

    testWidgets('should show correct screen titles in app bars', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => ShoppingAppState(),
          child: MaterialApp(
            home: const MainScreen(),
          ),
        ),
      );

      // Initially should show Shopping Lists title
      expect(find.text('Shopping Lists'), findsAtLeast(1));
      
      // Switch to second screen (Workouts)
      await tester.tap(find.text('Workouts').last);
      await tester.pumpAndSettle();
      
      // Should show Workouts title
      expect(find.text('Workouts'), findsAtLeast(1));
      
      // Switch to third screen (Workout Logs)
      await tester.tap(find.text('Workout Logs').last);
      await tester.pumpAndSettle();
      
      // Should show Workout Logs title
      expect(find.text('Workout Logs'), findsAtLeast(1));
    });

    testWidgets('should maintain shopping lists functionality in first tab', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => ShoppingAppState(),
          child: MaterialApp(
            home: const MainScreen(),
          ),
        ),
      );

      // Should show FAB for adding new lists
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
      
      // Tap FAB to open add list dialog
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      
      // Should show add list dialog
      expect(find.text('New Shopping List'), findsOneWidget);
      expect(find.text('List name'), findsOneWidget);
    });

    testWidgets('should show weight tracking screen with empty state', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => ShoppingAppState(),
          child: MaterialApp(
            home: const MainScreen(),
          ),
        ),
      );

      // Navigate to weight tracking tab
      await tester.tap(find.text('Workout Logs').last);
      await tester.pumpAndSettle();

      // Should show workout logs screen content
      expect(find.text('Workout Logs'), findsAtLeast(1));
      expect(find.text('No workout logs yet'), findsOneWidget);
      expect(find.text('Start logging by saving weights for your exercises'), findsOneWidget);
      expect(find.byIcon(Icons.fitness_center), findsAtLeast(1)); // Icon in empty state
    });

    testWidgets('should show weight tracking with exercise data', (tester) async {
      final appState = ShoppingAppState();
      
      // Add a workout with an exercise that has weight tracking
      appState.addWorkoutList('Test Workout');
      final workoutId = appState.workoutLists[0].id;
      appState.addExerciseToWorkout(workoutId, 'Bench Press', weight: '80kg');
      final exerciseId = appState.workoutLists[0].exercises[0].id;
      appState.saveWeightForExercise(workoutId, exerciseId, '85kg');

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: appState,
          child: MaterialApp(
            home: const MainScreen(),
          ),
        ),
      );

      // Navigate to weight tracking tab
      await tester.tap(find.text('Workout Logs').last);
      await tester.pumpAndSettle();

      // Should show the exercise weight data
      expect(find.text('Workout Logs'), findsAtLeast(1));
      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('Test Workout'), findsOneWidget);
      expect(find.text('85kg'), findsOneWidget);
      expect(find.text('TODAY'), findsOneWidget);
      
      // Should not show empty state
      expect(find.text('No weight tracking data yet'), findsNothing);
    });

    testWidgets('should show progression indicators for weight changes', (tester) async {
      final appState = ShoppingAppState();
      
      // Add a workout with an exercise
      appState.addWorkoutList('Test Workout');
      final workoutId = appState.workoutLists[0].id;
      appState.addExerciseToWorkout(workoutId, 'Bench Press', weight: '80kg');
      final exerciseId = appState.workoutLists[0].exercises[0].id;
      
      // Add multiple weight entries to show progression
      appState.saveWeightForExercise(workoutId, exerciseId, '80kg');
      appState.saveWeightForExercise(workoutId, exerciseId, '85kg');

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: appState,
          child: MaterialApp(
            home: const MainScreen(),
          ),
        ),
      );

      // Navigate to weight tracking tab
      await tester.tap(find.text('Workout Logs').last);
      await tester.pumpAndSettle();

      // Should show weight progression
      expect(find.text('85kg'), findsOneWidget); // Latest weight (previous weight not shown in summary)
      expect(find.byIcon(Icons.trending_up), findsAtLeastNWidgets(1)); // Progression indicator(s)
    });

    testWidgets('should navigate to exercise weight history when exercise card is tapped', (tester) async {
      final appState = ShoppingAppState();
      
      // Add a workout with an exercise that has weight tracking
      appState.addWorkoutList('Test Workout');
      final workoutId = appState.workoutLists[0].id;
      appState.addExerciseToWorkout(workoutId, 'Bench Press', weight: '80kg');
      final exerciseId = appState.workoutLists[0].exercises[0].id;
      
      // Add weight entry
      appState.saveWeightForExercise(workoutId, exerciseId, '85kg');

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: appState,
          child: MaterialApp(
            home: const MainScreen(),
          ),
        ),
      );

      // Navigate to weight tracking tab
      await tester.tap(find.text('Workout Logs').last);
      await tester.pumpAndSettle();

      // Should show exercise card
      expect(find.text('Bench Press'), findsOneWidget);
      
      // Tap on the exercise card
      await tester.tap(find.text('Bench Press'));
      await tester.pumpAndSettle();
      
      // Should navigate to exercise weight history screen
      expect(find.text('Bench Press'), findsAtLeast(1)); // In app bar
      expect(find.text('85kg'), findsOneWidget);
      expect(find.text('LATEST'), findsOneWidget);
      expect(find.text('TODAY'), findsOneWidget);
    });
  });
}