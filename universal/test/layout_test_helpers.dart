import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Asserts [finder] stays clear of a bottom system inset (e.g. a
/// gesture/button navigation bar) of [bottomInset] logical pixels,
/// simulated via an ambient [MediaQueryData.padding] in the pumped tree.
void expectClearOfBottomInset(
  WidgetTester tester,
  Finder finder,
  double bottomInset,
) {
  final screenHeight =
      tester.view.physicalSize.height / tester.view.devicePixelRatio;
  final maxAllowedY = screenHeight - bottomInset;

  final bottom = tester.getBottomLeft(finder);

  expect(bottom.dy, lessThanOrEqualTo(maxAllowedY));
}
