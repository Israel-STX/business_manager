import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
import 'screens/clients_screen.dart';
import 'screens/services_screen.dart';
import 'screens/calendar_screen.dart';

void main() {
  runApp(const BusinessManagerApp());
}

class BusinessManagerApp extends StatelessWidget {
  const BusinessManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Business Manager',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: DashboardScreen(),
      routes: {
        '/clients': (context) => ClientsScreen(),
        '/services': (context) => ServicesScreen(),
        '/calendar': (context) => CalendarScreen(),
      },
    );
  }
}
