import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal/widgets/dashed_circle_badge.dart';

void main() {
  group('DashedCircleBadge', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DashedCircleBadge(color: Colors.grey),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    test('shouldRepaint is true only when the color actually changes', () {
      const newPainter = DashedCirclePainter(color: Colors.red);

      expect(
        newPainter.shouldRepaint(const DashedCirclePainter(color: Colors.grey)),
        isTrue,
      );
      expect(
        newPainter.shouldRepaint(const DashedCirclePainter(color: Colors.red)),
        isFalse,
      );
    });
  });
}
