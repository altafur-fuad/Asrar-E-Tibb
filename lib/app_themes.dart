import 'package:flutter/material.dart';

class AppThemes {
  static const Color primaryBlue = Color(0xFF26658C);

  // ---------------- LIGHT THEME ----------------
  static final ThemeData light = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: Colors.white,
    useMaterial3: true,

    colorScheme: const ColorScheme.light(
      primary: primaryBlue,
      secondary: primaryBlue,
      brightness: Brightness.light,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black, // <-- icon + title color
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black), // <-- AppBar icons
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    iconTheme: const IconThemeData(
      color: Colors.black87, // All icons default
    ),

    // Switch
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStatePropertyAll(Colors.black),
      trackColor: WidgetStatePropertyAll(Colors.grey),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryBlue,
      foregroundColor: Colors.white,
    ),
  );

  // ---------------- DARK THEME ----------------
  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: const Color(0xFF121212),
    useMaterial3: true,

    colorScheme: const ColorScheme.dark(
      primary: primaryBlue,
      secondary: primaryBlue,
      brightness: Brightness.dark,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1C3B50),
      foregroundColor: Colors.white, // <-- icon + title
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white), // <-- AppBar icons
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    iconTheme: const IconThemeData(
      color: Colors.white70, // All icons default
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStatePropertyAll(Colors.white),
      trackColor: WidgetStatePropertyAll(Colors.grey),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryBlue,
      foregroundColor: Colors.white,
    ),
  );
}
