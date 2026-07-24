import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal/models/workout.dart';
import 'package:universal/widgets/set_input_row.dart';

void main() {
  group('SetInputRow layout', () {
    testWidgets(
      'does not scroll horizontally and does not overflow at a real phone '
      'width',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.625;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SetInputRow(
                weightStepperKey: 'weight-stepper',
                unitKgKey: 'unit-kg',
                unitLbsKey: 'unit-lbs',
                repsStepperKey: 'reps-stepper',
                weight: 60,
                unit: WeightUnit.kg,
                reps: 8,
                onWeightChanged: (_) {},
                onUnitChanged: (_) {},
                onRepsChanged: (_) {},
              ),
            ),
          ),
        );

        expect(find.byType(SingleChildScrollView), findsNothing);
        expect(find.byType(Wrap), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
