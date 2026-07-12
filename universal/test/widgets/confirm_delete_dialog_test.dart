import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal/widgets/confirm_delete_dialog.dart';

void main() {
  group('ConfirmDeleteDialog', () {
    testWidgets('displays the given message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDialog<bool>(
                context: context,
                builder: (context) =>
                    const ConfirmDeleteDialog(message: 'Delete this Set?'),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Delete this Set?'), findsOneWidget);
    });

    testWidgets('confirming pops true', (tester) async {
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showDialog<bool>(
                  context: context,
                  builder: (context) =>
                      const ConfirmDeleteDialog(message: 'Delete this Set?'),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('confirm-delete-confirm')));
      await tester.pumpAndSettle();

      expect(result, isTrue);
    });

    testWidgets('cancelling pops false', (tester) async {
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showDialog<bool>(
                  context: context,
                  builder: (context) =>
                      const ConfirmDeleteDialog(message: 'Delete this Set?'),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('confirm-delete-cancel')));
      await tester.pumpAndSettle();

      expect(result, isFalse);
    });
  });
}
