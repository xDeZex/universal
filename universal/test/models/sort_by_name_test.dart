import 'package:flutter_test/flutter_test.dart';
import 'package:universal/models/sort_by_name.dart';

class _Named {
  final String name;

  const _Named(this.name);
}

void main() {
  group('sortByName', () {
    test('sorts alphabetically, case-insensitively', () {
      final items = [_Named('push Day'), _Named('Arms'), _Named('Full Body')];

      final sorted = sortByName<_Named>(items, (item) => item.name);

      expect(sorted.map((item) => item.name).toList(), [
        'Arms',
        'Full Body',
        'push Day',
      ]);
    });

    test('does not mutate the input list', () {
      final items = [_Named('Push'), _Named('Arms')];

      sortByName<_Named>(items, (item) => item.name);

      expect(items.map((item) => item.name).toList(), ['Push', 'Arms']);
    });

    test('returns an empty list unchanged', () {
      final sorted = sortByName<_Named>(const [], (item) => item.name);

      expect(sorted, isEmpty);
    });
  });
}
