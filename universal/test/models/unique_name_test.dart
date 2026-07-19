import 'package:flutter_test/flutter_test.dart';
import 'package:universal/models/unique_name.dart';

class _Named {
  final String id;
  final String name;

  const _Named(this.id, this.name);
}

void main() {
  group('validateUniqueName', () {
    test('returns null for a valid, non-colliding name', () {
      final existing = [_Named('1', 'Bench Press'), _Named('2', 'Squat')];

      final result = validateUniqueName<_Named>(
        candidate: 'Incline Bench Press',
        existing: existing,
        nameOf: (item) => item.name,
      );

      expect(result, isNull);
    });

    test('returns blank for an empty name', () {
      final result = validateUniqueName<_Named>(
        candidate: '',
        existing: const [],
        nameOf: (item) => item.name,
      );

      expect(result, UniqueNameError.blank);
    });

    test('returns blank for a whitespace-only name', () {
      final result = validateUniqueName<_Named>(
        candidate: '   ',
        existing: const [],
        nameOf: (item) => item.name,
      );

      expect(result, UniqueNameError.blank);
    });

    test('returns duplicate for a name colliding case-insensitively', () {
      final existing = [_Named('1', 'Bench Press'), _Named('2', 'Squat')];

      final result = validateUniqueName<_Named>(
        candidate: 'squat',
        existing: existing,
        nameOf: (item) => item.name,
      );

      expect(result, UniqueNameError.duplicate);
    });

    test('excludeWhere exempts an item from its own collision check', () {
      final self = _Named('1', 'Bench Press');
      final existing = [self, _Named('2', 'Squat')];

      final result = validateUniqueName<_Named>(
        candidate: 'Bench Press',
        existing: existing,
        nameOf: (item) => item.name,
        excludeWhere: (item) => item.id == self.id,
      );

      expect(result, isNull);
    });

    test('without excludeWhere, a name colliding with itself is a duplicate', () {
      final self = _Named('1', 'Bench Press');
      final existing = [self, _Named('2', 'Squat')];

      final result = validateUniqueName<_Named>(
        candidate: 'Bench Press',
        existing: existing,
        nameOf: (item) => item.name,
      );

      expect(result, UniqueNameError.duplicate);
    });
  });
}
