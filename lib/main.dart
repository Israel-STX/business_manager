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
      home: const DashboardScreen(),
      routes: {
        '/clients': (context) => const ClientsScreen(),
        '/services': (context) => const ServicesScreen(),
        '/calendar': (context) => const CalendarScreen(),
      },
    );
  }
}
