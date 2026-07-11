import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal/services/update_service.dart';

import 'package:universal/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App launches and shows home screen', (tester) async {
    final updateService = UpdateService(
      httpClient: MockClient(
        (request) async =>
            http.Response('{"tag_name": "dev", "assets": []}', 200),
      ),
      buildTag: 'dev',
    );

    await tester.pumpWidget(UniversalApp(updateService: updateService));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Checklists'),
      ),
      findsOneWidget,
    );
    expect(find.text('No checklists yet'), findsOneWidget);
  });
}
