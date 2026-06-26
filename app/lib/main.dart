import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const UniversalApp());
}

class UniversalApp extends StatelessWidget {
  const UniversalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Universal',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
