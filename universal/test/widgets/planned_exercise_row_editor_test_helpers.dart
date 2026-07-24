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
        body: Padding(
          // Matches the horizontal padding PlannedExerciseCard._buildRow
          // applies around this editor at its real call site.
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: StatefulBuilder(
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
    ),
  );
  return current;
}
