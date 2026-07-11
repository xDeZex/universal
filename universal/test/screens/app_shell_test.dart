import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal/screens/app_shell.dart';
import 'package:universal/screens/home_screen.dart';
import 'package:universal/screens/workout_home_screen.dart';
import 'package:universal/services/update_service.dart';

Finder _navTab(String label) => find.descendant(
  of: find.byType(BottomNavigationBar),
  matching: find.text(label),
);

Future<void> _pumpAppShell(WidgetTester tester) async {
  await tester.pumpWidget(
    ChangeNotifierProvider<UpdateService>.value(
      value: UpdateService(
        httpClient: MockClient(
          (request) async =>
              http.Response('{"tag_name": "dev", "assets": []}', 200),
        ),
        buildTag: 'dev',
      ),
      child: const MaterialApp(home: AppShell()),
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AppShell', () {
    testWidgets(
      'shows a bottom navigation bar with Checklists and Workout tabs',
      (tester) async {
        await _pumpAppShell(tester);
        await tester.pumpAndSettle();

        expect(find.byType(BottomNavigationBar), findsOneWidget);
        expect(_navTab('Checklists'), findsOneWidget);
        expect(_navTab('Workout'), findsOneWidget);
        expect(find.byType(HomeScreen), findsOneWidget);
      },
    );

    testWidgets('tapping the Workout tab shows the Workout home screen', (
      tester,
    ) async {
      await _pumpAppShell(tester);
      await tester.pumpAndSettle();

      await tester.tap(_navTab('Workout'));
      await tester.pumpAndSettle();

      expect(find.byType(WorkoutHomeScreen), findsOneWidget);
    });

    testWidgets(
      'switching away from Checklists and back does not reload HomeScreen',
      (tester) async {
        await _pumpAppShell(tester);
        await tester.pumpAndSettle();

        await tester.tap(_navTab('Workout'));
        await tester.pumpAndSettle();
        await tester.tap(_navTab('Checklists'));
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsNothing);
      },
    );
  });
}
