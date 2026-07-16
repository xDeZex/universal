import 'package:flutter_test/flutter_test.dart';
import 'package:universal/models/routine.dart';
import 'package:universal/models/workout.dart';

void main() {
  group('PlannedWeight', () {
    test('round-trips through toJson/fromJson', () {
      const weight = PlannedWeight(value: 60, unit: WeightUnit.lbs);

      final restored = PlannedWeight.fromJson(weight.toJson());

      expect(restored.value, 60);
      expect(restored.unit, WeightUnit.lbs);
    });

    test('fromJson throws when unit key is missing', () {
      final json = {'value': 60};

      expect(() => PlannedWeight.fromJson(json), throwsA(anything));
    });
  });
}
