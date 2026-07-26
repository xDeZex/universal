import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal/services/storage_service.dart';

/// A [StorageService] whose [onCorruptData] reports land in [reports]
/// instead of going to the real logger.
({StorageService storageService, List<({String key, Object error})> reports})
    _recordingStorageService() {
  final reports = <({String key, Object error})>[];
  return (
    storageService: StorageService(
      onCorruptData: (key, error, stackTrace) =>
          reports.add((key: key, error: error)),
    ),
    reports: reports,
  );
}

void main() {
  group('StorageService onCorruptData', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test(
      'loadChecklists does not report corrupt data when there is none',
      () async {
        final (:storageService, :reports) = _recordingStorageService();

        await storageService.loadChecklists();

        expect(reports, isEmpty);
      },
    );

    test(
      'loadChecklists reports the corrupt key and error exactly once',
      () async {
        SharedPreferences.setMockInitialValues({
          'checklists': 'not valid json',
        });
        final (:storageService, :reports) = _recordingStorageService();

        await storageService.loadChecklists();

        expect(reports, hasLength(1));
        expect(reports.single.key, 'checklists');
        expect(reports.single.error, isA<FormatException>());
      },
    );

    test('loadWorkouts reports its own key, not another list\'s', () async {
      SharedPreferences.setMockInitialValues({'workouts': 'not valid json'});
      final (:storageService, :reports) = _recordingStorageService();

      await storageService.loadWorkouts();

      expect(reports.single.key, 'workouts');
    });

    test(
      'loadChecklists falls back to the default logger without crashing '
      'when onCorruptData is not injected',
      () async {
        SharedPreferences.setMockInitialValues({
          'checklists': 'not valid json',
        });
        final storageService = StorageService();

        final checklists = await storageService.loadChecklists();

        expect(checklists, isEmpty);
      },
    );
  });
}
