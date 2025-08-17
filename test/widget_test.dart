import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal/main.dart';
import 'package:universal/providers/shopping_app_state.dart';

void main() {
  group('Shopping List App Widget Tests', () {
    setUp(() {
      // Reset SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('should show empty state when no shopping lists exist', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      expect(find.text('No shopping lists yet.\nTap the + button to create one!'), findsOneWidget);
    });

    testWidgets('should show add shopping list dialog when FAB is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('New Shopping List'), findsOneWidget);
      expect(find.text('List name'), findsOneWidget);
      expect(find.text('Create'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('should create new shopping list when dialog is submitted', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Tap FAB to open dialog
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Enter list name
      await tester.enterText(find.byType(TextField), 'Test Shopping List');
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      // Verify list was created
      expect(find.text('Test Shopping List'), findsOneWidget);
      expect(find.text('0/0 items completed'), findsOneWidget);
    });

    testWidgets('should handle Swedish characters in shopping list name', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Handlingslista åäö');
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      expect(find.text('Handlingslista åäö'), findsOneWidget);
    });

    testWidgets('should navigate to shopping list detail when list is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Create a shopping list
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Test List');
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      // Tap on the list to navigate to detail
      await tester.tap(find.text('Test List'));
      await tester.pumpAndSettle();

      // Should be on detail screen
      expect(find.text('No items in this list yet.\nTap the + button to add items!'), findsOneWidget);
    });

    testWidgets('should show delete confirmation dialog', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Create a shopping list
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Test List');
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      // Tap delete button
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      expect(find.text('Delete List'), findsOneWidget);
      expect(find.text('Are you sure you want to delete "Test List"?'), findsOneWidget);
    });

    testWidgets('should delete shopping list when confirmed', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Create a shopping list
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Test List');
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      // Delete the list
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Should return to empty state
      expect(find.text('No shopping lists yet.\nTap the + button to create one!'), findsOneWidget);
      expect(find.text('Test List'), findsNothing);
    });
  });
}
