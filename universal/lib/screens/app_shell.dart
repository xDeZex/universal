import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../repositories/workout_repository.dart';
import 'home_screen.dart';
import 'workout_home_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  static final _tabs = [
    const HomeScreen(),
    ChangeNotifierProvider<WorkoutRepository>(
      create: (_) => WorkoutRepository()..load(),
      child: const WorkoutHomeScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist),
            label: 'Checklists',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Workout',
          ),
        ],
      ),
    );
  }
}
