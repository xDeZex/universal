import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal/repositories/workout_repository.dart';
import 'package:universal/screens/settings_screen.dart';
import 'package:universal/screens/workout_home_screen.dart';
import 'package:universal/services/update_service.dart';

http.Response _releaseResponse(String tagName) {
  return http.Response('{"tag_name": "$tagName", "assets": []}', 200);
}

Future<UpdateService> _pumpWorkoutHomeScreen(
  WidgetTester tester, {
  required String buildTag,
  required String latestTag,
}) async {
  final updateService = UpdateService(
    httpClient: MockClient(
      (request) async => _releaseResponse(latestTag),
    ),
    buildTag: buildTag,
  );

  await tester.pumpWidget(
    ChangeNotifierProvider<UpdateService>.value(
      value: updateService,
      child: ChangeNotifierProvider<WorkoutRepository>(
        create: (_) => WorkoutRepository()..load(),
        child: const MaterialApp(home: WorkoutHomeScreen()),
      ),
    ),
  );
  await updateService.checkForUpdate();
  await tester.pumpAndSettle();

  return updateService;
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('WorkoutHomeScreen settings entry point', () {
    testWidgets('tapping the settings icon opens SettingsScreen', (
      tester,
    ) async {
      await _pumpWorkoutHomeScreen(
        tester,
        buildTag: 'v1',
        latestTag: 'v1',
      );

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    testWidgets('shows an update badge when a newer release is available', (
      tester,
    ) async {
      await _pumpWorkoutHomeScreen(
        tester,
        buildTag: 'v1',
        latestTag: 'v2',
      );

      final badge = tester.widget<Badge>(find.byType(Badge));
      expect(badge.isLabelVisible, true);
    });

    testWidgets('hides the update badge when already up to date', (
      tester,
    ) async {
      await _pumpWorkoutHomeScreen(
        tester,
        buildTag: 'v1',
        latestTag: 'v1',
      );

      final badge = tester.widget<Badge>(find.byType(Badge));
      expect(badge.isLabelVisible, false);
    });
  });
}
