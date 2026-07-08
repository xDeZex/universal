import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:universal/screens/settings_screen.dart';
import 'package:universal/services/update_service.dart';

http.Response _releaseResponse(String tagName) {
  return http.Response(
    '{"tag_name": "$tagName", "assets": ['
    '{"name": "Universal.apk", "browser_download_url": "https://example.com/Universal.apk"},'
    '{"name": "Universal.apk.sha256", "browser_download_url": "https://example.com/Universal.apk.sha256"}'
    ']}',
    200,
  );
}

Future<void> _pumpSettingsScreen(
  WidgetTester tester,
  UpdateService service,
) async {
  await tester.pumpWidget(
    ChangeNotifierProvider<UpdateService>.value(
      value: service,
      child: const MaterialApp(home: SettingsScreen()),
    ),
  );
}

void main() {
  group('SettingsScreen', () {
    testWidgets('shows checking state while the check is in flight',
        (tester) async {
      final completer = Completer<http.Response>();
      final service = UpdateService(
        httpClient: MockClient((request) async => completer.future),
        buildTag: 'dev',
      );

      await _pumpSettingsScreen(tester, service);
      await tester.pump();

      expect(find.text('Checking for updates...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete(_releaseResponse('dev'));
      await tester.pumpAndSettle();
    });

    testWidgets('shows up to date state when tags match', (tester) async {
      final service = UpdateService(
        httpClient: MockClient((request) async => _releaseResponse('dev')),
        buildTag: 'dev',
      );

      await _pumpSettingsScreen(tester, service);
      await tester.pumpAndSettle();

      expect(find.text('Up to date'), findsOneWidget);
      expect(find.text('Download'), findsNothing);
    });

    testWidgets(
        'shows update available state with Download button when tags differ',
        (tester) async {
      final service = UpdateService(
        httpClient: MockClient((request) async => _releaseResponse('newer')),
        buildTag: 'dev',
      );

      await _pumpSettingsScreen(tester, service);
      await tester.pumpAndSettle();

      expect(find.text('Update available'), findsOneWidget);
      expect(find.text('Download'), findsOneWidget);
    });

    testWidgets('shows error state without Download button on failure',
        (tester) async {
      final service = UpdateService(
        httpClient: MockClient((request) async => http.Response('', 500)),
        buildTag: 'dev',
      );

      await _pumpSettingsScreen(tester, service);
      await tester.pumpAndSettle();

      expect(find.text('Unable to check for updates'), findsOneWidget);
      expect(find.text('Download'), findsNothing);
    });
  });
}
