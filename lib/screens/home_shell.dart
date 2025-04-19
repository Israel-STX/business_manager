import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'calendar_screen.dart';
import 'invoice_screen.dart';
import 'clients_screen.dart';
import 'services_screen.dart';

// bottom navigation bar to switch between screens of the app

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  // keeps track of the currently selected tab index
  // at this moment its the dashboard or home screen
  int _currentIndex = 2;

  // list of screens
  final List<Widget> _screens = const [
    CalendarScreen(),
    ClientsScreen(), 
    DashboardScreen(),
    InvoiceScreen(),
    ServicesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // displays the screen that matches the selected index
      body: _screens[_currentIndex],

      // the bottom navigation bar
      bottomNavigationBar: Theme(
        // removes effects by making them transparent
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            selectedLabelStyle: TextStyle(fontSize: 12),
            unselectedLabelStyle: TextStyle(fontSize: 12),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),

          // fixed layout keeps all labels visible
          type: BottomNavigationBarType.fixed,

          // sets the overall background and text colors
          backgroundColor: Colors.black,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white,
          showUnselectedLabels: true,

          // icons and labels for each screen
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Calendar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Clients',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long),
              label: 'Invoices',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.build),
              label: 'Services',
            ),
          ],
        ),
      ),
    );
  }
}
