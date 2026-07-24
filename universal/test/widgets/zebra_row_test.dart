import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal/widgets/zebra_row.dart';

void main() {
  group('ZebraRow', () {
    testWidgets('renders no background color on an even index', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ZebraRow(index: 0, child: Text('content'))),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.color, isNull);
    });

    testWidgets(
      'renders surfaceContainerHighest at half opacity on an odd index',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: ZebraRow(index: 1, child: Text('content'))),
          ),
        );

        final theme = Theme.of(tester.element(find.byType(Scaffold)));
        final expected = theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.5,
        );

        final container = tester.widget<Container>(find.byType(Container));
        expect(container.color, expected);
      },
    );
  });
}
