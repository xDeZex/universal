import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal/theme/app_theme.dart';
import 'package:universal/widgets/coplanar_card.dart';

void main() {
  group('CoplanarCard', () {
    testWidgets('renders its child inside a Card with 12dp horizontal / '
        '8dp vertical margin', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: CoplanarCard(child: Text('content', key: Key('child'))),
          ),
        ),
      );

      expect(find.byKey(const Key('child')), findsOneWidget);

      final card = tester.widget<Card>(find.byType(Card));
      expect(
        card.margin,
        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      );
    });

    testWidgets('sets no local color, elevation, or shape override, so it '
        "renders identically to the app's global CardThemeData defaults", (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(body: CoplanarCard(child: Text('content'))),
        ),
      );

      final card = tester.widget<Card>(find.byType(Card));
      expect(card.color, isNull);
      expect(card.elevation, isNull);
      expect(card.shape, isNull);

      final cardTheme = AppTheme.dark.cardTheme;
      final material = tester.widget<Material>(
        find.descendant(of: find.byType(Card), matching: find.byType(Material)).first,
      );
      expect(material.color, cardTheme.color);
      expect(material.elevation, cardTheme.elevation);
      expect(material.shape, cardTheme.shape);
    });

    testWidgets('sets clipBehavior: Clip.antiAlias', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CoplanarCard(child: Text('content'))),
        ),
      );

      final card = tester.widget<Card>(find.byType(Card));
      expect(card.clipBehavior, Clip.antiAlias);
    });
  });
}
