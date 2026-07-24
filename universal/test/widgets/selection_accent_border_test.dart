import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal/widgets/selection_accent_border.dart';

void main() {
  group('SelectionAccentBorder', () {
    Border leftBorder(WidgetTester tester) {
      final container = tester.widget<Container>(find.byType(Container));
      return (container.decoration as BoxDecoration).border as Border;
    }

    testWidgets(
      'renders its child with a 4dp left border in colorScheme.primary '
      'when selected is true',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SelectionAccentBorder(
                selected: true,
                child: const Text('content'),
              ),
            ),
          ),
        );

        final primary = Theme.of(
          tester.element(find.byType(Scaffold)),
        ).colorScheme.primary;

        final border = leftBorder(tester);
        expect(border.left.width, 4);
        expect(border.left.color, primary);
      },
    );

    testWidgets('renders the same 4dp left border in Colors.transparent (not '
        'omitted) when selected is false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SelectionAccentBorder(
              selected: false,
              child: Text('content'),
            ),
          ),
        ),
      );

      final border = leftBorder(tester);
      expect(border.left.width, 4);
      expect(border.left.color, Colors.transparent);
    });

    testWidgets('toggling selected does not change the rendered size or the '
        "child's horizontal offset", (tester) async {
      Widget build(bool selected) {
        return MaterialApp(
          home: Scaffold(
            body: SelectionAccentBorder(
              selected: selected,
              child: const Text('content', key: Key('child')),
            ),
          ),
        );
      }

      await tester.pumpWidget(build(false));
      final sizeUnselected = tester.getSize(find.byType(Container));
      final offsetUnselected = tester.getTopLeft(
        find.byKey(const Key('child')),
      );

      await tester.pumpWidget(build(true));
      final sizeSelected = tester.getSize(find.byType(Container));
      final offsetSelected = tester.getTopLeft(find.byKey(const Key('child')));

      expect(sizeSelected, sizeUnselected);
      expect(offsetSelected, offsetUnselected);
    });
  });
}
