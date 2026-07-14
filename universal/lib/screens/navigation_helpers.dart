import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../repositories/workout_repository.dart';

Future<T?> pushWithRepository<T>(
  BuildContext context,
  WorkoutRepository repo,
  WidgetBuilder builder,
) {
  return Navigator.push<T>(
    context,
    MaterialPageRoute(
      builder: (context) => ChangeNotifierProvider<WorkoutRepository>.value(
        value: repo,
        child: Builder(builder: builder),
      ),
    ),
  );
}
