import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal/widgets/safe_scaffold.dart';

import '../layout_test_helpers.dart';

void main() {
  group('SafeScaffold', () {
    testWidgets('body content stays clear of the bottom system inset '
        '(e.g. a gesture/button navigation bar)', (tester) async {
      const bottomInset = 48.0;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              padding: EdgeInsets.only(bottom: bottomInset),
            ),
            child: SafeScaffold(
              body: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    key: const ValueKey('pinned-bottom-button'),
                    onPressed: () {},
                    child: const Text('Pinned'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expectClearOfBottomInset(
        tester,
        find.byKey(const ValueKey('pinned-bottom-button')),
        bottomInset,
      );
    });

    testWidgets('renders the given appBar and floatingActionButton', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SafeScaffold(
            appBar: AppBar(title: const Text('Screen Title')),
            floatingActionButton: FloatingActionButton(
              key: const ValueKey('fab'),
              onPressed: () {},
              child: const Icon(Icons.add),
            ),
            body: const SizedBox.shrink(),
          ),
        ),
      );

      expect(find.text('Screen Title'), findsOneWidget);
      expect(find.byKey(const ValueKey('fab')), findsOneWidget);
    });

    testWidgets('floatingActionButton stays clear of the bottom system inset '
        '(e.g. a gesture/button navigation bar)', (tester) async {
      const bottomInset = 48.0;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              padding: EdgeInsets.only(bottom: bottomInset),
            ),
            child: SafeScaffold(
              floatingActionButton: FloatingActionButton(
                key: const ValueKey('fab'),
                onPressed: () {},
                child: const Icon(Icons.add),
              ),
              body: const SizedBox.shrink(),
            ),
          ),
        ),
      );

      expectClearOfBottomInset(
        tester,
        find.byKey(const ValueKey('fab')),
        bottomInset,
      );
    });
  });
}
