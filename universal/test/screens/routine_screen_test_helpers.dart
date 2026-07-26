import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> openRenameDialog(WidgetTester tester, String title) async {
  await tester.tap(
    find.descendant(of: find.byType(AppBar), matching: find.text(title)),
  );
  await tester.pumpAndSettle();
}

Future<TestGesture> startCardDrag(WidgetTester tester, Key cardKey) async {
  final gesture = await tester.startGesture(
    tester.getCenter(find.byKey(cardKey)),
  );
  await tester.pump(kLongPressTimeout + kPressTimeout);
  return gesture;
}

Future<void> moveDragBy(
  WidgetTester tester,
  TestGesture gesture,
  double totalDy,
) async {
  const stepsPerSegment = 10;
  final step = totalDy / stepsPerSegment;
  for (var i = 0; i < stepsPerSegment; i++) {
    await gesture.moveBy(Offset(0, step));
    await tester.pump(const Duration(milliseconds: 16));
  }
}

Future<void> dragCard(WidgetTester tester, Key cardKey, double totalDy) async {
  final gesture = await startCardDrag(tester, cardKey);
  await moveDragBy(tester, gesture, totalDy);
  await gesture.up();
  await tester.pumpAndSettle();
}
