import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal/models/checklist.dart';
import 'package:universal/screens/home_screen.dart';
import 'package:universal/screens/settings_screen.dart';
import 'package:universal/services/update_service.dart';

http.Response _releaseResponse(String tagName) {
  return http.Response('{"tag_name": "$tagName", "assets": []}', 200);
}

Future<void> _pumpHomeScreen(
  WidgetTester tester, {
  List<Checklist>? initialChecklists,
  UpdateService? updateService,
}) async {
  await tester.pumpWidget(
    ChangeNotifierProvider<UpdateService>.value(
      value: updateService ??
          UpdateService(
            httpClient: MockClient((request) async => _releaseResponse('dev')),
            buildTag: 'dev',
          ),
      child: MaterialApp(
        home: HomeScreen(initialChecklists: initialChecklists),
      ),
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('HomeScreen', () {
    testWidgets('displays app title', (tester) async {
      await _pumpHomeScreen(tester);

      expect(find.text('Checklists'), findsOneWidget);
    });

    testWidgets('shows empty state when no checklists', (tester) async {
      await _pumpHomeScreen(tester);
      await tester.pumpAndSettle();

      expect(find.text('No checklists yet'), findsOneWidget);
      expect(find.text('Tap + to create one'), findsOneWidget);
    });

    testWidgets('has FAB to add new checklist', (tester) async {
      await _pumpHomeScreen(tester);

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('tapping FAB shows dialog to name checklist', (tester) async {
      await _pumpHomeScreen(tester);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('New Checklist'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('can create a new checklist', (tester) async {
      await _pumpHomeScreen(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Groceries');
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      expect(find.text('Groceries'), findsOneWidget);
    });

    testWidgets('displays checklists with count', (tester) async {
      await _pumpHomeScreen(
        tester,
        initialChecklists: [
          Checklist(
            name: 'Groceries',
            items: [
              ChecklistItem(name: 'Milk'),
              ChecklistItem(name: 'Bread', isChecked: true),
            ],
          ),
        ],
      );
      await tester.pumpAndSettle();

      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('1/2'), findsOneWidget);
    });

    testWidgets('can delete a checklist', (tester) async {
      await _pumpHomeScreen(
        tester,
        initialChecklists: [Checklist(name: 'Groceries')],
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      expect(find.text('Groceries'), findsNothing);
      expect(find.text('No checklists yet'), findsOneWidget);
    });

    testWidgets('can rename a checklist', (tester) async {
      await _pumpHomeScreen(
        tester,
        initialChecklists: [Checklist(name: 'Groceries')],
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      expect(find.text('Rename Checklist'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Shopping');
      await tester.tap(find.text('Rename'));
      await tester.pumpAndSettle();

      expect(find.text('Shopping'), findsOneWidget);
      expect(find.text('Groceries'), findsNothing);
    });

    testWidgets('navigates to checklist screen on tap', (tester) async {
      await _pumpHomeScreen(
        tester,
        initialChecklists: [Checklist(name: 'Groceries')],
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Groceries'));
      await tester.pumpAndSettle();

      expect(find.text('Groceries'), findsOneWidget);
    });

    testWidgets('has a Settings icon that navigates to SettingsScreen',
        (tester) async {
      await _pumpHomeScreen(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    testWidgets('shows no badge when no update is available', (tester) async {
      final service = UpdateService(
        httpClient: MockClient((request) async => _releaseResponse('dev')),
        buildTag: 'dev',
      );
      await service.checkForUpdate();

      await _pumpHomeScreen(tester, updateService: service);
      await tester.pumpAndSettle();

      final badge = tester.widget<Badge>(find.byType(Badge));
      expect(badge.isLabelVisible, isFalse);
    });

    testWidgets('shows badge when an update is available', (tester) async {
      final service = UpdateService(
        httpClient: MockClient((request) async => _releaseResponse('newer')),
        buildTag: 'dev',
      );
      await service.checkForUpdate();

      await _pumpHomeScreen(tester, updateService: service);
      await tester.pumpAndSettle();

      final badge = tester.widget<Badge>(find.byType(Badge));
      expect(badge.isLabelVisible, isTrue);
    });

    testWidgets('badge remains visible after navigating to Settings and back',
        (tester) async {
      final service = UpdateService(
        httpClient: MockClient((request) async => _releaseResponse('newer')),
        buildTag: 'dev',
      );
      await service.checkForUpdate();

      await _pumpHomeScreen(tester, updateService: service);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();

      final badge = tester.widget<Badge>(find.byType(Badge));
      expect(badge.isLabelVisible, isTrue);
    });
  });
}
