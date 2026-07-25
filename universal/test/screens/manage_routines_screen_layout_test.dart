import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:universal/repositories/workout_repository.dart';
import 'package:universal/screens/manage_routines_screen.dart';

import '../layout_test_helpers.dart';

void main() {
  group('ManageRoutinesScreen layout', () {
    testWidgets(
      'the add-Routine FloatingActionButton stays clear of the bottom '
      'system inset (e.g. a gesture/button navigation bar)',
      (tester) async {
        const bottomInset = 48.0;
        final repository = WorkoutRepository();

        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                padding: EdgeInsets.only(bottom: bottomInset),
              ),
              child: ChangeNotifierProvider<WorkoutRepository>.value(
                value: repository,
                child: const ManageRoutinesScreen(),
              ),
            ),
          ),
        );

        expectClearOfBottomInset(
          tester,
          find.byType(FloatingActionButton),
          bottomInset,
        );
      },
    );
  });
}
