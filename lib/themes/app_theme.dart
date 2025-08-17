import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData createDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF6366F1), // Indigo
        primaryContainer: Color(0xFF4338CA),
        secondary: Color(0xFF8B5CF6), // Purple
        secondaryContainer: Color(0xFF7C3AED),
        surface: Color(0xFF121212), // Dark background
        surfaceContainerHighest: Color(0xFF1F1F1F), // Card background
        surfaceContainer: Color(0xFF1A1A1A), // Container background
        onSurface: Color(0xFFE5E5E5), // Primary text color
        onSurfaceVariant: Color(0xFFB0B0B0), // Secondary text color
        outline: Color(0xFF404040), // Border color
        error: Color(0xFFEF4444), // Error red
        onError: Color(0xFFFFFFFF),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1F1F1F),
        foregroundColor: Color(0xFFE5E5E5),
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFF1F1F1F),
        elevation: 2,
        shadowColor: Color(0x40000000),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      listTileTheme: const ListTileThemeData(
        textColor: Color(0xFFE5E5E5),
        iconColor: Color(0xFFB0B0B0),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF6366F1),
        foregroundColor: Color(0xFFFFFFFF),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: const Color(0xFFFFFFFF),
          elevation: 2,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF6366F1),
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: Color(0xFF1F1F1F),
        titleTextStyle: TextStyle(
          color: Color(0xFFE5E5E5),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: TextStyle(
          color: Color(0xFFB0B0B0),
          fontSize: 16,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF2A2A2A),
        labelStyle: TextStyle(color: Color(0xFFB0B0B0)),
        hintStyle: TextStyle(color: Color(0xFF808080)),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF404040)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF6366F1), width: 2),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF6366F1);
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(const Color(0xFFFFFFFF)),
        side: const BorderSide(color: Color(0xFF6366F1), width: 2),
      ),
      iconTheme: const IconThemeData(
        color: Color(0xFFB0B0B0),
        size: 24,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF404040),
        thickness: 1,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1F1F1F),
        selectedItemColor: Color(0xFF6366F1),
        unselectedItemColor: Color(0xFFB0B0B0),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: Color(0xFFE5E5E5)),
        displayMedium: TextStyle(color: Color(0xFFE5E5E5)),
        displaySmall: TextStyle(color: Color(0xFFE5E5E5)),
        headlineLarge: TextStyle(color: Color(0xFFE5E5E5)),
        headlineMedium: TextStyle(color: Color(0xFFE5E5E5)),
        headlineSmall: TextStyle(color: Color(0xFFE5E5E5)),
        titleLarge: TextStyle(color: Color(0xFFE5E5E5)),
        titleMedium: TextStyle(color: Color(0xFFE5E5E5)),
        titleSmall: TextStyle(color: Color(0xFFE5E5E5)),
        labelLarge: TextStyle(color: Color(0xFFE5E5E5)),
        labelMedium: TextStyle(color: Color(0xFFB0B0B0)),
        labelSmall: TextStyle(color: Color(0xFFB0B0B0)),
        bodyLarge: TextStyle(color: Color(0xFFE5E5E5)),
        bodyMedium: TextStyle(color: Color(0xFFE5E5E5)),
        bodySmall: TextStyle(color: Color(0xFFB0B0B0)),
      ),
    );
  }
}