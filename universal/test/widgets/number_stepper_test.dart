import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal/widgets/number_stepper.dart';

void main() {
  Future<void> pumpStepper(
    WidgetTester tester, {
    required num value,
    num step = 1,
    bool allowNegative = false,
    num? min,
    num? max,
    ValueChanged<num>? onChanged,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NumberStepper(
            keyPrefix: 'stepper',
            value: value,
            step: step,
            allowNegative: allowNegative,
            min: min,
            max: max,
            onChanged: onChanged ?? (_) {},
          ),
        ),
      ),
    );
  }

  IconButton findButton(WidgetTester tester, String key) =>
      tester.widget<IconButton>(find.byKey(ValueKey(key)));

  group('NumberStepper behavior', () {
    testWidgets('renders the value and both buttons by key', (tester) async {
      await pumpStepper(tester, value: 5);

      expect(find.byKey(const ValueKey('stepper-decrement')), findsOneWidget);
      expect(find.byKey(const ValueKey('stepper-value')), findsOneWidget);
      expect(find.byKey(const ValueKey('stepper-increment')), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('tapping increment calls onChanged with value + step', (
      tester,
    ) async {
      num? changed;
      await pumpStepper(
        tester,
        value: 5,
        step: 2,
        onChanged: (v) => changed = v,
      );

      await tester.tap(find.byKey(const ValueKey('stepper-increment')));

      expect(changed, 7);
    });

    testWidgets('tapping decrement calls onChanged with value - step', (
      tester,
    ) async {
      num? changed;
      await pumpStepper(
        tester,
        value: 5,
        step: 2,
        onChanged: (v) => changed = v,
      );

      await tester.tap(find.byKey(const ValueKey('stepper-decrement')));

      expect(changed, 3);
    });

    testWidgets('decrement is disabled at the default floor of 0', (
      tester,
    ) async {
      await pumpStepper(tester, value: 0);

      expect(findButton(tester, 'stepper-decrement').onPressed, isNull);
    });

    testWidgets('decrement is enabled below 0 when allowNegative is true', (
      tester,
    ) async {
      await pumpStepper(tester, value: 0, allowNegative: true);

      expect(
        findButton(tester, 'stepper-decrement').onPressed,
        isNotNull,
      );
    });

    testWidgets('decrement is disabled at an explicit min', (tester) async {
      await pumpStepper(tester, value: 1, min: 1);

      expect(findButton(tester, 'stepper-decrement').onPressed, isNull);
    });

    testWidgets('increment is disabled at an explicit max', (tester) async {
      await pumpStepper(tester, value: 10, max: 10);

      expect(findButton(tester, 'stepper-increment').onPressed, isNull);
    });

    testWidgets('increment has no ceiling by default', (tester) async {
      await pumpStepper(tester, value: 100000);

      expect(
        findButton(tester, 'stepper-increment').onPressed,
        isNotNull,
      );
    });
  });

  group('NumberStepper tonal pod styling', () {
    testWidgets(
      'renders as a fully-rounded pill filled with surfaceContainerHighest',
      (tester) async {
        await pumpStepper(tester, value: 5);

        final decoratedBox = tester.widget<DecoratedBox>(
          find
              .ancestor(
                of: find.byKey(const ValueKey('stepper-value')),
                matching: find.byType(DecoratedBox),
              )
              .first,
        );
        final decoration = decoratedBox.decoration as BoxDecoration;
        final context = tester.element(find.byType(NumberStepper));

        expect(decoration.borderRadius, BorderRadius.circular(999));
        expect(
          decoration.color,
          Theme.of(context).colorScheme.surfaceContainerHighest,
        );
      },
    );

    testWidgets(
      'decrement/increment render as filled-tonal icon buttons '
      '(secondaryContainer-filled Material)',
      (tester) async {
        await pumpStepper(tester, value: 5);
        final context = tester.element(find.byType(NumberStepper));
        final secondaryContainer =
            Theme.of(context).colorScheme.secondaryContainer;

        for (final key in ['stepper-decrement', 'stepper-increment']) {
          final materials = tester.widgetList<Material>(
            find.descendant(
              of: find.byKey(ValueKey(key)),
              matching: find.byType(Material),
            ),
          );
          expect(materials.map((m) => m.color), contains(secondaryContainer));
        }
      },
    );

    testWidgets(
      'decrement/increment use an 18dp icon and compact visual density',
      (tester) async {
        await pumpStepper(tester, value: 5);

        for (final key in ['stepper-decrement', 'stepper-increment']) {
          final button = findButton(tester, key);
          expect(button.iconSize, 18);
          expect(button.visualDensity, VisualDensity.compact);
        }
      },
    );

    testWidgets('value label has a fixed 36dp width and titleSmall style', (
      tester,
    ) async {
      await pumpStepper(tester, value: 5);

      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byKey(const ValueKey('stepper-value')),
          matching: find.byType(SizedBox),
        ),
      );
      final text = tester.widget<Text>(
        find.byKey(const ValueKey('stepper-value')),
      );
      final context = tester.element(find.byType(NumberStepper));

      expect(sizedBox.width, 36);
      expect(text.style, Theme.of(context).textTheme.titleSmall);
    });
  });
}
