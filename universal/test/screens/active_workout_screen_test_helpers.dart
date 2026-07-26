import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal/models/workout.dart';

Future<void> tapAndSettle(WidgetTester tester, String key) async {
  await tester.tap(find.byKey(ValueKey(key)));
  await tester.pumpAndSettle();
}

String weightStepperValue(WidgetTester tester) => tester
    .widget<Text>(find.byKey(const ValueKey('weight-stepper-value')))
    .data!;

String repsStepperValue(WidgetTester tester) =>
    tester.widget<Text>(find.byKey(const ValueKey('reps-stepper-value'))).data!;

bool isUnitSelected(WidgetTester tester, String key, WeightUnit unit) {
  final segmentedButton = tester.widget<SegmentedButton<WeightUnit>>(
    find.ancestor(
      of: find.byKey(ValueKey(key)),
      matching: find.byType(SegmentedButton<WeightUnit>),
    ),
  );
  return segmentedButton.selected.contains(unit);
}
