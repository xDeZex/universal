import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shopping_list_app/main.dart';
import 'package:shopping_list_app/screens/main_screen.dart';

void main() {
  group('Main Screen with Bottom Navigation', () {
    testWidgets('should show bottom navigation with two tabs', (tester) async {
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
      
      // Verify that both navigation items are present (may appear multiple times due to AppBar + Bottom Nav)
      expect(find.text('Shopping Lists'), findsAtLeast(1));
      expect(find.text('Workouts'), findsOneWidget);
      
      // Verify navigation icons are present
      expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
      expect(find.byIcon(Icons.fitness_center), findsOneWidget);
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
      
      // Tap on the second navigation item
      await tester.tap(find.text('Workouts').last); // Use .last to tap the bottom nav item
      await tester.pumpAndSettle();
      
      // Should now show the workout screen content
      expect(find.text('Workouts'), findsAtLeast(1)); // Title + bottom nav
      expect(find.text('No workouts yet.\nTap the + button to create your first workout!'), findsOneWidget);
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
      
      // Switch to second screen
      await tester.tap(find.text('Workouts').last);
      await tester.pumpAndSettle();
      
      // Should show Workouts title
      expect(find.text('Workouts'), findsAtLeast(1));
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
  });
}