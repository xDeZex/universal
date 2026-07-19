import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:universal/models/routine.dart';
import 'package:universal/repositories/workout_repository.dart';
import 'package:universal/screens/routine_screen.dart';

Future<WorkoutRepository> pumpRoutineScreen(
  WidgetTester tester, {
  required List<Routine> routines,
  required String routineId,
}) async {
  final repository = WorkoutRepository(
    initialWorkouts: const [],
    initialExercises: const [],
    initialRoutines: routines,
  );
  await tester.pumpWidget(
    MaterialApp(
      home: ChangeNotifierProvider<WorkoutRepository>.value(
        value: repository,
        child: RoutineScreen(routineId: routineId),
      ),
    ),
  );
  return repository;
}

Future<void> openRenameDialog(WidgetTester tester, String title) async {
  await tester.tap(
    find.descendant(of: find.byType(AppBar), matching: find.text(title)),
  );
  await tester.pumpAndSettle();
}
