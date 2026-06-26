import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:universal/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App launches and shows home screen', (tester) async {
    await tester.pumpWidget(const UniversalApp());
    await tester.pumpAndSettle();

    expect(find.text('Checklists'), findsOneWidget);
    expect(find.text('No checklists yet'), findsOneWidget);
  });
}
