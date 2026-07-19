import 'package:flutter_test/flutter_test.dart';
import 'package:universal/models/routine.dart';

void main() {
  group('RepsTarget', () {
    test('FixedReps round-trips through toJson/fromJson', () {
      const target = FixedReps(12);

      final restored = RepsTarget.fromJson(target.toJson());

      expect(restored, isA<FixedReps>());
      expect((restored as FixedReps).reps, 12);
    });

    test('RangeReps round-trips through toJson/fromJson', () {
      const target = RangeReps(min: 8, max: 12);

      final restored = RepsTarget.fromJson(target.toJson());

      expect(restored, isA<RangeReps>());
      restored as RangeReps;
      expect(restored.min, 8);
      expect(restored.max, 12);
    });

    test('fromJson throws on an unrecognized discriminator value', () {
      final json = {'type': 'unknown', 'reps': 12};

      expect(() => RepsTarget.fromJson(json), throwsA(anything));
    });
  });

  group('RangeReps.validate', () {
    test('returns no error for min < max', () {
      expect(RangeReps.validate(min: 8, max: 12), isNull);
    });

    test('returns an invalid-range error for min == max', () {
      expect(
        RangeReps.validate(min: 10, max: 10),
        RangeRepsError.invalidRange,
      );
    });

    test('returns an invalid-range error for min > max', () {
      expect(
        RangeReps.validate(min: 12, max: 8),
        RangeRepsError.invalidRange,
      );
    });
  });
}
