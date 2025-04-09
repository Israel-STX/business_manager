import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/clients_screen.dart';
import 'screens/services_screen.dart';
import 'screens/calendar_screen.dart';
import 'theme.dart';

// test data
import 'db/seed_data.dart';

// dev mode flag
const bool isDevMode = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // create test db with option to wipe db if in dev mode
  await SeedData.run(wipeExisting: isDevMode);

  runApp(const BusinessManagerApp());
}

class BusinessManagerApp extends StatelessWidget {
  const BusinessManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Business Manager',
      theme: AppThemes.bizTheme,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
