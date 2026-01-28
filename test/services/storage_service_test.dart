import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal/models/checklist.dart';
import 'package:universal/services/storage_service.dart';

void main() {
  group('StorageService', () {
    late StorageService storageService;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      storageService = StorageService();
    });

    test('loadChecklists returns empty list when no data', () async {
      final checklists = await storageService.loadChecklists();

      expect(checklists, isEmpty);
    });

    test('saveChecklists and loadChecklists round-trip works', () async {
      final checklists = [
        Checklist(
          name: 'Groceries',
          items: [
            ChecklistItem(name: 'Milk'),
            ChecklistItem(name: 'Bread', isChecked: true),
          ],
        ),
        Checklist(name: 'Todo'),
      ];

      await storageService.saveChecklists(checklists);
      final loaded = await storageService.loadChecklists();

      expect(loaded.length, 2);
      expect(loaded[0].name, 'Groceries');
      expect(loaded[0].items.length, 2);
      expect(loaded[0].items[0].name, 'Milk');
      expect(loaded[0].items[0].isChecked, false);
      expect(loaded[0].items[1].name, 'Bread');
      expect(loaded[0].items[1].isChecked, true);
      expect(loaded[1].name, 'Todo');
      expect(loaded[1].items, isEmpty);
    });

    test('saveChecklists overwrites existing data', () async {
      final initial = [Checklist(name: 'First')];
      await storageService.saveChecklists(initial);

      final replacement = [Checklist(name: 'Second')];
      await storageService.saveChecklists(replacement);

      final loaded = await storageService.loadChecklists();

      expect(loaded.length, 1);
      expect(loaded[0].name, 'Second');
    });

    test('saveChecklists with empty list clears data', () async {
      final checklists = [Checklist(name: 'Test')];
      await storageService.saveChecklists(checklists);

      await storageService.saveChecklists([]);

      final loaded = await storageService.loadChecklists();
      expect(loaded, isEmpty);
    });

    test('loadChecklists handles corrupted JSON gracefully', () async {
      SharedPreferences.setMockInitialValues({'checklists': 'not valid json'});
      storageService = StorageService();

      final checklists = await storageService.loadChecklists();

      expect(checklists, isEmpty);
    });
  });
}
