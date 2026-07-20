import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal/models/routine.dart';
import 'package:universal/widgets/planned_exercise_row_editor.dart';

Future<PlannedExerciseRow> pumpEditor(
  WidgetTester tester, {
  required PlannedExerciseRow row,
}) async {
  var current = row;
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: StatefulBuilder(
          builder: (context, setState) {
            return PlannedExerciseRowEditor(
              keyPrefix: 'row',
              row: current,
              onChanged: (updated) => setState(() => current = updated),
            );
          },
        ),
      ),
    ),
  );
  return current;
}
