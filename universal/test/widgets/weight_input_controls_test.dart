import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal/models/workout.dart';
import 'package:universal/widgets/weight_input_controls.dart';

void main() {
  Future<void> pumpControls(
    WidgetTester tester, {
    required num weight,
    required WeightUnit unit,
    ValueChanged<num>? onWeightChanged,
    ValueChanged<WeightUnit>? onUnitChanged,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WeightInputControls(
            weightStepperKey: 'weight-stepper',
            unitKgKey: 'unit-kg',
            unitLbsKey: 'unit-lbs',
            weight: weight,
            unit: unit,
            onWeightChanged: onWeightChanged ?? (_) {},
            onUnitChanged: onUnitChanged ?? (_) {},
          ),
        ),
      ),
    );
  }

  group('WeightInputControls', () {
    testWidgets('renders a weight stepper and a kg/lbs segmented toggle', (
      tester,
    ) async {
      await pumpControls(tester, weight: 60, unit: WeightUnit.kg);

      expect(
        find.byKey(const ValueKey('weight-stepper-value')),
        findsOneWidget,
      );
      expect(find.text('60'), findsOneWidget);
      expect(find.byType(SegmentedButton<WeightUnit>), findsOneWidget);
      expect(find.byKey(const ValueKey('unit-kg')), findsOneWidget);
      expect(find.byKey(const ValueKey('unit-lbs')), findsOneWidget);

      final segmentedButton = tester.widget<SegmentedButton<WeightUnit>>(
        find.byType(SegmentedButton<WeightUnit>),
      );
      expect(segmentedButton.selected, {WeightUnit.kg});
    });

    testWidgets('incrementing the weight stepper calls onWeightChanged', (
      tester,
    ) async {
      num? changed;
      await pumpControls(
        tester,
        weight: 60,
        unit: WeightUnit.kg,
        onWeightChanged: (value) => changed = value,
      );

      await tester.tap(find.byKey(const ValueKey('weight-stepper-increment')));
      await tester.pump();

      expect(changed, 62.5);
    });

    testWidgets('tapping the lbs segment calls onUnitChanged', (tester) async {
      WeightUnit? changed;
      await pumpControls(
        tester,
        weight: 60,
        unit: WeightUnit.kg,
        onUnitChanged: (value) => changed = value,
      );

      await tester.tap(find.byKey(const ValueKey('unit-lbs')));
      await tester.pump();

      expect(changed, WeightUnit.lbs);
    });
  });
}
