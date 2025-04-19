import 'package:flutter/material.dart';

// this is where all our theme stuff is
class AppThemes {
  
  static final ThemeData bizTheme = ThemeData(
    
    brightness: Brightness.light,

    // background color for pages
    scaffoldBackgroundColor: Colors.white,

    // main color used across the app
    primaryColor: Colors.black,

    // default font for all text
    fontFamily: 'Roboto',

    // color used for card widgets (like boxes and lists)
    cardColor: Colors.white,

    // how app bars (top bars) look
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      elevation: 0,
    ),

    // default styles for titles and body
    textTheme: const TextTheme(
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
      titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
      bodyLarge: TextStyle(fontSize: 16, color: Colors.black),
      bodyMedium: TextStyle(fontSize: 14, color: Colors.black),
    ),

    // elevated buttons style
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontSize: 16), // text size
      ),
    ),

    // floating buttons style
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
    ),

    // regular text style for cancel button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.black,
        textStyle: const TextStyle(fontSize: 16),
      ),
    ),

    // input boxes style
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  );

  // styles for calendar popup when picking a date
  static Widget datePickerTheme(BuildContext context, Widget? child) {
    return Theme(
      data: ThemeData.light().copyWith(
        primaryColor: Colors.black,
        colorScheme: const ColorScheme.light(primary: Colors.black),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: Colors.black),
        ),
      ),
      child: child!,
    );
  }

  // styles for clock popup when picking a time
  static Widget timePickerTheme(BuildContext context, Widget? child) {
    return Theme(
      data: ThemeData.light().copyWith(
        timePickerTheme: const TimePickerThemeData(
          backgroundColor: Colors.white,
          hourMinuteTextColor: Colors.black,
          dialHandColor: Colors.black,
          dialTextColor: Colors.black,
          entryModeIconColor: Colors.black,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: Colors.black),
        ),
      ),
      child: child!,
    );
  }
}
