import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'repositories/workout_repository.dart';
import 'screens/workout_home_screen.dart';
import 'services/update_service.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const UniversalApp());
}

class UniversalApp extends StatelessWidget {
  final UpdateService? updateService;

  const UniversalApp({super.key, this.updateService});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UpdateService>(
      create: (_) {
        final service = updateService ?? UpdateService();
        service.checkForUpdate();
        return service;
      },
      child: MaterialApp(
        title: 'Universal',
        theme: AppTheme.dark,
        home: ChangeNotifierProvider<WorkoutRepository>(
          create: (_) => WorkoutRepository()..load(),
          child: const WorkoutHomeScreen(),
        ),
      ),
    );
  }
}
