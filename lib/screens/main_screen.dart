import 'package:flutter/material.dart';
import 'shopping_lists_screen.dart';
import 'workout_lists_screen.dart';
import 'weight_tracking_screen.dart';
import 'calendar_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex.clamp(0, 3),
        children: [
          Navigator(
            key: _navigatorKeys[0],
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => const ShoppingListsScreen(showAppBar: true),
                settings: settings,
              );
            },
          ),
          Navigator(
            key: _navigatorKeys[1],
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => const WorkoutListsScreen(showAppBar: true),
                settings: settings,
              );
            },
          ),
          Navigator(
            key: _navigatorKeys[2],
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => const WeightTrackingScreen(),
                settings: settings,
              );
            },
          ),
          Navigator(
            key: _navigatorKeys[3],
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => const CalendarScreen(showAppBar: true),
                settings: settings,
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index >= 0 && index < 4) {
              // If tapping the same tab, pop to root
              if (index == _currentIndex) {
                _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
              } else {
                // When switching to a different tab, always go to its root page
                _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
                setState(() {
                  _currentIndex = index;
                });
              }
            }
          },
          type: BottomNavigationBarType.fixed,
          enableFeedback: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Shopping Lists',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Workouts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Workout Logs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
        ],
        ),
      ),
    );
  }
}