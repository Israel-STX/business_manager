import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

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

    // this sets spinner and other material components to black
    colorScheme: const ColorScheme.light(
      primary: Colors.black,
    ),

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
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      labelStyle: TextStyle(color: Colors.black),
      hintStyle: TextStyle(color: Colors.grey),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black, width: 2),
      ),
    ),

    // selection and cursor color in textfields
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Colors.black,
      selectionColor: Colors.grey,
      selectionHandleColor: Colors.black,
    ),
  );

  // styles for calendar popup when picking a date
  static Widget datePickerTheme(BuildContext context, Widget? child) {
    return Theme(
      data: ThemeData.light().copyWith(
        colorScheme: const ColorScheme.light(
          primary: Colors.black,
          onPrimary: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
        dialogTheme: const DialogTheme(
          backgroundColor: Colors.white,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.black,
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black),
          labelLarge: TextStyle(color: Colors.black),
        ),
      ),
      child: child!,
    );
  }

  // styles for clock popup when picking a time
  static Widget timePickerTheme(BuildContext context, Widget? child) {
    return Theme(
      data: ThemeData.light().copyWith(
        colorScheme: const ColorScheme.light(
          primary: Colors.grey,
          onPrimary: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
        timePickerTheme: const TimePickerThemeData(
          backgroundColor: Colors.white,
          hourMinuteTextColor: Colors.black,
          hourMinuteShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            side: BorderSide(color: Colors.black),
          ),
          dayPeriodTextColor: Colors.black,
          dayPeriodColor: Colors.grey,
          dialHandColor: Colors.grey,
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

  // style for calendar header (month, arrows)
  static const calendarHeaderStyle = HeaderStyle(
    titleCentered: true,
    formatButtonVisible: false,
    titleTextStyle: TextStyle(color: Colors.black),
    leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
    rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
  );

  // style for day labels (mon, tue, etc)
  static const calendarDaysOfWeekStyle = DaysOfWeekStyle(
    weekdayStyle: TextStyle(color: Colors.black),
    weekendStyle: TextStyle(color: Colors.black),
  );

  // style for each calendar day (text, selected, etc)
  static const calendarDayStyle = CalendarStyle(
    defaultTextStyle: TextStyle(color: Colors.black),
    weekendTextStyle: TextStyle(color: Colors.black),
    selectedDecoration: BoxDecoration(
      color: Colors.grey,
      shape: BoxShape.circle,
    ),
    todayDecoration: BoxDecoration(
      color: Colors.black,
      shape: BoxShape.circle,
    ),
    markerDecoration: BoxDecoration(
      color: Colors.transparent,
    ),
  );
}
