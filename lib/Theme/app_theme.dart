import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  // Define your light theme
  ThemeData get lightTheme => ThemeData(
    colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: const Color(0xFFFDFDFD),
        onPrimary: const Color(0xFFFFA726),
        secondary: Colors.black,
        onSecondary: const Color(
            0xFFDDDDDD),
        error: Colors.red,
        onError: const Color(0xFFECECEC),
        surface: const Color(0xFFECECEC),
        onSurface: const Color(0xFFECECEC),
      tertiary: const Color(0xFFFDFDFD),
      onTertiary: Colors.black.withValues(alpha: 0.25),
    ),
        fontFamily: 'Tahoma',
        brightness: Brightness.light,
        primaryColor: const Color(0xFFECECEC),
        scaffoldBackgroundColor: Colors.grey[200],
        cardColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A2433),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
          iconTheme: IconThemeData(color: Colors.black),
        ),
        datePickerTheme: DatePickerThemeData(
          backgroundColor: Colors.white,
          headerBackgroundColor: const Color(0xFF1A2433),
          headerForegroundColor: Colors.white,
          dayStyle:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          todayBorder: const BorderSide(color: Color(0xFF1A2433),),
          todayForegroundColor: WidgetStateProperty.all(const Color(0xFF1A2433),),
        ),
        timePickerTheme: TimePickerThemeData(
          backgroundColor: Colors.white,
          hourMinuteTextColor: Colors.black,
          hourMinuteColor: Colors.grey[200],
          dayPeriodTextColor: Colors.black,
          dayPeriodColor: Colors.grey[200],
          dialHandColor: Colors.blue,
          dialBackgroundColor: Colors.grey[100],
          entryModeIconColor: Colors.blue,
        ),
      );

  // Define your dark theme
  ThemeData get darkTheme => ThemeData(
        colorScheme: ColorScheme(
            brightness: Brightness.dark,
            primary: const Color(0xFF1E1E1E),
            onPrimary: const Color(0xFFF5F5F5),
            secondary: const Color(0xFFF5F5F5),
            onSecondary: Colors.black.withValues(alpha: 0.3),
            error: Colors.red,
            onError: const Color(0xFF1E1E1E),
            surface: const Color(0xFF1E1E1E),
            onSurface: const Color(0xFF1E1E1E),
            tertiary: Colors.black.withValues(alpha: 0.4),
            onTertiary: Colors.white.withValues(alpha: 0.15),
        ),
        fontFamily: 'Tahoma',
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF2D2B2B),
        scaffoldBackgroundColor: Colors.grey[900],
        cardColor: Colors.black.withValues(alpha: 0.4),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        datePickerTheme: DatePickerThemeData(
          backgroundColor: const Color(0xFF1E1E1E),
          headerBackgroundColor: Colors.blueGrey[800],
          headerForegroundColor: Colors.white,
          dayStyle:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          todayBorder: const BorderSide(color: Colors.blueGrey),
          todayForegroundColor: WidgetStateProperty.all(Colors.white),
        ),
        timePickerTheme: TimePickerThemeData(
          backgroundColor: Colors.grey[800],
          hourMinuteTextColor: Colors.white,
          hourMinuteColor: Colors.grey[700],
          dayPeriodTextColor: Colors.white,
          dayPeriodColor: Colors.grey[700],
          dialHandColor: Colors.blue,
          dialBackgroundColor: Colors.grey[900],
          entryModeIconColor: Colors.blue,
        ),
      );

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDark') ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> toggleTheme(bool isOn) async {
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', isOn);
  }
}
